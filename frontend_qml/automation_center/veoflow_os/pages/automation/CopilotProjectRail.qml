pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Panel {
    id: root

    property var projectModel: null
    property string selectedProjectId: ""
    property bool actionBusy: false
    property bool editorOpen: false

    signal createRequested(string title, string brief)
    signal selectRequested(string projectId)

    function openEditor(): void {
        root.editorOpen = true
        Qt.callLater(function() { projectTitle.forceActiveFocus() })
    }

    function finishCreate(): void {
        projectTitle.clear()
        projectBrief.clear()
        root.editorOpen = false
    }

    function platformFor(project): string {
        const row = project || ({})
        const explicit = String(row.platform || "").trim().toLowerCase()
        if (explicit) return explicit
        const searchable = (String(row.title || "") + " "
            + String(row.brief || "")).toLowerCase()
        const supported = ["youtube", "tiktok", "facebook", "instagram", "x", "linkedin"]
        for (let index = 0; index < supported.length; ++index) {
            if (searchable.indexOf(supported[index]) >= 0)
                return supported[index]
        }
        return "generic"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.leftMargin: 12
            Layout.rightMargin: 8
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: "Dự án kênh"
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.DemiBold
            }
            AppButton {
                objectName: "copilotNewProjectButton"
                text: root.editorOpen ? "Đóng" : "Thêm dự án"
                leadingIcon: root.editorOpen ? "ui/close" : "ui/plus"
                subtle: true
                implicitHeight: 34
                onClicked: root.editorOpen ? root.editorOpen = false : root.openEditor()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        ColumnLayout {
            visible: root.editorOpen
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 184 : 0
            Layout.margins: 10
            spacing: 7

            TextField {
                id: projectTitle
                objectName: "copilotProjectTitle"
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                placeholderText: "Tên dự án kênh"
                color: Theme.text
                placeholderTextColor: Theme.textFaint
                selectionColor: Theme.accent
                selectedTextColor: "white"
                font.pixelSize: Theme.fontBody
                leftPadding: 10
                rightPadding: 10
                activeFocusOnTab: true
                maximumLength: 160
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: projectTitle.activeFocus
                        ? Theme.accent : Theme.borderSoft
                }
            }

            TextArea {
                id: projectBrief
                objectName: "copilotProjectBrief"
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: "Mục tiêu, khán giả, ngôn ngữ và nền tảng…"
                color: Theme.text
                placeholderTextColor: Theme.textFaint
                selectionColor: Theme.accent
                selectedTextColor: "white"
                font.pixelSize: Theme.fontBody
                wrapMode: TextArea.Wrap
                leftPadding: 10
                rightPadding: 10
                topPadding: 8
                bottomPadding: 8
                activeFocusOnTab: true
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: projectBrief.activeFocus
                        ? Theme.accent : Theme.borderSoft
                }
            }

            AppButton {
                objectName: "copilotCreateProjectButton"
                Layout.fillWidth: true
                text: "Tạo kế hoạch"
                leadingIcon: "ui/plus"
                primary: true
                enabled: projectBrief.text.trim().length > 0 && !root.actionBusy
                onClicked: root.createRequested(
                    projectTitle.text.trim(), projectBrief.text.trim())
            }
        }

        Rectangle {
            visible: root.editorOpen
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 1 : 0
            color: Theme.borderSoft
        }

        ListView {
            id: projectList
            objectName: "copilotProjectList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 8
            spacing: 6
            clip: true
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.projectModel

            delegate: Rectangle {
                id: projectRow
                required property var modelData
                readonly property string projectId: String(
                    projectRow.modelData.projectId || "")
                readonly property bool selected:
                    projectRow.projectId === root.selectedProjectId

                width: projectList.width
                height: 76
                radius: Theme.radiusSmall
                color: projectRow.selected ? Theme.accentSoft
                    : projectHover.hovered ? Theme.hover : Theme.panel
                border.width: 1
                border.color: projectRow.selected || activeFocus
                    ? Theme.accent : Theme.borderSoft
                activeFocusOnTab: true
                Accessible.role: Accessible.Button
                Accessible.name: String(projectRow.modelData.title || "Dự án kênh")
                Keys.onReturnPressed: root.selectRequested(projectRow.projectId)
                Keys.onEnterPressed: root.selectRequested(projectRow.projectId)
                Keys.onSpacePressed: root.selectRequested(projectRow.projectId)
                HoverHandler { id: projectHover }
                TapHandler { onTapped: root.selectRequested(projectRow.projectId) }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 9

                    PlatformIcon {
                        objectName: "copilotProjectPlatformIcon_" + projectRow.projectId
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        platform: root.platformFor(projectRow.modelData)
                        iconSize: 28
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            Layout.fillWidth: true
                            text: String(projectRow.modelData.title || "Dự án kênh")
                            color: Theme.text
                            font.pixelSize: Theme.fontBody
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(projectRow.modelData.brief || "")
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(projectRow.modelData.statusLabel || "Bản nháp")
                                + " · v" + String(Number(
                                    projectRow.modelData.activeRevision || 0))
                            color: projectRow.selected ? Theme.accent : Theme.textFaint
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: !root.projectModel
                    || Number(root.projectModel.count || 0) === 0
                width: Math.min(parent.width - 28, 220)
                text: "Tạo dự án đầu tiên để AI hiểu mục tiêu phát triển kênh."
                color: Theme.textMuted
                font.pixelSize: Theme.fontBody
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }
    }
}
