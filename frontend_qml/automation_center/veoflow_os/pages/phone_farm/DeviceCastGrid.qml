pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation
import "../../components/device" as Device

Panel {
    id: root
    objectName: "deviceCastGrid"
    property var selectedDevice: ({})
    readonly property string selectedDeviceId: String(
        (root.selectedDevice || {}).deviceId || ""
    )
    property bool canOperateSelected: false
    property bool visualProductionFixture: false
    property var visualFixture: ({})
    clip: true
    color: Theme.panel
    readonly property bool authorizedCastSurfaceAvailable: false
    readonly property bool demoPosterAvailable: root.hasDemoPoster()
    readonly property real commandRailCellHeight: Math.max(
        0,
        (commandRail.height - commandRail.spacing * 10) / 11
    )
    signal deviceSelected(string deviceId)
    signal screenshotRequested()
    signal castMenuRequested(string deviceId)
    Accessible.name: "Lưới màn hình trực tiếp; decoder luồng QML chưa khả dụng"
    Accessible.role: Accessible.Pane

    function statusProvenance(statuses, fallback) {
        const source = String(((statuses || {}).provenance || {}).source || fallback || "")
            .toLowerCase()
        const simulated = Boolean(((statuses || {}).provenance || {}).simulated)
        return simulated || ["demo_seed", "demo_only", "simulated"].indexOf(source) >= 0
            ? "demo_seed" : "production"
    }

    function codecAuthoritative(castStatus, provenance, visualFixture) {
        if (provenance !== "production" && !visualFixture) return false
        const state = String((castStatus || {}).state || "").toLowerCase()
        const evidence = String((castStatus || {}).liveEvidenceState || "").toLowerCase()
        const codec = String((castStatus || {}).codec || "").trim()
        return codec.length > 0
            && ["ready", "streaming", "connected"].indexOf(state) >= 0
            && (visualFixture
                || ["reported", "verified"].indexOf(evidence) >= 0)
    }

    function castTone(value, provenance, visualFixture) {
        if (provenance !== "production" && !visualFixture) return Theme.accent
        const state = String(value || "unknown").toLowerCase()
        if (["ready", "streaming", "connected"].indexOf(state) >= 0)
            return Theme.success
        if (["attention", "degraded", "stale"].indexOf(state) >= 0)
            return Theme.warning
        return Theme.textFaint
    }

    function hasDemoPoster() {
        const source = (root.selectedDevice || {}).visualSource || ({})
        return String(source.kind || "") === "demo_poster"
            && Boolean(source.isDemo)
    }

    function demoPosterUrl(visualSource) {
        const source = visualSource || ({})
        const key = String(source.posterKey || "")
        const allowed = [
            "garden-creator",
            "mountain-route",
            "creator-products",
            "waterfall-travel"
        ]
        if (String(source.kind || "") !== "demo_poster"
                || String(source.provenance || "") !== "demo_seed"
                || !Boolean(source.isDemo) || allowed.indexOf(key) < 0)
            return ""
        return Qt.resolvedUrl("../../assets/demo/phone_farm/" + key + ".jpg")
    }

    component RailActionButton: Button {
        id: railButton
        property string iconName: ""
        property int railIndex: 0
        property bool visualActive: false
        property color visualTone: Theme.text
        readonly property int railIconSize: root.visualProductionFixture ? 21 : 19
        readonly property int railLabelSize: 9
        readonly property int railRestingBorderWidth:
            root.visualProductionFixture ? 1 : 0

        x: 2
        y: railButton.railIndex * (root.commandRailCellHeight + commandRail.spacing)
        width: 50
        height: root.commandRailCellHeight
        implicitWidth: 50
        implicitHeight: root.commandRailCellHeight
        padding: 0
        clip: true
        activeFocusOnTab: true
        Accessible.name: railButton.text
        Accessible.role: Accessible.Button

        background: Rectangle {
            objectName: "railButtonBackground"
            readonly property real outlineWidth: border.width
            radius: 5
            color: railButton.enabled && (railButton.down || railButton.hovered)
                ? Theme.accentSoft
                : railButton.visualActive ? Theme.elevated
                : Qt.rgba(Theme.elevated.r, Theme.elevated.g, Theme.elevated.b, 0.58)
            border.width: railButton.activeFocus ? 1
                : railButton.railRestingBorderWidth
            border.color: railButton.activeFocus ? Theme.accent
                : root.visualProductionFixture ? Theme.borderSoft : Theme.accent
        }

        contentItem: Item {
            UiIcon {
                objectName: "railActionIcon"
                x: (parent.width - width) / 2
                y: 4
                name: railButton.iconName
                tone: railButton.visualActive ? railButton.visualTone
                    : railButton.enabled ? Theme.text : Theme.textMuted
                iconSize: railButton.railIconSize
            }
            Text {
                objectName: "railActionLabel"
                x: 2
                y: 25
                width: Math.max(0, parent.width - 4)
                height: 16
                text: railButton.text
                color: railButton.visualActive ? railButton.visualTone
                    : railButton.enabled ? Theme.text : Theme.textMuted
                font.pixelSize: railButton.railLabelSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        RowLayout {
            objectName: "castHeaderRow"
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Text {
                objectName: "castHeaderTitle"
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: "Màn hình trực tiếp"
                color: Theme.text
                font.pixelSize: 15
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
            Foundation.StatusPill {
                objectName: "castSurfaceStatus"
                Layout.fillWidth: false
                Layout.minimumWidth: 0
                Layout.maximumWidth: 128
                Layout.preferredWidth: Math.min(implicitWidth, 128)
                visible: !root.visualProductionFixture
                text: root.demoPosterAvailable
                    ? "Decoder chưa có" : "Decoder bridge chưa có"
                tone: Theme.warning
                showDot: true
                clip: true
            }
        }

        Item {
            id: liveControlBody
            objectName: "selectedLiveControlBody"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 320

            Item {
                id: liveControlStage
                anchors.centerIn: parent
                width: Math.min(parent.width, 338)
                height: parent.height

                Button {
                    id: castTile
                    readonly property int index: 0
                    readonly property var record: root.selectedDevice || ({})
                    readonly property string deviceId: String(record.deviceId || "")
                    readonly property var label: record.label
                    readonly property var handle: record.handle
                    readonly property var foreground: record.foreground
                    readonly property var relayState: record.relayState
                    readonly property var castState: record.castState
                    readonly property var latencyMs: record.latencyMs
                    readonly property var visualSource: record.visualSource || ({})
                    readonly property var presentationProvenance:
                        record.presentationProvenance
                    readonly property var microStatuses: record.microStatuses || ({})
                    objectName: "castTile_" + String(castTile.deviceId || index)
                    readonly property var statusData: castTile.microStatuses || ({})
                    readonly property var networkStatus: statusData.network || ({})
                    readonly property var castStatus: statusData.cast || ({})
                    readonly property bool visualProductionFixture: Boolean(
                        statusData.visual_production_fixture
                    )
                    readonly property string statusProvenance: root.statusProvenance(
                        statusData, castTile.presentationProvenance
                    )
                    readonly property int qualityBars: Number(
                        castTile.castStatus.qualityLevel === undefined
                            ? (castTile.networkStatus.qualityLevel === undefined
                                ? -1 : castTile.networkStatus.qualityLevel)
                            : castTile.castStatus.qualityLevel
                    )
                    readonly property string qualityState: String(
                        castTile.networkStatus.qualityState || "unknown"
                    )
                    readonly property url posterUrl: root.demoPosterUrl(castTile.visualSource)
                    property string surfaceState: String(posterUrl).length > 0
                        ? "demo_poster" : "unavailable"
                    visible: root.selectedDeviceId.length > 0
                    x: 0
                    y: 0
                    width: Math.min(
                        276,
                        Math.max(180, liveControlStage.width - 62)
                    )
                    height: liveControlStage.height
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    activeFocusOnTab: true
                    Accessible.name: "Cast " + String(castTile.label || castTile.deviceId || "thiết bị")
                    Accessible.description: castTile.visualProductionFixture
                        ? "Fixture production mô phỏng từ demo_seed; codec "
                            + String(castTile.castStatus.codecLabel || "không rõ")
                            + "; không phải bằng chứng relay hoặc decoder trực tiếp."
                        : surfaceState === "demo_poster"
                        ? "Poster DEMO được bundle cục bộ; không có relay, codec hoặc cast trực tiếp."
                        : "Relay " + String(castTile.relayState || "không rõ")
                            + ", cast " + String(castTile.castState || "không rõ")
                            + ". Khung hình không khả dụng vì chưa có decoder bridge được ủy quyền."
                    onClicked: root.deviceSelected(String(castTile.deviceId || ""))

                    contentItem: Item {
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 0
                            spacing: 0
                            Rectangle {
                                objectName: "selectedCastViewport"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                readonly property int outlineWidth: border.width
                                readonly property int contentInset: 0
                                radius: Theme.radiusSmall
                                color: "transparent"
                                border.width: 0
                                border.color: "transparent"
                                clip: true
                                Image {
                                    id: poster
                                    objectName: "castPoster_" + String(castTile.deviceId || castTile.index)
                                    readonly property string displayFitMode:
                                        castTile.visualProductionFixture
                                            ? "crop" : "fit"
                                    anchors.fill: parent
                                    source: castTile.posterUrl
                                    visible: castTile.surfaceState === "demo_poster"
                                    fillMode: displayFitMode === "crop"
                                        ? Image.PreserveAspectCrop
                                        : Image.PreserveAspectFit
                                    clip: displayFitMode === "crop"
                                    asynchronous: true
                                    cache: true
                                    Accessible.name: "Poster demo cho " + String(castTile.label || castTile.deviceId)
                                    Accessible.description: "Nguồn demo_seed; không phải video hoặc cast trực tiếp"
                                    Accessible.role: Accessible.Graphic
                                }
                                Item {
                                    id: fixtureHud
                                    objectName: "castFixtureHud_"
                                        + String(castTile.deviceId || castTile.index)
                                    property bool interactive: false
                                    anchors.centerIn: poster
                                    width: castTile.visualProductionFixture
                                        ? poster.width : poster.paintedWidth
                                    height: castTile.visualProductionFixture
                                        ? poster.height : poster.paintedHeight
                                    visible: castTile.visualProductionFixture
                                        && castTile.surfaceState === "demo_poster"
                                    enabled: false
                                    z: 2
                                    Accessible.name: "HUD TikTok mô phỏng cho "
                                        + String(castTile.handle
                                            || castTile.label || castTile.deviceId)
                                    Accessible.description: "Fixture production không tương tác; nguồn demo_seed"
                                    Accessible.role: Accessible.Pane

                                    Column {
                                        objectName: "castFixtureHudActions_"
                                            + String(castTile.deviceId
                                                || castTile.index)
                                        anchors.right: parent.right
                                        anchors.rightMargin: 5
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.verticalCenterOffset: 8
                                        spacing: 7
                                        Repeater {
                                            model: [
                                                "device/account-link",
                                                "semantic/heart",
                                                "device/evidence",
                                                "ui/forward-10"
                                            ]
                                            delegate: Rectangle {
                                                id: hudAction
                                                required property int index
                                                required property string modelData
                                                width: 22
                                                height: 22
                                                radius: 11
                                                color: Qt.rgba(0, 0, 0, 0.42)
                                                border.width: 0
                                                UiIcon {
                                                    objectName: "castFixtureHudAction_"
                                                        + String(castTile.deviceId
                                                            || castTile.index)
                                                        + "_" + String(hudAction.index)
                                                    anchors.centerIn: parent
                                                    name: hudAction.modelData
                                                    tone: "white"
                                                    iconSize: 14
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: Math.min(62, parent.height * 0.38)
                                        gradient: Gradient {
                                            GradientStop { position: 0; color: "transparent" }
                                            GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.84) }
                                        }
                                    }
                                    ColumnLayout {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        anchors.leftMargin: 7
                                        anchors.rightMargin: 32
                                        anchors.bottomMargin: 6
                                        spacing: 2
                                        Text {
                                            objectName: "castFixtureHudHandle_"
                                                + String(castTile.deviceId
                                                    || castTile.index)
                                            Layout.fillWidth: true
                                            text: String(castTile.handle
                                                || castTile.label
                                                || castTile.deviceId || "—")
                                            color: "white"
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            objectName: "castFixtureHudCaption_"
                                                + String(castTile.deviceId
                                                    || castTile.index)
                                            Layout.fillWidth: true
                                            text: String(castTile.foreground
                                                || castTile.castStatus.resolution
                                                || castTile.castStatus.codecLabel
                                                || "—")
                                            color: Qt.rgba(1, 1, 1, 0.88)
                                            font.pixelSize: 8
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                                Rectangle {
                                    objectName: "castDemoBadge_" + String(castTile.deviceId || castTile.index)
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.margins: 8
                                    width: 52
                                    height: 22
                                    radius: 6
                                    color: Qt.rgba(0.43, 0.39, 0.95, 0.92)
                                    visible: false
                                    Text {
                                        anchors.centerIn: parent
                                        text: "DEMO"
                                        color: "white"
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                    }
                                }
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    width: Math.max(140, parent.width - 30)
                                    spacing: 5
                                    visible: castTile.surfaceState !== "demo_poster"
                                    Text { Layout.fillWidth: true; text: "Khung hình không khả dụng"; color: Theme.warning; font.pixelSize: 12; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter }
                                    Text { Layout.fillWidth: true; text: "Chưa có decoder bridge được ủy quyền"; color: Theme.textFaint; font.pixelSize: 11; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter }
                                }
                                Rectangle {
                                    id: telemetryBar
                                    objectName: "castTelemetryBar_"
                                        + String(castTile.deviceId || castTile.index)
                                    readonly property int outlineWidth: border.width
                                    readonly property real overlayOpacity: 0.58
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 30
                                    radius: 0
                                    z: 8
                                    color: Qt.rgba(0.04, 0.055, 0.075,
                                        telemetryBar.overlayOpacity)
                                    border.width: 0
                                    border.color: "transparent"
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 6
                                        Device.CodecBadge {
                                            objectName: "castCodec_"
                                                + String(castTile.deviceId || castTile.index)
                                            label: String(castTile.castStatus.codecLabel || "")
                                            tone: root.castTone(
                                                castTile.castStatus.state,
                                                castTile.statusProvenance,
                                                castTile.visualProductionFixture
                                            )
                                            status: String(castTile.castStatus.state || "unavailable")
                                            authoritative: root.codecAuthoritative(
                                                castTile.castStatus,
                                                castTile.statusProvenance,
                                                castTile.visualProductionFixture
                                            )
                                            provenance: castTile.statusProvenance
                                            visualProductionFixture: castTile.visualProductionFixture
                                            compact: true
                                            compactWidth: 48
                                            Layout.preferredWidth: 48
                                        }
                                        Text {
                                            objectName: "castFps_"
                                                + String(castTile.deviceId || castTile.index)
                                            Layout.fillWidth: true
                                            Layout.minimumWidth: 30
                                            text: castTile.castStatus.fps === null
                                                    || castTile.castStatus.fps === undefined
                                                ? "FPS —" : String(castTile.castStatus.fps) + " FPS"
                                                    + (castTile.networkStatus.rttMs !== null
                                                        && castTile.networkStatus.rttMs !== undefined
                                                        ? " · " + String(castTile.networkStatus.rttMs) + " ms"
                                                        : "")
                                            color: Qt.rgba(1, 1, 1, 0.86)
                                            font.pixelSize: 9
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }
                                        Device.SignalIndicator {
                                            objectName: "castSignal_"
                                                + String(castTile.deviceId || castTile.index)
                                            level: castTile.qualityBars
                                            latencyMs: castTile.networkStatus.rttMs
                                            status: String(castTile.networkStatus.state
                                                || castTile.qualityState || "unknown")
                                            sampleFresh: Boolean(castTile.networkStatus.isFresh)
                                            showBars: true
                                            showLatency: false
                                            provenance: castTile.statusProvenance
                                            compact: true
                                            showDemoBadge: false
                                        }
                                    }
                                }
                                Foundation.IconButton {
                                    objectName: "castOverflowButton_" + String(castTile.deviceId || castTile.index)
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 6
                                    z: 9
                                    width: 28
                                    height: 28
                                    text: ""
                                    iconName: "ui/more-vertical"
                                    accessibleName: "Tùy chọn cast " + String(castTile.label || castTile.deviceId || "thiết bị")
                                    activeFocusOnTab: true
                                    onClicked: root.castMenuRequested(String(castTile.deviceId || ""))
                                }
                            }
                        }
                    }
                    background: Rectangle {
                        id: castTileBackground
                        objectName: "castTileBackground_"
                            + String(castTile.deviceId || castTile.index)
                        readonly property bool fixtureSelected:
                            castTile.visualProductionFixture
                            && root.selectedDeviceId
                                === String(castTile.deviceId || "")
                        readonly property color fixtureTopTone: "transparent"
                        readonly property color fixtureBottomTone: "transparent"
                        radius: Theme.radiusSmall
                        clip: true
                        color: castTileBackground.fixtureSelected
                            ? castTileBackground.fixtureTopTone
                            : root.selectedDeviceId
                                === String(castTile.deviceId || "")
                            ? Theme.accentSoft : Theme.elevated
                        border.width: 0
                        border.color: "transparent"
                    }
                }
                Item {
                    id: commandRail
                    objectName: "castCommandRail"
                    x: castTile.width + 8
                    y: 0
                    width: 54
                    height: liveControlStage.height
                    property real spacing: 4

                    Repeater {
                        model: [
                            {"name": "phoneBackButton", "label": "Back", "icon": "ui/chevron-left"},
                            {"name": "phoneHomeButton", "label": "Home", "icon": "ui/home"},
                            {"name": "phoneRecentsButton", "label": "Recents", "icon": "ui/columns-3"},
                            {"name": "phoneRotateButton", "label": "Rotate", "icon": "ui/rotate-cw"}
                        ]
                        delegate: RailActionButton {
                            required property int index
                            required property var modelData
                            railIndex: index
                            objectName: String(modelData.name)
                            text: String(modelData.label)
                            iconName: String(modelData.icon)
                            enabled: false
                            visualActive: root.visualProductionFixture
                            Accessible.name: text
                            Accessible.description: "Không khả dụng khi chưa có interactive cast transport được ủy quyền"
                        }
                    }

                    RailActionButton {
                        railIndex: 4
                        objectName: "phoneScreenshotButton"
                        text: "Chụp"
                        iconName: "ui/camera"
                        enabled: root.canOperateSelected
                        visualActive: root.visualProductionFixture
                        Accessible.name: "Chụp ảnh màn hình qua lệnh semantic"
                        Accessible.description: enabled ? "Tạo device.screenshot.capture dưới lease hiện tại" : "Cần lease device.operate"
                        onClicked: root.screenshotRequested()
                    }

                    Repeater {
                        model: [
                            {"name": "phoneWakeButton", "label": "Wake", "icon": "ui/power"},
                            {"name": "phoneMicButton", "label": "Mic tắt", "icon": "ui/mic-off"},
                            {"name": "phoneAudioButton", "label": "Âm thanh", "icon": "ui/volume-2"},
                            {"name": "phoneFitButton", "label": "Fit", "icon": "ui/fit-screen"},
                            {"name": "phoneOneToOneButton", "label": "1:1", "icon": "semantic/smartphone"},
                            {"name": "phoneFullscreenButton", "label": "Toàn màn", "icon": "ui/maximize"}
                        ]
                        delegate: RailActionButton {
                            required property int index
                            required property var modelData
                            railIndex: index + 5
                            objectName: String(modelData.name)
                            text: root.visualProductionFixture
                                    && String(modelData.name) === "phoneMicButton"
                                ? "Mic TẮT" : String(modelData.label)
                            iconName: String(modelData.icon)
                            enabled: false
                            visualActive: root.visualProductionFixture
                            visualTone: root.visualProductionFixture
                                    && String(modelData.name) === "phoneMicButton"
                                ? Theme.danger : Theme.text
                            Accessible.name: text
                            Accessible.description: "Không khả dụng khi chưa có interactive cast transport được ủy quyền"
                        }
                    }
                }
            }

            Item {
                anchors.fill: parent
                visible: root.selectedDeviceId.length === 0
                Accessible.name: "Không có thiết bị được chọn cho màn hình cast"
                Accessible.role: Accessible.StaticText
                Text {
                    anchors.centerIn: parent
                    text: "Chọn một thiết bị để xem màn hình"
                    color: Theme.warning
                    font.pixelSize: 12
                }
            }
        }
    }
}
