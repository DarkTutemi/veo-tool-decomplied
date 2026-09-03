pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root

    property var messageModel: null
    property var contentModel: null
    property var sourceModel: null
    property var controlPlaneBridge: null
    property var strategy: ({})
    property var selectedProject: ({})
    property bool hasProject: false
    property bool actionBusy: false
    property int revision: 0
    property bool revisionApproved: false
    property string feedbackMessage: ""
    property string platform: "generic"

    readonly property bool compactLayout: width < 660

    signal sendRequested(string message)

    function suggest(text): void {
        chatComposer.text = text
        chatComposer.forceActiveFocus()
    }

    function send(): void {
        const message = chatComposer.text.trim()
        if (!root.hasProject || root.actionBusy || !message)
            return
        root.sendRequested(message)
    }

    function clearComposer(): void {
        chatComposer.clear()
    }

    function pillarText(): string {
        const pillars = root.strategy.contentPillars || []
        if (!pillars.length)
            return "Chưa có trụ cột"
        return pillars.slice(0, 3).join(" · ")
    }

    Connections {
        target: root.messageModel
        function onCountChanged() {
            Qt.callLater(function() { messageList.positionViewAtEnd() })
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 9

            UiIcon {
                objectName: "copilotHeaderIcon"
                name: "ui/sparkles"
                tone: Theme.accent
                iconSize: 19
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }
            Text {
                Layout.fillWidth: true
                text: "Channel Copilot"
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.DemiBold
            }
            Foundation.StatusPill {
                visible: root.revision > 0
                text: root.revisionApproved
                    ? "ĐÃ DUYỆT · V" + String(root.revision)
                    : "CHỜ DUYỆT · V" + String(root.revision)
                tone: root.revisionApproved ? Theme.success : Theme.warning
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        Rectangle {
            visible: root.feedbackMessage.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 30 : 0
            color: Theme.accentSoft
            Text {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                text: root.feedbackMessage
                color: Theme.accent
                font.pixelSize: Theme.fontMetadata
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        ListView {
            id: messageList
            objectName: "copilotMessageList"
            Layout.fillWidth: true
            Layout.preferredHeight: 82
            Layout.minimumHeight: 82
            Layout.maximumHeight: 82
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.topMargin: 7
            Layout.bottomMargin: 5
            spacing: 4
            clip: true
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.messageModel
            delegate: CopilotMessageDelegate {}
            ScrollBar.vertical: ScrollBar { visible: false }

            Text {
                anchors.centerIn: parent
                visible: root.hasProject && (!root.messageModel
                    || Number(root.messageModel.count || 0) === 0)
                width: Math.min(parent.width - 30, 430)
                text: "Mô tả mục tiêu hoặc chọn một gợi ý để AI lập chiến lược."
                color: Theme.textMuted
                font.pixelSize: Theme.fontBody
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }

        GridLayout {
            id: workGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.bottomMargin: 8
            columns: root.compactLayout ? 1 : 2
            columnSpacing: 10
            rowSpacing: 7

            RowLayout {
                visible: !root.compactLayout && root.revision > 0
                Layout.row: 0
                Layout.column: 0
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 96 : 0
                Layout.minimumHeight: visible ? 96 : 0
                Layout.maximumHeight: visible ? 96 : 0
                spacing: 7

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusSmall
                    color: Theme.panel
                    border.width: 1
                    border.color: Theme.borderSoft
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 3
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            UiIcon {
                                objectName: "copilotStrategyTargetIcon"
                                name: "ui/target"
                                tone: Theme.accent
                                iconSize: 14
                                Layout.preferredWidth: 14
                                Layout.preferredHeight: 14
                            }
                            Text { Layout.fillWidth: true; text: "ĐỊNH VỊ"; color: Theme.accent; font.pixelSize: Theme.fontMetadata; font.weight: Font.Bold }
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: String(root.strategy.positioning
                                || root.strategy.objective || "Chưa xác định")
                            color: Theme.text
                            font.pixelSize: Theme.fontMetadata
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusSmall
                    color: Theme.panel
                    border.width: 1
                    border.color: Theme.borderSoft
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 3
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            UiIcon {
                                objectName: "copilotStrategyLayersIcon"
                                name: "ui/layers"
                                tone: Theme.accent
                                iconSize: 14
                                Layout.preferredWidth: 14
                                Layout.preferredHeight: 14
                            }
                            Text { Layout.fillWidth: true; text: "TRỤ CỘT"; color: Theme.accent; font.pixelSize: Theme.fontMetadata; font.weight: Font.Bold }
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: root.pillarText()
                            color: Theme.text
                            font.pixelSize: Theme.fontMetadata
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusSmall
                    color: Theme.panel
                    border.width: 1
                    border.color: Theme.borderSoft
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 3
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            UiIcon {
                                objectName: "copilotStrategyCalendarIcon"
                                name: "ui/calendar"
                                tone: Theme.accent
                                iconSize: 14
                                Layout.preferredWidth: 14
                                Layout.preferredHeight: 14
                            }
                            Text { Layout.fillWidth: true; text: "NHỊP ĐĂNG"; color: Theme.accent; font.pixelSize: Theme.fontMetadata; font.weight: Font.Bold }
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: String(root.strategy.cadence || "Chưa có lịch")
                            color: Theme.text
                            font.pixelSize: Theme.fontMetadata
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            RowLayout {
                Layout.row: root.compactLayout ? 1 : 1
                Layout.column: 0
                Layout.fillWidth: true
                Layout.preferredHeight: root.compactLayout ? 68 : 96
                Layout.minimumHeight: Layout.preferredHeight
                Layout.maximumHeight: Layout.preferredHeight
                spacing: 7

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: chatComposer.activeFocus
                        ? Theme.accent : Theme.borderSoft

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        TextArea {
                            id: chatComposer
                            objectName: "copilotChatComposer"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            enabled: root.hasProject && !root.actionBusy
                            placeholderText: root.hasProject
                                ? "Mô tả mục tiêu hoặc yêu cầu AI lập kế hoạch từ Reference Pack đã chọn…"
                                : "Tạo dự án trước"
                            color: Theme.text
                            placeholderTextColor: Theme.textFaint
                            selectionColor: Theme.accent
                            selectedTextColor: "white"
                            font.pixelSize: Theme.fontBody
                            wrapMode: TextArea.Wrap
                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 7
                            bottomPadding: 3
                            activeFocusOnTab: true
                            Keys.onPressed: function(event) {
                                if ((event.modifiers & Qt.ControlModifier)
                                        && (event.key === Qt.Key_Return
                                            || event.key === Qt.Key_Enter)) {
                                    root.send()
                                    event.accepted = true
                                }
                            }
                            background: Item {}
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 31
                            Layout.leftMargin: 5
                            Layout.rightMargin: 5
                            Layout.bottomMargin: 4
                            spacing: 2

                            AppButton {
                                objectName: "copilotAttachSourceButton"
                                implicitHeight: 28
                                text: String(root.sourceModel
                                    ? root.sourceModel.count || 0 : 0)
                                    + (root.compactLayout ? " nguồn" : " nguồn đã đóng băng")
                                leadingIcon: "ui/layers"
                                subtle: true
                                enabled: false
                                visualEnabled: true
                                Accessible.description: "Nguồn được quản lý ở tab Nguồn tham khảo, không nhập trùng trong chat"
                            }
                            AppButton {
                                objectName: "copilotAnalyzeButton"
                                implicitHeight: 28
                                text: "Phân tích"
                                leadingIcon: "ui/sparkles"
                                subtle: true
                                enabled: root.hasProject && !root.actionBusy
                                onClicked: root.suggest(
                                    "Phân tích mục tiêu, nguồn tham khảo và đề xuất định vị kênh.")
                            }
                            Item { Layout.fillWidth: true }
                        }
                    }
                }
                AppButton {
                    objectName: "copilotSendButton"
                    Layout.preferredWidth: 46
                    Layout.fillHeight: true
                    text: ""
                    leadingIcon: "ui/send"
                    primary: true
                    enabled: root.hasProject
                        && chatComposer.text.trim().length > 0
                        && !root.actionBusy
                    Accessible.name: "Gửi yêu cầu tới Channel Copilot"
                    onClicked: root.send()
                }
            }

            RowLayout {
                Layout.row: root.compactLayout ? 2 : 2
                Layout.column: 0
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                Layout.minimumHeight: 38
                Layout.maximumHeight: 38
                spacing: 4

                AppButton {
                    objectName: "copilotIdeaSuggestionButton"
                    Layout.fillWidth: true
                    implicitHeight: 30
                    text: root.compactLayout ? "Ý tưởng" : "Lên ý tưởng 30 ngày"
                    leadingIcon: "semantic/lightbulb"
                    subtle: true
                    enabled: root.hasProject && !root.actionBusy
                    onClicked: root.suggest(
                        "Lập kế hoạch nội dung 30 ngày theo mục tiêu của kênh.")
                }
                AppButton {
                    objectName: "copilotScriptSuggestionButton"
                    Layout.fillWidth: true
                    implicitHeight: 30
                    text: "Viết 10 kịch bản"
                    leadingIcon: "ui/pencil"
                    subtle: true
                    enabled: root.hasProject && !root.actionBusy
                    onClicked: root.suggest(
                        "Đề xuất 10 kịch bản có thể sản xuất bằng các tab hiện có của Tool 1.")
                }
                AppButton {
                    objectName: "copilotChannelAnalysisButton"
                    Layout.fillWidth: true
                    implicitHeight: 30
                    text: root.compactLayout ? "Phân tích" : "Phân tích kênh mẫu"
                    leadingIcon: "semantic/bar-chart"
                    subtle: true
                    enabled: root.hasProject && !root.actionBusy
                    onClicked: root.suggest(
                        "Phân tích cấu trúc một kênh mẫu và rút ra hướng phát triển phù hợp.")
                }
            }

            ColumnLayout {
                Layout.row: 0
                Layout.column: root.compactLayout ? 0 : 1
                Layout.rowSpan: root.compactLayout ? 1 : 3
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: root.compactLayout ? 0 : 300
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    spacing: 7
                    Text {
                        Layout.fillWidth: true
                        text: "Kế hoạch nội dung"
                        color: Theme.text
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: String(root.contentModel
                            ? root.contentModel.count || 0 : 0) + " mục"
                        color: Theme.textFaint
                        font.pixelSize: Theme.fontMetadata
                    }
                }

                ListView {
                    id: contentList
                    objectName: "copilotContentPlanList"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: root.compactLayout ? 120 : 0
                    spacing: 5
                    clip: true
                    reuseItems: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.contentModel
                    delegate: CopilotContentItemDelegate {
                        platform: root.platform
                        showAssignmentAction: false
                    }
                    ScrollBar.vertical: ScrollBar { visible: false }

                    Text {
                        anchors.centerIn: parent
                        visible: !root.contentModel
                            || Number(root.contentModel.count || 0) === 0
                        width: Math.min(parent.width - 30, 320)
                        text: root.hasProject
                            ? "Kế hoạch sẽ xuất hiện sau phản hồi đầu tiên của AI."
                            : "Chọn hoặc tạo một dự án ở cột bên trái."
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontBody
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }

}
