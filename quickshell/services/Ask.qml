pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Ask — the question panel's brain.
//
// One `claude -p` per turn, streamed. The CLI is the transport rather than the
// API because the subscription lives in the CLI's credentials: nothing here
// ever sees a key, and nothing here has to hold one.
//
// The defaults deliberately strip Claude Code down to a chat: no settings
// sources, no MCP servers, no project files. That is not only about tokens —
// a session started from the shell would otherwise inherit whatever hooks and
// CLAUDE.md the last project left lying around, and answer in its voice.
// Everything below is overridable from ~/.config/quickshell/ask.json.
Singleton {
    id: root

    // ---------------------------------------------------------------- config
    readonly property string configPath:
        Quickshell.env("HOME") + "/.config/quickshell/ask.json"

    property var config: ({})

    readonly property var defaults: ({
        model: "sonnet",
        fallbackModel: "",
        systemPrompt: "You are a desktop answer panel. Answer the question directly and "
            + "compactly, in markdown, with no preamble. Prefer a few sentences over a "
            + "list, and a list over an essay. Say plainly when you do not know.",
        keepContext: true,
        // "" = none. "user,project,local" is the full Claude Code behaviour.
        settingSources: "",
        allowedTools: ["WebSearch", "WebFetch"],
        disallowedTools: ["Bash", "Edit", "Write", "NotebookEdit", "Agent", "Task"],
        workingDirectory: Quickshell.env("HOME"),
        maxTurns: 6
    })

    function setting(key: string): var {
        const v = root.config[key];
        return v === undefined || v === null ? root.defaults[key] : v;
    }

    readonly property string model: root.setting("model")

    // The model ring. Ctrl+M walks it; whatever ask.json asks for is row zero,
    // so a custom model stays reachable even when it is not one of the three.
    readonly property var models: {
        const ring = ["sonnet", "opus", "haiku"];
        const m = root.model;
        return ring.indexOf(m) >= 0 ? ring : [m].concat(ring);
    }

    function cycleModel(): void {
        const ring = root.models;
        const next = ring[(ring.indexOf(root.model) + 1) % ring.length];
        const c = JSON.parse(JSON.stringify(root.config));
        c.model = next;
        root.config = c;
        store.setText(JSON.stringify(c, null, 2) + "\n");
    }

    FileView {
        id: store
        path: root.configPath
        preload: true
        watchChanges: true
        printErrors: false
        atomicWrites: true
        onFileChanged: store.reload()
        onLoaded: {
            try {
                root.config = JSON.parse(store.text()) || ({});
            } catch (e) {
                root.config = ({});
                root.error = "ask.json is not valid JSON";
            }
        }
        // No file yet: write the defaults out so there is something to edit.
        onLoadFailed: error => {
            root.config = ({});
            store.setText(JSON.stringify(root.defaults, null, 2) + "\n");
        }
    }

    // ----------------------------------------------------------------- state
    // `turns` is the transcript the panel draws: { role, text } in order. The
    // answer being streamed is the last entry and is rewritten in place.
    property var turns: []
    property bool busy: false
    property string error: ""
    property string sessionId: ""
    property real lastCost: 0
    property int exitCode: 0
    property string stderrText: ""

    signal answered()

    function clear(): void {
        root.stop();
        root.turns = [];
        root.sessionId = "";
        root.error = "";
        root.lastCost = 0;
    }

    function stop(): void {
        if (proc.running) proc.running = false;
        root.busy = false;
    }

    function ask(question: string): void {
        const q = question.trim();
        if (q === "" || root.busy) return;

        root.error = "";
        root.turns = root.turns.concat([
            { role: "user", text: q },
            { role: "assistant", text: "" }
        ]);
        root.busy = true;

        root.exitCode = 0;
        root.stderrText = "";
        proc.running = false;
        // stdin is closed explicitly. Inherited from the shell it never ends,
        // and the CLI waits three seconds for input that is never coming
        // before it starts on the question.
        proc.command = ["sh", "-c", 'exec claude "$@" </dev/null', "claude"]
            .concat(root.argv(q).slice(1));
        proc.running = true;
    }

    // Arguments, not a shell line: the question is a single argv entry, so a
    // question containing quotes or `$(…)` is data and stays data.
    function argv(question: string): var {
        const args = ["claude", "-p", question,
                      "--model", root.setting("model"),
                      "--output-format", "stream-json",
                      "--include-partial-messages",
                      "--verbose",
                      "--setting-sources", root.setting("settingSources"),
                      "--strict-mcp-config",
                      "--mcp-config", '{"mcpServers":{}}',
                      "--max-turns", String(root.setting("maxTurns"))];

        const system = root.setting("systemPrompt");
        if (system !== "") args.push("--system-prompt", system);

        const fallback = root.setting("fallbackModel");
        if (fallback !== "") args.push("--fallback-model", fallback);

        const allowed = root.setting("allowedTools");
        if (allowed.length > 0) args.push("--allowed-tools", allowed.join(","));

        const disallowed = root.setting("disallowedTools");
        if (disallowed.length > 0) args.push("--disallowed-tools", disallowed.join(","));

        // Continuity is a resume, not a re-send: the CLI keeps the transcript,
        // so a follow-up costs one question rather than the whole thread.
        if (root.setting("keepContext") && root.sessionId !== "")
            args.push("--resume", root.sessionId);

        return args;
    }

    // The streamed answer lives in the last turn. Rewriting an array element in
    // place does not notify, so the array is rebuilt — the transcript is a
    // handful of entries, and this keeps the panel's binding honest.
    function _append(text: string): void {
        const t = root.turns.slice();
        const last = t.length - 1;
        if (last < 0 || t[last].role !== "assistant") return;
        t[last] = { role: "assistant", text: t[last].text + text };
        root.turns = t;
    }

    function _ingest(line: string): void {
        if (line === "") return;

        let ev;
        try {
            ev = JSON.parse(line);
        } catch (e) {
            return;   // partial line, or a stray log
        }

        switch (ev.type) {
        case "system":
            if (ev.subtype === "init" && ev.session_id) root.sessionId = ev.session_id;
            return;

        case "stream_event": {
            const inner = ev.event;
            if (inner?.type === "content_block_delta" && inner.delta?.type === "text_delta")
                root._append(inner.delta.text);
            return;
        }

        case "result":
            root.busy = false;
            if (ev.session_id) root.sessionId = ev.session_id;
            if (typeof ev.total_cost_usd === "number") root.lastCost = ev.total_cost_usd;
            if (ev.is_error) root.error = ev.result || "the request failed";
            // A turn that streamed nothing (a refusal, a rate limit) still has
            // an answer in the result field. Use it rather than showing a gap.
            else if (root.turns.length > 0
                     && root.turns[root.turns.length - 1].text === ""
                     && ev.result)
                root._append(ev.result);
            root.answered();
            return;
        }
    }

    Process {
        id: proc

        // Somewhere harmless and stable. The CLI still reads the directory it
        // is started in for project context; the shell's own is whatever
        // Hyprland handed it at login.
        workingDirectory: root.setting("workingDirectory")

        stdout: SplitParser {
            onRead: data => root._ingest(data)
        }

        // Only shown when the run actually failed. The CLI writes advisory
        // warnings here on a good run too, and a warning in red under the
        // answer reads as the answer being wrong.
        stderr: StdioCollector {
            onStreamFinished: root.stderrText = this.text.trim();
        }

        onExited: (code, status) => {
            root.busy = false;
            root.exitCode = code;
            if (code === 0 || root.error !== "") return;
            const lines = root.stderrText.split("\n").filter(l => l.trim() !== "");
            root.error = lines.length > 0
                ? lines[lines.length - 1]
                : "claude exited with " + code;
        }
    }
}
