pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "publishingCenterPanel"
    color: "transparent"
    border.width: 0
    property var controlPlaneBridge: null
    property string activeView: "calendar"
    Accessible.name: "Xuất bản, lịch đăng và bằng chứng"
    Accessible.role: Accessible.Pane

    function selectView(view) {
        const normalized = String(view || "calendar")
        if (["calendar", "queue", "recurrence", "history"].indexOf(normalized) < 0)
            return
        root.activeView = normalized
        if (normalized !== "history" && scheduleLoader.status === Loader.Ready)
            scheduleLoader.item.requestTab(normalized)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space3

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            spacing: Theme.space3

            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: 13
                color: Theme.accentSoft
                UiIcon {
                    anchors.centerIn: parent
                    name: "semantic/upload-cloud"
                    tone: Theme.accent
                    iconSize: 22
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Text {
                    Layout.fillWidth: true
                    text: "Xuất bản"
                    color: Theme.text
                    font.pixelSize: Theme.fontPageTitle
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: "Lịch đăng, hàng chờ PublishKit, kiểm tra lại tài khoản và bằng chứng sau đăng."
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontBody
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                spacing: 4
                AppButton {
                    objectName: "publishingCalendarTab"
                    text: "Lịch đăng"
                    leadingIcon: "ui/calendar"
                    primary: root.activeView === "calendar"
                    subtle: root.activeView !== "calendar"
                    onClicked: root.selectView("calendar")
                }
                AppButton {
                    objectName: "publishingQueueTab"
                    text: "Hàng chờ"
                    leadingIcon: "ui/list"
                    primary: root.activeView === "queue"
                    subtle: root.activeView !== "queue"
                    onClicked: root.selectView("queue")
                }
                AppButton {
                    objectName: "publishingRecurrenceTab"
                    text: "Lịch lặp"
                    leadingIcon: "ui/refresh-cw"
                    primary: root.activeView === "recurrence"
                    subtle: root.activeView !== "recurrence"
                    onClicked: root.selectView("recurrence")
                }
                AppButton {
                    objectName: "publishingHistoryTab"
                    text: "Bằng chứng"
                    leadingIcon: "semantic/shield-check"
                    primary: root.activeView === "history"
                    subtle: root.activeView !== "history"
                    onClicked: root.selectView("history")
                }
            }
        }

        Panel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Loader {
                id: scheduleLoader
                objectName: "publishingScheduleLoader"
                anchors.fill: parent
                active: root.activeView !== "history" || item !== null
                asynchronous: true
                visible: root.activeView !== "history"
                    && status === Loader.Ready
                source: "../SchedulePage.qml"
                onLoaded: {
                    item.embeddedMode = true
                    item.activeTab = root.activeView
                }
            }

            PublishHistoryPanel {
                anchors.fill: parent
                visible: root.activeView === "history"
                controlPlaneBridge: root.controlPlaneBridge
                closeVisible: false
                onScheduleRequested: root.selectView("calendar")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            spacing: 7
            Item { Layout.fillWidth: true }
            UiIcon {
                name: "semantic/shield-check"
                tone: Theme.textFaint
                iconSize: 14
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
            }
            Text {
                text: "Không blind-retry sau click đăng; trạng thái không chắc chắn chuyển needs_attention để đối soát."
                color: Theme.textFaint
                font.pixelSize: Theme.fontMetadata
                elide: Text.ElideRight
            }
            Item { Layout.fillWidth: true }
        }
    }
}
