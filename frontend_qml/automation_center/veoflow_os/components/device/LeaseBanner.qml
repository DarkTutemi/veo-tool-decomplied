import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "deviceLeaseBanner"

    property string leaseId: ""
    property string holderLabel: ""
    property string leaseState: "unknown"
    property int remainingSeconds: -1
    property int fencingToken: 0
    property bool ownedByOperator: false
    property bool demoReadOnly: false
    property bool visualProductionFixture: false
    property string fixtureOwnerLabel: ""
    property string fixtureSinceLabel: ""
    property bool compact: false
    property bool showExtendAction: false
    property bool extendActionEnabled: false
    property bool extendBusy: false
    property string extendActionObjectName: "deviceLeaseExtendButton"
    signal extendRequested()

    readonly property string normalizedState: StatusCatalog.normalize(root.leaseState)
    readonly property bool activeShapeValid: root.leaseId.length > 0
        && root.remainingSeconds > 0 && root.fencingToken > 0
    readonly property string effectiveState:
        root.demoReadOnly && !root.visualProductionFixture ? "demo_only"
        : (["active", "expiring"].indexOf(root.normalizedState) >= 0
            ? (root.activeShapeValid ? root.normalizedState : "unknown")
            : (["none", "expired", "stale"].indexOf(root.normalizedState) >= 0
                ? root.normalizedState : "unknown"))
    readonly property bool controlEligible: !root.demoReadOnly
        && root.ownedByOperator && root.activeShapeValid
        && ["active", "expiring"].indexOf(root.effectiveState) >= 0
    readonly property color statusTone: StatusCatalog.tone(root.effectiveState)
    readonly property string ownerText: root.holderLabel.trim().length > 0
        ? root.holderLabel.trim() : "Holder chưa xác minh"
    readonly property string remainingText: root.activeShapeValid
        ? root.formatRemaining(root.remainingSeconds) : "Thời hạn không hợp lệ"
    readonly property string primaryText:
        root.visualProductionFixture && root.fixtureOwnerLabel.length > 0
        ? "Thiết bị đang được khóa bởi " + root.fixtureOwnerLabel
        : root.demoReadOnly && !root.visualProductionFixture ? "Lease chỉ xem"
        : (root.effectiveState === "active" || root.effectiveState === "expiring"
            ? (root.ownedByOperator ? "Lease của bạn" : "Lease đang hoạt động")
            : "Lease " + StatusCatalog.label(root.effectiveState))
    readonly property string secondaryText: root.visualProductionFixture
            && root.activeShapeValid && root.fixtureSinceLabel.length > 0
        ? root.fixtureSinceLabel + " · " + root.remainingText
        : root.activeShapeValid
        ? root.ownerText + " · " + root.remainingText
        : "Lease ID, thời hạn hoặc fencing token không hợp lệ"

    function formatRemaining(seconds) {
        const value = Math.max(0, Math.floor(Number(seconds || 0)))
        if (value < 60)
            return "Còn " + String(value) + " giây"
        const minutes = Math.floor(value / 60)
        if (minutes < 60)
            return "Còn " + String(minutes) + " phút"
        const hours = Math.floor(minutes / 60)
        const remainder = minutes % 60
        return "Còn " + String(hours) + " giờ"
            + (remainder > 0 ? " " + String(remainder) + " phút" : "")
    }

    implicitWidth: 360
    implicitHeight: root.compact ? 52 : 60
    radius: 5
    color: root.visualProductionFixture
        ? Theme.accentSoft
        : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
    border.width: 1
    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.62)
    Accessible.name: root.visualProductionFixture && root.demoReadOnly
        ? root.primaryText + ", " + root.secondaryText
            + ", fixture production mô phỏng; điều khiển vẫn bị khóa"
        : root.demoReadOnly
        ? "Lease DEMO, chỉ xem, " + root.secondaryText
        : (root.effectiveState === "active" || root.effectiveState === "expiring"
            ? root.primaryText + ", " + root.secondaryText
            : "Lease " + StatusCatalog.label(root.effectiveState))
    Accessible.role: Accessible.StaticText

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 9
        UiIcon {
            objectName: "deviceLeaseIcon"
            name: "ui/lock"
            tone: Theme.accent
            iconSize: 18
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                Layout.fillWidth: true
                text: root.primaryText
                color: Theme.accent
                font.pixelSize: 12
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.secondaryText
                color: root.activeShapeValid
                    ? Qt.lighter(Theme.accent, 1.18) : Theme.warning
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
        Button {
            id: extendButton
            objectName: root.extendActionObjectName
            property bool visualEnabled: enabled
                || (root.visualProductionFixture && root.activeShapeValid)
            visible: root.showExtendAction
            Layout.preferredWidth: visible ? 86 : 0
            Layout.preferredHeight: 34
            implicitWidth: 86
            implicitHeight: 34
            padding: 0
            text: root.extendBusy ? "Đang gia hạn…" : "Gia hạn"
            activeFocusOnTab: visible
            enabled: visible && root.extendActionEnabled && root.controlEligible
                && !root.extendBusy
            Accessible.name: "Gia hạn lease"
            Accessible.description: root.demoReadOnly
                ? "Không khả dụng trong dữ liệu DEMO chỉ xem"
                : enabled
                    ? "Gia hạn lease bằng fencing token hiện tại"
                    : "Lease không hợp lệ, thiếu quyền hoặc đang xử lý"
            onClicked: root.extendRequested()

            background: Rectangle {
                radius: 4
                color: extendButton.enabled && (extendButton.down || extendButton.hovered)
                    ? Theme.accentSoft : "transparent"
                border.width: 1
                border.color: extendButton.visualEnabled
                    ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.70)
                    : Qt.rgba(Theme.textFaint.r, Theme.textFaint.g, Theme.textFaint.b, 0.36)
            }
            contentItem: Text {
                text: extendButton.text
                color: extendButton.visualEnabled ? Theme.text : Theme.textFaint
                font.pixelSize: 11
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Item {
            objectName: "deviceLeaseStatusBadge"
            visible: false
        }
    }
}
