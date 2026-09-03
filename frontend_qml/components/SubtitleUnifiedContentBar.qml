pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root
    objectName: "subtitleUnifiedContentBar"

    required property var controller
    readonly property var draft: controller.draft || ({})
    readonly property var caption: draft.caption || ({})
    readonly property var overlay: draft.overlay || ({})
    readonly property var jobContext: controller.jobContext || ({})
    readonly property bool subtitleEnabled: Boolean(controller.subtitlesEnabled)
    readonly property bool overlayEnabled: Boolean(controller.overlayEnabled)
    readonly property string captionMode: String(controller.contentMode || "subtitle")
    readonly property string learningTargetLanguage: String(overlay.target_language || "auto")
    readonly property string effectiveLearningLanguage: String(
        controller.effectiveLearningLanguage || "auto")
    signal objectChosen(string objectId)

    implicitHeight: VfTheme.dp(68)
    radius: VfTheme.radiusControl
    color: VfTheme.surfaceSoft
    border.width: 1
    border.color: VfTheme.border

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(8)

        Rectangle {
            id: enabledToggle
            objectName: "subtitleUnifiedEnabledToggle"
            Layout.preferredWidth: VfTheme.dp(154)
            Layout.fillHeight: true
            radius: VfTheme.dp(8)
            color: root.subtitleEnabled ? VfTheme.greenFill : VfTheme.surface
            border.width: 1
            border.color: root.subtitleEnabled ? VfTheme.greenBorder : VfTheme.borderStrong
            activeFocusOnTab: true
            Accessible.role: Accessible.CheckBox
            Accessible.name: qsTr("Bật phụ đề")
            Accessible.checked: root.subtitleEnabled

            Keys.onSpacePressed: root.controller.setEnabled(!root.subtitleEnabled)

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(9)
                spacing: VfTheme.dp(8)

                Text {
                    Layout.fillWidth: true
                    text: root.subtitleEnabled ? qsTr("Phụ đề bật") : qsTr("Phụ đề tắt")
                    color: root.subtitleEnabled ? VfTheme.greenText : VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(38)
                    Layout.preferredHeight: VfTheme.dp(21)
                    radius: height / 2
                    color: root.subtitleEnabled ? VfTheme.greenBorder : VfTheme.borderStrong

                    Rectangle {
                        width: VfTheme.dp(17)
                        height: width
                        radius: width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.subtitleEnabled
                            ? parent.width - width - VfTheme.dp(2)
                            : VfTheme.dp(2)
                        color: "#FFFFFF"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.controller.setEnabled(!root.subtitleEnabled)
            }
        }

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(300)
            Layout.fillHeight: true
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.width: 1
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(4)
                spacing: VfTheme.dp(4)

                Repeater {
                    model: [
                        { label: qsTr("Tự động"), value: "auto" },
                        { label: qsTr("Đơn ngữ"), value: "subtitle" },
                        { label: qsTr("Song ngữ"), value: "bilingual" }
                    ]

                    delegate: Button {
                        id: captionModeButton
                        required property var modelData
                        readonly property string modeValue: String(modelData.value)
                        readonly property bool selected: root.captionMode === modeValue
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        enabled: root.subtitleEnabled
                        hoverEnabled: true
                        activeFocusOnTab: true
                        Accessible.name: String(modelData.label)
                        onClicked: {
                            root.controller.setCaptionMode(captionModeButton.modeValue)
                            root.objectChosen("caption")
                        }

                        contentItem: Text {
                            text: String(captionModeButton.modelData.label)
                            color: captionModeButton.selected ? "#FFFFFF" : VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            font.weight: captionModeButton.selected ? Font.Bold : Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            radius: VfTheme.dp(7)
                            color: captionModeButton.selected
                                ? VfTheme.violet
                                : (captionModeButton.hovered ? VfTheme.surfaceSoft : "transparent")
                            border.width: captionModeButton.selected ? 1 : 0
                            border.color: VfTheme.violetBorderSoft
                        }
                    }
                }
            }
        }

        Rectangle {
            id: learningToggle
            objectName: "subtitleLearningOverlayToggle"
            Layout.preferredWidth: VfTheme.dp(106)
            Layout.fillHeight: true
            radius: VfTheme.dp(8)
            color: root.overlayEnabled && root.subtitleEnabled
                ? VfTheme.violetFill : VfTheme.surface
            border.width: 1
            border.color: root.overlayEnabled && root.subtitleEnabled
                ? VfTheme.violetBorder : VfTheme.border
            enabled: root.subtitleEnabled
            activeFocusOnTab: true
            Accessible.role: Accessible.CheckBox
            Accessible.name: qsTr("Học")
            Accessible.checked: root.overlayEnabled

            Keys.onSpacePressed: {
                var turningOn = !root.overlayEnabled
                root.controller.setOverlayEnabled(turningOn)
                root.objectChosen(turningOn ? "overlay" : "caption")
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(8)
                spacing: VfTheme.dp(7)

                Text {
                    Layout.fillWidth: true
                    text: qsTr("Học")
                    color: root.overlayEnabled && root.subtitleEnabled
                        ? VfTheme.violetText : VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontControl
                    font.weight: Font.Bold
                }

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(34)
                    Layout.preferredHeight: VfTheme.dp(19)
                    radius: height / 2
                    color: root.overlayEnabled ? VfTheme.violet : VfTheme.borderStrong

                    Rectangle {
                        width: VfTheme.dp(15)
                        height: width
                        radius: width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.overlayEnabled
                            ? parent.width - width - VfTheme.dp(2)
                            : VfTheme.dp(2)
                        color: "#FFFFFF"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.subtitleEnabled
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var turningOn = !root.overlayEnabled
                    root.controller.setOverlayEnabled(turningOn)
                    root.objectChosen(turningOn ? "overlay" : "caption")
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: VfTheme.dp(8)
            Layout.bottomMargin: VfTheme.dp(8)
            color: VfTheme.borderStrong
        }

        ColumnLayout {
            Layout.preferredWidth: VfTheme.dp(102)
            Layout.fillHeight: true
            spacing: 1

            Text {
                text: qsTr("NGÔN NGỮ SRT")
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                text: String(root.jobContext.content_language || "vi").toUpperCase()
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSection
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Picture-lock")
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                elide: Text.ElideRight
            }
        }

        VfSelectField {
            objectName: "subtitleTargetLanguageSelect"
            visible: root.captionMode === "bilingual"
            Layout.fillWidth: true
            Layout.minimumWidth: VfTheme.dp(170)
            fieldHeight: parent.height
            label: qsTr("Ngôn ngữ dòng B")
            value: String(root.caption.target_language || "en")
            options: root.controller.translationLanguages
            onSelected: function(value) { root.controller.setTargetLanguage(String(value)) }
        }

        VfSelectField {
            objectName: "subtitleLearningTargetLanguageSelect"
            visible: root.overlayEnabled
            Layout.fillWidth: true
            Layout.minimumWidth: VfTheme.dp(220)
            fieldHeight: parent.height
            popupMinWidth: VfTheme.dp(260)
            accent: VfTheme.violet
            label: root.learningTargetLanguage === "auto"
                && root.effectiveLearningLanguage !== "auto"
                ? qsTr("Ngôn ngữ học") + " · "
                    + root.effectiveLearningLanguage.toUpperCase()
                : qsTr("Ngôn ngữ học")
            tooltip: root.learningTargetLanguage === "auto"
                ? (root.effectiveLearningLanguage === "auto"
                    ? qsTr("Tự động suy luận từ ý tưởng, kịch bản và SRT thực tế")
                    : qsTr("Đã suy luận từ nội dung; SRT thực tế sẽ được kiểm tra lại"))
                : qsTr("Đã khóa ngôn ngữ học thủ công")
            value: root.learningTargetLanguage
            options: root.controller.learningLanguages
            onSelected: function(value) {
                root.controller.setLearningTargetLanguage(String(value))
            }
        }

        VfSelectField {
            objectName: "subtitleReadingSystemSelect"
            visible: root.overlayEnabled
            Layout.fillWidth: true
            Layout.minimumWidth: VfTheme.dp(190)
            fieldHeight: parent.height
            accent: VfTheme.violet
            label: qsTr("Hệ chữ đọc")
            value: String(root.overlay.reading_system || "auto")
            options: root.controller.readingSystems
            onSelected: function(value) { root.controller.setReadingSystem(String(value)) }
        }

        Item {
            Layout.fillWidth: true
            visible: root.captionMode !== "bilingual" && !root.overlayEnabled
        }
    }
}
