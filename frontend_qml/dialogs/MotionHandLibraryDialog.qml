pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "motionHandLibraryDialog"

    property var options: []
    property string roleFilter: ""
    property string selectedAssetId: "auto"
    property string searchText: ""
    readonly property int packagedAssetCount: Math.max(0, (root.options || []).length - 2)
    // Small static packaged catalog. Rebuilding it on a local search edit is
    // intentionally bounded and never touches a controller or the filesystem.
    readonly property var visibleOptions: root.filterOptions(root.options || [], root.searchText) // perf-lint: disable=R2

    signal assetChosen(string assetId)

    parent: Overlay.overlay
    modal: true
    header: null
    width: VfDialogMetrics.width(parent, 1120, 56)
    height: VfDialogMetrics.height(parent, 760, 56)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape

    function openFor(assetId) {
        root.searchText = ""
        root.selectedAssetId = String(assetId || "auto")
        root.open()
    }

    function filterOptions(items, needle) {
        var query = String(needle || "").trim().toLowerCase()
        if (!query.length)
            return items
        var rows = []
        for (var i = 0; i < items.length; i++) {
            var item = items[i] || ({})
            var assetId = String(item.value || "")
            var role = String(item.motion_role || "")
            if (root.roleFilter.length && assetId !== "auto" && assetId !== "random"
                    && role !== root.roleFilter)
                continue
            var haystack = [item.label, item.value, item.tool_family].join(" ").toLowerCase()
            if (haystack.indexOf(query) >= 0)
                rows.push(item)
        }
        return rows
    }

    function optionById(assetId) {
        var wanted = String(assetId || "auto")
        var items = root.options || []
        for (var i = 0; i < items.length; i++) {
            if (String((items[i] || {}).value || "") === wanted)
                return items[i] || ({})
        }
        return ({ label: wanted, value: wanted })
    }

    function fileUrl(raw) {
        var value = String(raw || "")
        if (!value.length)
            return ""
        if (value.indexOf("file:/") === 0 || value.indexOf("qrc:/") === 0
                || value.indexOf("http://") === 0 || value.indexOf("https://") === 0)
            return value
        return "file:///" + value.replace(/\\/g, "/")
    }

    background: Rectangle {
        radius: VfTheme.dp(12)
        color: VfTheme.surface
        border.width: 1
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(14)
        spacing: VfTheme.dp(10)

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(10)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(38)
                Layout.preferredHeight: VfTheme.dp(38)
                radius: VfTheme.dp(9)
                color: VfTheme.amberFill
                border.width: 1
                border.color: VfTheme.amberBorderSoft

                VfAppIcon {
                    anchors.centerIn: parent
                    name: "pencil"
                    size: VfTheme.dp(20)
                    framed: false
                    color: VfTheme.amberText
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Label {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("motion_hand_library.title", "Kho tay & bút vẽ"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: VfTheme.weightStrong
                }

                Label {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("motion_hand_library.subtitle", "{count} sprite hệ thống, cộng Auto và Random ổn định."))
                        .replace("{count}", String(root.packagedAssetCount))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                }
            }

            ToolButton {
                action: Action { onTriggered: root.reject() }
                icon.name: "close"
                text: "×"
                font.pixelSize: VfTheme.dp(18)
                ToolTip.visible: hovered
                ToolTip.text: (void i18n.revision, i18n.t("common.close", "Đóng"))
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(48)
            radius: VfTheme.dp(8)
            color: VfTheme.surfaceSoft
            border.width: 1
            border.color: VfTheme.borderSoft

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(7)
                spacing: VfTheme.dp(8)

                TextField {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: (void i18n.revision, i18n.t("motion_hand_library.search", "Tìm tay, marker, pencil, cartoon..."))
                    text: root.searchText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    onTextChanged: root.searchText = text
                    background: Rectangle {
                        radius: VfTheme.dp(7)
                        color: VfTheme.surface
                        border.width: 1
                        border.color: parent.activeFocus ? "#F59E0B" : VfTheme.borderSoft
                    }
                }

                Label {
                    text: String(root.visibleOptions.length) + " / " + String((root.options || []).length)
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: VfTheme.dp(9)
            color: VfTheme.surfaceSoft
            border.width: 1
            border.color: VfTheme.borderSoft
            clip: true

            VfGridView {
                id: assetGrid
                anchors.fill: parent
                anchors.margins: VfTheme.dp(8)
                cellWidth: VfTheme.dp(178)
                cellHeight: VfTheme.dp(202)
                model: root.visibleOptions
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    id: assetCard
                    required property var modelData

                    readonly property string assetId: String(assetCard.modelData.value || "auto")
                    readonly property bool selected: assetCard.assetId === root.selectedAssetId
                    readonly property string previewPath: String(assetCard.modelData.preview_path || "")

                    width: VfTheme.dp(168)
                    height: VfTheme.dp(192)
                    radius: VfTheme.dp(8)
                    color: assetMouse.containsMouse ? VfTheme.surface : VfTheme.surfaceSoft
                    border.width: assetCard.selected ? 2 : 1
                    border.color: assetCard.selected ? "#F59E0B" : VfTheme.borderSoft

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(7)
                        spacing: VfTheme.dp(5)

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(116)
                            radius: VfTheme.dp(7)
                            color: "#F7F7F5"
                            border.width: 1
                            border.color: VfTheme.borderSoft
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(5)
                                source: root.fileUrl(assetCard.previewPath)
                                visible: assetCard.previewPath.length > 0
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                sourceSize.width: VfTheme.dp(160)
                                sourceSize.height: VfTheme.dp(112)
                            }

                            Label {
                                anchors.centerIn: parent
                                visible: assetCard.previewPath.length <= 0
                                text: String(assetCard.modelData.symbol || "✍")
                                color: VfTheme.text
                                font.family: "Segoe UI Emoji"
                                font.pixelSize: VfTheme.dp(38)
                            }

                            Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: VfTheme.dp(5)
                                width: selectedBadge.implicitWidth + VfTheme.dp(10)
                                height: VfTheme.dp(20)
                                radius: VfTheme.dp(10)
                                visible: assetCard.selected
                                color: "#F59E0B"

                                Label {
                                    id: selectedBadge
                                    anchors.centerIn: parent
                                    text: (void i18n.revision, i18n.t("motion_hand_library.selected", "Đã chọn"))
                                    color: "#FFFFFF"
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9)
                                    font.weight: VfTheme.weightStrong
                                }
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: String(assetCard.modelData.label || assetCard.assetId)
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            font.weight: VfTheme.weightStrong
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: String(assetCard.modelData.tool_family || assetCard.assetId)
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: assetMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectedAssetId = assetCard.assetId
                        onDoubleClicked: {
                            root.selectedAssetId = assetCard.assetId
                            root.assetChosen(root.selectedAssetId)
                            root.accept()
                        }
                    }

                    ToolTip.visible: assetMouse.containsMouse
                    ToolTip.text: assetCard.assetId
                    ToolTip.delay: 350
                }
            }

            Label {
                anchors.centerIn: parent
                visible: root.visibleOptions.length <= 0
                text: (void i18n.revision, i18n.t("motion_hand_library.empty", "Không tìm thấy tay hoặc bút phù hợp."))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Label {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("motion_hand_library.current", "Lựa chọn hiện tại"))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                }

                Label {
                    Layout.fillWidth: true
                    text: String(root.optionById(root.selectedAssetId).label || root.selectedAssetId)
                    color: VfTheme.amberText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                tone: "neutral"
                onClicked: root.reject()
            }

            VfButton {
                actionId: "motion_hand_library.use_asset"
                text: (void i18n.revision, i18n.t("motion_hand_library.use", "Dùng tay / bút này"))
                tone: "primary"
                minWidth: VfTheme.dp(160)
                onClicked: {
                    root.assetChosen(root.selectedAssetId)
                    root.accept()
                }
            }
        }
    }
}
