// VfListView — a ListView with delegate recycling ON by default (qml-patterns Law 3).
//
// Use this instead of a bare `ListView` for any scrollable list. A new list then CANNOT
// ship the recurring "no reuseItems → delegates rebuild on every scroll/model change" jank,
// and it passes scripts/qml_perf_lint.py (R1) for free.
//
// It is a real ListView subclass, so every ListView property (model, delegate, header,
// section, ScrollBar, …) works unchanged:
//     VfListView { model: ctrl.rows; delegate: MyCard {} }
//
// Reuse contract: delegates MUST reset per-item state in their bindings (not Component.onCompleted)
// and pause animations on ListView.onPooled / resume on ListView.onReused. See reference/playbook.md.
import QtQuick

ListView {
    reuseItems: true
    cacheBuffer: Math.max(0, height * 2)
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickDeceleration: 3500
}
