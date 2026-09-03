pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "resourceTable"
    property var resourceModel: null
    property var checkAction: ({})
    property var catalogAction: ({})
    property var controlPlaneBridge: null
    property int commandRevision: 0
    readonly property bool checkBusy: {
        const revision = root.commandRevision
        return root.controlPlaneBridge.commandStore.isBusy("settings.resources.check", "global", "global")
    }
    readonly property bool catalogBusy: {
        const revision = root.commandRevision
        return root.controlPlaneBridge.commandStore.isBusy(
            "settings.resource.catalog.inspect", "global", "global")
    }
    signal actionRequested(var action)
    signal deepLinkRequested(var deepLink)
    Accessible.name: "Danh sách tài nguyên runtime"
    Accessible.role: Accessible.Table
    implicitHeight: 94 + Math.max(1, resourceModel ? resourceModel.count : 0) * 40

    readonly property bool compactColumns: root.width < 1120
    readonly property real columnScale: compactColumns ? 1.0 : Math.max(
        0.82, Math.min(1.0, Math.max(1, root.width - 20) / 1120))
    readonly property int installedColumnWidth: Math.round(
        (compactColumns ? 118 : 132) * columnScale)
    readonly property int availableColumnWidth: Math.round(112 * columnScale)
    readonly property int sourceColumnWidth: Math.round(
        (compactColumns ? 190 : 240) * columnScale)
    readonly property int sizeColumnWidth: Math.round(96 * columnScale)
    readonly property int integrityColumnWidth: Math.round(
        (compactColumns ? 150 : 144) * columnScale)
    readonly property int actionsColumnWidth: Math.round(
        (compactColumns ? 150 : 194) * columnScale)

    function versionLabel(value) {
        let label = String(value || "").trim()
        if (label.length === 0) return "—"
        label = label.replace(/^ffmpeg version\s+/i, "")
        if (label.indexOf(" ") >= 0) label = label.split(/\s+/)[0]
        const dateBuild = label.match(/^(\d{4}-\d{2}-\d{2})(?:-|$)/)
        if (dateBuild !== null) return dateBuild[1]
        return label
    }

    function availableVersionLabel(resourceId, value) {
        if (value !== null && value !== undefined && String(value).trim().length > 0)
            return root.versionLabel(value)
        const identity = String(resourceId || "")
        if (identity === "media_tools" || identity === "android_automation")
            return "Chưa kết nối"
        if (identity === "qml_modules") return "Theo ứng dụng"
        return "Chưa công bố"
    }

    function compactVersionLabel(installedValue, availableValue) {
        const installedText = root.versionLabel(installedValue)
        const availableText = root.versionLabel(availableValue)
        if (installedText !== "—") return installedText
        return availableText !== "—" ? "Mới " + availableText : "—"
    }

    function sourceLabel(value) {
        const sourceValue = String(value || "").trim()
        const labels = {
            "managed": "Được quản lý",
            "development_path": "Cài trên máy",
            "application_bundle": "Gói ứng dụng",
            "unavailable": "Chưa cấu hình"
        }
        if (labels[sourceValue] !== undefined) return labels[sourceValue]
        return sourceValue.length > 0 ? sourceValue : "Chưa cấu hình"
    }

    function channelLabel(value) {
        const channelValue = String(value || "").trim()
        const labels = {"stable": "Ổn định", "beta": "Beta"}
        if (labels[channelValue] !== undefined) return labels[channelValue]
        return channelValue
    }

    function sourceSummary(source, channel) {
        const sourceValue = String(source || "").trim()
        const compactLabels = {
            "VeoFlow CDN": "CDN",
            "managed": "Quản lý",
            "development_path": "Cài máy",
            "application_bundle": "Ứng dụng",
            "unavailable": "Chưa cấu hình"
        }
        const sourceText = root.compactColumns && compactLabels[sourceValue] !== undefined
            ? compactLabels[sourceValue] : root.sourceLabel(sourceValue)
        const channelText = root.channelLabel(channel)
        return channelText.length > 0 ? sourceText + " · " + channelText : sourceText
    }

    function actionAvailable(action) {
        return action !== null && action !== undefined
            && typeof action === "object" && action.available === true
    }

    function actionReason(action, fallback) {
        if (root.actionAvailable(action)) return ""
        const reason = action !== null && action !== undefined
            && typeof action === "object" ? String(action.reason_code || "") : ""
        return reason.length > 0 ? reason : String(fallback || "Hành động không khả dụng")
    }

    function resourceBusy(resourceId) {
        const revision = root.commandRevision
        if (!root.controlPlaneBridge || !root.controlPlaneBridge.commandStore)
            return false
        return root.controlPlaneBridge.commandStore.isBusy(
            "settings.resource.update", "resource", String(resourceId || "")
        )
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Tài nguyên ứng dụng"
                color: Theme.text
                font.pixelSize: 14
                font.weight: Font.Bold
            }
            Item { Layout.fillWidth: true }
            AppButton {
                id: catalogButton
                objectName: "resourceCatalogInspectButton"
                text: root.catalogBusy ? "Đang đọc CDN…"
                    : String(root.catalogAction.label || "Kiểm tra phiên bản CDN")
                leadingIcon: "semantic/upload-cloud"
                activeFocusOnTab: true
                enabled: root.actionAvailable(root.catalogAction) && !root.catalogBusy
                availabilityReason: enabled ? "" : (root.catalogBusy
                    ? "Đang đọc catalog CDN"
                    : root.actionReason(root.catalogAction,
                        "Không thể đọc catalog CDN"))
                Accessible.name: text
                Accessible.description: enabled
                    ? "Chỉ đọc catalog CDN, không tải hoặc cài tài nguyên"
                    : availabilityReason
                onClicked: root.actionRequested(root.catalogAction)
            }
            AppButton {
                id: checkButton
                objectName: "resourcesCheckButton"
                text: root.checkBusy ? "Đang kiểm tra…"
                    : String(root.checkAction.label || "Kiểm tra tài nguyên")
                primary: false
                leadingIcon: "ui/refresh-cw"
                activeFocusOnTab: true
                enabled: root.actionAvailable(root.checkAction) && !root.checkBusy
                availabilityReason: enabled ? "" : (root.checkBusy
                    ? "Đang kiểm tra tài nguyên"
                    : root.actionReason(root.checkAction,
                        "Không thể kiểm tra tài nguyên"))
                Accessible.name: text
                Accessible.description: enabled
                    ? "Yêu cầu backend kiểm tra manifest và tính toàn vẹn tài nguyên"
                    : availabilityReason
                onClicked: root.actionRequested(root.checkAction)
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.preferredWidth: parent.width
            Layout.maximumWidth: parent.width
            Layout.preferredHeight: 24
            spacing: 8
            Repeater {
                model: root.compactColumns ? [
                    {"key": "name", "label": "Thành phần", "fill": true, "width": 0},
                    {"key": "installed", "label": "Phiên bản", "fill": false,
                        "width": root.installedColumnWidth},
                    {"key": "source", "label": "Nguồn cài", "fill": false,
                        "width": root.sourceColumnWidth},
                    {"key": "integrity", "label": "Trạng thái", "fill": false,
                        "width": root.integrityColumnWidth},
                    {"key": "actions", "label": "Thao tác", "fill": false,
                        "width": root.actionsColumnWidth}
                ] : [
                    {"key": "name", "label": "Thành phần", "fill": true, "width": 0},
                    {"key": "installed", "label": "Đã cài", "fill": false,
                        "width": root.installedColumnWidth},
                    {"key": "available", "label": "Có sẵn", "fill": false,
                        "width": root.availableColumnWidth},
                    {"key": "source", "label": "Nguồn cài", "fill": false,
                        "width": root.sourceColumnWidth},
                    {"key": "size", "label": "Dung lượng", "fill": false,
                        "width": root.sizeColumnWidth},
                    {"key": "integrity", "label": "Trạng thái", "fill": false,
                        "width": root.integrityColumnWidth},
                    {"key": "actions", "label": "Thao tác", "fill": false,
                        "width": root.actionsColumnWidth}
                ]
                delegate: Text {
                    required property var modelData
                    objectName: "resourceHeader_" + String(modelData.key)
                    Layout.fillWidth: modelData.fill === true
                    Layout.minimumWidth: modelData.fill === true ? 0 : Number(modelData.width)
                    Layout.preferredWidth: modelData.fill === true ? 180 : Number(modelData.width)
                    Layout.maximumWidth: modelData.fill === true ? Infinity : Number(modelData.width)
                    Layout.fillHeight: true
                    text: String(modelData.label)
                    color: Theme.textFaint
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    horizontalAlignment: ["size", "integrity", "actions"].indexOf(
                        String(modelData.key)) >= 0 ? Text.AlignHCenter : Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.preferredWidth: parent.width
            Layout.maximumWidth: parent.width
            spacing: 0
            visible: root.resourceModel && root.resourceModel.count > 0
            Repeater {
                model: root.resourceModel
                delegate: Item {
                    id: resourceRow
                    required property string resource_id
                    required property string name
                    required property var installed_version
                    required property var available_version
                    required property var source
                    required property var channel
                    required property var size_bytes
                    required property string integrity
                    required property var manage_permission
                    required property var icon_key
                    required property var state_descriptor
                    required property var actions
                    objectName: "resourceRow_" + resourceRow.resource_id
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.preferredWidth: parent.width
                    Layout.maximumWidth: parent.width
                    Layout.preferredHeight: 40
                    readonly property bool busy: root.resourceBusy(resourceRow.resource_id)
                    readonly property var updateAction: (resourceRow.actions || {}).update || ({})
                    readonly property var detailsAction: (resourceRow.actions || {}).details || ({})
                    readonly property string integrityLabel: String(
                        (resourceRow.state_descriptor || {}).label || "Không rõ")
                    readonly property color integrityTone: {
                        const tone = String((resourceRow.state_descriptor || {}).tone_key || "warning")
                        if (tone === "success") return Theme.success
                        if (tone === "danger") return Theme.danger
                        if (tone === "info") return Theme.info
                        return Theme.warning
                    }
                    Accessible.name: String(resourceRow.name || resourceRow.resource_id || "Tài nguyên")
                        + ", phiên bản " + String(resourceRow.installed_version || "không rõ")
                        + ", toàn vẹn " + integrityLabel
                    Accessible.role: Accessible.Row

                    RowLayout {
                        anchors.fill: parent
                        spacing: 8
                        Text {
                            objectName: "resourceCell_" + resourceRow.resource_id + "_name"
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: 180
                            Layout.fillHeight: true
                            text: String(resourceRow.name || resourceRow.resource_id || "—")
                            color: Theme.text
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            readonly property bool labelTruncated: truncated
                        }
                        Text {
                            objectName: "resourceCell_" + resourceRow.resource_id + "_installed"
                            Layout.minimumWidth: root.installedColumnWidth
                            Layout.preferredWidth: root.installedColumnWidth
                            Layout.maximumWidth: root.installedColumnWidth
                            Layout.fillHeight: true
                            text: root.compactColumns
                                ? root.compactVersionLabel(
                                    resourceRow.installed_version,
                                    resourceRow.available_version)
                                : root.versionLabel(resourceRow.installed_version)
                            color: Theme.textMuted
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            readonly property bool labelTruncated: truncated
                        }
                        Text {
                            objectName: "resourceCell_" + resourceRow.resource_id + "_available"
                            visible: !root.compactColumns
                            Layout.minimumWidth: root.availableColumnWidth
                            Layout.preferredWidth: root.availableColumnWidth
                            Layout.maximumWidth: root.availableColumnWidth
                            Layout.fillHeight: true
                            text: root.availableVersionLabel(
                                resourceRow.resource_id, resourceRow.available_version)
                            color: resourceRow.available_version ? Theme.textMuted : Theme.warning
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            readonly property bool labelTruncated: truncated
                        }
                        Text {
                            objectName: "resourceCell_" + resourceRow.resource_id + "_source"
                            Layout.minimumWidth: root.sourceColumnWidth
                            Layout.preferredWidth: root.sourceColumnWidth
                            Layout.maximumWidth: root.sourceColumnWidth
                            Layout.fillHeight: true
                            text: root.sourceSummary(resourceRow.source, resourceRow.channel)
                            color: Theme.textMuted
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            readonly property bool labelTruncated: truncated
                        }
                        Text {
                            objectName: "resourceCell_" + resourceRow.resource_id + "_size"
                            visible: !root.compactColumns
                            Layout.minimumWidth: root.sizeColumnWidth
                            Layout.preferredWidth: root.sizeColumnWidth
                            Layout.maximumWidth: root.sizeColumnWidth
                            Layout.fillHeight: true
                            text: {
                                const bytes = Number(resourceRow.size_bytes)
                                return Number.isFinite(bytes) && bytes >= 0 ? (bytes / 1024 / 1024).toFixed(1) + " MB" : "—"
                            }
                            color: Theme.textMuted
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            readonly property bool labelTruncated: truncated
                        }
                        Foundation.StatusPill {
                            objectName: "resourceCell_" + resourceRow.resource_id + "_integrity"
                            Layout.minimumWidth: root.integrityColumnWidth
                            Layout.preferredWidth: root.integrityColumnWidth
                            Layout.maximumWidth: root.integrityColumnWidth
                            Layout.alignment: Qt.AlignVCenter
                            text: resourceRow.integrityLabel
                            tone: resourceRow.integrityTone
                            showDot: true
                        }
                        RowLayout {
                            objectName: "resourceCell_" + resourceRow.resource_id + "_actions"
                            Layout.minimumWidth: root.actionsColumnWidth
                            Layout.preferredWidth: root.actionsColumnWidth
                            Layout.maximumWidth: root.actionsColumnWidth
                            Layout.fillHeight: true
                            spacing: 4
                            AppButton {
                                id: updateButton
                                objectName: "resourceUpdateButton_" + resourceRow.resource_id
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                Layout.alignment: Qt.AlignVCenter
                                text: resourceRow.busy ? "Đang xử lý…" : "Kiểm tra"
                                activeFocusOnTab: true
                                visible: String(resourceRow.updateAction.capability || "").length > 0
                                enabled: !resourceRow.busy
                                    && root.actionAvailable(resourceRow.updateAction)
                                availabilityReason: enabled ? "" : (resourceRow.busy
                                    ? "Đang xử lý tài nguyên"
                                    : root.actionReason(resourceRow.updateAction,
                                        "Không thể cập nhật tài nguyên"))
                                Accessible.name: text + " cập nhật " + String(resourceRow.name || resourceRow.resource_id || "tài nguyên")
                                Accessible.description: enabled
                                    ? "Yêu cầu backend kiểm tra hoặc cập nhật tài nguyên này"
                                    : availabilityReason
                                onClicked: root.actionRequested(resourceRow.updateAction)
                            }
                            Item {
                                Layout.fillWidth: !updateButton.visible
                                Layout.preferredWidth: 0
                            }
                            Foundation.IconButton {
                                objectName: "resourceOverflowButton_" + resourceRow.resource_id
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                Layout.alignment: Qt.AlignVCenter
                                iconName: "ui/more-horizontal"
                                text: ""
                                accessibleName: "Tùy chọn " + String(resourceRow.name || resourceRow.resource_id || "tài nguyên")
                                activeFocusOnTab: true
                                enabled: root.actionAvailable(resourceRow.detailsAction)
                                Accessible.description: enabled ? ""
                                    : root.actionReason(resourceRow.detailsAction,
                                        "Chi tiết tài nguyên không khả dụng")
                                onClicked: root.deepLinkRequested(
                                    resourceRow.detailsAction.deep_link || ({}))
                            }
                        }
                    }

                    Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 1; color: Theme.borderSoft }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            visible: !root.resourceModel || root.resourceModel.count === 0
            Accessible.name: "Không có projection tài nguyên"
            Accessible.role: Accessible.StaticText
            Text {
                anchors.centerIn: parent
                text: "Không có dữ liệu tài nguyên từ backend"
                color: Theme.warning
                font.pixelSize: 12
            }
        }
    }
}
