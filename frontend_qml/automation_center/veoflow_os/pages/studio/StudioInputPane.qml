pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "studioInputPane"
    property var inputsData: ({})
    property var assetModel: null
    property var controlPlaneBridge: null
    property int snapshotRevision: 0
    property string selectedAssetId: ""
    property var batchSelection: ({})
    property bool canRead: false
    property bool busy: false
    readonly property string searchText: searchField.text
    readonly property string sourceValue: String((sourceFilter.currentValue === undefined ? "" : sourceFilter.currentValue) || "")
    readonly property string readinessValue: String(readinessFilter.currentValue || "all")
    readonly property string qcValue: String(qcFilter.currentValue || "all")
    readonly property int batchSelectionCount: Object.keys(root.batchSelection || ({})).length
    signal importRequested()
    signal refreshRequested()
    signal filtersRequested()
    signal assetRequested(string assetId)
    signal previousRequested()
    signal nextRequested()
    signal batchSelectionRequested(var selection)
    signal batchRenderRequested()
    color: Theme.panel
    radius: Theme.radiusMedium
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.role: Accessible.Pane
    Accessible.name: "Nguồn đầu vào Studio"

    function sourceOptions() {
        const revision = root.snapshotRevision
        const result = [{"label": "Tất cả nguồn", "value": ""}]
        const seen = ({})
        if (!root.assetModel) return result
        for (let index = 0; index < root.assetModel.count; index++) {
            const value = String((root.assetModel.get(index) || {}).source || "")
            if (!value || seen[value]) continue
            seen[value] = true
            result.push({"label": value, "value": value})
        }
        return result
    }

    function readinessLabel(value) {
        const state = String(value || "unknown").toLowerCase()
        if (state === "ready") return "Sẵn sàng"
        if (state === "attention") return "Cần chú ý"
        return "Chưa sẵn sàng"
    }

    function qcLabel(value) {
        const state = String(value || "unknown").toLowerCase()
        if (state === "passed") return "Đã QC"
        if (state === "warning") return "Cảnh báo"
        if (state === "failed") return "Lỗi QC"
        return "Chưa QC"
    }

    function batchSelected(assetId) {
        return Boolean((root.batchSelection || ({}))[String(assetId || "")])
    }

    function toggleBatchAsset(assetId: string): bool {
        const identity = String(assetId || "")
        if (!identity) return false
        const next = JSON.parse(JSON.stringify(root.batchSelection || ({})))
        if (next[identity]) delete next[identity]
        else next[identity] = true
        root.batchSelectionRequested(next)
        return true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Danh sách video"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
            Item { Layout.fillWidth: true }
            StudioButton {
                id: importButton
                objectName: "studioImportVideoButton"
                Layout.preferredHeight: 32
                text: "+  Thêm video"
                enabled: root.canRead && !root.busy
                activeFocusOnTab: true
                Accessible.role: Accessible.Button
                Accessible.name: "Thêm video vào danh sách"
                onClicked: root.importRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            StudioComboBox {
                id: sourceFilter
                objectName: "studioSourceFilter"
                Layout.fillWidth: true
                model: root.sourceOptions()
                textRole: "label"
                valueRole: "value"
                Accessible.name: "Lọc theo nguồn"
                onActivated: root.filtersRequested()
            }
            StudioButton {
                id: filterButton
                objectName: "studioAdvancedFiltersButton"
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                iconName: "ui/filter"
                text: ""
                activeFocusOnTab: true
                Accessible.name: "Mở tìm kiếm và bộ lọc QC"
                onClicked: filterPopup.open()
            }
            StudioButton {
                id: refreshButton
                objectName: "studioRefreshAssets"
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                iconName: "ui/refresh-cw"
                text: ""
                enabled: root.canRead && !root.busy
                activeFocusOnTab: true
                Accessible.role: Accessible.Button
                Accessible.name: "Làm mới video đầu vào"
                onClicked: root.refreshRequested()
                background: Rectangle { radius: 7; color: refreshButton.hovered ? Theme.hover : Theme.elevated; border.width: 1; border.color: Theme.borderSoft }
            }
        }

        ScrollView {
            id: assetList
            objectName: "studioAssetList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            Accessible.role: Accessible.List
            Accessible.name: "Danh sách video đầu vào"

            Column {
                id: assetColumn
                width: assetList.availableWidth
                spacing: 5
                Repeater {
                    model: root.assetModel
                    delegate: Rectangle {
                        id: row
                        required property string asset_id
                        required property var file_name
                        required property var duration_seconds
                        required property var media_width
                        required property var media_height
                        required property var readiness
                        required property var qc_status
                        required property var thumbnail_url
                        readonly property string assetId: String(row.asset_id || "")
                        readonly property string thumbnailSource: root.controlPlaneBridge
                            ? String(root.controlPlaneBridge.authorizedThumbnailUrl(
                                row.assetId, String(row.thumbnail_url || "")
                            ) || "") : ""
                        property bool selected: row.assetId === root.selectedAssetId
                        objectName: "studioAssetRow_" + row.assetId
                        width: assetColumn.width
                        height: 108
                        radius: 8
                        color: row.selected ? Theme.accentSoft : rowMouse.containsMouse ? Theme.hover : Theme.elevated
                        border.width: 1
                        border.color: row.selected ? Theme.accent : Theme.borderSoft
                        Accessible.role: Accessible.ListItem
                        Accessible.name: String(row.file_name || row.assetId)
                            + (row.selected ? ", đã chọn" : "")
                            + (root.batchSelected(row.assetId) ? ", trong batch" : "")
                        activeFocusOnTab: true

                        function activate(): bool {
                            root.assetRequested(row.assetId)
                            return true
                        }
                        Keys.onReturnPressed: row.activate()
                        Keys.onSpacePressed: row.activate()

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            Rectangle {
                                Layout.preferredWidth: 82
                                Layout.preferredHeight: 82
                                radius: 7
                                color: Theme.base
                                clip: true
                                Image {
                                    objectName: "studioAssetThumbnail_" + row.assetId
                                    anchors.fill: parent
                                    source: row.thumbnailSource
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    visible: status === Image.Ready
                                }
                                UiIcon {
                                    anchors.centerIn: parent
                                    name: "ui/play"
                                    tone: Theme.textFaint
                                    iconSize: 14
                                    visible: !row.thumbnailSource
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { Layout.fillWidth: true; text: String(row.file_name || row.assetId); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideMiddle }
                                Text {
                                    text: Math.round(Number(row.duration_seconds || 0)) + "s  ·  "
                                        + Number(row.media_width || 0) + "×" + Number(row.media_height || 0)
                                    color: Theme.textFaint
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: root.readinessLabel(row.readiness) + " · " + root.qcLabel(row.qc_status)
                                    color: String(row.qc_status || "") === "failed" ? Theme.danger
                                        : String(row.qc_status || "") === "warning" ? Theme.warning : Theme.success
                                    font.pixelSize: 11
                                }
                            }
                            Text { text: row.selected ? "✓" : ""; color: Theme.accent; font.pixelSize: 16 }
                            StudioButton {
                                objectName: "studioBatchSelect_" + row.assetId
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                iconName: root.batchSelected(row.assetId)
                                    ? "ui/check-square" : "ui/plus"
                                text: ""
                                checkable: true
                                checked: root.batchSelected(row.assetId)
                                activeFocusOnTab: true
                                Accessible.name: (checked ? "Bỏ khỏi" : "Thêm vào")
                                    + " batch " + String(row.file_name || row.assetId)
                                onClicked: root.toggleBatchAsset(row.assetId)
                            }
                        }
                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            anchors.rightMargin: 38
                            hoverEnabled: true
                            onClicked: row.activate()
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            Text {
                objectName: "studioAssetCount"
                text: (Number(root.inputsData.cursor || 0)
                    + (root.assetModel ? root.assetModel.count : 0))
                    + " / " + Number(root.inputsData.total || 0) + " video"
                color: Theme.textFaint
                font.pixelSize: 11
                Accessible.role: Accessible.StaticText
                Accessible.name: text
            }
            Item { Layout.fillWidth: true }
            StudioButton {
                id: batchButton
                objectName: "studioBatchRenderButton"
                text: root.batchSelectionCount > 0
                    ? "Dựng batch · " + root.batchSelectionCount : "Dựng batch"
                iconName: ""
                primary: root.batchSelectionCount >= 2
                enabled: root.batchSelectionCount >= 2 && root.canRead && !root.busy
                availabilityReason: enabled ? ""
                    : root.batchSelectionCount < 2 ? "Chọn ít nhất 2 video" : "Studio đang bận"
                activeFocusOnTab: true
                Accessible.name: "Dựng hàng loạt các video đã chọn"
                onClicked: root.batchRenderRequested()
            }
            StudioButton {
                id: previousButton
                objectName: "studioAssetPreviousPage"
                iconName: "ui/chevron-left"
                text: ""
                enabled: Number(root.inputsData.cursor || 0) > 0 && !root.busy
                activeFocusOnTab: true
                Accessible.name: "Trang video trước"
                onClicked: root.previousRequested()
            }
            StudioButton {
                id: nextButton
                objectName: "studioAssetNextPage"
                iconName: "ui/chevron-right"
                text: ""
                enabled: Boolean(root.inputsData.next_cursor) && !root.busy
                activeFocusOnTab: true
                Accessible.name: "Trang video tiếp theo"
                onClicked: root.nextRequested()
            }
        }
    }

    Popup {
        id: filterPopup
        objectName: "studioAdvancedFiltersPopup"
        x: 10
        y: 76
        width: root.width - 20
        padding: 9
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            radius: 9
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
        contentItem: ColumnLayout {
            spacing: 7
            Text {
                text: "Tìm và lọc video"
                color: Theme.text
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
            TextField {
                id: searchField
                objectName: "studioSearchField"
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                placeholderText: "Tên video…"
                color: Theme.text
                placeholderTextColor: Theme.textFaint
                activeFocusOnTab: true
                Accessible.name: "Tìm video đầu vào"
                onAccepted: {
                    root.filtersRequested()
                    filterPopup.close()
                }
                background: Rectangle {
                    radius: 7
                    color: Theme.elevated
                    border.width: 1
                    border.color: searchField.activeFocus ? Theme.accent : Theme.borderSoft
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                StudioComboBox {
                    id: readinessFilter
                    objectName: "studioReadinessFilter"
                    Layout.fillWidth: true
                    model: [
                        {"label": "Mọi trạng thái", "value": "all"},
                        {"label": "Sẵn sàng", "value": "ready"},
                        {"label": "Cần chú ý", "value": "attention"}
                    ]
                    textRole: "label"
                    valueRole: "value"
                    Accessible.name: "Lọc theo trạng thái sẵn sàng"
                }
                StudioComboBox {
                    id: qcFilter
                    objectName: "studioQcFilter"
                    Layout.fillWidth: true
                    model: [
                        {"label": "Mọi QC", "value": "all"},
                        {"label": "Đạt", "value": "passed"},
                        {"label": "Cảnh báo", "value": "warning"},
                        {"label": "Lỗi", "value": "failed"},
                        {"label": "Chưa có", "value": "unavailable"}
                    ]
                    textRole: "label"
                    valueRole: "value"
                    Accessible.name: "Lọc theo QC"
                }
            }
            StudioButton {
                objectName: "studioApplyAdvancedFilters"
                Layout.fillWidth: true
                primary: true
                text: "Áp dụng bộ lọc"
                activeFocusOnTab: true
                Accessible.name: "Áp dụng tìm kiếm và bộ lọc QC"
                onClicked: {
                    root.filtersRequested()
                    filterPopup.close()
                }
            }
        }
    }
}
