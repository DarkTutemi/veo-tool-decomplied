pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Dialog {
    id: root
    objectName: "automationResultDialog"
    property string resultKind: ""
    property var resultData: ({})

    width: 620
    height: 480
    modal: true
    focus: true
    padding: 14
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape

    ListModel {
        id: resultModel
        dynamicRoles: true
    }

    function openResult(kind, titleText, data) {
        root.resultKind = String(kind || "")
        root.title = String(titleText || "Kết quả server")
        root.resultData = data || ({})
        const nextItems = []
        if (root.resultKind === "definition") {
            if (root.resultData.workflow)
                nextItems.push(root.resultData.workflow)
        } else {
            const sourceItems = root.resultData.items || []
            for (let index = 0; index < sourceItems.length; ++index)
                nextItems.push(sourceItems[index])
        }
        // A concrete model reset keeps consecutive result commands from
        // retaining stale delegates from the previous result kind.
        resultModel.clear()
        for (let index = 0; index < nextItems.length; ++index)
            resultModel.append({"payload": nextItems[index]})
        root.open()
        resultList.positionViewAtBeginning()
        resultList.forceLayout()
    }

    function rowTitle(item) {
        const value = item || ({})
        if (root.resultKind === "events")
            return String(value.event_type || value.summary || value.id || "Sự kiện")
        if (root.resultKind === "history" || root.resultKind === "definition")
            return String(value.workflow_key || "Workflow") + " · v" + String(value.version || "—")
        return String(value.workflow_key || "Workflow") + " · " + String(value.id || "Run")
    }

    function rowSubtitle(item) {
        const value = item || ({})
        if (root.resultKind === "events")
            return String(value.state || "—") + " · "
                + String(value.created_at || "—") + " · "
                + String(value.actor_id || "server")
        if (root.resultKind === "history")
            return String(value.state || "—") + " · " + String(value.created_at || "—")
        if (root.resultKind === "definition")
            return String(value.definition_fingerprint || "")
        return String(value.state || "—") + " · " + String(value.started_at || value.created_at || "—")
    }

    function resultMetaText() {
        if (root.resultKind === "events")
            return "Nhật ký bất biến từ server"
        if (root.resultKind === "history")
            return "Lịch sử revision từ server"
        return "Phiên bản export " + String(root.resultData.export_version || "—")
            + " · " + String(root.resultData.generated_at || "")
    }

    header: Rectangle {
        implicitHeight: 54
        color: Theme.panel
        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            text: root.title
            color: Theme.text
            font.pixelSize: 16
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 1; color: Theme.borderSoft }
    }

    contentItem: ColumnLayout {
        spacing: 10
        RowLayout {
            Layout.fillWidth: true
            Foundation.StatusPill { text: "Server result"; tone: Theme.success }
            Text { Layout.fillWidth: true; text: root.resultMetaText(); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
            Text { text: String(root.resultData.total ?? resultModel.count) + " mục"; color: Theme.textMuted; font.pixelSize: 11 }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
        ListView {
            id: resultList
            objectName: "automationResultList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: resultModel
            delegate: Rectangle {
                id: resultRow
                required property var payload
                required property int index
                objectName: "automationResultRow_" + String(index)
                width: resultList.width
                height: 56
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                Column {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 3
                    Text { width: parent.width; text: root.rowTitle(resultRow.payload); color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                    Text { width: parent.width; text: root.rowSubtitle(resultRow.payload); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideMiddle }
                }
            }
        }
    }

    footer: Rectangle {
        implicitHeight: 58
        color: Theme.panel
        Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; height: 1; color: Theme.borderSoft }
        AppButton {
            objectName: "automationResultDialogCloseButton"
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: "Đóng"
            primary: true
            onClicked: root.close()
        }
    }

    background: Rectangle {
        radius: Theme.radiusLarge
        color: Theme.panel
        border.width: 1
        border.color: Theme.border
        Accessible.name: root.title
        Accessible.role: Accessible.Dialog
    }
}
