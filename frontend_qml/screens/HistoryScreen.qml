import QtQuick
import QtQuick.Layouts

import "../components/history"
import "../theme"

Item {
    id: screen

    readonly property var controller: historyController
    readonly property bool compact: width < 1050
    readonly property bool compactDetailOpen: compact
        && controller.selectedRunId.length > 0

    Rectangle {
        anchors.fill: parent
        color: VfTheme.surfaceSoft
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(7)
        spacing: VfTheme.dp(6)

        HistoryToolbar {
            Layout.fillWidth: true
            visible: !screen.compactDetailOpen
            sources: screen.controller.sources
            stateFilters: screen.controller.stateFilters
            currentSource: screen.controller.source
            currentState: screen.controller.state
            searchText: screen.controller.search
            busy: screen.controller.listLoading
            onSourceSelected: value => screen.controller.setSource(value)
            onStateSelected: value => screen.controller.setState(value)
            onSearchCommitted: value => screen.controller.setSearch(value)
            onRefreshRequested: screen.controller.refresh()
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            HistoryRunList {
                Layout.preferredWidth: screen.compact
                    ? Math.max(0, screen.width - VfTheme.dp(14))
                    : Math.max(0, screen.width - VfTheme.dp(14)) * 0.43
                Layout.fillHeight: true
                visible: !screen.compactDetailOpen
                runModel: screen.controller.runsModel
                selectedRunId: screen.controller.selectedRunId
                stats: screen.controller.stats
                loading: screen.controller.listLoading
                canLoadMore: screen.controller.canLoadMore
                onRunSelected: runId => screen.controller.selectRun(runId)
                onLoadMoreRequested: screen.controller.loadMore()
            }

            Rectangle {
                Layout.preferredWidth: screen.compact ? 0 : VfTheme.dp(7)
                Layout.fillHeight: true
                visible: !screen.compact
                color: VfTheme.border
            }

            HistoryDetailShell {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !screen.compact || screen.compactDetailOpen
                detail: screen.controller.selectedDetail
                itemModel: screen.controller.itemsModel
                loading: screen.controller.detailLoading
                actionsLocked: screen.controller.actionsLocked
                compact: screen.compact
                onBackRequested: screen.controller.selectRun("")
                onActionRequested: actionId => screen.controller.executeAction(actionId)
                onItemActionRequested: (itemId, actionId) =>
                    screen.controller.executeItemAction(itemId, actionId)
                onOpenArtifactRequested: target =>
                    screen.controller.openArtifact(target)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(20)
            visible: !screen.compactDetailOpen

            Text {
                text: String((screen.controller.stats || {}).total || 0) + " run tổng"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
            }

            Item { Layout.fillWidth: true }

            Text {
                text: screen.controller.canLoadMore ? "Cuộn để tải thêm" : "Đã tải hết"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
            }
        }
    }

    Component.onCompleted: screen.controller.setActive(visible)
    onVisibleChanged: screen.controller.setActive(visible)
}
