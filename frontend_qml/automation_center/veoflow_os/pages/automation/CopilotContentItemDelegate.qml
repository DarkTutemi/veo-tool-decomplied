pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    required property var modelData
    property string platform: "generic"
    property bool showAssignmentAction: false
    signal assignRequested(string contentItemId)

    readonly property string workflow: String(root.modelData.workflow || "")
    readonly property string readiness: String(
        root.modelData.readiness || "needs_review")
    readonly property string status: String(root.modelData.status || "draft")
    readonly property color workflowTone: root.workflow === "master"
        ? Theme.accent : root.workflow === "clone"
        ? Theme.info : root.workflow === "transcript"
        ? Theme.success : root.workflow === "affiliate"
        ? Theme.warning : Theme.textMuted

    width: ListView.view ? ListView.view.width : 620
    implicitHeight: 43
    height: implicitHeight
    radius: Theme.radiusSmall
    color: rowHover.hovered ? Theme.hover : Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.role: Accessible.ListItem
    Accessible.name: String(root.modelData.title || "Content item")
    HoverHandler { id: rowHover }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 7
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: Theme.elevated
            Text {
                anchors.centerIn: parent
                text: String(Number(root.modelData.position || 0) + 1)
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
                font.weight: Font.DemiBold
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Text {
                Layout.fillWidth: true
                text: String(root.modelData.title || "Content item")
                color: Theme.text
                font.pixelSize: Theme.fontMetadata
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: String(root.modelData.angle || root.modelData.content || "")
                color: Theme.textFaint
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 24
            radius: 12
            color: Theme.elevated
            Text {
                anchors.centerIn: parent
                text: root.workflow === "transcript" ? "AUDIO"
                    : root.workflow.toUpperCase()
                color: root.workflowTone
                font.pixelSize: 10
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
        }

        PlatformIcon {
            objectName: "copilotPlanPlatformIcon_" + String(
                root.modelData.contentItemId || "item")
            visible: root.platform.length > 0 && root.platform !== "generic"
            platform: root.platform
            iconSize: 16
            Layout.preferredWidth: visible ? 16 : 0
            Layout.preferredHeight: 16
        }

        Text {
            visible: root.width >= 420
            Layout.preferredWidth: visible ? 94 : 0
            text: String(root.modelData.readinessLabel || root.readiness)
            color: root.readiness === "ready" ? Theme.success
                : root.readiness === "needs_source"
                    || root.readiness === "needs_product"
                ? Theme.warning : Theme.textMuted
            font.pixelSize: 10
            elide: Text.ElideRight
        }

        Rectangle {
            visible: root.width < 420
            Layout.preferredWidth: visible ? 8 : 0
            Layout.preferredHeight: 8
            radius: 4
            color: root.readiness === "ready" ? Theme.success
                : root.readiness === "needs_source"
                    || root.readiness === "needs_product"
                ? Theme.warning : Theme.textMuted
            Accessible.name: String(root.modelData.readinessLabel || root.readiness)
        }

        AppButton {
            objectName: "copilotAssign_" + String(
                root.modelData.contentItemId || "")
            visible: root.showAssignmentAction
                && (root.status === "prepared" || root.status === "assigned")
            Layout.preferredWidth: visible ? 76 : 0
            implicitHeight: 30
            text: root.status === "assigned" ? "Đã giao"
                : root.status === "prepared" ? "Giao việc" : "Chi tiết"
            leadingIcon: root.status === "assigned"
                ? "ui/check" : root.status === "prepared" ? "ui/play" : ""
            primary: root.status === "prepared"
            enabled: Boolean(root.modelData.canAssign)
            visualEnabled: enabled || root.status === "assigned"
                || root.status === "draft" || root.status === "approved"
            onClicked: root.assignRequested(String(
                root.modelData.contentItemId || ""))
        }
    }
}
