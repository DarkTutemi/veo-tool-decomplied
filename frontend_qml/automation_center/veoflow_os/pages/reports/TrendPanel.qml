pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "reportTrendPanel"
    clip: true
    property var trend: ({})
    property var scope: ({})
    property var filterCatalog: ({})
    property string snapshotId: ""
    property var pointModel: null
    property int pointRevision: 0
    property var hiddenPlatforms: ({})
    property int legendRevision: 0
    property var hitPoints: []
    property var hoveredPoint: null
    property var presentationOverrides: ({})
    readonly property string metricValue: String(metricSelector.currentValue || "views")
    readonly property string granularityValue: String(granularitySelector.currentValue || "day")
    readonly property var controls: root.trend.controls || ({})
    readonly property var seriesDescriptors: root.trend.series || []
    readonly property var seriesPlatforms: root.seriesDescriptors.map(
        item => String((item || {}).platform || "unknown")
    )
    readonly property int seriesCount: root.seriesPlatforms.length
    readonly property int pointCount: root.pointModel ? root.pointModel.count : 0
    readonly property real plotLeft: 42
    readonly property real plotRight: 8
    readonly property real plotTop: 8
    readonly property real plotBottom: 24
    readonly property int plotGridLineCount: 5
    readonly property real pointMarkerRadius: 2.5
    readonly property bool gridEnabled: root.presentationEnabled("grid", true)
    readonly property bool areaFillEnabled: root.presentationEnabled("area_fill", false)
    signal snapshotRequested(var action)
    signal deepLinkRequested(var link)

    function selectedOptionIndex(options, wanted) {
        const source = options || []
        const key = String(wanted || "")
        for (let index = 0; index < source.length; index++)
            if (String((source[index] || {}).key || "") === key) return index
        return source.length > 0 ? 0 : -1
    }

    function mapOrEmpty(value) {
        return value === null || value === undefined || typeof value !== "object"
            ? ({}) : value
    }

    function syncSnapshotSelection() {
        metricSelector.currentIndex = root.selectedOptionIndex(
            root.filterCatalog.metrics, root.scope.metric || root.trend.metric
        )
        granularitySelector.currentIndex = root.selectedOptionIndex(
            root.filterCatalog.granularities,
            root.scope.granularity || root.trend.granularity
        )
    }

    onSnapshotIdChanged: Qt.callLater(root.syncSnapshotSelection)
    Component.onCompleted: Qt.callLater(root.syncSnapshotSelection)
    Accessible.name: "Xu hướng hiệu suất theo nền tảng"
    Accessible.role: Accessible.Chart

    function refreshPoints() {
        root.pointRevision += 1
        chart.requestPaint()
    }

    function descriptorForPlatform(platform) {
        const wanted = String(platform || "")
        for (let index = 0; index < root.seriesDescriptors.length; index++) {
            const descriptor = root.seriesDescriptors[index] || ({})
            if (String(descriptor.platform || "") === wanted) return descriptor
        }
        return ({})
    }

    function toneColor(toneKey) {
        const key = String(toneKey || "muted")
        if (key === "danger") return Theme.danger
        if (key === "info") return Theme.info
        if (key === "success") return Theme.success
        if (key === "warning") return Theme.warning
        if (key === "accent") return Theme.accent
        return Theme.textMuted
    }

    function platformColor(platform, index) {
        const descriptor = root.descriptorForPlatform(platform)
        const projected = root.toneColor(descriptor.tone_key)
        return projected || [Theme.accent, Theme.info, Theme.success, Theme.warning][index % 4]
    }

    function platformVisible(platform) {
        const revision = root.legendRevision
        return !Boolean((root.hiddenPlatforms || ({}))[String(platform || "unknown")])
    }

    function togglePlatform(platform) {
        const key = String(platform || "unknown")
        const next = Object.assign({}, root.hiddenPlatforms || ({}))
        next[key] = !Boolean(next[key])
        root.hiddenPlatforms = next
        root.legendRevision += 1
        chart.requestPaint()
    }

    function optionDescriptor(key) {
        const options = ((root.controls.chart_options || {}).options || [])
        for (let index = 0; index < options.length; index++)
            if (String((options[index] || {}).key || "") === key) return options[index]
        return ({})
    }

    function presentationEnabled(key, fallback) {
        if ((root.presentationOverrides || ({}))[key] !== undefined)
            return Boolean(root.presentationOverrides[key])
        const option = root.optionDescriptor(key)
        return option.key ? Boolean(option.selected) : Boolean(fallback)
    }

    function applyPresentationAction(action) {
        const descriptor = action || ({})
        const input = descriptor.input || ({})
        const key = String(input.option_key || "")
        if (descriptor.available !== true
                || String(descriptor.kind || "") !== "presentation"
                || !key || input.enabled === undefined) return false
        const next = Object.assign({}, root.presentationOverrides || ({}))
        next[key] = !root.presentationEnabled(key, Boolean(input.enabled))
        root.presentationOverrides = next
        chart.requestPaint()
        return true
    }

    function updateHover(x, y) {
        let closest = null
        let closestDistance = Number.POSITIVE_INFINITY
        for (let index = 0; index < root.hitPoints.length; index++) {
            const candidate = root.hitPoints[index] || ({})
            const dx = Number(candidate.x || 0) - Number(x || 0)
            const dy = Number(candidate.y || 0) - Number(y || 0)
            const distance = dx * dx + dy * dy
            if (distance < closestDistance) {
                closest = candidate
                closestDistance = distance
            }
        }
        root.hoveredPoint = closestDistance <= 18 * 18 ? closest : null
        chart.requestPaint()
    }

    function axisValueLabel(value) {
        const number = Number(value)
        if (!isFinite(number)) return ""
        const absolute = Math.abs(number)
        if (absolute >= 1000000000)
            return (number / 1000000000).toFixed(1).replace(/\.0$/, "") + "B"
        if (absolute >= 1000000)
            return (number / 1000000).toFixed(1).replace(/\.0$/, "") + "M"
        if (absolute >= 1000)
            return (number / 1000).toFixed(1).replace(/\.0$/, "") + "K"
        return String(Math.round(number * 100) / 100)
    }

    function pointTimeLabel(point) {
        const at = String((point || {}).at || "")
        if (!at) return ""
        const parsed = new Date(at)
        return isNaN(parsed.getTime()) ? at.slice(0, 10) : Qt.formatDateTime(parsed, "dd/MM")
    }

    function coverageReasonMessage() {
        const coverage = root.trend.coverage
        if (coverage === null || coverage === undefined)
            return "Chưa có fact để phân tích độ phủ"
        const validFacts = Math.max(0, Number(coverage.valid_facts || 0))
        const totalFacts = Math.max(0, Number(coverage.total_facts || 0))
        if (totalFacts <= 0) return "Chưa có fact để phân tích độ phủ"
        const missingFacts = Math.max(0, totalFacts - validFacts)
        if (missingFacts <= 0) return "Không có lý do thiếu dữ liệu"
        return String(missingFacts) + (missingFacts === 1 ? " fact" : " facts")
            + " không đủ dữ liệu nguồn hợp lệ"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 11
        spacing: 6
        RowLayout {
            Layout.fillWidth: true
            spacing: 7
            Text { text: "Hiệu suất nội dung"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
            ReportComboBox {
                id: metricSelector
                objectName: "reportMetricSelector"
                Layout.preferredWidth: 148
                model: root.filterCatalog.metrics || []
                textRole: "label"
                valueRole: "key"
                currentIndex: {
                    return root.selectedOptionIndex(
                        model, root.scope.metric || root.trend.metric)
                }
                enabled: count > 0
                availabilityReason: enabled ? "" : "Server chưa cung cấp danh mục chỉ số"
                Accessible.name: "Chỉ số biểu đồ"
                onOptionSelected: function(index, option) {
                    root.snapshotRequested(option.action)
                }
            }
            Item { Layout.fillWidth: true }
            Repeater {
                model: root.seriesPlatforms
                delegate: Rectangle {
                    id: legend
                    required property int index
                    required property var modelData
                    readonly property bool compactLegend: true
                    readonly property var descriptor:
                        root.descriptorForPlatform(legend.modelData)
                    readonly property string platformLabel: String(
                        descriptor.label || legend.modelData || "unknown")
                    readonly property bool platformEnabled:
                        root.platformVisible(legend.modelData)
                    readonly property color platformColorValue:
                        root.platformColor(legend.modelData, legend.index)
                    signal activate()
                    objectName: "reportLegend_" + String(legend.modelData || "unknown")
                    implicitWidth: legendContent.implicitWidth + 14
                    implicitHeight: 24
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: 24
                    radius: 12
                    color: "transparent"
                    border.width: activeFocus ? 1 : 0
                    border.color: Theme.accent
                    activeFocusOnTab: true
                    Accessible.name: (legend.platformEnabled ? "Ẩn " : "Hiện ")
                        + legend.platformLabel
                    Accessible.description: "Bật hoặc tắt chuỗi nền tảng trên biểu đồ"
                    Accessible.role: Accessible.Button
                    onActivate: root.togglePlatform(legend.modelData)
                    Keys.onReturnPressed: legend.activate()
                    Keys.onEnterPressed: legend.activate()
                    Keys.onSpacePressed: legend.activate()

                    Row {
                        id: legendContent
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle {
                            objectName: "reportLegendDot_" + String(
                                legend.modelData || "unknown")
                            width: 8
                            height: 8
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 4
                            color: legend.platformEnabled
                                ? legend.platformColorValue : "transparent"
                            border.width: 1
                            border.color: legend.platformColorValue
                            opacity: legend.platformEnabled ? 1 : 0.55
                        }
                        UiIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: String(legend.descriptor.icon_key || "")
                            tone: legend.platformColorValue
                            iconSize: 14
                            width: 14
                            height: 14
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: legend.platformLabel
                            color: legend.platformEnabled
                                ? Theme.textMuted : Theme.textFaint
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: legend.activate()
                    }
                }
            }
            ReportComboBox {
                id: granularitySelector
                objectName: "reportGranularitySelector"
                Layout.preferredWidth: 118
                model: root.filterCatalog.granularities || []
                textRole: "label"
                valueRole: "key"
                currentIndex: {
                    return root.selectedOptionIndex(
                        model, root.scope.granularity || root.trend.granularity)
                }
                enabled: count > 0
                availabilityReason: enabled ? "" : "Server chưa cung cấp độ chi tiết thời gian"
                Accessible.name: "Độ chi tiết thời gian"
                onOptionSelected: function(index, option) {
                    root.snapshotRequested(option.action)
                }
            }
            Foundation.IconButton {
                id: chartOptionsButton
                objectName: "reportChartOptions"
                readonly property var projectedAction: root.controls.chart_options || ({})
                iconName: String(projectedAction.icon_key || "")
                text: ""
                accessibleName: String(projectedAction.label || "Tùy chọn biểu đồ")
                activeFocusOnTab: true
                enabled: projectedAction.available === true
                    && (projectedAction.options || []).length > 0
                Accessible.description: enabled ? "" : String(
                    projectedAction.reason_code || "Tùy chọn biểu đồ không khả dụng"
                )
                onClicked: chartOptionsMenu.openAtTrigger()
            }
            Foundation.IconButton {
                id: chartOverflowButton
                objectName: "reportChartOverflow"
                readonly property var projectedAction: root.controls.overflow || ({})
                iconName: String(projectedAction.icon_key || "")
                text: ""
                accessibleName: String(projectedAction.label || "Thêm tùy chọn biểu đồ")
                activeFocusOnTab: true
                enabled: projectedAction.available === true
                    && (projectedAction.options || []).length > 0
                Accessible.description: enabled ? "" : String(
                    projectedAction.reason_code || "Thao tác biểu đồ không khả dụng"
                )
                onClicked: chartOverflowMenu.openAtTrigger()
            }
        }

        Canvas {
            id: chart
            objectName: "reportTrendCanvas"
            readonly property real firstPointX: root.hitPoints.length > 0
                ? Number((root.hitPoints[0] || {}).x || -1) : -1
            readonly property real firstPointY: root.hitPoints.length > 0
                ? Number((root.hitPoints[0] || {}).y || -1) : -1
            Layout.fillWidth: true
            Layout.fillHeight: true
            Accessible.name: root.pointCount > 0
                ? String(root.seriesCount) + " chuỗi, " + String(root.pointCount) + " điểm sourced"
                : "Không có điểm xu hướng khả dụng"
            Accessible.role: Accessible.Chart
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Connections {
                target: root
                function onTrendChanged() {
                    root.presentationOverrides = ({})
                    chart.requestPaint()
                }
            }
            Connections {
                target: root.pointModel
                function onCountChanged() { root.refreshPoints() }
                function onDataChanged() { root.refreshPoints() }
                function onModelReset() { root.refreshPoints() }
                function onRowsInserted() { root.refreshPoints() }
                function onRowsRemoved() { root.refreshPoints() }
                function onRowsMoved() { root.refreshPoints() }
            }
            onPaint: {
                const context = getContext("2d")
                context.reset()
                context.clearRect(0, 0, width, height)
                const platforms = root.seriesPlatforms
                const groups = ({})
                for (let platformIndex = 0; platformIndex < platforms.length; platformIndex++)
                    groups[platforms[platformIndex]] = []
                const values = []
                if (!root.pointModel) {
                    root.hitPoints = []
                    return
                }
                for (let pointIndex = 0; pointIndex < root.pointModel.count; pointIndex++) {
                    const point = root.pointModel.get(pointIndex) || ({})
                    const platform = String(point.platform || "unknown")
                    if (!groups[platform]) groups[platform] = []
                    groups[platform].push(point)
                    if (point.available && point.value !== null
                            && point.value !== undefined && isFinite(Number(point.value)))
                        values.push(Number(point.value))
                }
                if (values.length === 0) {
                    root.hitPoints = []
                    return
                }
                let minimum = Math.min.apply(Math, values)
                let maximum = Math.max.apply(Math, values)
                if (maximum === minimum) {
                    maximum += 1
                    minimum -= 1
                }
                const plotLeft = Math.min(root.plotLeft, Math.max(0, width / 3))
                const plotRight = Math.max(plotLeft + 1, width - root.plotRight)
                const plotTop = Math.min(root.plotTop, Math.max(0, height / 3))
                const plotBottom = Math.max(plotTop + 1, height - root.plotBottom)
                const plotWidth = Math.max(1, plotRight - plotLeft)
                const plotHeight = Math.max(1, plotBottom - plotTop)

                context.strokeStyle = Theme.borderSoft
                context.fillStyle = Theme.textFaint
                context.lineWidth = 1
                context.font = "10px sans-serif"
                context.textAlign = "right"
                context.textBaseline = "middle"
                for (let grid = 0; grid < root.plotGridLineCount; grid++) {
                    const ratio = root.plotGridLineCount <= 1
                        ? 0 : grid / (root.plotGridLineCount - 1)
                    const y = Math.round(plotTop + plotHeight * ratio) + 0.5
                    if (root.gridEnabled) {
                        context.beginPath()
                        context.moveTo(plotLeft, y)
                        context.lineTo(plotRight, y)
                        context.stroke()
                    }
                    const axisValue = maximum - (maximum - minimum) * ratio
                    context.fillText(root.axisValueLabel(axisValue), plotLeft - 6, y)
                }

                let timeAxisPoints = []
                const nextHitPoints = []
                for (let seriesIndex = 0; seriesIndex < platforms.length; seriesIndex++) {
                    const platform = platforms[seriesIndex]
                    if (!root.platformVisible(platform)) continue
                    const points = groups[platform] || []
                    if (timeAxisPoints.length === 0)
                        timeAxisPoints = points.filter(point => Boolean(point && point.at))
                    context.strokeStyle = root.platformColor(platform, seriesIndex)
                    context.fillStyle = context.strokeStyle
                    context.lineWidth = 2
                    context.beginPath()
                    const coordinates = []
                    for (let pointIndex = 0; pointIndex < points.length; pointIndex++) {
                        const point = points[pointIndex] || ({})
                        if (!point.available || point.value === null
                                || point.value === undefined || !isFinite(Number(point.value)))
                            continue
                        const x = points.length <= 1 ? plotLeft + plotWidth / 2
                            : plotLeft + plotWidth * pointIndex / (points.length - 1)
                        const y = plotTop + plotHeight
                            * (maximum - Number(point.value)) / (maximum - minimum)
                        if (coordinates.length === 0) context.moveTo(x, y)
                        else context.lineTo(x, y)
                        coordinates.push({"x": x, "y": y, "point": point})
                    }
                    if (coordinates.length > 0) {
                        if (root.areaFillEnabled) {
                            const first = coordinates[0]
                            const last = coordinates[coordinates.length - 1]
                            context.lineTo(last.x, plotBottom)
                            context.lineTo(first.x, plotBottom)
                            context.closePath()
                            context.globalAlpha = 0.12
                            context.fill()
                            context.globalAlpha = 1
                            context.beginPath()
                            context.moveTo(first.x, first.y)
                            for (let lineIndex = 1; lineIndex < coordinates.length; lineIndex++)
                                context.lineTo(coordinates[lineIndex].x, coordinates[lineIndex].y)
                        }
                        context.stroke()
                    }
                    for (let markerIndex = 0; markerIndex < coordinates.length; markerIndex++) {
                        const marker = coordinates[markerIndex]
                        context.beginPath()
                        context.arc(marker.x, marker.y, root.pointMarkerRadius, 0, Math.PI * 2)
                        context.fill()
                        nextHitPoints.push({
                            "x": marker.x,
                            "y": marker.y,
                            "platform": platform,
                            "at": String((marker.point || {}).at || ""),
                            "value": (marker.point || {}).value,
                            "unit": String((marker.point || {}).unit || "")
                        })
                    }
                }

                root.hitPoints = nextHitPoints

                if (root.hoveredPoint) {
                    const hover = root.hoveredPoint || ({})
                    context.strokeStyle = Theme.textMuted
                    context.lineWidth = 1
                    context.beginPath()
                    context.moveTo(Number(hover.x), plotTop)
                    context.lineTo(Number(hover.x), plotBottom)
                    context.moveTo(plotLeft, Number(hover.y))
                    context.lineTo(plotRight, Number(hover.y))
                    context.stroke()
                }

                if (timeAxisPoints.length > 0) {
                    context.fillStyle = Theme.textFaint
                    context.textBaseline = "bottom"
                    context.textAlign = "left"
                    context.fillText(root.pointTimeLabel(timeAxisPoints[0]), plotLeft, height - 2)
                    if (timeAxisPoints.length > 1) {
                        context.textAlign = "right"
                        context.fillText(
                            root.pointTimeLabel(timeAxisPoints[timeAxisPoints.length - 1]),
                            plotRight,
                            height - 2
                        )
                    }
                }
            }

            MouseArea {
                objectName: "reportTrendPointerLayer"
                anchors.fill: parent
                z: 1
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onPositionChanged: function(mouse) {
                    root.updateHover(mouse.x, mouse.y)
                }
                onExited: {
                    root.hoveredPoint = null
                    chart.requestPaint()
                }
            }

            Rectangle {
                id: trendTooltip
                objectName: "reportTrendTooltip"
                readonly property string metricKey: String(
                    root.trend.metric || root.metricValue || "")
                readonly property string platformKey: String(
                    (root.hoveredPoint || {}).platform || "")
                readonly property string timeLabel: root.pointTimeLabel(
                    root.hoveredPoint || ({}))
                readonly property string valueLabel: root.axisValueLabel(
                    (root.hoveredPoint || {}).value)
                    + (String((root.hoveredPoint || {}).unit || "")
                        && String((root.hoveredPoint || {}).unit || "") !== "count"
                        ? " " + String((root.hoveredPoint || {}).unit || "") : "")
                visible: Boolean(root.hoveredPoint)
                z: 2
                width: 210
                height: 64
                x: Math.max(4, Math.min(chart.width - width - 4,
                    Number((root.hoveredPoint || {}).x || 0) + 12))
                y: Math.max(4, Math.min(chart.height - height - 4,
                    Number((root.hoveredPoint || {}).y || 0) - height - 10))
                radius: Theme.radiusSmall
                color: Theme.panel
                border.width: 1
                border.color: Theme.accent
                Accessible.role: Accessible.ToolTip
                Accessible.name: metricKey + ", " + platformKey + ", "
                    + timeLabel + ", " + valueLabel
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        text: trendTooltip.metricKey + " · "
                            + trendTooltip.platformKey
                        color: Theme.text
                        font.pixelSize: Theme.fontMetadata
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: trendTooltip.timeLabel + " · "
                            + trendTooltip.valueLabel
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Rectangle {
            id: coverageWarning
            objectName: "reportCoverageWarning"
            readonly property string coverageState: String((root.trend.coverage || {}).state || "unavailable")
            readonly property string coverageText: String((root.trend.coverage || {}).valid_facts ?? "—")
                + " / " + String((root.trend.coverage || {}).total_facts ?? "—")
                + " số liệu"
            Layout.fillWidth: true
            Layout.minimumHeight: 40
            Layout.preferredHeight: 40
            Layout.bottomMargin: 1
            radius: Theme.radiusSmall
            color: root.trend.warning ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.12) : Theme.elevated
            border.width: 1
            border.color: root.trend.warning ? Theme.warning : Theme.borderSoft
            Accessible.name: "Coverage " + coverageWarning.coverageText + ". " + String(root.trend.warning || "Đầy đủ")
            Accessible.role: Accessible.StaticText
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.rightMargin: 9
                Text { Layout.fillWidth: true; text: root.trend.warning ? "Một số nguồn chưa đủ dữ liệu" : "Dữ liệu đầy đủ"; color: root.trend.warning ? Theme.warning : Theme.success; font.pixelSize: 11; elide: Text.ElideRight }
                Text { text: coverageWarning.coverageText; color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold }
                AppButton {
                    objectName: "reportTrendCoverageDetailsButton"
                    readonly property var projectedAction:
                        root.controls.coverage_details || ({})
                    text: String(projectedAction.label || "Chi tiết")
                    leadingIcon: String(projectedAction.icon_key || "")
                    enabled: projectedAction.available === true
                        && String(projectedAction.kind || "") === "disclosure"
                    availabilityReason: enabled ? "" : String(
                        projectedAction.reason_code || "Chi tiết coverage không khả dụng"
                    )
                    Accessible.name: "Xem chi tiết coverage biểu đồ"
                    onClicked: trendCoverageDialog.open()
                }
            }
        }
    }

    Popup {
        id: chartOptionsMenu
        objectName: "reportChartOptionsMenu"
        parent: Overlay.overlay
        function openAtTrigger() {
            const overlay = Overlay.overlay
            const position = chartOptionsButton.mapToItem(overlay, 0, 0)
            x = Math.max(12, Math.min(
                overlay.width - width - 12,
                position.x + chartOptionsButton.width - width
            ))
            const below = position.y + chartOptionsButton.height + 6
            y = below + height <= overlay.height - 12
                ? below : Math.max(12, position.y - height - 6)
            open()
        }
        width: 250
        height: 10 + ((root.controls.chart_options || {}).options || []).length * 42
        padding: 5
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Item {
            Repeater {
                model: (root.controls.chart_options || {}).options || []
                delegate: AppButton {
                    id: chartOption
                    required property int index
                    required property var modelData
                    readonly property var projectedAction:
                        chartOption.modelData.action || ({})
                    objectName: "reportChartOption_" + String(
                        chartOption.modelData.key || chartOption.index)
                    width: parent.width
                    height: 40
                    y: chartOption.index * 42
                    text: (root.presentationEnabled(
                        String(chartOption.modelData.key || ""),
                        Boolean(chartOption.modelData.selected)
                    ) ? "✓  " : "") + String(chartOption.modelData.label || "Tùy chọn")
                    leadingIcon: String(projectedAction.icon_key || "")
                    subtle: true
                    enabled: projectedAction.available === true
                        && String(projectedAction.kind || "") === "presentation"
                    availabilityReason: enabled ? "" : String(
                        projectedAction.reason_code
                            || "Tùy chọn trình bày không khả dụng"
                    )
                    onClicked: {
                        root.applyPresentationAction(projectedAction)
                        chartOptionsMenu.close()
                    }
                }
            }
        }
        background: Rectangle {
            radius: Theme.radiusMedium
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    Popup {
        id: chartOverflowMenu
        objectName: "reportChartOverflowMenu"
        parent: Overlay.overlay
        function openAtTrigger() {
            const overlay = Overlay.overlay
            const position = chartOverflowButton.mapToItem(overlay, 0, 0)
            x = Math.max(12, Math.min(
                overlay.width - width - 12,
                position.x + chartOverflowButton.width - width
            ))
            const below = position.y + chartOverflowButton.height + 6
            y = below + height <= overlay.height - 12
                ? below : Math.max(12, position.y - height - 6)
            open()
        }
        width: 230
        height: 10 + ((root.controls.overflow || {}).options || []).length * 42
        padding: 5
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Item {
            Repeater {
                model: (root.controls.overflow || {}).options || []
                delegate: AppButton {
                    id: overflowItem
                    required property int index
                    required property var modelData
                    objectName: "reportChartOverflowItem_" + String(overflowItem.index)
                    width: parent.width
                    height: 40
                    y: overflowItem.index * 42
                    text: String(overflowItem.modelData.label || "Chi tiết")
                    leadingIcon: String(overflowItem.modelData.icon_key || "")
                    subtle: true
                    enabled: overflowItem.modelData.available === true
                        && String(overflowItem.modelData.kind || "") === "disclosure"
                    availabilityReason: enabled ? "" : String(
                        overflowItem.modelData.reason_code || "Thao tác không khả dụng"
                    )
                    onClicked: {
                        chartOverflowMenu.close()
                        trendCoverageDialog.open()
                    }
                }
            }
        }
        background: Rectangle {
            radius: Theme.radiusMedium
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    ReportDialog {
        id: trendCoverageDialog
        objectName: "reportTrendCoverageDialog"
        parent: root
        x: Math.max(0, (root.width - width) / 2)
        y: Math.max(0, (root.height - height) / 2)
        width: Math.min(480, root.width - 24)
        height: Math.min(340, root.height - 24)
        title: "Chi tiết độ phủ xu hướng"
        contentItem: ColumnLayout {
            spacing: 10
            Text {
                Layout.fillWidth: true
                text: "Nguồn dữ liệu xu hướng đã được kiểm tra theo phạm vi báo cáo."
                color: Theme.textMuted
                font.pixelSize: Theme.fontBody
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: String((root.trend.coverage || {}).valid_facts ?? "—")
                    + " / " + String((root.trend.coverage || {}).total_facts ?? "—")
                    + " số liệu hợp lệ"
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
            }
            Text {
                id: trendCoverageReasonText
                objectName: "reportTrendCoverageReasonText"
                readonly property bool labelTruncated: truncated
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.coverageReasonMessage()
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "reportTrendCoverageCloseButton"
                    text: "Đóng"
                    onClicked: trendCoverageDialog.close()
                }
            }
        }
    }
}
