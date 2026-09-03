import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "theme"

ApplicationWindow {
    id: appWindow
    visible: true
    width: 420
    height: 900
    title: "Job Panel Stress — 50 jobs"
    color: VfTheme.bgPrimary

    property int tickCount: 0
    property real lastFrameMs: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: VfTheme.bgSecondary

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8

                Text {
                    text: "STRESS TEST: " + 50 + " jobs"
                    color: VfTheme.textPrimary
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    font.family: VfTheme.fontFamily
                }
                Item { Layout.fillWidth: true }
                Text {
                    id: fpsLabel
                    text: "tick #" + appWindow.tickCount + "  frame: " + appWindow.lastFrameMs.toFixed(1) + "ms"
                    color: VfTheme.textMuted
                    font.pixelSize: 11
                    font.family: VfTheme.fontFamily
                }
            }
        }

        JobPanelWidget {
            id: jobPanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            jobModel: stressModel
            route: "normal"
        }
    }
}
