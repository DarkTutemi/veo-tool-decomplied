pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"
import "MediaSourceResolver.js" as MediaSourceResolver

Item {
    id: board

    property var controller: null
    property bool hasPlan: false
    property bool portraitFrames: false
    property int page: 0
    property int pageSize: 4
    property int inputImageCount: 0
    property string previewPath: ""
    property bool busy: false
    property int progress: 0
    property string activityTitle: ""
    property string activityDetail: ""

    signal previewSelected(string path, string title, string status)
    signal previewOpened(string path, string title, string status)
    signal editCellRequested(string viewId, string viewLabel, int stageIdx,
                             string prompt, bool locked)

    readonly property real cardWidth: portraitFrames
                                      ? VfTheme.dp(78) : VfTheme.dp(118)
    readonly property real cardFrameHeight: portraitFrames
        ? Math.round(cardWidth * 16 / 9)
        : Math.round(cardWidth * 9 / 16)
    readonly property real cardHeight: VfTheme.dp(19) + cardFrameHeight

    function scrollToChapter(index) {
        if (!chapterList.visible)
            return
        var target = Math.max(0, Number(index))
        if (target < chapterList.count)
            chapterList.positionViewAtIndex(target, ListView.Contain)
    }

    Rectangle {
        anchors.fill: parent
        visible: !board.hasPlan
        color: VfTheme.surfaceSoft
        radius: VfTheme.dp(6)
        border.color: VfTheme.border

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width - VfTheme.dp(30), VfTheme.dp(430))
            spacing: VfTheme.dp(7)

            BusyIndicator {
                visible: board.busy
                running: board.busy
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: VfTheme.dp(38)
                Layout.preferredHeight: width
            }

            Text {
                Layout.fillWidth: true
                text: board.busy
                      ? String(board.activityTitle || "AI ĐANG CHUẨN BỊ WORKSPACE")
                      : board.inputImageCount > 0
                      ? "LLM sẽ biến từng ảnh mốc thành một phân đoạn storyboard."
                      : "LLM sẽ tạo ảnh mốc gốc, sau đó mở rộng storyboard có context."
                horizontalAlignment: Text.AlignHCenter
                color: board.busy ? VfTheme.blueText : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: board.busy ? VfTheme.dp(12) : VfTheme.dp(10)
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: board.busy
                      ? String(board.activityDetail || "Backend đang xử lý")
                      : "Mỗi phân đoạn xếp dọc · keyframe chảy hết bề ngang rồi xuống hàng"
                horizontalAlignment: Text.AlignHCenter
                color: board.busy ? VfTheme.textMuted : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: board.busy ? VfTheme.dp(9) : VfTheme.dp(8)
                wrapMode: Text.WordWrap
            }

            Rectangle {
                visible: board.busy
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(
                    parent.width, VfTheme.dp(330))
                Layout.preferredHeight: VfTheme.dp(9)
                radius: height / 2
                color: VfTheme.surface
                border.color: VfTheme.blueBorderSoft
                clip: true

                Rectangle {
                    width: Math.max(
                        parent.height,
                        parent.width
                        * Math.max(0, Math.min(100, board.progress)) / 100)
                    height: parent.height
                    radius: height / 2
                    color: VfTheme.primary

                    Behavior on width {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Text {
                visible: board.busy
                Layout.fillWidth: true
                text: Math.max(0, Math.min(100, board.progress))
                      + "% · dữ liệu sẽ xuất hiện ngay khi từng bước hoàn tất"
                horizontalAlignment: Text.AlignHCenter
                color: VfTheme.blueText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: Font.DemiBold
            }
        }
    }

    ListView {
        id: chapterList
        anchors.fill: parent
        visible: board.hasPlan
        model: board.controller ? board.controller.chapterModel : null
        interactive: true
        clip: true
        reuseItems: true
        boundsBehavior: Flickable.StopAtBounds
        spacing: VfTheme.dp(4)
        ScrollBar.vertical: ScrollBar {
            policy: chapterList.contentHeight > chapterList.height
                    ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        }

        delegate: Item {
            id: chapterRow
            required property int index
            required property string viewId
            required property string label
            required property int storyOrder
            required property string contextFromPrevious
            required property int stageCount
            required property int clipCount
            required property int completedClipCount
            required property string generationStrategy
            required property var cellsModel
            readonly property bool constructionChapter:
                generationStrategy === "reverse_regression"

            width: chapterList.width
            implicitHeight: chapterColumn.implicitHeight + VfTheme.dp(10)
            height: implicitHeight

            Rectangle {
                anchors.fill: parent
                radius: VfTheme.dp(5)
                color: chapterRow.index % 2 === 0
                       ? VfTheme.surface : VfTheme.surfaceSoft
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: VfTheme.border
            }

            ColumnLayout {
                id: chapterColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: VfTheme.dp(4)
                anchors.rightMargin: VfTheme.dp(4)
                anchors.topMargin: VfTheme.dp(5)
                spacing: VfTheme.dp(6)

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(36)
                    spacing: VfTheme.dp(8)

                    Rectangle {
                        Layout.preferredWidth: VfTheme.dp(3)
                        Layout.preferredHeight: VfTheme.dp(24)
                        radius: width / 2
                        color: VfTheme.primary
                    }

                    Rectangle {
                        Layout.preferredWidth: VfTheme.dp(28)
                        Layout.preferredHeight: width
                        radius: VfTheme.dp(6)
                        color: VfTheme.blueFill
                        border.color: VfTheme.blueBorderSoft
                        Text {
                            anchors.centerIn: parent
                            text: chapterRow.storyOrder + 1 < 10
                                  ? "0" + (chapterRow.storyOrder + 1)
                                  : String(chapterRow.storyOrder + 1)
                            color: VfTheme.blueText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                            font.weight: Font.Bold
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            Layout.fillWidth: true
                            text: chapterRow.label
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: (chapterRow.constructionChapter
                                   ? "PEEL START–END · "
                                   : chapterRow.generationStrategy.length > 0
                                     ? "LIVE CHAIN · " : "")
                                  + chapterRow.stageCount + " mốc · "
                                  + chapterRow.completedClipCount + " / "
                                  + chapterRow.clipCount + " clip hoàn thành"
                            color: VfTheme.blueText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(8)
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: chapterRow.contextFromPrevious.length > 0
                            text: chapterRow.contextFromPrevious
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(7)
                            elide: Text.ElideRight
                        }
                    }
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    Repeater {
                        model: chapterRow.cellsModel

                        delegate: Item {
                            id: cell
                            required property int stageIdx
                            required property string stageName
                            required property string visibleDescription
                            required property string status
                            required property string imagePath
                            required property bool locked
                            required property bool isAnchor
                            required property string source
                            required property string regressPrompt
                            required property string seqBadge
                            required property string sourceBadge
                            required property string viewId
                            required property string viewLabel

                            width: board.cardWidth
                            height: board.cardHeight

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: VfTheme.dp(4)

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: VfTheme.dp(15)
                                    spacing: VfTheme.dp(3)
                                    Text {
                                        text: "S" + cell.stageIdx
                                              + " · " + cell.stageName
                                        Layout.fillWidth: true
                                        color: cell.isAnchor
                                               ? VfTheme.amberText : VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(7)
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                    }
                                    Rectangle {
                                        visible: cell.isAnchor
                                        Layout.preferredWidth:
                                            anchorText.implicitWidth
                                            + VfTheme.dp(7)
                                        Layout.preferredHeight: VfTheme.dp(13)
                                        radius: height / 2
                                        color: VfTheme.amberFill
                                        border.color: VfTheme.amberBorderSoft
                                        Text {
                                            id: anchorText
                                            anchors.centerIn: parent
                                            text: "ẢNH MỐC"
                                            color: VfTheme.amberText
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(6)
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: board.cardFrameHeight
                                    radius: VfTheme.dp(4)
                                    color: VfTheme.surfaceSoft
                                    border.color: cell.imagePath === board.previewPath
                                                  && cell.imagePath.length > 0
                                                  ? VfTheme.primary
                                                  : cell.isAnchor
                                                    ? VfTheme.amberBorderSoft
                                                    : cell.imagePath.length > 0
                                                      ? VfTheme.blueBorderSoft
                                                      : VfTheme.border
                                    border.width: cell.imagePath === board.previewPath
                                                  && cell.imagePath.length > 0
                                                  ? 2 : 1
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: MediaSourceResolver.localFileUrl(
                                                    cell.imagePath)
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: false
                                        sourceSize.width: width
                                        sourceSize.height: height
                                        visible: cell.imagePath.length > 0
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        visible: cell.imagePath.length === 0
                                        text: cell.sourceBadge === "CHỜ LIVE-CHAIN"
                                              ? "CHỜ LIVE-CHAIN"
                                              : cell.sourceBadge === "CHỜ PEEL"
                                                ? "CHỜ PEEL"
                                              : cell.status === "pending" ? "◌" : "▧"
                                        color: cell.status === "pending"
                                               ? VfTheme.amberText
                                               : VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: cell.sourceBadge === "CHỜ LIVE-CHAIN"
                                                        || cell.sourceBadge === "CHỜ PEEL"
                                                        ? VfTheme.dp(6)
                                                        : VfTheme.dp(13)
                                        font.weight: Font.Bold
                                    }
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.margins: VfTheme.dp(3)
                                        width: sourceBadgeText.implicitWidth
                                               + VfTheme.dp(7)
                                        height: VfTheme.dp(13)
                                        radius: VfTheme.dp(3)
                                        color: cell.sourceBadge === "LIVE START"
                                               ? VfTheme.cyanFill
                                               : cell.sourceBadge === "LIVE END"
                                                 ? VfTheme.blueFill
                                                 : cell.sourceBadge === "CUT SEED"
                                                   ? VfTheme.violetFill
                                                   : VfTheme.surface
                                        border.color: cell.sourceBadge === "LIVE START"
                                                      ? VfTheme.cyanBorder
                                                      : cell.sourceBadge === "LIVE END"
                                                        ? VfTheme.blueBorderSoft
                                                        : cell.sourceBadge === "CUT SEED"
                                                          ? VfTheme.violetBorderSoft
                                                          : VfTheme.border
                                        Text {
                                            id: sourceBadgeText
                                            anchors.centerIn: parent
                                            text: cell.sourceBadge
                                            color: cell.sourceBadge === "LIVE START"
                                                   ? VfTheme.cyanText
                                                   : cell.sourceBadge === "LIVE END"
                                                     ? VfTheme.blueText
                                                     : cell.sourceBadge === "CUT SEED"
                                                       ? VfTheme.violetText
                                                       : VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(6)
                                            font.weight: Font.Bold
                                        }
                                    }
                                    Rectangle {
                                        visible: cell.imagePath.length > 0
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.margins: VfTheme.dp(3)
                                        width: VfTheme.dp(13)
                                        height: width
                                        radius: width / 2
                                        color: VfTheme.greenFill
                                        border.color: VfTheme.greenBorderSoft
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            color: VfTheme.greenText
                                            font.pixelSize: VfTheme.dp(7)
                                            font.weight: Font.Bold
                                        }
                                    }
                                    Rectangle {
                                        visible: cell.seqBadge.length > 0
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        anchors.margins: VfTheme.dp(2)
                                        width: VfTheme.dp(17)
                                        height: width
                                        radius: width / 2
                                        color: VfTheme.primary
                                        Text {
                                            anchors.centerIn: parent
                                            text: cell.seqBadge
                                            color: "white"
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(7)
                                            font.weight: Font.Bold
                                        }
                                    }
                                }
                            }

                            ToolTip.visible: hover.hovered
                            ToolTip.text: cell.visibleDescription
                            HoverHandler { id: hover }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (cell.imagePath.length > 0) {
                                        board.previewSelected(
                                            cell.imagePath,
                                            cell.viewLabel + " · S"
                                            + cell.stageIdx
                                            + " · " + cell.stageName,
                                            cell.status)
                                        board.previewOpened(
                                            cell.imagePath,
                                            cell.viewLabel + " · S"
                                            + cell.stageIdx
                                            + " · " + cell.stageName,
                                            cell.status)
                                    } else {
                                        board.editCellRequested(
                                            cell.viewId, cell.viewLabel,
                                            cell.stageIdx, cell.regressPrompt,
                                            cell.locked)
                                    }
                                }
                                onDoubleClicked: {
                                    if (cell.imagePath.length > 0) {
                                        board.previewOpened(
                                            cell.imagePath,
                                            cell.viewLabel + " · S"
                                            + cell.stageIdx
                                            + " · " + cell.stageName,
                                            cell.status)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
