pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
    id: control

    property string encodedDays: "0,1,2,3,4,5,6"
    property string availabilityReason: ""
    readonly property var dayLabels: ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
    readonly property string summaryText: control.selectedLabels().join(", ")
    signal encodedDaysEdited(string value)

    implicitHeight: 36
    Accessible.role: Accessible.Grouping
    Accessible.name: "Ngày áp dụng: " + control.summaryText
    Accessible.description: control.enabled
        ? "Chọn hoặc bỏ từng ngày trong tuần"
        : control.availabilityReason

    function selectedIndexes() {
        const parts = String(control.encodedDays || "").split(",")
        const result = []
        for (let index = 0; index < parts.length; ++index) {
            const value = Number(String(parts[index]).trim())
            if (Number.isInteger(value) && value >= 0 && value <= 6
                    && result.indexOf(value) < 0)
                result.push(value)
        }
        result.sort(function(left, right) { return left - right })
        return result
    }

    function selectedLabels() {
        const values = control.selectedIndexes()
        const labels = []
        for (let index = 0; index < values.length; ++index)
            labels.push(control.dayLabels[values[index]])
        return labels
    }

    function isSelected(dayIndex) {
        return control.selectedIndexes().indexOf(dayIndex) >= 0
    }

    function toggleDay(dayIndex) {
        if (!control.enabled)
            return false
        const values = control.selectedIndexes()
        const position = values.indexOf(dayIndex)
        if (position >= 0) {
            if (values.length === 1)
                return false
            values.splice(position, 1)
        } else {
            values.push(dayIndex)
            values.sort(function(left, right) { return left - right })
        }
        control.encodedDaysEdited(values.join(","))
        return true
    }

    RowLayout {
        anchors.fill: parent
        spacing: 6

        Repeater {
            model: 7
            delegate: Rectangle {
                id: dayButton
                required property int index
                readonly property bool selected: control.isSelected(dayButton.index)

                objectName: control.objectName + "_day_" + dayButton.index
                Layout.fillWidth: true
                Layout.minimumWidth: 34
                Layout.preferredHeight: 34
                radius: Theme.radiusSmall
                color: dayButton.selected ? Theme.accentSoft : Theme.elevated
                border.width: 1
                border.color: dayButton.selected ? Theme.accent : Theme.borderSoft
                opacity: control.enabled ? 1.0 : 0.55
                activeFocusOnTab: control.enabled
                Accessible.role: Accessible.CheckBox
                Accessible.name: control.dayLabels[dayButton.index]
                Accessible.checked: dayButton.selected
                Accessible.description: control.enabled
                    ? (dayButton.selected ? "Đang áp dụng" : "Không áp dụng")
                    : control.availabilityReason
                Keys.onReturnPressed: control.toggleDay(dayButton.index)
                Keys.onSpacePressed: control.toggleDay(dayButton.index)

                Text {
                    anchors.centerIn: parent
                    text: control.dayLabels[dayButton.index]
                    color: dayButton.selected ? Theme.accent : Theme.textMuted
                    font.pixelSize: 11
                    font.weight: dayButton.selected ? Font.DemiBold : Font.Normal
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: control.enabled
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: control.toggleDay(dayButton.index)
                }
            }
        }
    }
}
