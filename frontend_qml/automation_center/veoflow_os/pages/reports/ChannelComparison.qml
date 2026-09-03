pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "reportChannelComparison"
    clip: true
    property var projection: ({})
    property var channelModel: null
    readonly property int rowCount: root.channelModel ? root.channelModel.count : 0
    signal channelRequested(var link)
    Accessible.name: "So sánh hiệu suất theo kênh"
    Accessible.role: Accessible.Table

    function metricText(metric) {
        const item = metric || ({})
        if (!item.available || item.value === null || item.value === undefined) return "—"
        const value = Math.round(Number(item.value) * 100) / 100
        if (item.unit === "percent") return String(value) + "%"
        if (item.unit && item.unit !== "count") return String(value) + " " + String(item.unit)
        return String(value)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4
        Text { text: "So sánh hiệu suất theo kênh"; color: Theme.text; font.pixelSize: 12; font.weight: Font.Bold }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            Header { text: "KÊNH"; Layout.fillWidth: true }
            Header { text: "XUẤT BẢN"; Layout.preferredWidth: 62 }
            Header { text: "LƯỢT XEM"; Layout.preferredWidth: 74 }
            Header { text: "TƯƠNG TÁC"; Layout.preferredWidth: 70 }
            Header { text: "CHUYỂN ĐỔI"; Layout.preferredWidth: 72 }
            Header { text: "DOANH THU"; Layout.preferredWidth: 90 }
        }
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: 2
            clip: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ColumnLayout {
                width: parent.width
                spacing: 0
                Repeater {
                    model: root.channelModel
                    delegate: Rectangle {
                        id: channelRow
                        required property string channel_id
                        required property string channel_name
                        required property string platform
                        required property var published
                        required property var views
                        required property var engagement_rate
                        required property var conversions
                        required property var estimated_revenue
                        required property var deep_link
                        readonly property string channelId: channelRow.channel_id
                        signal activate()
                        objectName: "reportChannelRow_" + channelRow.channelId
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: rowMouse.containsMouse ? Theme.hover : "transparent"
                        activeFocusOnTab: true
                        Accessible.name: "Kênh " + String(channelRow.channel_name || channelRow.channelId)
                        Accessible.description: "Mở hiệu suất kênh theo deep link server"
                        Accessible.role: Accessible.Row
                        onActivate: {
                            const link = channelRow.deep_link || ({})
                            if (link.route) root.channelRequested(link)
                        }
                        Keys.onSpacePressed: channelRow.activate()
                        Keys.onReturnPressed: channelRow.activate()
                        RowLayout {
                            anchors.fill: parent
                            spacing: 5
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                SocialIcon { platform: String(channelRow.platform || ""); Layout.preferredWidth: 18; Layout.preferredHeight: 18 }
                                Text { Layout.fillWidth: true; text: String(channelRow.channel_name || channelRow.channelId); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            }
                            Metric { value: root.metricText(channelRow.published); widthHint: 62 }
                            Metric { value: root.metricText(channelRow.views); widthHint: 74 }
                            Metric { value: root.metricText(channelRow.engagement_rate); widthHint: 70 }
                            Metric { value: root.metricText(channelRow.conversions); widthHint: 72 }
                            Metric { value: root.metricText(channelRow.estimated_revenue); widthHint: 90 }
                        }
                        MouseArea { id: rowMouse; anchors.fill: parent; enabled: Boolean((channelRow.deep_link || {}).route); hoverEnabled: true; cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor; onClicked: channelRow.activate() }
                    }
                }
                Text { visible: root.rowCount === 0; Layout.fillWidth: true; Layout.preferredHeight: 52; text: "Không có channel facts"; color: Theme.textFaint; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }
    }

    component Header: Text { color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold; elide: Text.ElideRight }
    component Metric: Text {
        required property string value
        required property int widthHint
        Layout.preferredWidth: widthHint
        text: value
        color: value === "—" ? Theme.warning : Theme.textMuted
        font.pixelSize: 11
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
    }
}
