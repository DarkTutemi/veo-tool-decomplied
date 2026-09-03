import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Button {
    id: control
    property bool primary: false
    property bool subtle: false
    // Keeps fixture screenshots visually representative without granting the
    // underlying Button an executable state. `enabled` remains the only input
    // Qt uses for click/key delivery.
    property bool visualEnabled: control.enabled
    property string availabilityReason: ""
    property string leadingIcon: ""
    property string trailingIcon: ""
    property color textTone: !control.visualEnabled
        ? Theme.textFaint : control.primary ? "white" : Theme.textMuted
    property color iconTone: control.visualEnabled
        ? (control.primary ? "white" : Theme.textMuted) : Theme.textFaint
    property int iconSize: 16
    readonly property bool leadingIconReady: control.leadingIcon.length === 0
        || leadingGraphic.sourceReady
    readonly property bool trailingIconReady: control.trailingIcon.length === 0
        || trailingGraphic.sourceReady

    implicitHeight: 40
    leftPadding: 16
    rightPadding: 16
    font.pixelSize: 13
    font.weight: Font.DemiBold
    hoverEnabled: true
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.description: availabilityReason

    contentItem: RowLayout {
        spacing: 7
        UiIcon {
            id: leadingGraphic
            objectName: control.objectName.length > 0
                ? control.objectName + "LeadingIcon" : ""
            visible: control.leadingIcon.length > 0
            name: control.leadingIcon
            tone: control.iconTone
            iconSize: control.iconSize
            Layout.preferredWidth: visible ? control.iconSize : 0
            Layout.preferredHeight: control.iconSize
        }
        Text {
            Layout.fillWidth: true
            text: control.text
            color: control.textTone
            font: control.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        UiIcon {
            id: trailingGraphic
            objectName: control.objectName.length > 0
                ? control.objectName + "TrailingIcon" : ""
            visible: control.trailingIcon.length > 0
            name: control.trailingIcon
            tone: control.iconTone
            iconSize: control.iconSize
            Layout.preferredWidth: visible ? control.iconSize : 0
            Layout.preferredHeight: control.iconSize
        }
    }

    background: Rectangle {
        radius: Theme.radiusSmall
        color: !control.visualEnabled
            ? Theme.elevated
            : control.primary
            ? (control.down ? Qt.darker(Theme.accent, 1.12) : Theme.accent)
            : (control.hovered ? Theme.hover : (control.subtle ? "transparent" : Theme.elevated))
        border.width: control.primary || control.subtle ? 0 : 1
        border.color: Theme.border
    }
}
