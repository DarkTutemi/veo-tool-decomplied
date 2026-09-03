pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"
import "MediaSourceResolver.js" as MediaSourceResolver

Rectangle {
    id: builder
    objectName: "timeMachineJobBuilder"

    property var controller: null
    property string errorText: ""
    property bool draftPrepared: false
    property bool inputDirty: true
    signal actionError(string message)
    signal mediaLibraryRequested()
    signal subtitleStudioRequested()
    signal graphicsPresetRequested()

    readonly property var config: controller ? (controller.config || ({})) : ({})
    readonly property bool compact: width < VfTheme.dp(900)
    readonly property int imageCount: inputModel.count
    readonly property string intentText: intentField.text.trim()

    color: VfTheme.surface
    radius: VfTheme.radiusPanel
    border.color: VfTheme.greenBorder
    border.width: 1
    implicitHeight: content.implicitHeight + VfTheme.dp(16)

    ListModel { id: inputModel }

    Component.onCompleted: builder.applyDemoPayload(
        builder.controller ? builder.controller.demoPayload : ({}))

    Connections {
        target: builder.controller
        enabled: builder.controller !== null
        ignoreUnknownSignals: true

        function onDemoPayloadChanged() {
            builder.applyDemoPayload(builder.controller.demoPayload)
        }

    }

    function paths() {
        var result = []
        for (var i = 0; i < inputModel.count; ++i) {
            var path = String(inputModel.get(i).path || "")
            if (path.length > 0)
                result.push(path)
        }
        return result
    }

    function inputSnapshot() {
        var result = []
        for (var i = 0; i < inputModel.count; ++i) {
            var item = inputModel.get(i)
            var path = String(item.path || "")
            if (!path.length)
                continue
            result.push({
                media_id: String(item.mediaId || ""),
                path: path,
                label: String(item.label || ("Ảnh " + (i + 1))),
                detection: String(item.detection || "")
            })
        }
        return result
    }

    function localPath(value) {
        var raw = String(value || "")
        if (raw.indexOf("file:///") === 0)
            raw = raw.substring(8)
        else if (raw.indexOf("file://") === 0)
            raw = raw.substring(7)
        return decodeURIComponent(raw)
    }

    function shortName(path) {
        var parts = String(path || "").replace(/\\/g, "/").split("/")
        return parts.length ? parts[parts.length - 1] : ""
    }

    function mediaPath(item) {
        item = item || ({})
        return String(item.original_source_path || item.source_path
                      || item.file_path || item.path || item.blob_path || "")
    }

    function mediaName(item, fallbackIndex) {
        item = item || ({})
        return String(item.name || item.title || item.media_name
                      || item.file_name || ("Ảnh " + fallbackIndex))
    }

    function mediaAnalysis(item) {
        item = item || ({})
        var text = String(item.analysis_summary || item.analysis
                          || item.description || item.caption || "")
        return text.length > 0 ? text : "Đã lấy từ Media Library"
    }

    function addMediaSelection(selection) {
        var items = []
        if (selection && selection.items && selection.items.length)
            items = selection.items
        else if (selection && (selection.item || selection.media))
            items = [selection.item || selection.media]

        if (!items.length)
            return { ok: false, message: "Chưa chọn ảnh trong Media Library." }

        var known = ({})
        for (var i = 0; i < inputModel.count; ++i) {
            var current = inputModel.get(i)
            known[String(current.mediaId || "") + "|" + String(current.path || "")] = true
        }

        var added = 0
        for (var j = 0; j < items.length; ++j) {
            var item = items[j] || ({})
            var mediaId = String(item.id || item.media_id || "")
            var path = builder.mediaPath(item)
            var previewSource = MediaSourceResolver.imageSource(item)
            var key = mediaId + "|" + path
            if (!path.length || known[key])
                continue
            inputModel.append({
                mediaId: mediaId,
                path: path,
                previewSource: previewSource,
                label: builder.mediaName(item, inputModel.count + 1),
                detection: builder.mediaAnalysis(item)
            })
            known[key] = true
            added += 1
        }

        if (added === 0)
            return {
                ok: false,
                message: "Ảnh đã có trong đầu vào hoặc chưa có tệp local."
            }
        builder.invalidateDraft()
        return {
            ok: true,
            message: "Đã thêm " + added + " ảnh từ Media Library."
        }
    }

    function applyDemoPayload(payload) {
        var data = payload || ({})
        if (!Boolean(data.enabled))
            return
        inputModel.clear()
        var items = data.items || []
        for (var i = 0; i < items.length; ++i) {
            var item = items[i] || ({})
            var path = String(item.path || "")
            inputModel.append({
                mediaId: String(item.mediaId || ""),
                path: path,
                previewSource: MediaSourceResolver.localFileUrl(
                    String(item.previewSource || path)),
                label: String(item.label || ("Ảnh " + (i + 1))),
                detection: String(item.detection || "Đã nhận diện")
            })
        }
        intentField.text = String(data.intent || "")
        builder.errorText = ""
        builder.inputDirty = false
        builder.draftPrepared = true
    }

    function invalidateDraft() {
        builder.inputDirty = true
        builder.draftPrepared = false
    }

    function enqueue() {
        if (inputModel.count === 0
                && !intentField.text.trim().length) {
            builder.errorText = "Nhập ý tưởng hoặc chọn ảnh tham chiếu."
            builder.actionError(builder.errorText)
            return
        }
        var result = builder.controller.enqueueJob(
            builder.inputSnapshot(),
            intentField.text,
            "auto",
            ({})
        )
        if (!(result && result.ok)) {
            if (Boolean((result || {}).alerted)) {
                // Shared runtime alert already contains the Notice, hints and
                // route action. Avoid duplicating it as an inline error.
                builder.errorText = ""
                builder.actionError("")
                return
            }
            builder.errorText = String(
                (result || {}).message || "Không thể thêm job vào hàng chờ."
            )
            builder.actionError(builder.errorText)
            return
        }
        builder.errorText = ""
        builder.actionError("")
        inputModel.clear()
        intentField.clear()
        builder.inputDirty = true
        builder.draftPrepared = false
    }

    function ttsSnapshot() {
        return ({})
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(6)

        GridLayout {
            Layout.fillWidth: true
            columns: builder.compact ? 1 : 2
            columnSpacing: VfTheme.dp(8)
            rowSpacing: VfTheme.dp(7)

            Rectangle {
                objectName: "timeMachineIdeaCard"
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: builder.width * 0.5
                Layout.preferredHeight: VfTheme.dp(132)
                radius: VfTheme.dp(8)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(7)
                    spacing: VfTheme.dp(5)

                    RowLayout {
                        Layout.fillWidth: true
                        VfAppIcon {
                            name: "brain"
                            size: VfTheme.dp(15)
                            color: VfTheme.violetText
                        }
                        Text {
                            text: "Ý TƯỞNG JOB"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true }
                    }

                    TextArea {
                        id: intentField
                        objectName: "timeMachineIntentInput"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 0
                        placeholderText:
                            "Mô tả điều bạn muốn AI dựng theo thời gian…\n"
                            + "Ví dụ: từ một bãi đất trống đến khu vui chơi "
                            + "màu nước dành cho trẻ em."
                        color: VfTheme.text
                        selectByMouse: true
                        wrapMode: TextEdit.Wrap
                        leftPadding: VfTheme.dp(8)
                        rightPadding: VfTheme.dp(8)
                        topPadding: VfTheme.dp(7)
                        bottomPadding: VfTheme.dp(7)
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        clip: true
                        onTextChanged: builder.invalidateDraft()
                        background: Rectangle {
                            color: VfTheme.surface
                            border.color: intentField.activeFocus
                                          ? VfTheme.blueBorderSoft : VfTheme.border
                            radius: VfTheme.dp(6)
                        }
                    }

                }
            }

            Rectangle {
                objectName: "timeMachineInputMedia"
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: builder.width * 0.5
                Layout.preferredHeight: VfTheme.dp(132)
                radius: VfTheme.dp(8)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(7)
                    spacing: VfTheme.dp(5)

                    RowLayout {
                        Layout.fillWidth: true
                        VfAppIcon {
                            name: "framed-picture"
                            size: VfTheme.dp(15)
                            color: VfTheme.amberText
                        }
                        Text {
                            text: "ẢNH MỐC & THAM CHIẾU"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            font.weight: Font.Bold
                        }
                        Text {
                            Layout.fillWidth: true
                            text: inputModel.count + " ảnh"
                            horizontalAlignment: Text.AlignRight
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                        }
                    }

                    ListView {
                        id: inputList
                        objectName: "timeMachineInputMediaList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        orientation: ListView.Horizontal
                        spacing: VfTheme.dp(6)
                        clip: true
                        reuseItems: true
                        model: inputModel

                        header: Rectangle {
                            width: visible ? VfTheme.dp(178) : 0
                            height: inputList.height
                            visible: inputModel.count === 0
                            radius: VfTheme.dp(7)
                            color: VfTheme.surface
                            border.color: VfTheme.border

                            Column {
                                anchors.centerIn: parent
                                width: parent.width - VfTheme.dp(18)
                                spacing: VfTheme.dp(5)
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "✦"
                                    color: VfTheme.violet
                                    font.pixelSize: VfTheme.dp(19)
                                }
                                Text {
                                    width: parent.width
                                    text: "AI CÓ THỂ TỰ SINH ẢNH MỐC"
                                    horizontalAlignment: Text.AlignHCenter
                                    color: VfTheme.violetText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9)
                                    font.weight: Font.Bold
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        footer: Rectangle {
                            width: VfTheme.dp(146)
                            height: inputList.height
                            radius: VfTheme.dp(7)
                            color: VfTheme.blueFill
                            border.color: VfTheme.blueBorderSoft

                            Column {
                                anchors.centerIn: parent
                                spacing: VfTheme.dp(4)
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "+"
                                    color: VfTheme.blueText
                                    font.pixelSize: VfTheme.dp(22)
                                    font.weight: Font.Bold
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "MEDIA LIBRARY"
                                    color: VfTheme.blueText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9)
                                    font.weight: Font.Bold
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: builder.mediaLibraryRequested()
                            }
                        }

                        delegate: Rectangle {
                            id: inputCard
                            required property int index
                            required property string mediaId
                            required property string path
                            required property string previewSource
                            required property string label
                            required property string detection
                            width: VfTheme.dp(166)
                            height: inputList.height
                            radius: VfTheme.dp(7)
                            color: VfTheme.surface
                            border.color: VfTheme.border
                            clip: true

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(4)
                                spacing: VfTheme.dp(3)

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: VfTheme.dp(54)
                                    radius: VfTheme.dp(5)
                                    color: VfTheme.surfaceSoft
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: inputCard.previewSource.length > 0
                                                ? inputCard.previewSource
                                                : MediaSourceResolver.localFileUrl(
                                                      inputCard.path)
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        sourceSize.width: width
                                        sourceSize.height: height
                                    }

                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.margins: VfTheme.dp(3)
                                        width: VfTheme.dp(18)
                                        height: width
                                        radius: width / 2
                                        color: Qt.rgba(0.02, 0.05, 0.12, 0.72)
                                        Text {
                                            anchors.centerIn: parent
                                            text: "×"
                                            color: "white"
                                            font.weight: Font.Bold
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                inputModel.remove(inputCard.index)
                                                builder.invalidateDraft()
                                            }
                                        }
                                    }
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: VfTheme.dp(22)
                                    text: inputCard.label
                                    selectByMouse: true
                                    leftPadding: VfTheme.dp(6)
                                    rightPadding: VfTheme.dp(6)
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9)
                                    onEditingFinished: {
                                        inputModel.setProperty(
                                            inputCard.index, "label", text.trim())
                                        builder.invalidateDraft()
                                    }
                                    background: Rectangle {
                                        radius: VfTheme.dp(5)
                                        color: VfTheme.surfaceSoft
                                        border.color: parent.activeFocus
                                                      ? VfTheme.blueBorderSoft
                                                      : VfTheme.border
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: inputCard.detection + " · "
                                          + builder.shortName(inputCard.path)
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }

                }
            }
        }

        Text {
            Layout.fillWidth: true
            visible: builder.errorText.length > 0
            text: builder.errorText
            color: VfTheme.redText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            wrapMode: Text.WordWrap
        }
    }
}
