import QtQuick
import "../.."

Item {
    id: root
    objectName: "deviceAvatar"

    property string deviceId: ""
    property string label: ""
    property string healthState: "unknown"
    property bool selected: false
    property bool hasActiveOperation: false
    property string leaseState: "none"
    property string provenance: "production"
    property bool visualProductionFixture: false
    property int avatarSize: 46
    property bool showDemoBadge: true

    readonly property string effectiveHealth: StatusCatalog.normalize(root.healthState)
    readonly property bool isDemo: StatusCatalog.isDemoProvenance(root.provenance)
    readonly property color statusTone: StatusCatalog.tone(root.effectiveHealth)
    // Measured from the approved 1920x1080 Phone Farm reference crop.  The
    // avatar is a device silhouette, not another selected-state card.
    readonly property int phoneFrameWidth: 24
    readonly property int phoneFrameHeight: 48
    readonly property int phoneBorderWidth: 1

    implicitWidth: root.avatarSize
    implicitHeight: root.avatarSize
    Accessible.name: (root.label || root.deviceId || "Thiết bị") + ", "
        + StatusCatalog.label(root.effectiveHealth)
        + (root.isDemo ? ", dữ liệu DEMO" : "")
        + (root.hasActiveOperation ? ", đang có tác vụ" : "")
    Accessible.role: Accessible.Graphic

    Rectangle {
        id: phoneFrame
        objectName: "deviceAvatarFrame"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 2
        width: root.phoneFrameWidth
        height: root.phoneFrameHeight
        radius: 3
        color: Theme.base
        border.width: root.phoneBorderWidth
        border.color: root.statusTone
        antialiasing: true

        Rectangle {
            id: phoneScreen
            objectName: "deviceAvatarScreen"
            anchors.fill: parent
            anchors.margins: 2
            radius: 2
            color: root.visualProductionFixture
                ? Theme.elevated : Qt.darker(root.statusTone, 7.0)
        }

        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 0
            width: 14
            height: 2
            radius: 1
            color: root.statusTone
        }

        Rectangle {
            id: healthMark
            objectName: "deviceAvatarHealthMark"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            width: 7
            height: 7
            radius: 1
            rotation: 45
            color: root.statusTone
            antialiasing: true
        }
    }

    // Operation state remains part of the semantic/a11y contract.  The
    // approved avatar has one health mark, so a second floating dot would add
    // visual noise and duplicate the operation indicators elsewhere in-row.
    Item {
        objectName: "deviceAvatarOperationMark"
        visible: false
    }

    Rectangle {
        objectName: "deviceAvatarDemoBadge"
        visible: root.showDemoBadge && root.isDemo
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 1
        anchors.topMargin: 1
        width: 20
        height: 14
        radius: 3
        color: Theme.accentSoft
        border.width: 1
        border.color: Theme.accent
        Text {
            objectName: "deviceAvatarDemoBadgeLabel"
            anchors.centerIn: parent
            text: "D"
            color: Theme.accent
            font.pixelSize: 11
            font.weight: Font.Bold
        }
    }
}
