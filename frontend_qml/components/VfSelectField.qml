pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"
import "AppIconRegistry.js" as AppIconRegistry

Rectangle {
    id: root

    property string label: ""
    property var options: []
    property var value: ""
    property color accent: VfTheme.primary
    property string iconRole: ""
    property string symbolRole: ""
    property string symbolFontFamily: "Segoe UI Emoji"
    property string tooltip: ""
    property real fieldHeight: VfTheme.fieldHeight
    property real selectorHeight: VfTheme.dp(26)
    property real labelFontSize: VfTheme.fontSmall
    property real valueFontSize: VfTheme.fontSmall
    property int labelFontWeight: VfTheme.weightStrong
    property int valueFontWeight: VfTheme.weightRegular
    // Dense two-column inspectors can opt out of the global 190dp popup floor.
    // Bind this to the field width when the menu must stay inside its panel.
    property real popupMinWidth: VfTheme.dp(190)
    // Compact inspector rows can place the label and selector side by side.
    // Default stays stacked so existing forms are visually unchanged.
    property bool inlineLabel: false
    property real inlineLabelWidth: VfTheme.dp(150)
    // Toolbar-height combo: hide stacked label, fill 34dp chip chrome.
    property bool compact: false

    signal selected(var value)

    function cleanText(value) {
        var text = String(value || "").trim()
        text = text.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]\uFE0F?\s*/, "")
        text = text.replace(/^[\u2600-\u27BF]\uFE0F?\s*/, "")
        return text.trim()
    }

    Layout.fillWidth: true
    implicitHeight: root.compact ? VfTheme.controlHeight : root.fieldHeight
    radius: VfTheme.radiusControl
    color: root.enabled
        ? (root.compact ? VfTheme.surface : VfTheme.surfaceSoft)
        : VfTheme.panelRaised
    border.color: root.enabled
        ? (root.compact ? VfTheme.borderStrong : VfTheme.borderSoft)
        : VfTheme.border
    border.width: 1
    clip: true
    opacity: root.enabled ? 1.0 : 0.55

    HoverHandler { id: fieldHover }
    ToolTip.visible: fieldHover.hovered
        && (root.tooltip.length > 0 || (root.compact && root.label.length > 0))
    ToolTip.text: root.tooltip.length > 0 ? root.tooltip : root.label
    ToolTip.delay: 450

    function optionIndex(searchValue) {
        var items = root.options || []
        for (var i = 0; i < items.length; i++) {
            if (String(items[i].value) === String(searchValue))
                return i
        }
        return items.length > 0 ? 0 : -1
    }

    function optionObject(option) {
        if (option && typeof option === "object")
            return option
        return ({ label: String(option || ""), value: option })
    }

    function optionText(option) {
        var item = root.optionObject(option)
        return String(item.label !== undefined ? item.label : item.value || "")
    }

    // Per-option disable (capability gate): option = {label, value, disabled: true,
    // reason: "..."} → hiện mờ, KHÔNG click được, hover hiện lý do. Backend quyết
    // disabled từ initialData/credit — UI chỉ render.
    function optionDisabled(option) {
        var item = root.optionObject(option)
        return item.disabled === true
    }

    function optionReason(option) {
        var item = root.optionObject(option)
        return String(item.reason || "")
    }

    function optionIconValue(option) {
        var item = root.optionObject(option)
        if (root.iconRole.length > 0 && item[root.iconRole] !== undefined)
            return String(item[root.iconRole] || "")
        if (item.icon !== undefined)
            return String(item.icon || "")
        if (item.icon_path !== undefined)
            return String(item.icon_path || "")
        if (item.flag !== undefined)
            return String(item.flag || "")
        if (item.flag_file !== undefined)
            return String(item.flag_file || "")
        return ""
    }

    function optionAppIconName(option) {
        if (root.iconRole === "flag")
            return ""
        var raw = String(root.optionIconValue(option) || "").trim()
        if (!raw.length)
            return ""
        if (raw.indexOf("/") >= 0 || raw.indexOf("\\") >= 0 || raw.indexOf(":") >= 0)
            return ""
        if (/^[a-z]{2}$/.test(raw))
            return ""
        return AppIconRegistry.normalizeIconName(raw)
    }

    function optionIconPath(option) {
        var raw = root.optionIconValue(option)
        if (!raw.length)
            return ""
        if (root.optionAppIconName(option).length)
            return ""
        if (raw.indexOf(":/") === 0 || raw.indexOf("qrc:/") === 0 || raw.indexOf("file:/") === 0 || raw.indexOf("data:") === 0)
            return raw
        if (raw.indexOf("/") >= 0 || raw.indexOf("\\") >= 0)
            return Qt.resolvedUrl(raw)
        return Qt.resolvedUrl("../../assets/flags/" + raw + ".png")
    }

    function optionSymbol(option) {
        var item = root.optionObject(option)
        if (root.symbolRole.length > 0 && item[root.symbolRole] !== undefined)
            return String(item[root.symbolRole] || "")
        if (item.emoji !== undefined)
            return String(item.emoji || "")
        if (item.symbol !== undefined)
            return String(item.symbol || "")
        return ""
    }

    function currentOption() {
        var index = root.optionIndex(root.value)
        if (index < 0)
            return ({})
        return root.optionObject((root.options || [])[index] || ({}))
    }

    Rectangle {
        id: accentBar
        visible: !root.compact
        x: VfTheme.dp(6)
        y: root.inlineLabel
            ? Math.round((root.height - height) / 2)
            : VfTheme.dp(8)
        width: VfTheme.dp(3)
        height: VfTheme.dp(9)
        radius: VfTheme.dp(2)
        color: root.enabled ? root.accent : VfTheme.textSubtle
    }

    Text {
        id: labelText
        visible: !root.compact
        x: accentBar.x + accentBar.width + VfTheme.dp(5)
        y: root.inlineLabel
            ? Math.round((root.height - height) / 2)
            : Math.round(accentBar.y + (accentBar.height - height) / 2)
        width: root.inlineLabel
            ? Math.max(0, root.inlineLabelWidth - x - VfTheme.dp(6))
            : Math.max(0, root.width - x - VfTheme.dp(6))
        text: root.cleanText(root.label)
        color: root.enabled ? VfTheme.textMuted : VfTheme.textSubtle
        font.family: VfTheme.fontFamily
        font.pixelSize: root.labelFontSize
        font.weight: root.labelFontWeight
        elide: Text.ElideRight
        maximumLineCount: 1
    }

    ComboBox {
        id: combo
        objectName: root.objectName.length > 0
            ? root.objectName + "ComboBox" : ""

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: root.compact ? parent.top : undefined
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.compact
            ? VfTheme.dp(2)
            : (root.inlineLabel ? root.inlineLabelWidth : VfTheme.dp(6))
        anchors.rightMargin: root.compact ? VfTheme.dp(2) : VfTheme.dp(6)
        anchors.topMargin: root.compact ? VfTheme.dp(2) : 0
        anchors.bottomMargin: root.compact
            ? VfTheme.dp(2)
            : (root.inlineLabel ? VfTheme.dp(4) : VfTheme.dp(6))
        height: root.compact ? undefined : root.selectorHeight
        model: root.options || []
        textRole: "label"
        valueRole: "value"
        currentIndex: root.optionIndex(root.value)
        enabled: root.enabled && (root.options || []).length > 0
        clip: true
        font.family: VfTheme.fontFamily
        font.pixelSize: root.valueFontSize
        palette.base: VfTheme.surface
        palette.button: VfTheme.surface
        palette.window: VfTheme.surface
        palette.text: VfTheme.text
        palette.buttonText: VfTheme.text
        palette.windowText: VfTheme.text
        palette.highlight: VfTheme.blueFill
        palette.highlightedText: VfTheme.text
        onActivated: root.selected(combo.currentValue)

        contentItem: Item {
            // Never derive a control's implicit size from its resolved size:
            // Basic ComboBox uses contentItem.implicitHeight to resolve height.
            implicitHeight: root.compact
                ? VfTheme.controlHeight - VfTheme.dp(4)
                : root.selectorHeight

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: VfTheme.dp(7)
                anchors.rightMargin: VfTheme.dp(22)
                spacing: (optionAppIcon.visible || optionIcon.visible || optionSymbolText.visible) ? 6 : 0

                VfAppIcon {
                    id: optionAppIcon
                    anchors.verticalCenter: parent.verticalCenter
                    size: 16
                    framed: false
                    name: root.optionAppIconName(root.currentOption())
                    visible: name.length > 0
                }

                Image {
                    id: optionIcon
                    anchors.verticalCenter: parent.verticalCenter
                    width: visible ? 18 : 0
                    height: visible ? 12 : 0
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    source: root.optionIconPath(root.currentOption())
                    // source is a url; use String(...) — url has no .length so
                    // `source.length > 0` is always false and hides the flag.
                    visible: String(source).length > 0 && !optionAppIcon.visible
                }

                Text {
                    id: optionSymbolText
                    anchors.verticalCenter: parent.verticalCenter
                    width: visible ? 16 : 0
                    text: root.optionSymbol(root.currentOption())
                    visible: text.length > 0
                    color: VfTheme.text
                    font.family: root.symbolFontFamily
                    font.pixelSize: root.valueFontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    width: parent.width
                        - (optionAppIcon.visible ? optionAppIcon.width + 6 : 0)
                        - (optionIcon.visible ? optionIcon.width + 6 : 0)
                        - (optionSymbolText.visible ? optionSymbolText.width + 6 : 0)
                    // Fallback về nhãn của option đang chọn nếu displayText rỗng
                    // (một số lần model đổi làm displayText trễ 1 frame).
                    text: combo.displayText || root.optionText(root.currentOption())
                    color: combo.enabled ? VfTheme.text : VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: root.valueFontSize
                    font.weight: root.valueFontWeight
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }

        background: Rectangle {
            radius: VfTheme.radiusControl - 3
            color: root.compact ? "transparent" : VfTheme.surface
            border.color: combo.activeFocus ? root.accent : VfTheme.borderBox
            border.width: root.compact ? 0 : 1
        }

        indicator: Text {
            x: combo.width - width - 8
            y: Math.round((combo.height - height) / 2)
            width: VfTheme.dp(10)
            height: combo.height
            text: "v"
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            font.weight: VfTheme.weightStrong
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        delegate: ItemDelegate {
            id: comboDelegate
            required property int index
            required property var modelData
            width: combo.width
            height: VfTheme.dp(28)
            highlighted: combo.highlightedIndex >= 0 ? combo.highlightedIndex === index : combo.currentIndex === index

            background: Rectangle {
                color: comboDelegate.highlighted ? VfTheme.blueFill : VfTheme.surface
                border.color: comboDelegate.highlighted ? VfTheme.blueBorder : "transparent"
                radius: VfTheme.dp(6)
            }

            contentItem: Row {
                spacing: (optionItemAppIcon.visible || optionItemIcon.visible || optionItemSymbol.visible) ? 6 : 0

                VfAppIcon {
                    id: optionItemAppIcon
                    anchors.verticalCenter: parent.verticalCenter
                    size: 16
                    framed: false
                    name: root.optionAppIconName(comboDelegate.modelData)
                    visible: name.length > 0
                }

                Image {
                    id: optionItemIcon
                    anchors.verticalCenter: parent.verticalCenter
                    width: visible ? 18 : 0
                    height: visible ? 12 : 0
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    source: root.optionIconPath(comboDelegate.modelData)
                    visible: String(source).length > 0 && !optionItemAppIcon.visible
                }

                Text {
                    id: optionItemSymbol
                    anchors.verticalCenter: parent.verticalCenter
                    width: visible ? 16 : 0
                    text: root.optionSymbol(comboDelegate.modelData)
                    visible: text.length > 0
                    color: VfTheme.text
                    font.family: root.symbolFontFamily
                    font.pixelSize: root.valueFontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    height: parent.height
                    width: parent.width
                        - (optionItemAppIcon.visible ? optionItemAppIcon.width + 6 : 0)
                        - (optionItemIcon.visible ? optionItemIcon.width + 6 : 0)
                        - (optionItemSymbol.visible ? optionItemSymbol.width + 6 : 0)
                    text: root.optionText(comboDelegate.modelData)
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        popup: Popup {
            objectName: root.objectName.length > 0
                ? root.objectName + "Popup" : ""
            // In-scene overlay (Popup.Item = Basic-style default; pinned so a future
            // Qt/style change can't move it to a native window).
            popupType: Popup.Item
            y: combo.height + 4
            // Mặc định vẫn giữ sàn 190dp để option dễ đọc. Inspector dày đặc có
            // thể truyền popupMinWidth=field.width để popup không lòi khỏi panel.
            width: Math.max(combo.width, root.popupMinWidth)
            x: Math.min(0, combo.width - width)
            padding: VfTheme.dp(4)
            implicitHeight: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, 240)
            // Popup rộng hơn combo thì lùi trái (x âm) — nhưng combo sát mép cửa sổ
            // thì popup bị đẩy RA NGOÀI app và bị cắt cụt. Trước khi mở, clamp theo
            // Overlay: giữ right-align như cũ khi đủ chỗ, hết chỗ thì tịnh tiến vào
            // trong; đáy không đủ chỗ thì mở NGƯỢC LÊN. Chiều cao tính từ số option
            // (28dp/dòng, trần 240) vì ListView bên dưới chỉ nạp model khi visible.
            onAboutToShow: {
                var overlay = combo.Overlay.overlay
                if (!overlay)
                    return
                var pos = combo.mapToItem(overlay, 0, 0)
                var margin = VfTheme.dp(6)
                var wanted = Math.min(0, combo.width - width)
                var minX = margin - pos.x
                var maxX = overlay.width - margin - pos.x - width
                x = Math.max(minX, Math.min(wanted, maxX))
                var rows = (root.options || []).length
                var h = Math.min(rows * VfTheme.dp(28) + topPadding + bottomPadding, 240)
                var below = combo.height + 4
                y = (pos.y + below + h > overlay.height - margin && pos.y - h - 4 >= margin)
                    ? -h - 4
                    : below
            }
            onOpened: Qt.callLater(function() {
                if (combo.currentIndex >= 0)
                    popupList.positionViewAtIndex(combo.currentIndex, ListView.Center)
            })

            // BUG FIX (dropdown mở ra nhưng các dòng option TRỐNG CHỮ trên 1 số máy):
            // bind THẲNG vào root.options (mảng), KHÔNG tái dùng combo.delegateModel —
            // chia sẻ delegateModel cho view thứ 2 làm các dòng option rỗng bất định (model
            // chỉ nuôi 1 view tin cậy). Mảng thô đảm bảo mỗi delegate `modelData` = object option.
            contentItem: ListView { // perf-lint: disable=R1  tiny static option list; recycling pointless
                id: popupList
                objectName: root.objectName.length > 0
                    ? root.objectName + "PopupList" : ""
                clip: true
                implicitHeight: contentHeight
                model: combo.popup.visible ? (root.options || []) : null
                currentIndex: combo.highlightedIndex >= 0 ? combo.highlightedIndex : combo.currentIndex
                ScrollIndicator.vertical: ScrollIndicator { }

                delegate: ItemDelegate {
                    id: optDelegate
                    required property int index
                    required property var modelData
                    // Capability gate: option disabled → mờ + không click + tooltip lý do.
                    readonly property bool optDisabled: root.optionDisabled(modelData)
                    readonly property string optReason: root.optionReason(modelData)
                    width: ListView.view ? ListView.view.width : combo.width
                    height: VfTheme.dp(28)
                    leftPadding: VfTheme.dp(10)
                    rightPadding: VfTheme.dp(8)
                    // Basic style mặc định topPadding=bottomPadding=12 → ô cao 28 chỉ còn
                    // 4px cho content → text lệch không canh giữa dọc. Bỏ padding dọc.
                    topPadding: 0
                    bottomPadding: 0
                    hoverEnabled: true
                    // Highlight khi RÊ CHUỘT (hovered) HOẶC là item đang chọn — để di chuột
                    // có trạng thái "đang chọn" như dropdown thường (trước bị mất).
                    // Option disabled không highlight (không mời gọi click).
                    highlighted: (hovered && !optDisabled) || ListView.isCurrentItem
                    ToolTip.visible: hovered && optDisabled && optReason.length > 0
                    ToolTip.delay: 250
                    ToolTip.text: optReason
                    onClicked: {
                        if (optDelegate.optDisabled)
                            return
                        var opt = root.optionObject(modelData)
                        combo.currentIndex = index
                        root.selected(opt.value)
                        combo.popup.close()
                    }

                    background: Rectangle {
                        color: optDelegate.highlighted ? VfTheme.blueFill : VfTheme.surface
                        border.color: optDelegate.highlighted ? VfTheme.blueBorder : "transparent"
                        radius: VfTheme.dp(6)
                        opacity: optDelegate.optDisabled ? 0.55 : 1
                    }

                    // RowLayout + Layout.fillWidth: cho Text nhãn nhận đúng phần rộng còn
                    // lại. `width: parent.width - …` trên Row co-theo-nội-dung (cũ) là binding
                    // vòng → ra 0 trên 1 số layout → chữ vô hình.
                    contentItem: RowLayout {
                        spacing: (optIcon.visible || optSym.visible) ? 6 : 0

                        Image {
                            id: optIcon
                            Layout.preferredWidth: visible ? 18 : 0
                            Layout.preferredHeight: visible ? 12 : 0
                            Layout.alignment: Qt.AlignVCenter
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            source: root.optionIconPath(optDelegate.modelData)
                            visible: String(source).length > 0
                        }

                        Text {
                            id: optSym
                            Layout.preferredWidth: visible ? 16 : 0
                            Layout.alignment: Qt.AlignVCenter
                            text: root.optionSymbol(optDelegate.modelData)
                            visible: text.length > 0
                            color: VfTheme.text
                            font.family: root.symbolFontFamily
                            font.pixelSize: root.valueFontSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: root.optionText(optDelegate.modelData)
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: root.valueFontSize
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            background: Rectangle {
                radius: VfTheme.radiusControl
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                border.width: 1
            }
        }
    }

    // Vùng label phía trên (combo chỉ chiếm dải đáy ~26dp của field 56dp) vốn
    // KHÔNG bấm được -> trước đây phải click 2 lần (lần đầu trúng label = no-op).
    // Cho cả dải trên mở dropdown để toàn bộ field đều click được.
    MouseArea {
        x: 0
        y: 0
        width: root.inlineLabel ? root.inlineLabelWidth : root.width
        height: root.inlineLabel ? root.height : Math.max(0, combo.y)
        enabled: combo.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            combo.forceActiveFocus()
            combo.popup.open()
        }
    }
}
