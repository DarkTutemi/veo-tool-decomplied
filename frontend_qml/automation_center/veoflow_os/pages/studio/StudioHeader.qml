pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "studioHeader"
    property var headerData: ({})
    property string aspectRatio: "9:16"
    property string modeValue: "manual"
    property bool canRead: false
    property bool draftDirty: false
    property bool saveEnabled: false
    property bool saveBusy: false
    property bool renderEnabled: false
    property bool renderBusy: false
    property var renderPolicy: ({})
    property string renderKind: "final"
    property int renderPriority: 50
    signal aspectRequested(string value)
    signal modeRequested(string value)
    signal saveRequested()
    signal renderRequested()
    signal renderOptionsRequested(string kind, int priority)
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.role: Accessible.Pane
    Accessible.name: "Thanh công cụ Studio"

    function modeFor(key) {
        const modes = root.headerData.modes || []
        for (let index = 0; index < modes.length; index++) {
            const item = modes[index] || ({})
            if (String(item.key || "") === key) return item
        }
        return ({})
    }

    function priorityIndex(value) {
        const options = root.renderPolicy.priority_options || []
        for (let index = 0; index < options.length; index++) {
            if (Number(options[index]) === Number(value)) return index
        }
        return 0
    }

    function displayTitle() {
        const projected = String(root.headerData.title || "")
        return projected === "Hoàn thiện video" || !projected
            ? "Studio hoàn thiện" : projected
    }

    component SegmentButton: Button {
        id: control
        property bool selected: false
        property string availabilityReason: ""
        implicitWidth: 72
        implicitHeight: 34
        activeFocusOnTab: true
        Accessible.role: Accessible.Button
        Accessible.name: text
        Accessible.description: availabilityReason
        contentItem: Text {
            text: control.text
            color: !control.enabled ? Theme.textFaint : control.selected ? Theme.text : Theme.textMuted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 12
            font.weight: control.selected ? Font.DemiBold : Font.Normal
        }
        background: Rectangle {
            radius: 8
            color: control.selected ? Theme.accentSoft : control.hovered ? Theme.hover : "transparent"
            border.width: control.selected ? 1 : 0
            border.color: Theme.accent
        }
    }

    component ActionButton: Button {
        id: control
        property bool primary: false
        property string iconName: ""
        property string availabilityReason: ""
        property string accessibleName: text
        implicitHeight: 36
        implicitWidth: 104
        activeFocusOnTab: true
        Accessible.role: Accessible.Button
        Accessible.name: accessibleName
        Accessible.description: availabilityReason
        contentItem: RowLayout {
            spacing: 6
            UiIcon {
                Layout.alignment: Qt.AlignVCenter
                visible: control.iconName.length > 0
                name: control.iconName
                tone: control.enabled ? (control.primary ? "white" : Theme.text) : Theme.textFaint
                iconSize: 17
            }
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                visible: control.text.length > 0
                text: control.text
                color: control.enabled ? (control.primary ? "white" : Theme.text) : Theme.textFaint
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }
        background: Rectangle {
            radius: 8
            color: !control.enabled ? Theme.elevated
                : control.primary ? (control.pressed ? Qt.darker(Theme.accent, 1.15) : Theme.accent)
                : control.hovered ? Theme.hover : Theme.elevated
            border.width: control.primary && control.enabled ? 0 : 1
            border.color: Theme.border
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 16

        ColumnLayout {
            spacing: 1
            Text {
                objectName: "studioHeaderTitle"
                text: root.displayTitle()
                color: Theme.text
                font.pixelSize: Theme.fontPageTitle
                font.weight: Font.Bold
            }
            Text {
                text: "Gắn logo, watermark và kiểm tra trước khi lên lịch đăng"
                color: Theme.textFaint
                font.pixelSize: 11
            }
        }
        Item { Layout.fillWidth: true }

        RowLayout {
            spacing: 2
            SegmentButton {
                objectName: "studioAspect16x9"
                text: "16:9"
                selected: root.aspectRatio === "16:9"
                enabled: root.canRead
                onClicked: root.aspectRequested("16:9")
            }
            SegmentButton {
                objectName: "studioAspect9x16"
                text: "9:16"
                selected: root.aspectRatio === "9:16"
                enabled: root.canRead
                onClicked: root.aspectRequested("9:16")
            }
        }

        Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 28; color: Theme.borderSoft }

        RowLayout {
            spacing: 2
            SegmentButton {
                objectName: "studioModeManual"
                text: String(root.modeFor("manual").label || "Thủ công")
                selected: root.modeValue === "manual"
                enabled: root.canRead && root.modeFor("manual").available !== false
                availabilityReason: String(root.modeFor("manual").reason || "")
                onClicked: root.modeRequested("manual")
            }
            SegmentButton {
                objectName: "studioModeAuto"
                text: String(root.modeFor("auto").label || "Tự động")
                selected: root.modeValue === "auto"
                enabled: root.canRead && Boolean(root.modeFor("auto").available)
                availabilityReason: String(root.modeFor("auto").reason || "")
                onClicked: root.modeRequested("auto")
            }
        }

        ActionButton {
            objectName: "studioSaveRecipeButton"
            text: root.saveBusy ? "Đang lưu…" : "Lưu cấu hình"
            enabled: root.saveEnabled
            availabilityReason: !root.draftDirty ? "RECIPE_DRAFT_UNCHANGED" : ""
            onClicked: root.saveRequested()
        }
        RowLayout {
            spacing: 3
            ActionButton {
                objectName: "studioRenderButton"
                text: root.renderBusy ? "Đang xuất…" : "Xuất video"
                iconName: "ui/play"
                primary: true
                enabled: root.renderEnabled
                implicitWidth: 124
                onClicked: root.renderRequested()
            }
            ActionButton {
                id: renderMenuButton
                objectName: "studioRenderMenuButton"
                iconName: "ui/chevron-down"
                text: ""
                accessibleName: "Mở tùy chọn render"
                implicitWidth: 38
                enabled: root.canRead && (root.renderPolicy.priority_options || []).length > 0
                availabilityReason: enabled ? "" : "STUDIO_RENDER_OPTIONS_UNAVAILABLE"
                onClicked: renderOptions.open()
            }
        }
    }

    Popup {
        id: renderOptions
        objectName: "studioRenderOptionsPopup"
        property string pendingKind: root.renderKind
        x: Math.max(8, root.width - width - 18)
        y: root.height - 2
        width: 248
        padding: 12
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        onOpened: {
            pendingKind = root.renderKind
            prioritySelector.currentIndex = root.priorityIndex(root.renderPriority)
        }
        background: Rectangle {
            radius: 10
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
        contentItem: ColumnLayout {
            spacing: 9
            Accessible.role: Accessible.Pane
            Accessible.name: "Tùy chọn render"
            Text {
                text: "Loại render"
                color: Theme.text
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
            RowLayout {
                spacing: 4
                SegmentButton {
                    objectName: "studioRenderKindDraft"
                    Layout.fillWidth: true
                    text: "Bản nháp"
                    selected: renderOptions.pendingKind === "draft"
                    onClicked: renderOptions.pendingKind = "draft"
                }
                SegmentButton {
                    objectName: "studioRenderKindFinal"
                    Layout.fillWidth: true
                    text: "Bản cuối"
                    selected: renderOptions.pendingKind === "final"
                    onClicked: renderOptions.pendingKind = "final"
                }
            }
            Text { text: "Độ ưu tiên hàng đợi"; color: Theme.textMuted; font.pixelSize: 11 }
            StudioComboBox {
                id: prioritySelector
                objectName: "studioRenderPriority"
                Layout.fillWidth: true
                model: root.renderPolicy.priority_options || []
                currentIndex: root.priorityIndex(root.renderPriority)
                Accessible.name: "Độ ưu tiên render"
            }
            ActionButton {
                objectName: "studioRenderOptionsApply"
                Layout.fillWidth: true
                text: "Áp dụng"
                primary: true
                enabled: prioritySelector.currentIndex >= 0
                onClicked: {
                    const options = root.renderPolicy.priority_options || []
                    const priority = Number(options[prioritySelector.currentIndex] || 0)
                    root.renderOptionsRequested(renderOptions.pendingKind, priority)
                    renderOptions.close()
                }
            }
        }
    }
}
