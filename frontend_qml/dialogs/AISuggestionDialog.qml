import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "AISuggestionDialog"

    property string baseIdea: ""
    property var suggestions: []
    property var selectedIndexes: []
    property string creativityLevel: "balanced"
    property int suggestionCount: 5
    property string statusText: (void i18n.revision, i18n.t("ai_suggestion.no_ideas_yet", "No ideas yet."))
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal generateRequested(string baseIdea, int count, string creativityLevel)
    signal ideasApproved(var ideas)

    parent: Overlay.overlay
    modal: true
    title: (void i18n.revision, i18n.t("ai_suggestion.title", "AI Suggestion"))
    header: null
    width: VfDialogMetrics.width(parent, 875, 56)
    height: VfDialogMetrics.height(parent, 795, 56)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    function openFor(value) {
        root.baseIdea = String(value || "")
        baseIdeaInput.text = root.baseIdea
        if ((root.suggestions || []).length === 0)
            root.statusText = (void i18n.revision, i18n.t("ai_suggestion.no_ideas_yet", "No ideas yet."))
        root.open()
    }

    function setSuggestions(ideas) {
        root.suggestions = ideas || []
        var next = []
        for (var i = 0; i < root.suggestions.length; i++)
            next.push(i)
        root.selectedIndexes = next
        root.updateSelectedStatus()
    }

    function isSelected(index) {
        return root.selectedIndexes.indexOf(index) >= 0
    }

    function setSelected(index, selected) {
        var next = [].concat(root.selectedIndexes || [])
        var pos = next.indexOf(index)
        if (selected && pos < 0)
            next.push(index)
        if (!selected && pos >= 0)
            next.splice(pos, 1)
        next.sort(function(a, b) { return a - b })
        root.selectedIndexes = next
        root.updateSelectedStatus()
    }

    function selectedIdeas() {
        var out = []
        var list = root.suggestions || []
        var indexes = root.selectedIndexes || []
        for (var i = 0; i < indexes.length; i++) {
            var index = Number(indexes[i])
            if (index >= 0 && index < list.length)
                out.push(String(list[index] || ""))
        }
        return out
    }

    function selectedCount() {
        return root.selectedIdeas().length
    }

    function updateSelectedStatus() {
        if ((root.suggestions || []).length <= 0) {
            root.statusText = (void i18n.revision, i18n.t("ai_suggestion.no_ideas_yet", "No ideas yet."))
            return
        }
        var count = root.selectedCount()
        if (count <= 0) {
            root.statusText = (void i18n.revision, i18n.t("ai_suggestion.no_ideas_selected", "No ideas selected."))
            return
        }
        root.statusText = (void i18n.revision, i18n.t("ai_suggestion.ideas_selected", "{count} ideas selected.")).replace("{count}", String(count))
    }

    function requestGenerate() {
        var text = baseIdeaInput.text.trim()
        if (text.length === 0) {
            root.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                (void i18n.revision, i18n.t("ai_suggestion.enter_base_idea_first", "Enter a base idea first."))
            )
            return false
        }
        root.baseIdea = text
        root.statusText = (void i18n.revision, i18n.t("ai_suggestion.generating", "Generating..."))
        root.generateRequested(root.baseIdea, root.suggestionCount, root.creativityLevel)
        return true
    }

    function approveSelected() {
        var ideas = root.selectedIdeas()
        if (ideas.length <= 0) {
            root.showFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                (void i18n.revision, i18n.t("ai_suggestion.select_at_least_one", "Select at least one idea."))
            )
            return false
        }
        root.ideasApproved(ideas)
        root.accept()
        return true
    }

    function showFeedback(titleText, messageText) {
        root.feedbackTitle = String(titleText || "")
        root.feedbackMessage = String(messageText || "")
        feedbackDialog.open()
    }

    function setBaseIdeaForVisualTest(value) {
        baseIdeaInput.text = String(value || "")
        root.baseIdea = baseIdeaInput.text
        return true
    }

    function setSuggestionsForVisualTest(ideas) {
        root.setSuggestions(ideas || [])
        return true
    }

    function selectedCountForVisualTest() {
        return root.selectedCount()
    }

    function statusTextForVisualTest() {
        return String(root.statusText || "")
    }

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(10)
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(16)
        spacing: VfTheme.dp(12)

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(34)
            color: VfTheme.surfaceSoft

            Text {
                anchors.left: parent.left
                anchors.leftMargin: VfTheme.dp(8)
                anchors.verticalCenter: parent.verticalCenter
                text: (void i18n.revision, i18n.t("ai_suggestion.title", "AI Suggestion"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.Bold
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(200)
            radius: VfTheme.dp(8)
            color: VfTheme.cyanFill
            border.color: VfTheme.cyanBorderSoft

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(10)
                spacing: VfTheme.dp(6)

                Text {
                    text: (void i18n.revision, i18n.t("ai_suggestion.base_idea", "Base idea"))
                    color: VfTheme.cyanText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: Font.Bold
                }

                TextArea {
                    id: baseIdeaInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.baseIdea
                    placeholderText: (void i18n.revision, i18n.t("ai_suggestion.base_idea_placeholder", "Enter the source idea to expand."))
                    wrapMode: TextArea.Wrap
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    background: Rectangle {
                        radius: VfTheme.dp(5)
                        color: VfTheme.surface
                        border.color: baseIdeaInput.activeFocus ? "#0EA5E9" : VfTheme.cyanBorderSoft
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(10)

            Text {
                text: (void i18n.revision, i18n.t("ai_suggestion.suggestion_count", "Suggestions"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
            }

            SpinBox {
                id: countSpin
                from: 1
                to: 20
                value: root.suggestionCount
                onValueModified: root.suggestionCount = value
            }

            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("ai_suggestion.generate_btn", "Generate"))
                tone: "accent"
                minWidth: VfTheme.dp(110)
                onClicked: root.requestGenerate()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(12)

            Text {
                text: (void i18n.revision, i18n.t("ai_suggestion.creativity_label", "Creativity level:"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
            }

            CreativityOption {
                text: (void i18n.revision, i18n.t("ai_suggestion.creativity_safe", "Safe"))
                value: "conservative"
            }
            CreativityOption {
                text: (void i18n.revision, i18n.t("ai_suggestion.creativity_balanced", "Balanced"))
                value: "balanced"
            }
            CreativityOption {
                text: (void i18n.revision, i18n.t("ai_suggestion.creativity_creative", "Creative"))
                value: "creative"
            }
            CreativityOption {
                text: (void i18n.revision, i18n.t("ai_suggestion.creativity_wild", "Wild"))
                value: "wild"
            }
            Item { Layout.fillWidth: true }
        }

        Text {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("ai_suggestion.ideas_list_label", "Suggested ideas"))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(13)
            font.weight: Font.DemiBold
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: VfTheme.dp(6)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderStrong
            border.width: 1
            clip: true

            ListView {
                id: ideasList
                anchors.fill: parent
                clip: true
                reuseItems: true
                model: root.suggestions || []  // perf-lint: disable=R2  static/single-populate config list — one-time rebuild, no continuous cost

                delegate: Rectangle {
                    width: ideasList.width
                    height: Math.max(44, ideaText.implicitHeight + 18)
                    color: index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft
                    border.color: VfTheme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: VfTheme.dp(8)
                        anchors.rightMargin: VfTheme.dp(8)
                        spacing: VfTheme.dp(8)

                        CheckBox {
                            checked: root.isSelected(index)
                            onToggled: root.setSelected(index, checked)
                        }

                        Text {
                            id: ideaText
                            Layout.fillWidth: true
                            text: String(modelData || "")
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(13)
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(28)
            color: VfTheme.surfaceSoft

            Row {
                anchors.left: parent.left
                anchors.leftMargin: VfTheme.dp(8)
                anchors.verticalCenter: parent.verticalCenter
                spacing: VfTheme.dp(4)
                property color statusColor: (root.selectedCount() > 0 || (root.suggestions || []).length <= 0) ? "#059669" : "#EF4444"

                VfAppIcon {
                    name: (root.suggestions || []).length <= 0 ? "check-mark-button" : ""
                    size: VfTheme.dp(12)
                    framed: false
                    color: parent.statusColor
                    visible: name.length > 0
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: root.statusText
                    color: parent.statusColor
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(10)
            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("ai_suggestion.cancel_btn", "Cancel"))
                minWidth: VfTheme.dp(90)
                onClicked: root.reject()
            }

            VfButton {
                text: root.selectedCount() > 0
                    ? (void i18n.revision, i18n.t("ai_suggestion.add_to_list_count", "Add {count} to list")).replace("{count}", String(root.selectedCount()))
                    : (void i18n.revision, i18n.t("ai_suggestion.add_to_list", "Add to list"))
                tone: "success"
                minWidth: VfTheme.dp(140)
                enabled: root.selectedCount() > 0
                onClicked: root.approveSelected()
            }
        }
    }

    component CreativityOption: RowLayout {
        id: creativityOption
        property string text: ""
        property string value: ""
        spacing: VfTheme.dp(4)

        RadioButton {
            id: optionButton
            checked: root.creativityLevel === creativityOption.value
            onToggled: if (checked) root.creativityLevel = creativityOption.value
        }

        Text {
            text: creativityOption.text
            color: optionButton.checked ? "#60A5FA" : VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            verticalAlignment: Text.AlignVCenter
        }
    }

    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }
}
