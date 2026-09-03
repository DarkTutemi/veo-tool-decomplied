import QtQuick
import QtQuick.Controls
import "../.."

SpinBox {
    id: control
    property int displayDivisor: 1
    property string unitSuffix: ""

    function formattedValue(rawValue, locale) {
        const divisor = Math.max(1, control.displayDivisor)
        const shown = Math.round(Number(rawValue) / divisor)
        const numberText = Number(shown).toLocaleString(locale, "f", 0)
        return control.unitSuffix.length > 0
            ? numberText + " " + control.unitSuffix : numberText
    }

    function rawValueFromText(text) {
        const digits = String(text || "").replace(/[^0-9-]/g, "")
        const shown = Number(digits || 0)
        return Math.round(shown * Math.max(1, control.displayDivisor))
    }

    textFromValue: function(rawValue, locale) {
        return control.formattedValue(rawValue, locale)
    }
    valueFromText: function(text, locale) {
        return control.rawValueFromText(text)
    }
    implicitHeight: 34
    font.pixelSize: 11
    contentItem: TextInput {
        z: 2
        text: control.textFromValue(control.value, control.locale)
        color: control.enabled ? Theme.text : Theme.textFaint
        selectionColor: Theme.accent
        selectedTextColor: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: Qt.ImhFormattedNumbersOnly
    }
    up.indicator: Rectangle {
        x: control.width - width
        y: 1
        width: 24
        height: control.height / 2 - 1
        color: control.up.pressed ? Theme.hover : "transparent"
        UiIcon { anchors.centerIn: parent; name: "ui/plus"; tone: Theme.textFaint; iconSize: 10 }
    }
    down.indicator: Rectangle {
        x: control.width - width
        y: control.height / 2
        width: 24
        height: control.height / 2 - 1
        color: control.down.pressed ? Theme.hover : "transparent"
        UiIcon { anchors.centerIn: parent; name: "ui/minus"; tone: Theme.textFaint; iconSize: 10 }
    }
    background: Rectangle {
        radius: Theme.radiusSmall
        color: Theme.elevated
        border.width: 1
        border.color: control.activeFocus ? Theme.accent : Theme.borderSoft
    }
}
