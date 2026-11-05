pragma Singleton

import QtQuick
import Quickshell

// One transient surface at a time. Without a shared owner, a quick sweep over
// the bar/rail can leave several independently animated windows mapped on top
// of each other. Every coordinated surface exposes dismiss().
Singleton {
    property var active: null

    function claim(surface: var) {
        if (active && active !== surface) {
            const previous = active;
            active = null;
            previous.dismissImmediately();
        }
        active = surface;
    }

    function release(surface: var) {
        if (active === surface)
            active = null;
    }

    function dismissAll() {
        if (active)
            active.dismiss();
    }
}
