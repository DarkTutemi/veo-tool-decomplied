pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"
import "JobClock.js" as JobClock

// Durable Affiliate conveyor. The model is owned by WorkPanelController
// (QAbstractListModel); this view never polls or mutates a JavaScript list.
AffiliateSection {
    id: pool
    objectName: "affiliateQueuePool"

    property var queueModel: null
    property var stats: ({})
    property var routeConfig: ({})
    property bool pipelineBusy: false
    property string readyProductId: ""
    property string readyProductName: ""
    property int readyVariantCount: 0
    property bool readyToQueue: false
    property string readinessText: "Chọn sản phẩm và chờ chuẩn bị hoàn tất"
    property bool analysisReady: false
    property bool sheetReady: false
    property string characterStatus: "CHAR —"
    property bool characterConfigured: false
    property string backgroundStatus: "BG —"
    property bool backgroundConfigured: false
    readonly property var pipelineLabels: [
        "NHẬP", "SHEET", "PLAN", "ASSET",
        "VOICE", "PACKAGE", "RENDER", "MERGE"
    ]
    readonly property real jobColumnWidth: Math.max(
        VfTheme.dp(360), Math.min(VfTheme.dp(470), width * 0.31)
    )
    readonly property real packageColumnWidth: VfTheme.dp(310)
    readonly property real actionButtonWidth: VfTheme.dp(30)
    // Bộ đếm thời gian job (bắt đầu chạy → hoàn tất). Date.now() là epoch-ms
    // (~1.7e12); QML `int` là int32 và clamp → đồng hồ đứng ở 0s (như CloneWorkspace).
    property double elapsedClockMs: Date.now()
    // 3 icon actions use NormalToolbarButton's icon padding (~38px/button), so
    // 124dp could compress the last button under DPI scaling. Reserve enough
    // width for retry + folder + delete, including cell padding and gaps.
    readonly property real resultColumnWidth: VfTheme.dp(160)

    signal actionRequested(string actionId, var payload)
    signal clearRequested()

    component QueueHeaderLabel: Text {
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontTiny
        font.weight: VfTheme.weightStrong
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    component QueueHeaderCell: Rectangle {
        id: headerCell
        property string label: ""
        property int align: Text.AlignLeft
        implicitWidth: 0
        implicitHeight: 0
        clip: true
        color: "transparent"
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: VfTheme.borderSoft
        }
        QueueHeaderLabel {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(8)
            anchors.rightMargin: VfTheme.dp(8)
            text: headerCell.label
            horizontalAlignment: headerCell.align
        }
    }

    component QueueGridCell: Rectangle {
        id: gridCell
        property int cellPadding: VfTheme.dp(7)
        default property alias contentData: cellContent.data
        implicitWidth: 0
        implicitHeight: 0
        clip: true
        color: "transparent"
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: VfTheme.borderSoft
        }
        Item {
            id: cellContent
            anchors.fill: parent
            anchors.margins: gridCell.cellPadding
        }
    }

    component QueueInfoChip: Rectangle {
        id: infoChip
        property string label: ""
        property bool ready: false
        property color readyColor: VfTheme.greenText
        property color readyFill: VfTheme.greenFill
        implicitWidth: chipText.implicitWidth + VfTheme.dp(8)
        implicitHeight: VfTheme.dp(17)
        radius: height / 2
        color: ready ? readyFill : VfTheme.surfaceSoft
        border.width: 0
        border.color: "transparent"
        Text {
            id: chipText
            anchors.centerIn: parent
            text: infoChip.label
            color: infoChip.ready ? infoChip.readyColor : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(8)
            font.weight: VfTheme.weightStrong
        }
    }

    function nonEmpty(parts) {
        var output = []
        for (var i = 0; i < parts.length; i++) {
            var text = String(parts[i] || "").trim()
            if (text.length > 0)
                output.push(text)
        }
        return output.join(" · ")
    }

    function displayJob(row) {
        return (row || {}).display_job || ({})
    }

    function displayPackage(row) {
        return (row || {}).display_package || ({})
    }

    function rowSourceMeta(row) {
        var job = pool.displayJob(row)
        return pool.nonEmpty([
            job.price,
            job.platform,
            job.shop,
            Number(job.image_count || 0) > 0
                ? Number(job.image_count) + " ảnh" : "",
            String(job.commission_rate || "").length > 0
                ? "HH " + job.commission_rate : "",
            String(job.sold || "").length > 0
                ? job.sold + " bán" : ""
        ])
    }

    function rowCreativeMeta(row) {
        var job = pool.displayJob(row)
        var variant = String(job.variant_index || "")
        return pool.nonEmpty([
            job.video_type,
            variant.length > 0 ? "Biến thể #" + variant : "",
            job.hook
        ])
    }

    function rowPackageMeta(row) {
        var pack = pool.displayPackage(row)
        var scenes = Number(pack.scene_total || 0) > 0
                ? Number(pack.scene_done || 0) + "/"
                  + Number(pack.scene_total || 0) + " cảnh"
                : ""
        var refs = Number(pack.reference_budget || 0) > 0
                ? "max " + Number(pack.reference_budget) + " refs" : ""
        return pool.nonEmpty([
            pack.model,
            pack.aspect_ratio,
            pack.resolution,
            scenes,
            refs
        ])
    }

    function rowPipelineIndex(row) {
        return Math.max(0, Math.min(
            pool.pipelineLabels.length - 1,
            Number((row || {}).pipeline_index || 0)
        ))
    }

    function rowPaused(row) {
        return Boolean((row || {}).paused_no_live_accounts)
                || Boolean((row || {}).submit_gate_paused)
    }

    function rowFailed(row) {
        if (pool.rowPaused(row))
            return false
        var status = String((row || {}).status || "").toLowerCase()
        return String((row || {}).error_message || "").length > 0
                || status.indexOf("fail") >= 0
                || status.indexOf("error") >= 0
    }

    function rowProgress(row) {
        return Math.min(100, Math.max(
            0, Number((row || {}).job_progress || 0)
        ))
    }

    function rowPhaseLabel(row) {
        return String((row || {}).lifecycle_phase || "") === "preparation"
                ? "CHUẨN BỊ" : "SẢN XUẤT"
    }

    function rowStatusLabel(row) {
        var stage = String((row || {}).lifecycle_stage || "").toLowerCase()
        var status = String((row || {}).status || "").toLowerCase()
        if (pool.rowPaused(row))
            return "TẠM DỪNG"
        if (pool.rowFailed(row))
            return "LỖI"
        if (stage === "waiting_submit")
            return "TẠM DỪNG"
        if (stage === "package_ready")
            return "SẴN SÀNG"
        if (stage === "done" || status === "complete" || status === "completed")
            return "HOÀN TẤT"
        if (status === "pending" || status === "queued")
            return "ĐANG CHỜ"
        return String((row || {}).lifecycle_phase || "") === "preparation"
                ? "ĐANG CHUẨN BỊ" : "ĐANG CHẠY"
    }

    function rowVariantLabel(row) {
        var config = (row || {}).config || ({})
        var variant = String((row || {}).variant_index
                             || config.variant_index || "")
        var type = String((row || {}).video_type_label
                          || (row || {}).video_type
                          || config.video_type || "")
        var hook = String((row || {}).hook || "")
        var result = type
        if (variant.length > 0)
            result += (result.length > 0 ? " · " : "") + "Biến thể #" + variant
        if (hook.length > 0)
            result += (result.length > 0 ? " · " : "") + hook
        return result
    }

    function rowImageSource(row) {
        var value = String((row || {}).product_image || "")
        if (value.length === 0)
            return ""
        if (value.indexOf("http://") === 0
                || value.indexOf("https://") === 0
                || value.indexOf("file:") === 0
                || value.indexOf("data:") === 0
                || value.indexOf("qrc:") === 0)
            return value
        return "file:///" + value.replace(/\\/g, "/")
    }

    Layout.fillWidth: true
    Layout.preferredHeight: VfTheme.dp(252)
    Layout.minimumHeight: VfTheme.dp(220)
    Layout.maximumHeight: VfTheme.dp(300)

    accent: VfTheme.amber
    accentFill: VfTheme.amberFill
    badgeText: "③"
    title: (void i18n.revision,
            i18n.t("affiliate.production_pool", "DANH SÁCH CÔNG VIỆC"))
    hint: (void i18n.revision, i18n.t(
        "affiliate.production_pool_hint",
        "Import tự chuẩn bị sản phẩm. Bấm Thêm vào hàng chờ để khóa cấu hình, tài nguyên và mọi biến thể; Tự động hoá quy trình BẬT chạy cuốn chiếu job đã khóa, TẮT thì bấm Bắt đầu xử lí sản phẩm để chạy thủ công."
    ))

    // Header theo DÒNG PIPELINE: [phá hủy] → [chế độ: Tự động] → [bước: chạy].
    // Tự động BẬT → hệ thống tự cuốn chiếu (nút thủ công ẩn); TẮT → BẮT ĐẦU XỬ LÍ.
    headerActions: [
        NormalToolbarButton {
            compact: true
            text: "🗑 " + (void i18n.revision,
                           i18n.t("affiliate.clear_all", "XOÁ DANH SÁCH SẢN PHẨM"))
            danger: true
            onClicked: pool.clearRequested()
        },
        NormalToolbarButton {
            actionId: "affiliate.queue.autopilot"
            compact: true
            text: Boolean((pool.routeConfig || {}).auto_pool_enabled)
                  ? "⚡ " + (void i18n.revision,
                              i18n.t("affiliate.auto_pool_on", "TỰ ĐỘNG HOÁ QUY TRÌNH: BẬT"))
                  : "○ " + (void i18n.revision,
                             i18n.t("affiliate.auto_pool_off", "TỰ ĐỘNG HOÁ QUY TRÌNH: TẮT"))
            selected: Boolean((pool.routeConfig || {}).auto_pool_enabled)
            tooltip: (void i18n.revision, i18n.t(
                "affiliate.auto_pool_tip",
                "Bật: tự submit và render cuốn chiếu các job đã khóa. Tắt: sản phẩm vẫn được chuẩn bị, job chỉ chạy khi bấm Bắt đầu xử lí; job đã submit không bị huỷ."
            ))
            onClicked: pool.actionRequested(
                "work_panel.affiliate_auto_pool_toggle",
                { enabled: !Boolean((pool.routeConfig || {}).auto_pool_enabled) }
            )
        },
        // Chạy THỦ CÔNG — chỉ hiện khi Tự động TẮT (một lái duy nhất tại mỗi thời điểm).
        NormalToolbarButton {
            compact: true
            text: "▶ " + (void i18n.revision,
                           i18n.t("affiliate.start_manual", "BẮT ĐẦU XỬ LÍ SẢN PHẨM"))
            visible: !Boolean((pool.routeConfig || {}).auto_pool_enabled)
            blocked: queueList.count <= 0
            blockedTooltip: (void i18n.revision, i18n.t(
                "affiliate.start_manual_empty",
                "Danh sách trống — bấm Thêm vào công việc để chốt job trước."
            ))
            tooltip: (void i18n.revision, i18n.t(
                "affiliate.start_manual_tip",
                "Chạy ngay thủ công: bắt đầu các job đang chờ và mở submit-gate cho package chờ duyệt. Không phân tích hay đóng gói lại."
            ))
            onClicked: pool.actionRequested(
                "work_panel.affiliate_continue_submit",
                {}
            )
        }
    ]

    // Tick 1Hz CHỈ cập nhật text hiển thị (elapsedClockMs) — không đụng model
    // (Law 3: model là QAbstractListModel event-driven; timer chỉ làm đồng hồ).
    Timer {
        interval: 1000
        repeat: true
        running: pool.visible && queueList.count > 0
        onRunningChanged: pool.elapsedClockMs = Date.now()
        onTriggered: pool.elapsedClockMs = Date.now()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(8)
        anchors.topMargin: VfTheme.dp(45)
        spacing: VfTheme.dp(6)

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(7)

            NormalToolbarButton {
                id: admitButton
                actionId: "affiliate.queue.admit"
                text: pool.readyVariantCount > 0
                      ? "＋ Thêm vào công việc (" + pool.readyVariantCount + ")"
                      : "＋ Thêm vào công việc"
                selected: pool.readyToQueue
                blocked: !pool.readyToQueue || pool.pipelineBusy
                blockedTooltip: pool.readinessText
                minWidth: VfTheme.dp(190)
                Layout.preferredWidth: VfTheme.dp(190)
                Layout.minimumWidth: VfTheme.dp(190)
                tooltip: pool.readinessText
                onClicked: pool.actionRequested(
                    "work_panel.affiliate_manual_enqueue",
                    { product_id: pool.readyProductId }
                )
            }

            Flow {
                visible: pool.readyProductId.length > 0
                Layout.preferredWidth: Math.min(
                    VfTheme.dp(340), Math.max(VfTheme.dp(230), pool.width * 0.24)
                )
                Layout.minimumWidth: VfTheme.dp(230)
                Layout.preferredHeight: implicitHeight
                spacing: VfTheme.dp(4)
                QueueInfoChip {
                    label: pool.analysisReady ? "SP ✓" : "SP …"
                    ready: pool.analysisReady
                }
                QueueInfoChip {
                    label: pool.sheetReady ? "SHEET ✓" : "SHEET …"
                    ready: pool.sheetReady
                }
                QueueInfoChip {
                    label: pool.readyVariantCount > 0
                           ? pool.readyVariantCount + " VAR" : "VAR —"
                    ready: pool.readyVariantCount > 0
                }
                QueueInfoChip {
                    label: pool.characterStatus
                    ready: pool.characterConfigured
                    readyColor: pool.characterStatus.indexOf("AUTO") >= 0
                                ? VfTheme.cyanText : VfTheme.greenText
                    readyFill: pool.characterStatus.indexOf("AUTO") >= 0
                               ? VfTheme.cyanFill : VfTheme.greenFill
                }
                QueueInfoChip {
                    label: pool.backgroundStatus
                    ready: pool.backgroundConfigured
                    readyColor: pool.backgroundStatus.indexOf("AUTO") >= 0
                                ? VfTheme.cyanText : VfTheme.greenText
                    readyFill: pool.backgroundStatus.indexOf("AUTO") >= 0
                               ? VfTheme.cyanFill : VfTheme.greenFill
                }
            }

            Rectangle {
                id: activityDot
                readonly property bool busy: pool.pipelineBusy
                                             || Number((pool.stats || {}).generating || 0) > 0
                Layout.preferredWidth: VfTheme.dp(9)
                Layout.preferredHeight: VfTheme.dp(9)
                radius: width / 2
                color: busy ? VfTheme.amber : VfTheme.greenBorder
                SequentialAnimation on opacity {
                    running: activityDot.busy && VfTheme.motion
                    loops: Animation.Infinite
                    alwaysRunToEnd: true
                    NumberAnimation { to: 0.3; duration: 650; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 1.0; duration: 650; easing.type: Easing.InOutQuad }
                }
                onBusyChanged: if (!busy) opacity = 1
            }
            Text {
                Layout.fillWidth: true
                text: {
                    if (pool.pipelineBusy)
                        return String((pool.routeConfig || {})._generating_status
                                      || "Đang chuẩn bị sản phẩm kế tiếp…")
                    if (pool.readyProductId.length > 0)
                        return pool.readinessText
                    return "Chọn một sản phẩm để kiểm tra và chốt vào hàng chờ"
                }
                color: pool.pipelineBusy ? VfTheme.amberText : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
                elide: Text.ElideRight
            }
            Repeater {
                model: [
                    { label: "Chuẩn bị", value: Number((pool.routeConfig || {})._lifecycle_preparing || 0), error: false },
                    { label: "Package", value: Number((pool.routeConfig || {})._lifecycle_package_ready || 0), error: false },
                    { label: "Chạy", value: Number((pool.stats || {}).generating || 0), error: false },
                    { label: "Chờ", value: Number((pool.stats || {}).pending || 0), error: false },
                    { label: "Lỗi", value: Number((pool.stats || {}).failed || 0)
                                               + Number((pool.routeConfig || {})._lifecycle_failed || 0), error: true }
                ]
                Rectangle {
                    required property var modelData
                    Layout.preferredWidth: statText.implicitWidth + VfTheme.dp(10)
                    Layout.preferredHeight: VfTheme.dp(18)
                    radius: height / 2
                    color: VfTheme.surfaceSoft
                    border.width: modelData.error && modelData.value > 0 ? 1 : 0
                    border.color: modelData.error && modelData.value > 0
                                  ? VfTheme.redBorder : "transparent"
                    Text {
                        id: statText
                        anchors.centerIn: parent
                        text: modelData.label + " " + modelData.value
                        color: modelData.error && modelData.value > 0
                               ? VfTheme.redText : VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontTiny
                        font.weight: VfTheme.weightStrong
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(25)
            color: VfTheme.surfaceSoft
            border.width: 1
            border.color: VfTheme.borderSoft

            RowLayout {
                anchors.fill: parent
                spacing: 0

                QueueHeaderCell {
                    label: "#"
                    align: Text.AlignHCenter
                    Layout.preferredWidth: VfTheme.dp(34)
                    Layout.minimumWidth: VfTheme.dp(34)
                    Layout.maximumWidth: VfTheme.dp(34)
                    Layout.fillHeight: true
                }
                QueueHeaderCell {
                    label: "JOB / NGUỒN / BIẾN THỂ"
                    Layout.preferredWidth: pool.jobColumnWidth
                    Layout.minimumWidth: pool.jobColumnWidth
                    Layout.maximumWidth: pool.jobColumnWidth
                    Layout.fillHeight: true
                }
                QueueHeaderCell {
                    label: "PIPELINE THỰC THI / CÔNG VIỆC HIỆN TẠI"
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.fillHeight: true
                }
                QueueHeaderCell {
                    label: "PRODUCTION PACKAGE / LIVE"
                    Layout.preferredWidth: pool.packageColumnWidth
                    Layout.minimumWidth: pool.packageColumnWidth
                    Layout.maximumWidth: pool.packageColumnWidth
                    Layout.fillHeight: true
                }
                QueueHeaderCell {
                    label: "KẾT QUẢ / THAO TÁC"
                    align: Text.AlignHCenter
                    Layout.preferredWidth: pool.resultColumnWidth
                    Layout.minimumWidth: pool.resultColumnWidth
                    Layout.maximumWidth: pool.resultColumnWidth
                    Layout.fillHeight: true
                }
            }
        }

        ListView {
            id: queueList
            objectName: "affiliateQueueList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            spacing: 0
            model: pool.queueModel
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Text {
                anchors.centerIn: parent
                visible: queueList.count === 0
                text: pool.pipelineBusy
                      ? "Sản phẩm đầu tiên đang được chuẩn bị…"
                      : "Chưa có job · chọn sản phẩm đã sẵn sàng rồi bấm Thêm vào hàng chờ"
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
            }

            delegate: Rectangle {
                id: queueRowDelegate
                required property int index
                required property var qrow
                readonly property string rowIdentity: String(
                    (qrow || {}).id || (qrow || {}).row_id
                    || (qrow || {}).batch_id || ""
                )
                readonly property bool focused:
                    String((qrow || {}).row_kind || "") !== "preparation"
                    && rowIdentity.length > 0
                    && rowIdentity === String(
                        (pool.routeConfig || {})._active_variant_batch_id || ""
                    )

                width: ListView.view.width
                height: VfTheme.dp(64)
                color: focused
                       ? VfTheme.blueFill
                       : (index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft)
                border.width: focused ? 1 : 0
                border.color: focused ? VfTheme.blueBorder : "transparent"

                TapHandler {
                    enabled: String((queueRowDelegate.qrow || {}).row_kind || "")
                             !== "preparation"
                    gesturePolicy: TapHandler.ReleaseWithinBounds
                    onTapped: function(eventPoint, button) {
                        // The result column owns retry/folder/delete buttons.
                        if (eventPoint.position.x
                                >= queueRowDelegate.width - pool.resultColumnWidth)
                            return
                        pool.actionRequested(
                            "work_panel.affiliate_focus_variant",
                            { row_id: queueRowDelegate.rowIdentity }
                        )
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: VfTheme.dp(3)
                    color: pool.rowFailed(queueRowDelegate.qrow)
                           ? VfTheme.redBorder
                           : (String((queueRowDelegate.qrow || {}).lifecycle_phase || "") === "preparation"
                              ? VfTheme.violet : VfTheme.amber)
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: VfTheme.borderSoft
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    QueueGridCell {
                        Layout.preferredWidth: VfTheme.dp(34)
                        Layout.minimumWidth: VfTheme.dp(34)
                        Layout.maximumWidth: VfTheme.dp(34)
                        Layout.fillHeight: true
                        cellPadding: 0
                        Text {
                            anchors.centerIn: parent
                            text: String(queueRowDelegate.index + 1)
                            horizontalAlignment: Text.AlignHCenter
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                        }
                    }

                    QueueGridCell {
                        Layout.preferredWidth: pool.jobColumnWidth
                        Layout.minimumWidth: pool.jobColumnWidth
                        Layout.maximumWidth: pool.jobColumnWidth
                        Layout.fillHeight: true
                        RowLayout {
                            anchors.fill: parent
                            spacing: VfTheme.dp(7)

                            Rectangle {
                                Layout.preferredWidth: VfTheme.dp(40)
                                Layout.preferredHeight: VfTheme.dp(40)
                                radius: VfTheme.dp(5)
                                color: VfTheme.surfaceSoft
                                border.width: 1
                                border.color: VfTheme.borderSoft
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: pool.rowImageSource(queueRowDelegate.qrow)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    sourceSize.width: 96
                                    sourceSize.height: 96
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Text {
                                    Layout.fillWidth: true
                                    text: String((queueRowDelegate.qrow || {}).product_name
                                                 || (queueRowDelegate.qrow || {}).name || "Video")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: VfTheme.weightStrong
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: pool.rowSourceMeta(queueRowDelegate.qrow)
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: pool.rowCreativeMeta(queueRowDelegate.qrow)
                                    color: VfTheme.violet
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }

                    QueueGridCell {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: VfTheme.dp(4)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(3)
                                Repeater {
                                    model: pool.pipelineLabels
                                    Rectangle {
                                        id: pipelineStep
                                        required property int index
                                        required property string modelData
                                        readonly property int currentStep:
                                            pool.rowPipelineIndex(queueRowDelegate.qrow)
                                        readonly property bool done: index < currentStep
                                        readonly property bool active: index === currentStep

                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(20)
                                        radius: VfTheme.dp(4)
                                        color: pool.rowFailed(queueRowDelegate.qrow)
                                               && pipelineStep.active
                                               ? VfTheme.redFill
                                               : (pipelineStep.done
                                                  ? VfTheme.greenFill
                                                  : (pipelineStep.active
                                                     ? (String((queueRowDelegate.qrow || {}).lifecycle_phase || "") === "preparation"
                                                        ? VfTheme.violetFill : VfTheme.amberFill)
                                                     : VfTheme.surfaceSoft))
                                        border.width: 1
                                        border.color: pool.rowFailed(queueRowDelegate.qrow)
                                                      && pipelineStep.active
                                                      ? VfTheme.redBorder
                                                      : (pipelineStep.done
                                                         ? VfTheme.greenBorder
                                                         : (pipelineStep.active
                                                            ? (String((queueRowDelegate.qrow || {}).lifecycle_phase || "") === "preparation"
                                                               ? VfTheme.violetBorder : VfTheme.amberBorder)
                                                            : VfTheme.borderSoft))
                                        Text {
                                            anchors.centerIn: parent
                                            text: pipelineStep.modelData
                                            color: pool.rowFailed(queueRowDelegate.qrow)
                                                   && pipelineStep.active
                                                   ? VfTheme.redText
                                                   : (pipelineStep.done
                                                      ? VfTheme.greenText
                                                      : (pipelineStep.active
                                                         ? VfTheme.text : VfTheme.textMuted))
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(7)
                                            font.weight: VfTheme.weightStrong
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(6)
                                Text {
                                    Layout.fillWidth: true
                                    text: {
                                        var error = String((queueRowDelegate.qrow || {}).error_message || "")
                                        var message = pool.rowPaused(queueRowDelegate.qrow)
                                                ? String((queueRowDelegate.qrow || {}).progress_message
                                                         || "Thêm hoặc bật tài khoản Live, sau đó bấm Tiếp tục")
                                                : error.length > 0
                                                ? error
                                                : String((queueRowDelegate.qrow || {}).stage_label
                                                         || (queueRowDelegate.qrow || {}).progress_message
                                                         || (queueRowDelegate.qrow || {}).status
                                                         || "Chờ")
                                        return pool.rowPhaseLabel(queueRowDelegate.qrow)
                                                + " · " + message
                                    }
                                    color: pool.rowFailed(queueRowDelegate.qrow)
                                           ? VfTheme.redText
                                           : (pool.rowPaused(queueRowDelegate.qrow)
                                              ? VfTheme.amberText : VfTheme.textSubtle)
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    elide: Text.ElideRight
                                }
                                Rectangle {
                                    Layout.preferredWidth: VfTheme.dp(96)
                                    Layout.preferredHeight: VfTheme.dp(5)
                                    radius: height / 2
                                    color: VfTheme.borderSoft
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: parent.width
                                               * pool.rowProgress(queueRowDelegate.qrow) / 100
                                        radius: parent.radius
                                        color: pool.rowFailed(queueRowDelegate.qrow)
                                               ? VfTheme.redBorder : VfTheme.greenBorder
                                    }
                                }
                                Text {
                                    text: pool.rowProgress(queueRowDelegate.qrow) + "%"
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.weight: VfTheme.weightStrong
                                }
                                // ⏱ thời gian chạy: từ started_at (backend stamp lúc
                                // job bắt đầu) đến khi hoàn tất (đóng băng ở terminal).
                                Text {
                                    visible: JobClock.timestampMs(
                                                 (queueRowDelegate.qrow || {}).started_at) > 0
                                    text: {
                                        void pool.elapsedClockMs
                                        return "⏱ " + JobClock.rowElapsedLabel(
                                            queueRowDelegate.qrow,
                                            pool.elapsedClockMs,
                                            String((queueRowDelegate.qrow || {}).status || "")
                                        )
                                    }
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.weight: VfTheme.weightStrong
                                }
                            }
                        }
                    }

                    QueueGridCell {
                        Layout.preferredWidth: pool.packageColumnWidth
                        Layout.minimumWidth: pool.packageColumnWidth
                        Layout.maximumWidth: pool.packageColumnWidth
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: VfTheme.dp(4)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(4)
                                QueueInfoChip {
                                    readonly property var pack:
                                        pool.displayPackage(queueRowDelegate.qrow)
                                    label: "OBJ " + Number(pack.objects || 0)
                                    ready: Number(pack.objects || 0) > 0
                                }
                                QueueInfoChip {
                                    readonly property var pack:
                                        pool.displayPackage(queueRowDelegate.qrow)
                                    label: "CHAR " + Number(pack.characters || 0)
                                    ready: Number(pack.characters || 0) > 0
                                    readyColor: VfTheme.violet
                                    readyFill: VfTheme.violetFill
                                }
                                QueueInfoChip {
                                    readonly property var pack:
                                        pool.displayPackage(queueRowDelegate.qrow)
                                    label: "BG " + Number(pack.backgrounds || 0)
                                    ready: Number(pack.backgrounds || 0) > 0
                                    readyColor: VfTheme.cyan
                                    readyFill: VfTheme.cyanFill
                                }
                                QueueInfoChip {
                                    readonly property var pack:
                                        pool.displayPackage(queueRowDelegate.qrow)
                                    label: String(pack.narrator || "").length > 0
                                           ? "NAR " + String(pack.narrator)
                                           : "NAR —"
                                    ready: String(pack.narrator || "").length > 0
                                    readyColor: VfTheme.amberText
                                    readyFill: VfTheme.amberFill
                                }
                                Item { Layout.fillWidth: true }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: pool.rowPackageMeta(queueRowDelegate.qrow)
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                elide: Text.ElideRight
                            }
                        }
                    }

                    QueueGridCell {
                        Layout.preferredWidth: pool.resultColumnWidth
                        Layout.minimumWidth: pool.resultColumnWidth
                        Layout.maximumWidth: pool.resultColumnWidth
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: VfTheme.dp(4)

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(21)
                            radius: height / 2
                            color: pool.rowFailed(queueRowDelegate.qrow)
                                   ? VfTheme.redFill
                                   : (pool.rowPaused(queueRowDelegate.qrow)
                                      ? VfTheme.amberFill
                                      : (pool.rowProgress(queueRowDelegate.qrow) >= 100
                                         ? VfTheme.greenFill : VfTheme.surfaceSoft))
                            border.width: 1
                            border.color: pool.rowFailed(queueRowDelegate.qrow)
                                          ? VfTheme.redBorder
                                          : (pool.rowPaused(queueRowDelegate.qrow)
                                             ? VfTheme.amberBorderSoft
                                             : (pool.rowProgress(queueRowDelegate.qrow) >= 100
                                                ? VfTheme.greenBorder : VfTheme.borderSoft))
                            Text {
                                anchors.centerIn: parent
                                text: pool.rowStatusLabel(queueRowDelegate.qrow)
                                color: pool.rowFailed(queueRowDelegate.qrow)
                                       ? VfTheme.redText
                                       : (pool.rowPaused(queueRowDelegate.qrow)
                                          ? VfTheme.amberText
                                          : (pool.rowProgress(queueRowDelegate.qrow) >= 100
                                             ? VfTheme.greenText : VfTheme.textSubtle))
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: VfTheme.weightStrong
                            }
                        }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(3)
                                Item { Layout.fillWidth: true }
                                NormalToolbarButton {
                                    visible: String((queueRowDelegate.qrow || {}).merged_video || "").length > 0
                                    compact: true
                                    text: "▶"
                                    selected: true
                                    minWidth: pool.actionButtonWidth
                                    Layout.preferredWidth: pool.actionButtonWidth
                                    Layout.minimumWidth: pool.actionButtonWidth
                                    Layout.maximumWidth: pool.actionButtonWidth
                                    onClicked: pool.actionRequested(
                                        "work_panel.affiliate_open_path",
                                        { path: String(queueRowDelegate.qrow.merged_video) }
                                    )
                                }
                                NormalToolbarButton {
                                    visible: pool.rowFailed(queueRowDelegate.qrow)
                                    compact: true
                                    text: "↻"
                                    minWidth: pool.actionButtonWidth
                                    Layout.preferredWidth: pool.actionButtonWidth
                                    Layout.minimumWidth: pool.actionButtonWidth
                                    Layout.maximumWidth: pool.actionButtonWidth
                                    tooltip: String((queueRowDelegate.qrow || {}).row_kind || "") === "preparation"
                                             ? "Chuẩn bị lại sản phẩm"
                                             : "Chạy lại chỉ scene lỗi"
                                    onClicked: pool.actionRequested(
                                        String((queueRowDelegate.qrow || {}).retry_action
                                               || "work_panel.affiliate_retry_failed"),
                                        String((queueRowDelegate.qrow || {}).row_kind || "") === "preparation"
                                        ? { product_id: String((queueRowDelegate.qrow || {}).product_id || "") }
                                        : { row_id: String((queueRowDelegate.qrow || {}).id
                                                           || (queueRowDelegate.qrow || {}).row_id
                                                           || (queueRowDelegate.qrow || {}).batch_id || "") }
                                    )
                                }
                                NormalToolbarButton {
                                    visible: String((queueRowDelegate.qrow || {}).row_kind || "") !== "preparation"
                                    compact: true
                                    text: "📁"
                                    minWidth: pool.actionButtonWidth
                                    Layout.preferredWidth: pool.actionButtonWidth
                                    Layout.minimumWidth: pool.actionButtonWidth
                                    Layout.maximumWidth: pool.actionButtonWidth
                                    onClicked: pool.actionRequested(
                                        "work_panel.affiliate_open_path",
                                        { path: String((queueRowDelegate.qrow || {}).output_folder || "") }
                                    )
                                }
                                NormalToolbarButton {
                                    visible: String((queueRowDelegate.qrow || {}).row_kind || "") !== "preparation"
                                    compact: true
                                    text: "🗑"
                                    danger: true
                                    minWidth: pool.actionButtonWidth
                                    Layout.preferredWidth: pool.actionButtonWidth
                                    Layout.minimumWidth: pool.actionButtonWidth
                                    Layout.maximumWidth: pool.actionButtonWidth
                                    onClicked: pool.actionRequested(
                                        "work_panel.queue_delete_row",
                                        {
                                            row_id: String((queueRowDelegate.qrow || {}).id
                                                           || (queueRowDelegate.qrow || {}).row_id
                                                           || (queueRowDelegate.qrow || {}).batch_id || ""),
                                            row: queueRowDelegate.qrow
                                        }
                                    )
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }
        }
    }
}
