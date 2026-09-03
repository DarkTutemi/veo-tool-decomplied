import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Item {
    id: screen
    objectName: "jobPanelStudyScreen"

    property int railWidth: 340
    property int selectedIndex: 0
    property real previewScale: 1.0
    property var sampleRows: [
        {
            id: "job_multi_asset_running",
            feature: "multi_asset_video",
            title: "Launch Hero Montage",
            prompt: "Launch hero montage with premium product macro shots",
            status: "generating",
            aspect: "16:9",
            progress: 67,
            job_progress: 67,
            progress_message: "Scene 3/5 rendering on Ultra account",
            thumbnail_url: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 320 180'><rect width='320' height='180' fill='%2394A3B8'/><rect x='16' y='16' width='288' height='148' rx='14' fill='%23CBD5E1'/><circle cx='160' cy='90' r='32' fill='%23FFFFFF' fill-opacity='0.22'/><polygon points='148,70 148,110 183,90' fill='%23FFFFFF'/></svg>",
            output_folder: "H:/veoflow/output/launch_hero",
            assets: [
                { id: "CHAR_000", media_id: "CHAR_000" },
                { id: "OBJ_000", media_id: "OBJ_000" },
                { id: "SET_000", media_id: "SET_000" },
                { id: "OBJ_001", media_id: "OBJ_001" },
                { id: "OBJ_002", media_id: "OBJ_002" },
                { id: "LIGHT_000", media_id: "LIGHT_000" },
                { id: "CAM_000", media_id: "CAM_000" }
            ],
            generated_videos: [
                { scene_id: "S01", path: "H:/veoflow/output/launch_hero/scene_01.mp4" },
                { scene_id: "S02", path: "H:/veoflow/output/launch_hero/scene_02.mp4" }
            ],
            images: [
                { name: "Poster Frame", path: "H:/veoflow/output/launch_hero/poster.png", thumbnail_path: "" },
                { name: "End Card", path: "H:/veoflow/output/launch_hero/endcard.png", thumbnail_path: "" }
            ],
            dispatcher_breakdown: [
                { scene_id: "S01", status: "complete", progress: 100, video_path: "H:/veoflow/output/launch_hero/scene_01.mp4" },
                { scene_id: "S02", status: "complete", progress: 100, video_path: "H:/veoflow/output/launch_hero/scene_02.mp4" },
                { scene_id: "S03", status: "running", progress: 67, video_path: "" },
                { scene_id: "S04", status: "queued", progress: 0, video_path: "" },
                { scene_id: "S05", status: "queued", progress: 0, video_path: "" }
            ],
            scene_analysis: [
                { scene_id: "S01", title: "Macro product reveal" },
                { scene_id: "S02", title: "Lifestyle motion beat" },
                { scene_id: "S03", title: "Character handoff shot" },
                { scene_id: "S04", title: "CTA pack shot" },
                { scene_id: "S05", title: "End frame logo hold" }
            ],
            scene_count: 5,
            video_count: 2
        },
        {
            id: "job_single_complete",
            feature: "text2video_16_9",
            title: "Minimal Intro Loop",
            prompt: "Minimal intro loop with soft gradient background",
            status: "complete",
            aspect: "16:9",
            progress: 100,
            job_progress: 100,
            progress_message: "Render finished and assets saved.",
            thumbnail_url: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 320 180'><rect width='320' height='180' fill='%2399F6E4'/><rect x='16' y='16' width='288' height='148' rx='14' fill='%2314B8A6'/><circle cx='160' cy='90' r='30' fill='%23FFFFFF' fill-opacity='0.22'/><polygon points='148,70 148,110 183,90' fill='%23FFFFFF'/></svg>",
            output_folder: "H:/veoflow/output/minimal_intro",
            assets: [
                { id: "IMG_001", media_id: "IMG_001" }
            ],
            generated_videos: [
                { scene_id: "OUT", path: "H:/veoflow/output/minimal_intro/final.mp4" }
            ],
            scene_count: 1,
            video_count: 1
        },
        {
            id: "job_failed_clone",
            feature: "clone_video",
            title: "Creator Clip Remix",
            prompt: "Clone creator clip and rebuild with faster rhythm",
            status: "failed",
            aspect: "9:16",
            progress: 18,
            job_progress: 18,
            error_message: "Captcha provider unavailable; retry required.",
            thumbnail_url: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 320 180'><rect width='320' height='180' fill='%23FCA5A5'/><rect x='16' y='16' width='288' height='148' rx='14' fill='%23EF4444'/><circle cx='160' cy='90' r='30' fill='%23FFFFFF' fill-opacity='0.18'/><path d='M142 68 L178 104 M178 68 L142 104' stroke='%23FFFFFF' stroke-width='10' stroke-linecap='round'/></svg>",
            output_folder: "H:/veoflow/output/creator_remix",
            assets: [
                { id: "VOICE_A", media_id: "VOICE_A" },
                { id: "CHAR_A", media_id: "CHAR_A" },
                { id: "SET_A", media_id: "SET_A" }
            ],
            dispatcher_breakdown: [
                { scene_id: "S01", status: "failed", progress: 18, error_message: "Captcha provider unavailable", video_path: "" }
            ],
            scene_count: 4,
            video_count: 0
        }
    ]

    function selectedRow() {
        if (!sampleRows || sampleRows.length === 0)
            return ({})
        var index = Math.max(0, Math.min(selectedIndex, sampleRows.length - 1))
        return sampleRows[index] || ({})
    }

    component WidthChip: Rectangle {
        id: widthChip
        property string label: ""
        property bool selected: false
        signal clicked()

        radius: VfTheme.dp(8)
        color: selected ? VfTheme.blueFill : VfTheme.surface
        border.color: selected ? "#60A5FA" : VfTheme.borderStrong
        implicitWidth: chipText.implicitWidth + 18
        implicitHeight: VfTheme.dp(30)

        Text {
            id: chipText
            anchors.centerIn: parent
            text: widthChip.label
            color: widthChip.selected ? VfTheme.blueText : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            font.weight: Font.Medium
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: widthChip.clicked()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: VfTheme.surfaceSoft

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(16)
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: "Job Panel Study · current rail + responsive checks"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                text: "Current QML already separates queue detail into the main workspace. This study now focuses on the queue card itself: dense single-box layout, thumbnail + overlays + action column + max-7 asset strip."
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Text {
                    text: "Rail width"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: Font.Medium
                }

                WidthChip { label: "320"; selected: screen.railWidth === 320; onClicked: screen.railWidth = 320 }
                WidthChip { label: "340"; selected: screen.railWidth === 340; onClicked: screen.railWidth = 340 }
                WidthChip { label: "380"; selected: screen.railWidth === 380; onClicked: screen.railWidth = 380 }
                WidthChip { label: "420"; selected: screen.railWidth === 420; onClicked: screen.railWidth = 420 }

                Item { Layout.preferredWidth: VfTheme.dp(12) }

                Text {
                    text: "Scale"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: Font.Medium
                }

                WidthChip { label: "85%"; selected: Math.abs(screen.previewScale - 0.85) < 0.001; onClicked: screen.previewScale = 0.85 }
                WidthChip { label: "100%"; selected: Math.abs(screen.previewScale - 1.0) < 0.001; onClicked: screen.previewScale = 1.0 }
                WidthChip { label: "150%"; selected: Math.abs(screen.previewScale - 1.5) < 0.001; onClicked: screen.previewScale = 1.5 }
                WidthChip { label: "200%"; selected: Math.abs(screen.previewScale - 2.0) < 0.001; onClicked: screen.previewScale = 2.0 }

                Item { Layout.fillWidth: true }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(14)

                ColumnLayout {
                    Layout.preferredWidth: screen.railWidth + 24
                    Layout.fillHeight: true
                    spacing: VfTheme.dp(8)

                    Text {
                        text: "Current QML rail"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Uses the real JobPanelWidget -> JobPanelCard path. This column is the actual rail implementation after the dense-card patch."
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        wrapMode: Text.WordWrap
                    }

                    Rectangle {
                        Layout.preferredWidth: screen.railWidth + 24
                        Layout.fillHeight: true
                        radius: VfTheme.dp(14)
                        color: VfTheme.surface
                        border.color: VfTheme.border

                        JobPanelWidget {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(8)
                            rows: screen.sampleRows
                            stats: ({ total: screen.sampleRows.length, queued: 0, generating: 1, completed: 1, failed: 1 })
                            route: "normal"
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: VfTheme.dp(8)

                    Text {
                        text: "Responsive checks · actual card"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        font.weight: Font.DemiBold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Same JobCardWidget rendered in focused mode. Use width chips to stress layout, and scale chips to inspect 85 / 100 / 150 / 200 percent zoom."
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        wrapMode: Text.WordWrap
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)

                        Repeater {
                            model: screen.sampleRows

                            delegate: WidthChip {
                                required property var modelData
                                required property int index
                                label: String(modelData.title || ("Row " + String(index + 1)))
                                selected: screen.selectedIndex === index
                                onClicked: screen.selectedIndex = index
                            }
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth
                        contentHeight: studyCol.implicitHeight
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        Column {
                            id: studyCol
                            width: Math.max(parent.availableWidth, 480)
                            spacing: VfTheme.dp(12)

                            Repeater {
                                model: [
                                    { label: "Compact · 280px", width: VfTheme.dp(280) },
                                    { label: "Current rail width", width: screen.railWidth },
                                    { label: "Wide rail · 420px", width: VfTheme.dp(420) }
                                ]

                                delegate: Column {
                                    required property var modelData
                                    spacing: VfTheme.dp(6)

                                    Text {
                                        text: String(modelData.label) + " @ " + String(Math.round(screen.previewScale * 100)) + "%"
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(11)
                                        font.weight: Font.DemiBold
                                    }

                                    Item {
                                        width: modelData.width * screen.previewScale
                                        height: liveCard.implicitHeight * screen.previewScale

                                        JobCardWidget {
                                            id: liveCard
                                            width: modelData.width
                                            row: screen.selectedRow()
                                            scale: screen.previewScale
                                            transformOrigin: Item.TopLeft
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: Math.min(parent.width, 460)
                                radius: VfTheme.dp(14)
                                color: VfTheme.surfaceSoft
                                border.color: VfTheme.border
                                implicitHeight: detailNoteColumn.implicitHeight + 20

                                Column {
                                    id: detailNoteColumn
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(12)
                                    spacing: VfTheme.dp(6)

                                    Text {
                                        width: parent.width
                                        text: "Decision from this study"
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(12)
                                        font.weight: Font.Bold
                                    }

                                    Text {
                                        width: parent.width
                                        text: "Queue card should stay focused on thumbnail, state, 7 asset slots, and the four quick actions. Deep scene/output progress still belongs in the selected-row workspace, not inside the rail card."
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(11)
                                        wrapMode: Text.WordWrap
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
