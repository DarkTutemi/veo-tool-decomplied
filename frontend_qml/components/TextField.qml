import QtQuick
import QtQuick.Controls
import QtQuick.Controls as Controls

Controls.TextField {
    id: control

    ContextMenu.menu: VfTextEditingContextMenu {
        editor: control
    }
}
