import QtQuick

JobPanelCard {
    id: root

    readonly property string primitiveContract: "JobCardWidget is the PyQt compatibility facade used by JobPanelWidget; JobPanelCard owns the visual implementation."

    signal actionRequested(string actionId, string jobId, int index)

    onCommandRequested: (actionId, jobId, index) => root.actionRequested(actionId, jobId, index)
}
