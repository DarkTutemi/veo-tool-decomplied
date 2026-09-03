import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Item {
    id: root

    property bool showClone: true
    property bool showSpeed: true
    property bool horizontal: false
    property string gender: "female"
    property string language: ""
    property string age: ""
    property string pitch: ""
    property real speed: 1.0
    property string refAudio: ""
    property string refText: ""
    property var languageOptions: [
        { label: "Auto", value: "" },
        { label: "Vietnamese", value: "vi" },
        { label: "Japanese", value: "ja" },
        { label: "Korean", value: "ko" },
        { label: "English", value: "en" },
        { label: "Chinese", value: "zh" },
        { label: "Spanish", value: "es" },
        { label: "French", value: "fr" },
        { label: "German", value: "de" }
    ]
    property var ageOptions: [
        { label: "(auto)", value: "" },
        { label: "child", value: "child" },
        { label: "teenager", value: "teenager" },
        { label: "young adult", value: "young adult" },
        { label: "middle-aged", value: "middle-aged" },
        { label: "elderly", value: "elderly" }
    ]
    property var pitchOptions: [
        { label: "(auto)", value: "" },
        { label: "very low pitch", value: "very low pitch" },
        { label: "low pitch", value: "low pitch" },
        { label: "moderate pitch", value: "moderate pitch" },
        { label: "high pitch", value: "high pitch" },
        { label: "very high pitch", value: "very high pitch" }
    ]

    signal configChanged(var config)
    signal browseReferenceRequested()

    Layout.fillWidth: true
    implicitHeight: root.horizontal && !root.showClone ? 28 : configColumn.implicitHeight

    function optionIndex(options, value) {
        var items = options || []
        for (var i = 0; i < items.length; i++) {
            if (String(items[i].value) === String(value))
                return i
        }
        return items.length > 0 ? 0 : -1
    }

    function currentConfig() {
        return {
            instruct: root.refAudio.length > 0 ? "" : root.buildInstruct(),
            ref_audio: root.refAudio.length > 0 ? root.refAudio : null,
            ref_text: root.refText.length > 0 ? root.refText : null,
            language: root.language.length > 0 ? root.language : null,
            speed: root.speed
        }
    }

    function buildInstruct() {
        var parts = [root.gender]
        if (root.age.length > 0)
            parts.push(root.age)
        if (root.pitch.length > 0)
            parts.push(root.pitch)
        if (root.language.length > 0)
            parts.push(root.language + " language")
        return parts.join(", ")
    }

    function emitConfigChanged() {
        root.configChanged(root.currentConfig())
    }

    component FieldLabel: Text {
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(9)
        font.weight: VfTheme.weightStrong
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    component MiniCombo: ComboBox {
        id: combo

        property var options: []
        property var selectedValue: ""
        signal selected(var value)

        Layout.preferredHeight: VfTheme.dp(24)
        Layout.minimumWidth: VfTheme.dp(90)
        model: options || []
        textRole: "label"
        valueRole: "value"
        currentIndex: root.optionIndex(options, selectedValue)
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(10)
        onActivated: selected(combo.currentValue)

        contentItem: Text {
            leftPadding: VfTheme.dp(7)
            rightPadding: VfTheme.dp(18)
            text: combo.displayText
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            radius: VfTheme.dp(4)
            color: VfTheme.surface
            border.width: 1
            border.color: combo.activeFocus ? "#7C3AED" : VfTheme.borderStrong
        }

        indicator: Text {
            x: combo.width - width - 7
            y: Math.round((combo.height - height) / 2)
            width: VfTheme.dp(9)
            height: combo.height
            text: "v"
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(8)
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        delegate: ItemDelegate {
            width: combo.width
            height: VfTheme.dp(24)

            contentItem: Text {
                text: modelData.label
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        popup: Popup {
            y: combo.height + 4
            width: combo.width
            padding: 4
            background: Rectangle {
                color: VfTheme.surface
                border.color: VfTheme.border
                border.width: 1
                radius: 6
            }
            contentItem: ListView { // perf-lint: disable=R1  ComboBox dropdown popup with tiny static list (4-9 items); recycling pointless
                clip: true
                implicitHeight: contentHeight
                model: combo.delegateModel
                currentIndex: combo.highlightedIndex
            }
        }
    }

    component CompactTextField: TextField {
        id: input

        Layout.fillWidth: true
        implicitHeight: VfTheme.dp(24)
        selectByMouse: true
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(10)
        color: VfTheme.text
        placeholderTextColor: VfTheme.textSubtle
        leftPadding: VfTheme.dp(7)
        rightPadding: VfTheme.dp(7)

        background: Rectangle {
            radius: VfTheme.dp(4)
            color: VfTheme.surface
            border.width: 1
            border.color: input.activeFocus ? "#7C3AED" : VfTheme.borderStrong
        }
    }

    ColumnLayout {
        id: configColumn

        anchors.fill: parent
        spacing: VfTheme.dp(3)

        GridLayout {
            visible: !root.horizontal || root.showClone
            Layout.fillWidth: true
            columns: 2
            rowSpacing: VfTheme.dp(3)
            columnSpacing: VfTheme.dp(6)

            FieldLabel { text: "Gender" }
            FieldLabel { text: "Language" }

            RowLayout {
                spacing: VfTheme.dp(4)

                RadioButton {
                    text: (void i18n.revision, i18n.t("voice_studio.local_gender_male", "Male"))
                    checked: root.gender === "male"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    onToggled: if (checked) {
                        root.gender = "male"
                        root.emitConfigChanged()
                    }
                }

                RadioButton {
                    text: (void i18n.revision, i18n.t("voice_studio.local_gender_female", "Female"))
                    checked: root.gender === "female"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    onToggled: if (checked) {
                        root.gender = "female"
                        root.emitConfigChanged()
                    }
                }
            }

            MiniCombo {
                Layout.fillWidth: true
                options: root.languageOptions
                selectedValue: root.language
                onSelected: value => {
                    root.language = String(value)
                    root.emitConfigChanged()
                }
            }

            FieldLabel { text: (void i18n.revision, i18n.t("voice_studio.local_age", "Age")) }
            FieldLabel { text: (void i18n.revision, i18n.t("voice_studio.local_pitch", "Pitch")) }

            MiniCombo {
                Layout.fillWidth: true
                options: root.ageOptions
                selectedValue: root.age
                onSelected: value => {
                    root.age = String(value)
                    root.emitConfigChanged()
                }
            }

            MiniCombo {
                Layout.fillWidth: true
                options: root.pitchOptions
                selectedValue: root.pitch
                onSelected: value => {
                    root.pitch = String(value)
                    root.emitConfigChanged()
                }
            }
        }

        RowLayout {
            visible: root.horizontal && !root.showClone
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            FieldLabel { text: "Gender" }
            RadioButton {
                text: (void i18n.revision, i18n.t("voice_studio.local_gender_male", "Male"))
                checked: root.gender === "male"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                onToggled: if (checked) {
                    root.gender = "male"
                    root.emitConfigChanged()
                }
            }
            RadioButton {
                text: (void i18n.revision, i18n.t("voice_studio.local_gender_female", "Female"))
                checked: root.gender === "female"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                onToggled: if (checked) {
                    root.gender = "female"
                    root.emitConfigChanged()
                }
            }

            FieldLabel { text: "Language" }
            MiniCombo {
                Layout.preferredWidth: VfTheme.dp(90)
                options: root.languageOptions
                selectedValue: root.language
                onSelected: value => {
                    root.language = String(value)
                    root.emitConfigChanged()
                }
            }

            FieldLabel { text: (void i18n.revision, i18n.t("voice_studio.local_age", "Age")) }
            MiniCombo {
                Layout.preferredWidth: VfTheme.dp(100)
                options: root.ageOptions
                selectedValue: root.age
                onSelected: value => {
                    root.age = String(value)
                    root.emitConfigChanged()
                }
            }

            FieldLabel { text: (void i18n.revision, i18n.t("voice_studio.local_pitch", "Pitch")) }
            MiniCombo {
                Layout.preferredWidth: VfTheme.dp(110)
                options: root.pitchOptions
                selectedValue: root.pitch
                onSelected: value => {
                    root.pitch = String(value)
                    root.emitConfigChanged()
                }
            }
        }

        RowLayout {
            visible: root.showSpeed
            Layout.fillWidth: true
            spacing: VfTheme.dp(6)

            FieldLabel { text: (void i18n.revision, i18n.t("voice_studio.local_speed", "Speed")) }

            Slider {
                Layout.fillWidth: true
                from: 0.5
                to: 2.0
                stepSize: 0.1
                value: root.speed
                onMoved: {
                    root.speed = value
                    root.emitConfigChanged()
                }
            }

            Text {
                text: root.speed.toFixed(1) + "x"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                Layout.preferredWidth: VfTheme.dp(30)
                horizontalAlignment: Text.AlignRight
            }
        }

        Rectangle {
            visible: root.showClone
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: VfTheme.borderSoft
        }

        RowLayout {
            visible: root.showClone
            Layout.fillWidth: true
            spacing: VfTheme.dp(6)

            Text {
                text: (void i18n.revision, i18n.t("voice_studio.local_voice_clone", "Voice Clone"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: VfTheme.weightStrong
            }

            Item { Layout.fillWidth: true }

            Text {
                text: (void i18n.revision, i18n.t("voice_studio.local_clone_override_hint", "(overrides config)"))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(8)
                font.italic: true
            }
        }

        RowLayout {
            visible: root.showClone
            Layout.fillWidth: true
            spacing: VfTheme.dp(4)

            CompactTextField {
                text: root.refAudio
                placeholderText: (void i18n.revision, i18n.t("voice_studio.local_ref_audio_placeholder", "Reference audio"))
                onTextEdited: {
                    root.refAudio = text
                    root.emitConfigChanged()
                }
            }

            VfButton {
                text: "..."
                minWidth: VfTheme.dp(24)
                implicitHeight: VfTheme.dp(24)
                leftPadding: 0
                rightPadding: 0
                onClicked: root.browseReferenceRequested()
            }
        }

        CompactTextField {
            visible: root.showClone
            text: root.refText
            placeholderText: (void i18n.revision, i18n.t("voice_studio.local_ref_text_placeholder", "Reference transcript"))
            onTextEdited: {
                root.refText = text
                root.emitConfigChanged()
            }
        }
    }
}
