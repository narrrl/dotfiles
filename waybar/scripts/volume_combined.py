import subprocess
import json
import sys

def get_wpctl_status(target):
    try:
        output = subprocess.check_output(["wpctl", "get-volume", target], text=True)
        parts = output.strip().split()
        if len(parts) < 2:
            return 0, False
        vol = int(float(parts[1]) * 100)
        muted = "[MUTED]" in output
        return vol, muted
    except:
        return 0, False

def get_pactl_description(target_type):
    try:
        cmd_info = ["pactl", "info"]
        info = subprocess.check_output(cmd_info, text=True)
        search_key = "Default Sink" if target_type == "sink" else "Default Source"
        default_dev = next(line.split(": ")[1] for line in info.splitlines() if search_key in line)
        
        cmd_list = ["pactl", "list", "sinks" if target_type == "sink" else "sources"]
        output = subprocess.check_output(cmd_list, text=True)
        
        blocks = output.split("\n\n")
        for block in blocks:
            if f"Name: {default_dev}" in block:
                for line in block.splitlines():
                    if "Description:" in line:
                        desc = line.split(": ")[1].strip()
                        # Add a small hint if it is a monitor, though cycle_input should prevent it
                        if ".monitor" in default_dev:
                            return "Monitor: " + desc[:11]
                        return desc[:20]
    except:
        pass
    return "Unknown"

try:
    target_type = sys.argv[1] if len(sys.argv) > 1 else "sink"
    target = "@DEFAULT_AUDIO_SINK@" if target_type == "sink" else "@DEFAULT_AUDIO_SOURCE@"

    vol, muted = get_wpctl_status(target)
    name = get_pactl_description(target_type)

    if muted:
        icon = "" if target_type == "sink" else ""
        text = f"{name} {icon}"
        cls = "muted"
    else:
        if target_type == "sink":
            if vol <= 30: icon = ""
            elif vol <= 60: icon = ""
            else: icon = ""
        else:
            icon = ""
        text = f"{name} {vol}% {icon}"
        cls = "unmuted"

    print(json.dumps({"text": text, "class": cls, "percentage": vol}))
except Exception as e:
    print(json.dumps({"text": "Error", "class": "error"}))
