import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string mediaId: ""
    property string originalPath: ""
    property string aspectRatio: "VIDEO_ASPECT_RATIO_LANDSCAPE"
    property string tierMode: "ultra"
    property bool isImageRequest: false
    property bool startEnabled: true
    property string dialogKind: "Video"
    property var basePayload: ({})
    property var resolutionModel: []
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal dryRunRequested(var payload)
    signal upscaleRequested(var payload)

    function localOptions() {
        if (root.isImageRequest)
            return [
                { label: "2K", value: "2k" },
                { label: "4K", value: "4k" }
            ]
        if (root.tierMode === "premium") {
            return [
                { label: "Upscale not available for Premium", value: "none" }
            ]
        }
        return [
            { label: "1080p (HD)", value: "1080p" },
            { label: "4K (Ultra HD)", value: "4k" }
        ]
    }

    function configureOptions(nextOptions) {
        if (nextOptions && nextOptions.resolutions)
            root.resolutionModel = nextOptions.resolutions
        else
            root.resolutionModel = root.localOptions()
        root.startEnabled = !(nextOptions && nextOptions.start_enabled === false)
        if (resolutionCombo)
            resolutionCombo.currentIndex = 0
    }

    function openFor(payload, nextOptions) {
        var request = payload || ({})
        root.basePayload = request
        root.mediaId = String(request.media_id || request.mediaId || "")
        root.originalPath = String(request.original_path || request.originalPath || "")
        root.aspectRatio = String(request.aspect_ratio || request.aspectRatio || "VIDEO_ASPECT_RATIO_LANDSCAPE")
        root.tierMode = String(request.tier_mode || request.tierMode || "ultra").toLowerCase()
        root.isImageRequest = Boolean(request.is_image || request.image_upscale || request.asset_type === "image")
        root.dialogKind = root.isImageRequest ? "Image" : "Video"
        root.statusText = ""
        root.feedbackTitle = ""
        root.feedbackMessage = ""
        root.configureOptions(nextOptions)
        root.open()
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || "")
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function resultMessage(payload, fallbackMessage) {
        var result = payload && typeof payload === "object" ? payload : ({})
        var blocker = result.blocker && typeof result.blocker === "object" ? result.blocker : ({})
        var validation = result.validation && typeof result.validation === "object" ? result.validation : ({})
        var errors = Array.isArray(validation.errors) ? validation.errors : []
        var firstError = errors.length > 0 && errors[0] && typeof errors[0] === "object"
            ? String(errors[0].message || errors[0].code || "")
            : ""
        return String(
            result.message
            || blocker.message
            || result.error
            || result.code
            || firstError
            || fallbackMessage
            || "Re-upscale request failed."
        )
    }

    function applyResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok || payload.accepted === false) {
            var failure = root.resultMessage(payload, "Re-upscale request failed.")
            root.statusText = failure
            root.showFeedback((void i18n.revision, i18n.t("extend.reupscale_blocked", "Re-Upscale blocked")), failure)
            return false
        }

        var success = root.resultMessage(payload, "Re-upscale request accepted.")
        root.statusText = success
        if (payload.dry_run)
            return true
        root.accept()
        return true
    }

    function selectedResolution() {
        if (resolutionCombo.currentIndex < 0 || resolutionCombo.currentIndex >= root.resolutionModel.length)
            return "1080p"
        var item = root.resolutionModel[resolutionCombo.currentIndex]
        return String(item.value || item || "1080p")
    }

    function requestPayload() {
        var payload = {}
        var base = root.basePayload || ({})
        for (var key in base)
            payload[key] = base[key]
        payload.media_id = root.mediaId
        payload.resolution = root.selectedResolution()
        payload.original_path = root.originalPath
        payload.aspect_ratio = root.aspectRatio
        payload.tier_mode = root.tierMode
        payload.is_image = root.isImageRequest
        return payload
    }

    title: root.isImageRequest ? "Upscale Image" : "Re-Upscale Video"
    header: null
    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 437, 48)
    height: VfDialogMetrics.height(parent, root.originalPath ? 340 : 304, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(25)
        spacing: VfTheme.dp(12)

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(29)
            color: VfTheme.surfaceSoft

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(8)
                anchors.rightMargin: VfTheme.dp(8)
                spacing: VfTheme.dp(10)

                VfAppIcon {
                    name: "red-triangle"
                    size: VfTheme.dp(13)
                    framed: false
                    color: "#EC4899"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: root.isImageRequest ? "Upscale Image" : "Re-Upscale Video"
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(20)
                    font.weight: VfTheme.weightTitle
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: VfTheme.textMuted
        }

        Text {
            Layout.fillWidth: true
            text: "Resolution:"
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
        }

        NoScrollComboBox {
            id: resolutionCombo
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(45)
            model: root.resolutionModel
            textRole: "label"
            valueRole: "value"
            enabled: root.startEnabled && root.tierMode !== "premium"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(6)
            visible: root.originalPath.length > 0

            Text {
                Layout.fillWidth: true
                text: "Overwrite file:"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
            }

            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(42)
                text: root.originalPath
                readOnly: true
                selectByMouse: true
                color: VfTheme.amberText
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: VfTheme.amberFill
                    border.color: "#F59E0B"
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: root.originalPath.length === 0
            spacing: VfTheme.dp(8)

            VfAppIcon {
                name: "red-triangle"
                size: VfTheme.dp(12)
                framed: false
                color: "#F59E0B"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                Layout.fillWidth: true
                text: "No original file path - will save to default output folder"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                elide: Text.ElideRight
            }
        }

        Item { Layout.preferredHeight: VfTheme.dp(8) }

        Text {
            Layout.fillWidth: true
            visible: root.statusText.length > 0
            text: root.statusText
            color: VfTheme.amberText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(16)

            Item { Layout.fillWidth: true }

            VfButton {
                text: "Cancel"
                minWidth: VfTheme.dp(100)
                implicitHeight: VfTheme.dp(45)
                onClicked: root.reject()
            }

            VfButton {
                text: "Start Upscale"
                tone: "accent"
                minWidth: VfTheme.dp(188)
                implicitHeight: VfTheme.dp(45)
                enabled: root.startEnabled && root.mediaId.length > 0 && root.tierMode !== "premium" && root.selectedResolution() !== "none"
                onClicked: {
                    var payload = root.requestPayload()
                    root.upscaleRequested(payload)
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: "OK"
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }

    Component.onCompleted: root.configureOptions()
}
