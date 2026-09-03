import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Dialogs
import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "csvImportDialog"

    property string filePath: ""
    property var previewRows: []
    property int importedCount: previewRows.length
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property bool closeAfterFeedback: false

    signal chooseFileRequested()
    signal downloadTemplateRequested()
    signal importRequested(var rows)

    function requestChooseFile() {
        root.chooseFileRequested()
    }

    function requestDownloadTemplate() {
        root.downloadTemplateRequested()
    }

    function requestImportRows() {
        root.importRequested(root.previewRows)
    }

    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, 875, 48)
    height: VfDialogMetrics.height(parent, 730, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 16
    standardButtons: Dialog.NoButton

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("csv_import_dialog.title", "Import sản phẩm từ CSV"))
        iconName: "inbox-tray"
        onCloseClicked: root.reject()
    }

    background: Rectangle {
        color: VfTheme.surface
        radius: 8
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    function applyImportResult(result) {
        var response = result || ({})
        root.closeAfterFeedback = false
        if (response.ok === false) {
            var message = String(response.message || response.error || response.code || "Import failed.")
            root.statusText = message
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        root.statusText = String(response.message || "Import completed.")
        root.feedbackTitle = (void i18n.revision, i18n.t("common.success", "Success"))
        root.feedbackMessage = root.statusText
        root.closeAfterFeedback = true
        feedbackDialog.open()
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 114
            radius: 4
            color: VfTheme.surface
            border.color: VfTheme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2

                Label {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("csv_import_dialog.required_headers", "File CSV cần có header: name, category, price, description, image_path, key_features"))
                    color: VfTheme.textMuted
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }

                Label {
                    Layout.fillWidth: true
                    text: "• category: cosmetics, fashion, electronics, home, food, sports, beauty, health, baby, other"
                    color: VfTheme.textMuted
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }

                Label {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("csv_import_dialog.key_features_hint", "• key_features: phân cách bằng dấu ; (ví dụ: Nhẹ;Bền;Chống nước)"))
                    color: VfTheme.textMuted
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }

                Label {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("csv_import_dialog.image_path_hint", "• image_path: đường dẫn file ảnh cục bộ (tùy chọn)"))
                    color: VfTheme.textMuted
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
            }
        }

        Dialogs.Button {
            text: (void i18n.revision, i18n.t("csv_import_dialog.download_template", "Tải file mẫu CSV"))
            actionId: "download csv template"
            tone: "neutral"
            tooltip: (void i18n.revision, i18n.t("csv_import_dialog.download_template_tooltip", "Tải file CSV mẫu để nhập sản phẩm"))
            minWidth: 160
            implicitHeight: 38
            font.family: "Segoe UI"
            font.pixelSize: 12
            onClicked: root.requestDownloadTemplate()
        }

        Label {
            Layout.fillWidth: true
            visible: root.statusText.length > 0
            text: root.statusText
            color: "#FCA5A5"
            font.family: "Segoe UI"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Dialogs.Button {
                text: (void i18n.revision, i18n.t("csv_import_dialog.choose_file", "Chọn file CSV"))
                actionId: "choose csv file"
                tone: "neutral"
                tooltip: (void i18n.revision, i18n.t("csv_import_dialog.choose_file_tooltip", "Chọn file CSV từ máy"))
                minWidth: 160
                implicitHeight: 38
                font.family: "Segoe UI"
                font.pixelSize: 12
                onClicked: root.requestChooseFile()
            }

            Label {
                Layout.fillWidth: true
                text: root.filePath.length > 0 ? root.filePath : (void i18n.revision, i18n.t("csv_import_dialog.no_file_selected", "Chưa chọn file"))
                color: VfTheme.textSubtle
                font.family: "Segoe UI"
                font.pixelSize: 12
                elide: Text.ElideMiddle
                verticalAlignment: Text.AlignVCenter
            }
        }

        Label {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("csv_import_dialog.preview_label", "XEM TRƯỚC (5 DÒNG ĐẦU)"))
            color: VfTheme.textSubtle
            font.family: "Segoe UI"
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 2
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                CsvRow {
                    Layout.fillWidth: true
                    isHeader: true
                    rowData: ({ name: (void i18n.revision, i18n.t("csv_import_dialog.column_name", "Tên SP")), category: (void i18n.revision, i18n.t("csv_import_dialog.column_category", "Danh mục")), price: (void i18n.revision, i18n.t("csv_import_dialog.column_price", "Giá")), description: (void i18n.revision, i18n.t("csv_import_dialog.column_description", "Mô tả")), image_path: (void i18n.revision, i18n.t("csv_import_dialog.column_image", "Ảnh đường dẫn")) })
                }

                Repeater {
                    model: root.previewRows.slice(0, 5)
                    CsvRow {
                        Layout.fillWidth: true
                        rowData: modelData
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: root.importedCount > 0 ? ((void i18n.revision, i18n.t("csv_import_dialog.found_rows", "Tìm thấy")) + " " + root.importedCount + " " + (void i18n.revision, i18n.t("csv_import_dialog.data_rows", "dòng dữ liệu"))) : (void i18n.revision, i18n.t("csv_import_dialog.no_data", "Chưa có dữ liệu"))
            color: VfTheme.textSubtle
            font.family: "Segoe UI"
            font.pixelSize: 12
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Item {
                Layout.fillWidth: true
            }

            Dialogs.Button {
                text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                actionId: "dialog.close"
                tone: "neutral"
                tooltip: (void i18n.revision, i18n.t("csv_import_dialog.cancel_import_tooltip", "Huỷ nhập CSV"))
                minWidth: 72
                implicitHeight: 34
                font.family: "Segoe UI"
                font.pixelSize: 12
                onClicked: root.reject()
            }

            Dialogs.Button {
                text: (void i18n.revision, i18n.t("csv_import_dialog.import_button", "Import")) + " " + root.importedCount + " " + (void i18n.revision, i18n.t("csv_import_dialog.products", "sản phẩm"))
                actionId: "import csv products"
                tone: "primary"
                tooltip: (void i18n.revision, i18n.t("csv_import_dialog.import_tooltip", "Import các sản phẩm đã đọc từ CSV"))
                minWidth: 158
                implicitHeight: 34
                enabled: root.importedCount > 0
                font.family: "Segoe UI"
                font.pixelSize: 12
                onClicked: root.requestImportRows()
            }
        }
    }

    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        padding: 20
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: 8
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: 14

            Label {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: "Segoe UI"
                font.pixelSize: 18
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: "Segoe UI"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                Dialogs.Button {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    actionId: "dialog.ok"
                    tone: "primary"
                    tooltip: (void i18n.revision, i18n.t("csv_import_dialog.close_notification_tooltip", "Đóng thông báo"))
                    minWidth: 96
                    implicitHeight: 32
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                    onClicked: {
                        feedbackDialog.close()
                        if (root.closeAfterFeedback) {
                            root.closeAfterFeedback = false
                            root.accept()
                        }
                    }
                }
            }
        }
    }

    component CsvRow: Rectangle {
        property var rowData: ({})
        property bool isHeader: false
        implicitHeight: isHeader ? 38 : 30
        color: isHeader ? VfTheme.surfaceSoft : VfTheme.surface
        border.color: VfTheme.borderStrong

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            CsvCell { text: String(rowData.name || ""); bold: isHeader; widthValue: 110 }
            CsvCell { text: String(rowData.category || ""); bold: isHeader; widthValue: 120 }
            CsvCell { text: String(rowData.price || ""); bold: isHeader; widthValue: 100 }
            CsvCell { text: String(rowData.description || ""); bold: isHeader; fill: true }
            CsvCell { text: String(rowData.image_path || ""); bold: isHeader; widthValue: 130 }
        }
    }

    component CsvCell: Label {
        property bool bold: false
        property bool fill: false
        property int widthValue: 80
        Layout.preferredWidth: fill ? -1 : widthValue
        Layout.fillWidth: fill
        color: bold ? VfTheme.textMuted : VfTheme.text
        font.family: "Segoe UI"
        font.pixelSize: bold ? 11 : 10
        font.weight: bold ? Font.DemiBold : Font.Normal
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
