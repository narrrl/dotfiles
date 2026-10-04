pragma Singleton

import QtQuick
import Quickshell

// Shape maths for panels. Under the YoRHa theme nothing leans and nothing is
// chopped (Theme.skew and Theme.cut are 0); surfaces are rounded rectangles
// (roundedRect). The polygon helpers are kept so a shape can be brought back
// on purpose.
// Originally the Persona 5 panel language: everything leans, and corners
// get chopped rather than rounded.
Singleton {
    id: root

    // A right-leaning parallelogram filling w x h. `lean` is the horizontal
    // offset applied to the top edge, as a fraction of height.
    function parallelogram(w: real, h: real, lean: real): var {
        const off = h * lean;
        return [
            Qt.point(off, 0),
            Qt.point(w, 0),
            Qt.point(w - off, h),
            Qt.point(0, h)
        ];
    }

    // Same, leaning the other way.
    function parallelogramL(w: real, h: real, lean: real): var {
        const off = h * lean;
        return [
            Qt.point(0, 0),
            Qt.point(w - off, 0),
            Qt.point(w, h),
            Qt.point(off, h)
        ];
    }

    // Vertical counterpart: the *horizontal* edges slant instead, by a fraction
    // of width. A tall rail slab has to lean this way — leaning its vertical
    // edges by a fraction of its height would shear it clean off the screen.
    function parallelogramV(w: real, h: real, lean: real): var {
        const off = w * lean;
        return [
            Qt.point(0, off),
            Qt.point(w, 0),
            Qt.point(w, h - off),
            Qt.point(0, h)
        ];
    }

    function parallelogramVL(w: real, h: real, lean: real): var {
        const off = w * lean;
        return [
            Qt.point(0, 0),
            Qt.point(w, off),
            Qt.point(w, h),
            Qt.point(0, h - off)
        ];
    }

    function rect(w: real, h: real): var {
        return [Qt.point(0, 0), Qt.point(w, 0), Qt.point(w, h), Qt.point(0, h)];
    }

    // Move `dist` px from `p` toward `q`.
    function toward(p: point, q: point, dist: real): point {
        const dx = q.x - p.x;
        const dy = q.y - p.y;
        const len = Math.hypot(dx, dy);
        if (len < 0.0001) return p;
        const t = Math.min(dist, len / 2) / len;
        return Qt.point(p.x + dx * t, p.y + dy * t);
    }

    // Chop the listed corners of a polygon. `corners` is an array of indices;
    // pass null to chop every corner.
    function chamfer(pts: var, size: real, corners: var): var {
        if (size <= 0) return root.closed(pts);
        const n = pts.length;
        const out = [];
        for (let i = 0; i < n; i++) {
            const p = pts[i];
            if (corners !== null && corners.indexOf(i) === -1) {
                out.push(p);
                continue;
            }
            out.push(root.toward(p, pts[(i - 1 + n) % n], size));
            out.push(root.toward(p, pts[(i + 1) % n], size));
        }
        return root.closed(out);
    }

    // A polygon as an SVG path string, for PathSvg.
    function svg(pts: var): string {
        if (pts.length === 0) return "";
        let d = `M ${pts[0].x} ${pts[0].y}`;
        for (let i = 1; i < pts.length; i++) d += ` L ${pts[i].x} ${pts[i].y}`;
        return d + " Z";
    }

    // A w x h rectangle with every corner rounded by `r`, clamped so a short
    // piece becomes a pill rather than folding over itself.
    function roundedRect(w: real, h: real, r: real): string {
        const k = Math.max(0, Math.min(r, w / 2, h / 2));
        if (k <= 0) return root.svg([Qt.point(0, 0), Qt.point(w, 0), Qt.point(w, h), Qt.point(0, h)]);
        return `M ${k} 0 H ${w - k} A ${k} ${k} 0 0 1 ${w} ${k}`
             + ` V ${h - k} A ${k} ${k} 0 0 1 ${w - k} ${h}`
             + ` H ${k} A ${k} ${k} 0 0 1 0 ${h - k}`
             + ` V ${k} A ${k} ${k} 0 0 1 ${k} 0 Z`;
    }

    function closed(pts: var): var {
        if (pts.length === 0) return pts;
        const out = pts.slice();
        out.push(pts[0]);
        return out;
    }

    // Shrink a polygon toward its centroid — used for inner strokes.
    function inset(pts: var, amount: real): var {
        let cx = 0, cy = 0;
        for (const p of pts) { cx += p.x; cy += p.y; }
        cx /= pts.length; cy /= pts.length;
        return pts.map(p => {
            const dx = cx - p.x, dy = cy - p.y;
            const len = Math.hypot(dx, dy);
            if (len < 0.0001) return p;
            const t = amount / len;
            return Qt.point(p.x + dx * t, p.y + dy * t);
        });
    }

    // A jagged "torn paper" edge, the Persona 5 speech-bubble signature.
    // Returns a polygon `w` x `h` whose bottom edge is serrated.
    function torn(w: real, h: real, teeth: int, depth: real): var {
        const out = [Qt.point(0, 0), Qt.point(w, 0)];
        const step = w / teeth;
        for (let i = 0; i < teeth; i++) {
            const x1 = w - i * step - step / 2;
            const x2 = w - (i + 1) * step;
            out.push(Qt.point(x1, h));
            out.push(Qt.point(x2, h - depth));
        }
        return out;
    }
}
