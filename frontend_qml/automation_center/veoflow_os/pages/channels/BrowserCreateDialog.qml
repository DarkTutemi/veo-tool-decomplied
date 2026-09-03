pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Dialog {
    id: root
    objectName: "browserCreateDialog"
    property bool canCreate: false
    property bool busy: false
    property int selectedMode: 0
    signal createRequested(var payload)
    signal importPreviewRequested(var payload)

    width: 620
    height: 510
    modal: true
    closePolicy: Popup.CloseOnEscape
    leftPadding: 18
    rightPadding: 18
    topPadding: 14
    bottomPadding: 14

    onOpened: {
        root.selectedMode = 0
        browserLabel.text = ""
        platform.currentIndex = 0
        notes.text = ""
        importCsv.text = ""
        importPlatform.currentIndex = 0
        importOs.currentIndex = 0
        browserLabel.forceActiveFocus()
    }

    function draft() {
        return {
            "label": browserLabel.text.trim(),
            "platform": String(platform.currentValue || "tiktok"),
            "notes": notes.text.trim()
        }
    }

    function importDraft() {
        return {
            "csv_content": importCsv.text.trim(),
            "default_platform": String(importPlatform.currentValue || "tiktok"),
            "default_os": String(importOs.currentValue || "windows")
        }
    }

    background: Rectangle {
        color: Theme.panel
        radius: Theme.radiusMedium
        border.width: 1
        border.color: Theme.border
    }

    header: Rectangle {
        implicitHeight: 60
        color: Theme.elevated
        radius: Theme.radiusMedium
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 12
            Text {
                Layout.fillWidth: true
                text: "Thêm Browser"
                color: Theme.text
                font.pixelSize: 18
                font.weight: Font.Bold
            }
            UiIcon {
                name: "product/chrome"
                tone: Theme.accent
                iconSize: 22
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 10
        Accessible.name: "Trình tạo hoặc nhập browser profile"
        Accessible.role: Accessible.Form

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            ModeButton {
                objectName: "browserCreateModeSingle"
                label: "Tạo một Browser"
                iconName: "ui/plus"
                selected: root.selectedMode === 0
                onActivated: {
                    root.selectedMode = 0
                    browserLabel.forceActiveFocus()
                }
            }
            ModeButton {
                objectName: "browserCreateModeImport"
                label: "Nhập CSV"
                iconName: "semantic/upload-cloud"
                selected: root.selectedMode === 1
                onActivated: {
                    root.selectedMode = 1
                    importCsv.forceActiveFocus()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.selectedMode

            GridLayout {
                columns: 2
                columnSpacing: 12
                rowSpacing: 12

                FieldLabel { text: "Tên browser" }
                TextField {
                    id: browserLabel
                    objectName: "browserCreateLabel"
                    Layout.fillWidth: true
                    placeholderText: "Ví dụ: Bếp Nhà Mình"
                    activeFocusOnTab: true
                    Accessible.name: "Tên browser mới"
                }
                FieldLabel { text: "Nền tảng chính" }
                BrowserComboBox {
                    id: platform
                    objectName: "browserCreatePlatform"
                    Layout.fillWidth: true
                    model: [
                        {"label": "TikTok", "value": "tiktok"},
                        {"label": "YouTube", "value": "youtube"},
                        {"label": "Facebook", "value": "facebook"},
                        {"label": "Instagram", "value": "instagram"},
                        {"label": "X", "value": "x"},
                        {"label": "LinkedIn", "value": "linkedin"}
                    ]
                    Accessible.name: "Nền tảng chính của browser"
                }
                FieldLabel { text: "Ghi chú" }
                TextArea {
                    id: notes
                    objectName: "browserCreateNotes"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 92
                    placeholderText: "Mục đích vận hành (không bắt buộc)"
                    wrapMode: TextEdit.Wrap
                    activeFocusOnTab: true
                    Accessible.name: "Ghi chú browser"
                }
                Text {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    text: "Danh tính, thư mục profile và template mặc định được backend tạo, kiểm tra và khóa an toàn."
                    color: Theme.textFaint
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                }
                Item { Layout.columnSpan: 2; Layout.fillHeight: true }
            }

            ColumnLayout {
                spacing: 10
                Text {
                    Layout.fillWidth: true
                    text: "Dán CSV để backend kiểm tra từng dòng. Preview không tạo browser và execute chỉ dùng import ID đã đóng băng."
                    color: Theme.textMuted
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                }
                TextArea {
                    id: importCsv
                    objectName: "browserImportCsv"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 150
                    wrapMode: TextEdit.NoWrap
                    placeholderText: "label,platform,os,locale,timezone\nTikTok VN 01,tiktok,windows,vi-VN,Asia/Bangkok"
                    activeFocusOnTab: true
                    Accessible.name: "Nội dung CSV nhập browser"
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    BrowserComboBox {
                        id: importPlatform
                        objectName: "browserImportPlatform"
                        Layout.fillWidth: true
                        model: [
                            {"label": "Mặc định TikTok", "value": "tiktok"},
                            {"label": "Mặc định YouTube", "value": "youtube"},
                            {"label": "Mặc định Facebook", "value": "facebook"},
                            {"label": "Mặc định LinkedIn", "value": "linkedin"}
                        ]
                        Accessible.name: "Nền tảng mặc định khi nhập"
                    }
                    BrowserComboBox {
                        id: importOs
                        objectName: "browserImportOs"
                        Layout.fillWidth: true
                        model: [
                            {"label": "Windows", "value": "windows"},
                            {"label": "macOS", "value": "macos"},
                            {"label": "Linux", "value": "linux"}
                        ]
                        Accessible.name: "Hệ điều hành mặc định khi nhập"
                    }
                }
            }
        }
    }

    footer: Rectangle {
        implicitHeight: 64
        color: Theme.elevated
        radius: Theme.radiusMedium
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            Text {
                Layout.fillWidth: true
                text: root.selectedMode === 0
                    ? "Tạo theo policy workspace"
                    : "Preview trước · execute theo import ID"
                color: Theme.textFaint
                font.pixelSize: 11
            }
            AppButton {
                objectName: "browserCreateCancel"
                text: "Hủy"
                activeFocusOnTab: true
                Accessible.name: text
                onClicked: root.reject()
            }
            AppButton {
                objectName: "browserCreateSubmit"
                visible: root.selectedMode === 0
                text: root.busy ? "Đang tạo..." : "Tạo Browser"
                primary: true
                activeFocusOnTab: true
                enabled: root.canCreate && !root.busy
                    && browserLabel.text.trim().length > 0
                Accessible.name: text
                onClicked: root.createRequested(root.draft())
            }
            AppButton {
                objectName: "browserImportPreview"
                visible: root.selectedMode === 1
                text: root.busy ? "Đang kiểm tra..." : "Preview & kiểm tra"
                primary: true
                activeFocusOnTab: true
                enabled: root.canCreate && !root.busy
                    && importCsv.text.trim().length > 0
                Accessible.name: text
                Accessible.description: "Gửi CSV tới browser.import.preview; không tạo browser"
                onClicked: root.importPreviewRequested(root.importDraft())
            }
        }
    }

    component FieldLabel: Text {
        color: Theme.textMuted
        font.pixelSize: 12
        verticalAlignment: Text.AlignVCenter
    }

    component ModeButton: Button {
        id: modeButton
        required property string label
        required property string iconName
        required property bool selected
        signal activated()
        Layout.fillWidth: true
        Layout.preferredHeight: 38
        text: modeButton.label
        hoverEnabled: true
        activeFocusOnTab: true
        Accessible.name: modeButton.label
        Accessible.description: modeButton.selected ? "Đang chọn" : "Chuyển chế độ"
        onClicked: modeButton.activated()
        contentItem: RowLayout {
            spacing: 8
            UiIcon {
                name: modeButton.iconName
                tone: modeButton.selected ? Theme.accent : Theme.textFaint
                iconSize: 15
            }
            Text {
                Layout.fillWidth: true
                text: modeButton.label
                color: modeButton.selected ? Theme.text : Theme.textMuted
                font.pixelSize: 12
                font.weight: modeButton.selected ? Font.DemiBold : Font.Normal
                horizontalAlignment: Text.AlignHCenter
            }
        }
        background: Rectangle {
            radius: Theme.radiusSmall
            color: modeButton.selected
                ? Theme.accentSoft : (modeButton.hovered ? Theme.hover : Theme.elevated)
            border.width: 1
            border.color: modeButton.selected ? Theme.accent : Theme.borderSoft
        }
    }
}
