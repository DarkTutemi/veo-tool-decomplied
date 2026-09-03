import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    objectName: "asyncStateView"
    default property alias contentData: contentHost.data
    property string viewState: "loading"
    property bool hasData: false
    property string accessibleName: "Vùng nội dung"
    property string emptyTitle: "Chưa có dữ liệu"
    property string emptyDescription: "Dữ liệu sẽ xuất hiện tại đây khi sẵn sàng."
    property string emptyIconName: "semantic/info"
    property string emptyEyebrow: "SẴN SÀNG BẮT ĐẦU"
    property var emptyGuidance: []
    property string emptyActionText: ""
    property string emptyActionIconName: "ui/plus"
    property bool emptyActionEnabled: true
    property string emptyActionReason: ""
    property string emptySecondaryActionText: ""
    property string emptySecondaryActionIconName: "ui/refresh-cw"
    property bool emptySecondaryActionEnabled: true
    property string emptySecondaryActionReason: ""
    property string errorMessage: "Không thể tải dữ liệu."
    property string requiredPermission: ""
    property bool freshnessBannerEnabled: true
    signal retry()
    signal emptyAction()
    signal emptySecondaryAction()
    readonly property bool knownState: ["loading", "empty", "content", "partial", "stale", "offline", "error", "permission"].indexOf(viewState) >= 0
    readonly property bool showContent: hasData && ["content", "partial", "stale", "offline", "error"].indexOf(viewState) >= 0
    readonly property bool showEmpty: !hasData && ["empty", "content", "partial", "stale"].indexOf(viewState) >= 0
    readonly property bool showError: !showContent && (["error", "offline"].indexOf(viewState) >= 0 || !knownState)
    readonly property bool showFreshnessBanner: showContent && ["partial", "stale", "offline", "error"].indexOf(viewState) >= 0
    Accessible.name: accessibleName
    Accessible.role: Accessible.Client

    Item {
        id: contentHost
        objectName: "asyncContentHost"
        anchors.fill: parent
        visible: root.showContent
    }

    ColumnLayout {
        objectName: "asyncLoadingState"
        visible: root.viewState === "loading"
        anchors.fill: parent; anchors.margins: 24; spacing: 14
        Repeater {
            model: 7
            delegate: Skeleton {
                required property int index
                Layout.fillWidth: true
                Layout.preferredHeight: index === 0 ? 30 : 16
            }
        }
        Item { Layout.fillHeight: true }
    }
    EmptyState {
        objectName: "asyncEmptyState"
        anchors.fill: parent
        visible: root.showEmpty
        title: root.emptyTitle
        description: root.emptyDescription
        iconName: root.emptyIconName
        eyebrow: root.emptyEyebrow
        guidance: root.emptyGuidance
        actionText: root.emptyActionText
        actionIconName: root.emptyActionIconName
        actionEnabled: root.emptyActionEnabled
        actionReason: root.emptyActionReason
        secondaryActionText: root.emptySecondaryActionText
        secondaryActionIconName: root.emptySecondaryActionIconName
        secondaryActionEnabled: root.emptySecondaryActionEnabled
        secondaryActionReason: root.emptySecondaryActionReason
        onActionTriggered: root.emptyAction()
        onSecondaryActionTriggered: root.emptySecondaryAction()
    }
    ErrorState {
        objectName: "asyncErrorState"
        anchors.fill: parent
        visible: root.showError
        message: root.viewState === "offline"
            ? "Không có dữ liệu đã lưu để dùng khi ngoại tuyến."
            : root.errorMessage
        onRetry: root.retry()
    }
    PermissionState {
        objectName: "asyncPermissionState"
        anchors.fill: parent
        visible: root.viewState === "permission"
        permission: root.requiredPermission
    }

    Rectangle {
        objectName: "asyncFreshnessBanner"
        visible: root.freshnessBannerEnabled && root.showFreshnessBanner
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 24, bannerText.implicitWidth + 28); height: 30; radius: 8
        color: ["offline", "error"].indexOf(root.viewState) >= 0 ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.16) : Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.14)
        border.width: 1; border.color: ["offline", "error"].indexOf(root.viewState) >= 0 ? Theme.danger : Theme.warning
        Text {
            id: bannerText
            anchors.centerIn: parent
            text: root.viewState === "offline"
                ? "Ngoại tuyến · đang hiển thị dữ liệu gần nhất"
                : root.viewState === "error"
                    ? "Làm mới thất bại · đang hiển thị dữ liệu gần nhất"
                    : root.viewState === "stale"
                        ? "Dữ liệu có thể đã cũ"
                        : "Một phần nguồn dữ liệu chưa sẵn sàng"
            color: ["offline", "error"].indexOf(root.viewState) >= 0 ? Theme.danger : Theme.warning
            font.pixelSize: 11
        }
    }
}
