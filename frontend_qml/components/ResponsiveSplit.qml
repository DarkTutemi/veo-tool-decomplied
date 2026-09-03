import QtQuick
import QtQuick.Layouts

// ResponsiveSplit — a 2-pane split that SCALES BY RATIO at every window size and
// STACKS vertically when the window gets too narrow, instead of forcing a hard
// min-width that overflows (the "hardcore" bug: fixed 560/660 px columns spilled
// past a narrow viewport, clipping buttons + full-width boxes).
//
// Principle (Bố Độ): like a video that stays the same video on a big or small
// screen — the layout keeps its 1-to-1 proportions and never clips.
//
// Usage — drop EXACTLY two children (left pane, right pane):
//   ResponsiveSplit {
//       rightRatio: 0.40          // right pane = 40% of width when side-by-side
//       stackBelow: 820           // narrower than this → stack vertically
//       gap: VfTheme.dp(10)
//       LeftFrame  { Layout.fillWidth: true;  Layout.fillHeight: !parent.stacked
//                    Layout.preferredHeight: parent.stacked ? implicitHeight : -1 }
//       RightFrame { Layout.preferredWidth: parent.rightPaneWidth
//                    Layout.fillWidth: parent.stacked
//                    Layout.fillHeight: !parent.stacked
//                    Layout.preferredHeight: parent.stacked ? implicitHeight : -1 }
//   }
// The LEFT pane uses fillWidth (takes the leftover), so nothing is ever forced
// wider than the viewport; the RIGHT pane scales by ratio with a small floor.
GridLayout {
    id: root

    // Below this width the two panes stack (1 column) instead of side-by-side.
    property int stackBelow: 820
    // Right pane's share of the width when side-by-side. Left takes the rest.
    property real rightRatio: 0.40
    // Small usability floor for the right pane (NOT a hard column min — the split
    // stacks before this ever forces an overflow).
    property int rightMin: 300
    property int gap: 10

    readonly property bool stacked: width < stackBelow
    // Right pane width: a ratio of the total when side-by-side; full width stacked.
    readonly property int rightPaneWidth: stacked ? width : Math.max(rightMin, Math.round(width * rightRatio))

    columns: stacked ? 1 : 2
    columnSpacing: gap
    rowSpacing: gap
}
