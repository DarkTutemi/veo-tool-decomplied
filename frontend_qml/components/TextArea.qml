import QtQuick
import QtQuick.Controls
import QtQuick.Controls as Controls

Controls.TextArea {
    id: control

    ContextMenu.menu: VfTextEditingContextMenu {
        editor: control
    }
}
