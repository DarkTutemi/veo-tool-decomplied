// VfGridView — a GridView with delegate recycling ON by default (qml-patterns Law 3).
// Same rationale as VfListView; use instead of a bare `GridView` for any scrollable grid
// (media tiles, thumbnails). Passes scripts/qml_perf_lint.py (R1) for free.
import QtQuick

GridView {
    reuseItems: true
    cacheBuffer: Math.max(0, height * 2)
    clip: true
    boundsBehavior: Flickable.StopAtBounds
}
