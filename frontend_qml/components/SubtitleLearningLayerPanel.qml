pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root
    objectName: "subtitleLearningLayerPanel"

    property bool active: false
    property bool groupMoveActive: false
    property string selectedObject: "overlay"
    property string selectedStyle: "lemma"
    property var profile: ({})
    property var cue: ({})

    signal layerChosen(string objectId, string styleId)
    signal groupMoveChosen()

    readonly property var layers: [
        {
            key: "lemma",
            order: "1",
            label: qsTr("Từ / câu gốc"),
            objectId: "overlay",
            styleId: "lemma",
            sample: String((root.cue || {}).lemma || "HOT")
        },
        {
            key: "reading",
            order: "2",
            label: qsTr("Cách đọc / phiên âm"),
            objectId: "overlay",
            styleId: "reading",
            sample: String((root.cue || {}).reading || "/hɑːt/")
        },
        {
            key: "meaning",
            order: "3",
            label: qsTr("Nghĩa / bản dịch"),
            objectId: "caption",
            styleId: "spoken",
            sample: String((root.cue || {}).native_meaning
                || (root.cue || {}).caption || qsTr("Nghĩa của câu"))
        }
    ]

    function layerScale(objectId, styleId) {
        var objectData = (root.profile || {})[String(objectId)] || ({})
        var styles = objectData.styles || ({})
        var style = styles[String(styleId)] || ({})
        return Number(style.scale === undefined ? 1.0 : style.scale)
    }

    visible: active
    implicitHeight: active ? layerColumn.implicitHeight + VfTheme.dp(16) : 0
    radius: VfTheme.dp(9)
    color: VfTheme.surfaceSoft
    border.width: 1
    border.color: VfTheme.violetBorderSoft

    ColumnLayout {
        id: layerColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(5)

        Text {
            Layout.fillWidth: true
            text: qsTr("CHỌN ĐÚNG DÒNG ĐỂ CHỈNH")
            color: VfTheme.violetText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            font.weight: Font.Bold
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: qsTr("Chọn cả bộ để kéo chung; chọn từng dòng để tinh chỉnh riêng.")
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            wrapMode: Text.WordWrap
        }

        VfChip {
            objectName: "subtitleLearningGroupMoveTab"
            Layout.fillWidth: true
            minWidth: 0
            showLeadingIcon: false
            accent: VfTheme.violet
            fontPixelSize: VfTheme.fontSmall
            selected: root.groupMoveActive
            text: qsTr("KÉO CẢ BỘ 3 LỚP")
            tooltip: qsTr("Kéo khung chung trên canvas; vị trí riêng của từng dòng được giữ nguyên")
            onClicked: root.groupMoveChosen()
        }

        Repeater {
            model: root.layers

            delegate: VfChip {
                id: layerChip
                required property var modelData
                property string layerKey: String(modelData.key)

                objectName: "subtitleLearningLayerTab_" + layerKey
                Layout.fillWidth: true
                minWidth: 0
                showLeadingIcon: false
                accent: VfTheme.violet
                fontPixelSize: VfTheme.fontSmall
                selected: !root.groupMoveActive
                    && root.selectedObject === String(modelData.objectId)
                    && root.selectedStyle === String(modelData.styleId)
                text: String(modelData.order) + " · " + String(modelData.label)
                    + " · " + root.layerScale(modelData.objectId, modelData.styleId).toFixed(2)
                    + "×"
                tooltip: String(modelData.label) + " · " + String(modelData.sample)
                    + " · " + qsTr("Cỡ chữ %1×").arg(
                        root.layerScale(modelData.objectId, modelData.styleId).toFixed(2))
                    + " · " + qsTr("Có vị trí kéo riêng")
                onClicked: root.layerChosen(
                    String(layerChip.modelData.objectId),
                    String(layerChip.modelData.styleId))
            }
        }
    }
}
