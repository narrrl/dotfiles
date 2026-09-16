pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The launcher's brain: the application index, the query language, ranking,
// and the actual spawning. The UI in launcher/ owns no logic beyond keys and
// animation — everything it shows comes out of `results`.
//
// The one idea the launcher is built around is that a query is a *verb plus an
// object*. Fuzzel only ever had the verb: you typed a name and it ran the app
// with no arguments. Here the object is first class, so `gitlab.enqs.de` is a
// complete thought — the object is the URL, and the list becomes the set of
// verbs that can act on it, with the system default already selected. Hitting
// Enter the moment you stop typing is the fast path; arrowing down to a
// different verb is the slow one.
Singleton {
    id: root

    // ------------------------------------------------------------- the index
    // Every launchable thing, flattened. A desktop entry with actions
    // contributes one item per action as well as itself, so "Brave (Private)"
    // is a peer of "Brave" in the list rather than something you have to drill
    // into. That is the whole reason fuzzel's `show-actions` was off: nested
    // disclosure in a launcher is a step too many.
    readonly property var index: {
        const out = [];
        const apps = DesktopEntries.applications.values;

        for (let i = 0; i < apps.length; i++) {
            const e = apps[i];
            if (e.noDisplay) continue;

            out.push({
                key: root._entryKey(e.id),
                id: e.id,
                actionId: "",
                name: e.name,
                sub: e.genericName || e.comment || "",
                icon: e.icon,
                exec: e.execString,
                categories: root._bag(e.categories),
                keywords: root._bag(e.keywords),
                terminal: e.runInTerminal,
                kind: "app"
            });

            const actions = e.actions;
            for (let j = 0; j < actions.length; j++) {
                const a = actions[j];
                out.push({
                    key: root._entryKey(e.id) + ":" + a.id,
                    id: e.id,
                    actionId: a.id,
                    name: e.name + " · " + a.name,
                    sub: a.name,
                    icon: a.icon || e.icon,
                    exec: a.execString,
                    categories: root._bag(e.categories),
                    keywords: root._bag(e.keywords),
                    terminal: e.runInTerminal,
                    kind: "action"
                });
            }
        }
        return out;
    }

    function _entryKey(id: string): string {
        return id.endsWith(".desktop") ? id : id + ".desktop";
    }

    // Categories and Keywords come across as string *lists*, not strings, and
    // an absent one is undefined rather than empty. Both get flattened to one
    // lowercase haystack so the scoring below can just call `includes`.
    function _bag(v: var): string {
        if (!v) return "";
        return (Array.isArray(v) ? v.join(" ") : String(v)).toLowerCase();
    }

    // --------------------------------------------------------- query parsing
    // A query resolves to a mode and, in app mode, an optional argument. There
    // are two ways to end up with an argument:
    //
    //   pinned    you pressed Tab on a result, which froze that app as the verb
    //             and handed the rest of the input to it. Unambiguous, works
    //             for arguments that look like nothing in particular.
    //   implicit  what you typed is *obviously* an object — a URL, a path, an
    //             email. Nothing is pinned, so every app is a candidate verb
    //             and the ranking decides who goes first.
    //
    // Implicit detection is deliberately conservative. A false positive turns
    // an app search into an open-with list, which is jarring; a false negative
    // just means you press Tab.
    readonly property var urlRe: /^[a-z][a-z0-9+.-]*:\/\//i
    readonly property var hostRe: /^([a-z0-9-]+\.)+[a-z]{2,}(\/\S*)?$/i
    readonly property var mailRe: /^[^\s@]+@[^\s@]+\.[a-z]{2,}$/i
    readonly property var pathRe: /^(~|\/|\.\/)\S*$/

    function classify(text: string): string {
        const t = text.trim();
        if (t === "") return "";
        if (root.urlRe.test(t) || root.hostRe.test(t)) return "url";
        if (root.mailRe.test(t)) return "mail";
        if (root.pathRe.test(t)) return "path";
        return "";
    }

    // Turn a bare host into something a browser will accept. `gitlab.enqs.de`
    // on its own is a relative path as far as xdg-open is concerned.
    function normalizeArg(text: string, kind: string): string {
        const t = text.trim();
        if (kind === "url") return root.urlRe.test(t) ? t : "https://" + t;
        if (kind === "mail") return "mailto:" + t;
        if (kind === "path" && t.startsWith("~"))
            return Quickshell.env("HOME") + t.slice(1);
        return t;
    }

    // ------------------------------------------------------------- defaults
    // Which app the system would have picked. This is what puts Brave at row
    // zero without the launcher having an opinion about browsers.
    property string defaultBrowser: ""
    property string defaultMail: ""

    Process {
        running: true
        command: ["xdg-mime", "query", "default", "x-scheme-handler/https"]
        stdout: StdioCollector {
            onStreamFinished: root.defaultBrowser = this.text.trim()
        }
    }

    Process {
        running: true
        command: ["xdg-mime", "query", "default", "x-scheme-handler/mailto"]
        stdout: StdioCollector {
            onStreamFinished: root.defaultMail = this.text.trim()
        }
    }

    // --------------------------------------------------------------- ranking
    // Subsequence match with a bias toward matches that start a word. Returns
    // -1 for no match. The numbers are only meaningful relative to each other.
    function fuzzy(hay: string, needle: string): real {
        if (needle === "") return 0;
        const h = hay.toLowerCase();
        const n = needle.toLowerCase();

        if (h === n) return 1000;
        if (h.startsWith(n)) return 700 - h.length;

        // Start of any word inside the name — "code" hitting "Visual Studio
        // Code" should beat "code" scattered through "Chromium Dev Tools".
        const word = h.indexOf(" " + n);
        if (word !== -1) return 500 - word;
        if (h.includes(n)) return 300 - h.indexOf(n);

        // Plain subsequence, penalised by how far apart the letters are.
        let score = 120;
        let at = -1;
        for (let i = 0; i < n.length; i++) {
            const next = h.indexOf(n[i], at + 1);
            if (next === -1) return -1;
            score -= (next - at - 1) * 0.5;
            at = next;
        }
        return Math.max(score, 1);
    }

    function _appScore(item: var, term: string): real {
        if (term === "") return 0;

        let best = root.fuzzy(item.name, term);

        // Secondary fields are worth less than the name on purpose: matching a
        // Keywords= line should break a tie, not win outright.
        const sub = root.fuzzy(item.sub, term);
        if (sub > 0) best = Math.max(best, sub * 0.45);

        const id = root.fuzzy(item.id, term);
        if (id > 0) best = Math.max(best, id * 0.6);

        if (item.keywords.includes(term.toLowerCase()))
            best = Math.max(best, 140);

        // An action only surfaces on a free-text search once you have typed
        // enough to plausibly mean it, otherwise every browser triples the
        // length of the list for a one-letter query.
        if (item.kind === "action" && term.length < 2) return -1;

        return best;
    }

    // How well an app suits an object it did not ask for. Everything stays in
    // the list — the point is that you can open a URL with anything — but the
    // system default and then the plausible handlers float up.
    function _affinity(item: var, kind: string): real {
        let a = 0;

        if (kind === "url" || kind === "mail") {
            const wanted = kind === "url" ? root.defaultBrowser : root.defaultMail;
            if (wanted !== "" && item.key.startsWith(wanted)) a += 4000;
            if (item.categories.includes("webbrowser")) a += 2000;
            if (kind === "mail" && item.categories.includes("email")) a += 2500;
            if (item.categories.includes("network")) a += 400;
        } else if (kind === "path") {
            if (item.categories.includes("filemanager")) a += 2500;
            if (item.categories.includes("texteditor")) a += 1800;
            if (item.categories.includes("development")) a += 600;
            if (item.terminal) a += 300;
        }

        // The main entry outranks its own actions for an unasked-for object:
        // "open this link in Brave" is the common case, "…in a private window"
        // is the deliberate one.
        if (item.kind === "action") a -= 250;
        return a;
    }

    // The single entry point the UI binds to.
    //
    //   term    what to match apps against ("" means "everything")
    //   arg     the object, if any
    //   argKind "" | url | mail | path
    function search(term: string, arg: string, argKind: string): var {
        const scored = [];
        const idx = root.index;
        const open = arg !== "";

        for (let i = 0; i < idx.length; i++) {
            const item = idx[i];
            let s = root._appScore(item, term);
            if (term !== "" && s < 0) continue;

            // With nothing typed, actions would double the length of a list
            // that is already just "your apps, by how often you use them".
            if (term === "" && !open && item.kind === "action") continue;

            if (open) s += root._affinity(item, argKind);
            s += root.frecency(item.key);
            scored.push({ item: item, score: s });
        }

        scored.sort((a, b) => b.score - a.score || a.item.name.localeCompare(b.item.name));
        return scored.slice(0, 60).map(e => e.item);
    }

    // -------------------------------------------------------------- frecency
    // Usage decays: something you opened forty times last year should not
    // outrank what you opened twice this morning. Half-life is a week, which
    // is long enough to be stable and short enough to follow a change of
    // project.
    property var usage: ({})
    readonly property real halfLife: 7 * 24 * 3600

    function frecency(key: string): real {
        const u = root.usage[key];
        if (!u) return 0;
        const age = Date.now() / 1000 - u.t;
        return u.n * 240 * Math.pow(0.5, age / root.halfLife);
    }

    function _remember(key: string): void {
        const u = root.usage[key];
        const now = Date.now() / 1000;

        // Decay the stored count on write rather than letting it grow without
        // bound, so `n` stays a decayed weight instead of a lifetime total.
        const decayed = u ? u.n * Math.pow(0.5, (now - u.t) / root.halfLife) : 0;
        root.usage[key] = { n: decayed + 1, t: now };
        root.usageChanged();
        store.setText(JSON.stringify(root.usage));
    }

    FileView {
        id: store
        path: Quickshell.env("HOME") + "/.local/state/takemi/launcher.json"
        preload: true
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                root.usage = JSON.parse(store.text()) || ({});
            } catch (e) {
                root.usage = ({});
            }
        }
    }

    // ----------------------------------------------------------------- spawn
    // Handing uwsm a desktop ID is the good path: it expands the Exec field
    // codes around our argument, picks the terminal for Terminal=true entries,
    // and drops the process in its own scope.
    //
    // It refuses one thing, and it is exactly the thing this launcher is for.
    // `Exec=brave --incognito` declares no field code, so uwsm rejects
    // `brave-browser.desktop:new-private-window <url>` with "does not support
    // arguments" — which would make "open this link in a private window", the
    // motivating example for the whole feature, the one case that does not
    // work. Most Desktop Action entries are written that way.
    //
    // So when the target declares no placeholder we build the command line
    // ourselves and hand uwsm an argv instead of an ID. It is still scoped and
    // still supervised; we just did the expansion.
    readonly property var fieldRe: /%[fFuU]/
    readonly property var anyFieldRe: /^%[a-zA-Z]$/

    function launch(item: var, arg: string): void {
        root._remember(item.key);

        if (arg === "") {
            proc.exec(["uwsm", "app", "--", item.key]);
            return;
        }

        if (root.fieldRe.test(item.exec || "")) {
            proc.exec(["uwsm", "app", "--", item.key, arg]);
            return;
        }

        const argv = root._tokenize(item.exec || "")
            .filter(t => !root.anyFieldRe.test(t));
        if (argv.length === 0) {
            proc.exec(["uwsm", "app", "--", item.key]);
            return;
        }
        argv.push(arg);

        // Without this the unit is named after the bare executable and every
        // app launched this way collides in the unit namespace.
        const name = item.key.replace(".desktop", "").replace(/[^a-zA-Z0-9_-]/g, "-");
        const head = ["uwsm", "app", "-a", name];
        if (item.terminal) head.push("-T");
        proc.exec(head.concat(["--"]).concat(argv));
    }

    // Exec lines are shell-ish but not shell: the spec allows double quotes and
    // backslash escapes, and nothing else. Splitting on whitespace would break
    // every entry with a quoted path, and running it through `sh -c` would make
    // a desktop file a code-execution surface.
    function _tokenize(line: string): var {
        const out = [];
        let cur = "";
        let quoted = false;
        let has = false;

        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) {
                cur += line[++i];
                has = true;
            } else if (c === '"') {
                quoted = !quoted;
                has = true;
            } else if (!quoted && (c === " " || c === "\t")) {
                if (has) { out.push(cur); cur = ""; has = false; }
            } else {
                cur += c;
                has = true;
            }
        }
        if (has) out.push(cur);
        return out;
    }

    function runShell(line: string, inTerminal: bool): void {
        if (line.trim() === "") return;
        if (inTerminal) proc.exec(["uwsm", "app", "-T", "--", "sh", "-c", line]);
        else proc.exec(["uwsm", "app", "--", "sh", "-c", line]);
    }

    function copy(text: string): void {
        proc.exec(["wl-copy", "--", text]);
    }

    // Fire-and-forget. Each call replaces the last, which is fine because uwsm
    // has already handed the app off to systemd by the time it exits.
    Process { id: proc }

    // ----------------------------------------------------------------- dmenu
    // The launcher can stand in for `fuzzel --dmenu`, which is what lets fuzzel
    // leave the system entirely: fluxo's bluetooth menu and anything else that
    // pipes a list through a picker go through here instead.
    //
    // The transport is two files, because IPC calls return immediately and a
    // dmenu has to block until someone chooses. `takemi-dmenu` writes the
    // choices, calls in, then waits for the answer file to appear. If the
    // launcher is dismissed the answer file is written empty, so the caller
    // sees an empty selection rather than hanging.
    property var dmenuItems: []
    property string dmenuPrompt: ""
    property string dmenuOut: ""
    readonly property bool dmenuActive: root.dmenuOut !== ""

    function beginDmenu(inPath: string, outPath: string, prompt: string): void {
        root.dmenuPrompt = prompt;
        root.dmenuOut = outPath;
        dmenuIn.path = "";
        dmenuIn.path = inPath;
    }

    // Writing the answer with a FileView does not work: assigning `path` kicks
    // off a read of a file that does not exist yet, and the write never lands —
    // which leaves the caller blocked until its own timeout. A one-shot
    // redirect is both simpler and actually synchronous from the caller's point
    // of view, since the file appears complete or not at all.
    //
    // The choice and the path go in as positional arguments rather than being
    // interpolated into the script, so a clipboard entry containing a quote or
    // a `$(…)` is data and stays data.
    function finishDmenu(choice: string): void {
        if (root.dmenuOut === "") return;
        // Write beside the target and rename, so the waiting script can treat
        // "the file exists" as "the answer is complete".
        dmenuWriter.exec(["sh", "-c",
                          'printf "%s" "$1" > "$2.part" && mv "$2.part" "$2"',
                          "sh", choice, root.dmenuOut]);
        root.dmenuOut = "";
        root.dmenuItems = [];
        root.dmenuPrompt = "";
    }

    Process { id: dmenuWriter }

    FileView {
        id: dmenuIn
        onLoaded: {
            const out = [];
            const lines = dmenuIn.text().split("\n");
            for (let i = 0; i < lines.length; i++) {
                if (lines[i] === "") continue;
                out.push({ kind: "dmenu", name: lines[i], sub: "", icon: "" });
            }
            root.dmenuItems = out;
        }
    }

    function searchDmenu(term: string): var {
        if (term === "") return root.dmenuItems.slice(0, 200);
        const scored = [];
        for (let i = 0; i < root.dmenuItems.length; i++) {
            const c = root.dmenuItems[i];
            const s = root.fuzzy(c.name, term);
            if (s < 0) continue;
            scored.push({ item: c, score: s });
        }
        scored.sort((a, b) => b.score - a.score);
        return scored.slice(0, 200).map(e => e.item);
    }

    // ------------------------------------------------------------- clipboard
    // cliphist keeps the history; this just reads and replays it. `cliphist
    // list` emits "<id>\t<preview>" per line, where the preview is already
    // single-line and truncated — binary entries come through as a
    // "[[ binary data … ]]" placeholder, which is exactly what should be shown
    // for them anyway.
    property var clips: []

    function refreshClips(): void {
        clipList.running = false;
        clipList.running = true;
    }

    Process {
        id: clipList
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                const lines = this.text.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const tab = lines[i].indexOf("\t");
                    if (tab <= 0) continue;
                    const id = lines[i].slice(0, tab);
                    if (!/^[0-9]+$/.test(id)) continue;
                    out.push({
                        kind: "clip",
                        clipId: id,
                        name: lines[i].slice(tab + 1),
                        sub: "",
                        icon: "edit-paste"
                    });
                }
                root.clips = out;
            }
        }
    }

    // The id is checked against /^[0-9]+$/ on the way in, above, which is what
    // makes it safe to put on a shell command line. Decoding needs the pipe:
    // entries can be binary, so the bytes must go straight from cliphist into
    // wl-copy without being round-tripped through a QML string.
    function pasteClip(item: var): void {
        if (!/^[0-9]+$/.test(item.clipId)) return;
        proc.exec(["sh", "-c", "cliphist decode " + item.clipId + " | wl-copy"]);
    }

    function searchClips(term: string): var {
        if (term === "") return root.clips.slice(0, 60);
        const scored = [];
        for (let i = 0; i < root.clips.length; i++) {
            const c = root.clips[i];
            const s = root.fuzzy(c.name, term);
            if (s < 0) continue;
            scored.push({ item: c, score: s });
        }
        scored.sort((a, b) => b.score - a.score);
        return scored.slice(0, 60).map(e => e.item);
    }

    // ------------------------------------------------------------ calculator
    // Arithmetic only. The expression is checked against a whitelist before it
    // goes anywhere near the JS engine — a launcher that evals whatever you
    // typed is a launcher that runs whatever a stray paste contained.
    readonly property var mathRe: /^[0-9+\-*/%(). ,e]+$/i

    function calc(expr: string): string {
        const e = expr.trim();
        if (e === "" || !root.mathRe.test(e)) return "";
        try {
            const v = Function('"use strict"; return (' + e + ')')();
            if (typeof v !== "number" || !isFinite(v)) return "";
            return String(Math.round(v * 1e10) / 1e10);
        } catch (err) {
            return "";
        }
    }
}
