import QtQuick
import QtQuick.Controls
import QtQuick.Controls as Controls

Controls.SpinBox {
    id: control

    contentItem: TextInput {
        clip: width < implicitWidth
        text: control.displayText
        opacity: control.enabled ? 1 : 0.3
        font: control.font
        color: control.palette.buttonText
        selectionColor: control.palette.highlight
        selectedTextColor: control.palette.highlightedText
        horizontalAlignment: control.mirrored ? Text.AlignRight : Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        readOnly: !control.editable
        selectByMouse: control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints

        ContextMenu.menu: VfTextEditingContextMenu {
            editor: parent
        }
    }
}
