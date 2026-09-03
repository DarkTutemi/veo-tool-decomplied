import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../theme"

// IMPORT SẢN PHẨM — ba nguồn chính: Shopee, TikTok và Kho đã nhập.
//   Mỗi thẻ = 1 sản phẩm. Ảnh nằm trong một khu vực riêng, có ảnh chính, thumbnail
//   và nút quản lý ảnh; thông tin sản phẩm được chia thành từng trường có nhãn.
//   Chỉ ẢNH bắt buộc — trường trống được AI bổ sung trong bước chuẩn bị.
//   CSV/Excel đã bỏ khỏi giao diện vì hai marketplace là đường nhập chính.
Dialog {
    id: root

    // [{name, price, uses, description, brand, category, paths: [..], image_urls: [..],
    //   all_paths: [..], all_image_urls: [..], count}]
    // `all_*` giữ gallery gốc để user mở lại grid và chọn lại; `paths/image_urls`
    // chỉ chứa ảnh đã tick và là payload thực sự đi qua cổng Import.
    property var items: []
    signal importRequested(var items)

    // KÊNH (multi-kênh 23/7): mỗi kênh = 1 profile browser riêng (login sàn + danh
    // tính riêng) — làm nhiều kênh TikTok/Shopee thì chọn kênh rồi lặp lại quy trình.
    property var channelOptions: [{ label: "Kênh chính", value: "affiliate" }]
    property string browserAccount: "affiliate"
    property bool addingChannel: false
    function reloadChannels() {
        var accs = workPanelController.affiliateBrowserAccounts() || []
        var opts = []
        var seen = false
        for (var i = 0; i < accs.length; i++) {
            opts.push({ label: String(accs[i].label || accs[i].key), value: String(accs[i].key) })
            if (String(accs[i].key) === root.browserAccount) seen = true
        }
        if (opts.length === 0) opts = [{ label: "Kênh chính", value: "affiliate" }]
        root.channelOptions = opts
        if (!seen) root.browserAccount = String(opts[0].value)
    }
    // {key: browser kênh đó đang chạy?} — chấm xanh trên tab.
    property var channelStatus: ({})
    function refreshChannelStatus() {
        root.channelStatus = workPanelController.affiliateChannelStatus() || ({})
    }
    // Bấm tab = chuyển kênh + MỞ browser kênh đó (như Chrome đổi profile).
    function selectChannel(key) {
        root.browserAccount = String(key)
        workPanelController.openAffiliateChannelBrowser(String(key))
        var st = {}
        for (var k in (root.channelStatus || {})) st[k] = root.channelStatus[k]
        st[String(key)] = true            // optimistic — poll 4s sẽ chỉnh lại nếu fail
        root.channelStatus = st
    }
    function commitNewChannel(text) {
        var res = workPanelController.addAffiliateBrowserAccount(String(text || "")) || ({})
        if (res.ok) {
            root.reloadChannels()
            root.addingChannel = false
            root.selectChannel(String(res.key))   // kênh mới → mở browser luôn để login
        }
        fileStatus.isError = !res.ok
        if (!res.ok) fileStatus.text = "Không thêm được kênh (" + String(res.error || "") + ")"
    }
    onOpened: { reloadChannels(); refreshChannelStatus() }
    // Chấm trạng thái tự tươi khi dialog mở — đọc 1 dict nhỏ, rẻ.
    Timer {
        interval: 4000; repeat: true
        running: root.visible
        onTriggered: root.refreshChannelStatus()
    }

    readonly property var _categories: [
        { value: "",            label: (void i18n.revision, i18n.t("affiliate_import.cat_auto", "Auto")) },
        { value: "cosmetics",   label: "Mỹ phẩm" },
        { value: "beauty",      label: "Làm đẹp" },
        { value: "fashion",     label: "Thời trang" },
        { value: "electronics", label: "Điện tử" },
        { value: "home",        label: "Gia dụng" },
        { value: "food",        label: "Thực phẩm" },
        { value: "health",      label: "Sức khỏe" },
        { value: "sports",      label: "Thể thao" },
        { value: "baby",        label: "Mẹ & Bé" },
        { value: "other",       label: "Khác" }
    ]
    // Mở dialog luôn có sẵn một thẻ trống để nhập thủ công.
    function resetForm() { root.items = [root.emptyRow()] }
    function emptyRow() {
        return { name: "", price: "", uses: "", description: "", brand: "",
                 category: "", paths: [], image_urls: [],
                 all_paths: [], all_image_urls: [], count: 0,
                 product_url: "", affiliate_link: "", tiktok_product_id: "",
                 browser_account: "", commission_rate: 0, sold: "",
                 shopee_item_id: "", shopee_category_id: "", shop_id: "",
                 shop_name: "", rating: 0, rating_count: 0, stock: 0,
                 discount: "" }
    }
    function appendRows(rows) {
        var out = root.items.slice()
        // Bảng chỉ còn đúng 1 hàng trống mặc định → thay nó bằng data đổ vào.
        if (out.length === 1 && Number(out[0].count || 0) === 0
                && String(out[0].name || "") === "" && rows.length > 0)
            out = []
        for (var i = 0; i < rows.length; i++) out.push(rows[i])
        root.items = out
    }
    function addManualRow() { root.appendRows([root.emptyRow()]) }
    // target = key sàn ("shopee"/"tiktok") — URL marketplace chốt ở
    // product_browser.MARKETPLACE_URLS (KHÔNG hardcode URL trong QML).
    function openBrowse(target) {
        workPanelController.startAffiliateBrowseImport(String(target || "shopee"), root.browserAccount)
        fileStatus.isError = false
        fileStatus.text = (void i18n.revision, i18n.t("affiliate_import.browse_hint",
            "Đã mở trang tiếp thị — mở 1 sản phẩm, chọn ảnh rồi bấm ➕ Nhập; hàng sẽ tự hiện ở bảng này."))
    }
    // SP nhập từ overlay browser (bấm ➕ Nhập trên trang Shopee/TikTok) → thành
    // HÀNG trong bảng này để duyệt tiếp — dialog GIỮ MỞ trong lúc lướt.
    function appendOverlayRow(data) {
        var d = data || {}
        var row = root.emptyRow()
        row.name = String(d.name || "")
        row.price = String(d.price || "")
        row.description = String(d.description || "")
        row.brand = String(d.brand || "")
        row.category = String(d.category || "")
        row.image_urls = (d.image_urls || []).slice(0, 10)
        row.all_image_urls = row.image_urls.slice()
        row.count = row.image_urls.length
        // BUG 23/7: 3 field này từng bị rơi ở đây → SP qua bảng duyệt mất link gốc.
        row.product_url = String(d.product_url || d.source_url || "")
        row.affiliate_link = String(d.affiliate_link || "")
        row.commission_rate = Number(d.commission_rate || 0)
        row.sold = String(d.sold || "")
        row.shopee_item_id = String(d.shopee_item_id || "")
        row.shopee_category_id = String(d.shopee_category_id || "")
        row.shop_id = String(d.shop_id || "")
        row.shop_name = String(d.shop_name || "")
        row.rating = Number(d.rating || 0)
        row.rating_count = Number(d.rating_count || 0)
        row.stock = Number(d.stock || 0)
        row.discount = String(d.discount || "")
        row.tiktok_product_id = String(d.tiktok_product_id || "")
        row.browser_account = String(d.browser_account || root.browserAccount)
        root.appendRows([row])
        fileStatus.isError = false
        fileStatus.text = "🛍 Nhận '" + row.name.substring(0, 40) + "' từ browser (" + row.count + " ảnh)"
    }
    function appendWarehouseRow(data) {
        var d = data || {}
        var productId = String(d.product_id || "")
        if (!productId) return false
        for (var i = 0; i < root.items.length; i++) {
            if (String((root.items[i] || {})._warehouse_product_id || "") === productId)
                return false
        }
        var row = root.emptyRow()
        row._warehouse_product_id = productId
        row.name = String(d.name || "")
        row.price = String(d.price || "")
        row.uses = String(d.uses || "")
        row.description = String(d.description || "")
        row.brand = String(d.brand || "")
        row.category = String(d.category || "")
        row.paths = (d.source_paths || []).slice(0, 10)
        row.all_paths = row.paths.slice()
        row.count = row.paths.length
        row.product_url = String(d.product_url || "")
        row.affiliate_link = String(d.affiliate_link || "")
        row.commission_rate = Number(d.commission_rate || 0)
        row.sold = String(d.sold || "")
        row.shopee_item_id = String(d.shopee_item_id || "")
        row.shopee_category_id = String(d.shopee_category_id || "")
        row.shop_id = String(d.shop_id || "")
        row.shop_name = String(d.shop_name || "")
        row.rating = Number(d.rating || 0)
        row.rating_count = Number(d.rating_count || 0)
        row.stock = Number(d.stock || 0)
        row.discount = String(d.discount || "")
        row.tiktok_product_id = String(d.tiktok_product_id || "")
        row.browser_account = String(d.browser_account || root.browserAccount)
        root.appendRows([row])
        fileStatus.isError = false
        fileStatus.text = "📦 Đã đưa '" + row.name.substring(0, 48)
                        + "' từ kho vào bảng — bấm Import để làm lại."
        return true
    }
    function stagedWarehouseProductIds() {
        var ids = []
        for (var i = 0; i < root.items.length; i++) {
            var productId = String((root.items[i] || {})._warehouse_product_id || "")
            if (productId && ids.indexOf(productId) < 0) ids.push(productId)
        }
        return ids
    }
    function warehouseProductIsStaged(productId) {
        return root.stagedWarehouseProductIds().indexOf(String(productId || "")) >= 0
    }
    function addRowImages(idx) {
        var picked = nativeShell.pickFiles(
            (void i18n.revision, i18n.t("affiliate_import.pick_row_images", "Chọn ảnh cho SP này (tối đa 10)")),
            "Images (*.png *.jpg *.jpeg *.webp);;All Files (*.*)", "")
        if (!(picked && picked.ok && picked.paths && picked.paths.length > 0)) return
        var out = root.items.slice()
        if (idx < 0 || idx >= out.length) return
        var it = {}
        for (var k in out[idx]) it[k] = out[idx][k]
        var paths = (it.paths || []).slice()
        var allPaths = (it.all_paths || it.paths || []).slice()
        var selectedCount = paths.length + ((it.image_urls || []).length)
        for (var i = 0; i < picked.paths.length; i++) {
            var p = String(picked.paths[i] || "")
            if (p.length === 0 || allPaths.indexOf(p) >= 0) continue
            allPaths.push(p)
            if (selectedCount < 10) {
                paths.push(p)
                selectedCount++
            }
        }
        it.paths = paths
        it.all_paths = allPaths
        it.count = paths.length + ((it.image_urls || []).length)
        out[idx] = it
        root.items = out
    }
    function imageCandidates(row) {
        var item = row || {}
        var selectedPaths = item.paths || []
        var selectedUrls = item.image_urls || []
        var allPaths = (item.all_paths && item.all_paths.length > 0)
                     ? item.all_paths : selectedPaths
        var allUrls = (item.all_image_urls && item.all_image_urls.length > 0)
                    ? item.all_image_urls : selectedUrls
        var out = []
        for (var p = 0; p < allPaths.length; p++) {
            var path = String(allPaths[p] || "")
            if (!path) continue
            out.push({
                key: "path:" + path, kind: "path", value: path,
                source: "file:///" + path.replace(/\\/g, "/"),
                selected: selectedPaths.indexOf(path) >= 0,
                primary: selectedPaths.length > 0 && selectedPaths[0] === path
            })
        }
        for (var u = 0; u < allUrls.length; u++) {
            var url = String(allUrls[u] || "")
            if (!url) continue
            out.push({
                key: "url:" + url, kind: "url", value: url, source: url,
                selected: selectedUrls.indexOf(url) >= 0,
                primary: selectedPaths.length === 0
                         && selectedUrls.length > 0 && selectedUrls[0] === url
            })
        }
        return out
    }
    function openImagePicker(idx) {
        if (idx < 0 || idx >= root.items.length) return
        var row = root.items[idx] || {}
        var candidates = root.imageCandidates(row)
        if (candidates.length === 0) {
            root.addRowImages(idx)
            return
        }
        imagePicker.rowIndex = idx
        imagePicker.productName = String(row.name || "")
        imagePicker.notice = ""
        imagePicker.candidates = candidates
        imagePicker.open()
    }
    function applyImageSelection(idx, candidates) {
        if (idx < 0 || idx >= root.items.length) return
        var primary = null
        var rest = []
        for (var i = 0; i < candidates.length; i++) {
            var candidate = candidates[i] || {}
            if (!candidate.selected) continue
            if (candidate.primary && primary === null) primary = candidate
            else rest.push(candidate)
        }
        var selected = primary === null ? rest : [primary].concat(rest)
        selected = selected.slice(0, 10)
        var paths = []
        var urls = []
        for (var j = 0; j < selected.length; j++) {
            if (String(selected[j].kind || "") === "path")
                paths.push(String(selected[j].value || ""))
            else
                urls.push(String(selected[j].value || ""))
        }
        var out = root.items.slice()
        var item = {}
        for (var key in out[idx]) item[key] = out[idx][key]
        item.paths = paths
        item.image_urls = urls
        item.count = paths.length + urls.length
        out[idx] = item
        root.items = out
    }
    function setItemField(idx, key, value) {
        var out = root.items.slice()
        if (idx >= 0 && idx < out.length) {
            var it = {}
            for (var k in out[idx]) it[k] = out[idx][k]
            it[key] = value
            out[idx] = it
            root.items = out
        }
    }
    function removeAt(idx) {
        var out = root.items.slice()
        if (idx >= 0 && idx < out.length) out.splice(idx, 1)
        root.items = out
    }
    function readyCount() {
        var n = 0
        for (var i = 0; i < root.items.length; i++)
            if (Number((root.items[i] || {}).count || 0) > 0) n++
        return n
    }

    // Inline components dùng trong bảng — khai ở root scope (chuẩn Qt).
    // Thẻ NGUỒN IMPORT (bố chốt 22/7): icon vuông màu sàn + tên + mô tả + badge type.
    component SourceCard: Rectangle {
        id: sc
        property string iconText: ""
        property color iconBg: VfTheme.primary
        property string title: ""
        property string desc: ""
        property var badges: []
        signal activated()
        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(96)
        radius: VfTheme.dp(10)
        color: scMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
        border.color: scMouse.containsMouse ? VfTheme.primary : VfTheme.borderBox
        border.width: 1
        RowLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(10)
            spacing: VfTheme.dp(9)
            Rectangle {
                Layout.preferredWidth: VfTheme.dp(38)
                Layout.preferredHeight: VfTheme.dp(38)
                Layout.alignment: Qt.AlignTop
                radius: VfTheme.dp(9)
                color: sc.iconBg
                Text {
                    anchors.centerIn: parent
                    text: sc.iconText
                    color: "#FFFFFF"
                    font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(17); font.weight: Font.Bold
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: VfTheme.dp(2)
                Text {
                    Layout.fillWidth: true
                    text: sc.title
                    color: VfTheme.text; font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12.5); font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: sc.desc
                    color: VfTheme.textSubtle; font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                }
                RowLayout {
                    visible: (sc.badges || []).length > 0
                    spacing: VfTheme.dp(4)
                    Repeater {
                        model: sc.badges || []
                        Rectangle {
                            Layout.preferredWidth: bdText.implicitWidth + VfTheme.dp(10)
                            Layout.preferredHeight: VfTheme.dp(15)
                            radius: VfTheme.dp(4)
                            color: VfTheme.surfaceSoft
                            border.color: VfTheme.borderSoft; border.width: 1
                            Text {
                                id: bdText
                                anchors.centerIn: parent
                                text: String(modelData)
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(8.5)
                                font.weight: VfTheme.weightStrong
                            }
                        }
                    }
                }
            }
        }
        MouseArea {
            id: scMouse
            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: sc.activated()
        }
    }
    component LabeledField: ColumnLayout {
        id: lf
        property string label: ""
        property alias text: editor.text
        property alias placeholderText: editor.placeholderText
        signal committed(string value)
        spacing: VfTheme.dp(3)
        Text {
            Layout.fillWidth: true
            text: lf.label
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(9.5)
            font.weight: VfTheme.weightStrong
            elide: Text.ElideRight
        }
        TextField {
            id: editor
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(34)
            color: VfTheme.text
            placeholderTextColor: VfTheme.textSubtle
            selectByMouse: true
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11.5)
            leftPadding: VfTheme.dp(8)
            rightPadding: VfTheme.dp(8)
            background: Rectangle {
                radius: VfTheme.radiusControl
                color: VfTheme.surfaceSoft
                border.color: editor.activeFocus ? VfTheme.primary : VfTheme.borderBox
                border.width: 1
            }
            onEditingFinished: lf.committed(text)
        }
    }

    Dialog {
        id: imagePicker
        property int rowIndex: -1
        property string productName: ""
        property var candidates: []
        property string notice: ""

        function selectedCount() {
            var count = 0
            for (var i = 0; i < candidates.length; i++)
                if ((candidates[i] || {}).selected) count++
            return count
        }
        function toggleCandidate(candidateIndex) {
            if (candidateIndex < 0 || candidateIndex >= candidates.length) return
            var old = candidates[candidateIndex] || {}
            if (!old.selected && selectedCount() >= 10) {
                notice = "Chỉ chọn tối đa 10 ảnh cho một sản phẩm."
                return
            }
            var out = candidates.slice()
            var changed = {}
            for (var key in old) changed[key] = old[key]
            changed.selected = !old.selected
            if (!changed.selected) changed.primary = false
            out[candidateIndex] = changed
            candidates = out
            notice = ""
        }
        function makePrimary(candidateIndex) {
            if (candidateIndex < 0 || candidateIndex >= candidates.length) return
            var target = candidates[candidateIndex] || {}
            if (!target.selected && selectedCount() >= 10) {
                notice = "Bỏ chọn một ảnh trước khi đặt ảnh chính mới."
                return
            }
            var out = []
            for (var i = 0; i < candidates.length; i++) {
                var source = candidates[i] || {}
                var changed = {}
                for (var key in source) changed[key] = source[key]
                changed.primary = i === candidateIndex
                if (i === candidateIndex) changed.selected = true
                out.push(changed)
            }
            candidates = out
            notice = ""
        }
        function selectAll() {
            var out = []
            for (var i = 0; i < candidates.length; i++) {
                var source = candidates[i] || {}
                var changed = {}
                for (var key in source) changed[key] = source[key]
                changed.selected = i < 10
                if (!changed.selected) changed.primary = false
                out.push(changed)
            }
            candidates = out
            notice = candidates.length > 10
                   ? "Đã chọn 10 ảnh đầu tiên." : ""
        }
        function clearAll() {
            var out = []
            for (var i = 0; i < candidates.length; i++) {
                var source = candidates[i] || {}
                var changed = {}
                for (var key in source) changed[key] = source[key]
                changed.selected = false
                changed.primary = false
                out.push(changed)
            }
            candidates = out
            notice = ""
        }
        function addImagesFromComputer() {
            root.addRowImages(rowIndex)
            if (rowIndex >= 0 && rowIndex < root.items.length)
                candidates = root.imageCandidates(root.items[rowIndex] || {})
        }

        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(860), VfTheme.dp(48))
        height: Math.min(parent.height - VfTheme.dp(48), VfTheme.dp(650))
        padding: VfTheme.dp(18)
        title: ""
        standardButtons: Dialog.NoButton
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(10)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(10)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(2)
                    Text {
                        Layout.fillWidth: true
                        text: "Chọn ảnh sản phẩm"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(17)
                        font.weight: Font.Bold
                    }
                    Text {
                        Layout.fillWidth: true
                        text: imagePicker.productName || "Sản phẩm chưa đặt tên"
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11.5)
                        elide: Text.ElideRight
                    }
                }
                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(30)
                    Layout.preferredHeight: VfTheme.dp(30)
                    radius: VfTheme.dp(7)
                    color: closeImagePickerMouse.containsMouse ? VfTheme.surfaceSoft : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                    }
                    MouseArea {
                        id: closeImagePickerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: imagePicker.close()
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: "Tick ảnh muốn giữ · bấm ★ để đặt ảnh chính · tối đa 10 ảnh"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11.5)
                wrapMode: Text.WordWrap
            }

            VfGridView {
                id: productImageGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: imagePicker.candidates
                cellWidth: VfTheme.dp(156)
                cellHeight: VfTheme.dp(178)

                delegate: Item {
                    id: imageCell
                    required property int index
                    required property var modelData
                    width: productImageGrid.cellWidth
                    height: productImageGrid.cellHeight
                    readonly property var imageData: modelData || ({})
                    readonly property bool chosen: !!imageData.selected

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(4)
                        radius: VfTheme.dp(9)
                        color: VfTheme.surfaceSoft
                        border.color: imageCell.chosen ? VfTheme.primary : VfTheme.borderBox
                        border.width: imageCell.chosen ? 2 : 1
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(3)
                            source: String(imageCell.imageData.source || "")
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: true
                            sourceSize.width: 300
                            sourceSize.height: 300
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: VfTheme.dp(7)
                            width: VfTheme.dp(24)
                            height: VfTheme.dp(24)
                            radius: VfTheme.dp(7)
                            color: imageCell.chosen ? VfTheme.primary : "#B0000000"
                            border.color: imageCell.chosen ? VfTheme.primary : "#80FFFFFF"
                            Text {
                                anchors.centerIn: parent
                                text: imageCell.chosen ? "✓" : ""
                                color: "white"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(13)
                                font.weight: Font.Bold
                            }
                        }

                        Rectangle {
                            z: 3
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: VfTheme.dp(7)
                            width: VfTheme.dp(30)
                            height: VfTheme.dp(30)
                            radius: VfTheme.dp(8)
                            color: imageCell.imageData.primary ? "#E9A23B" : "#B0000000"
                            border.color: imageCell.imageData.primary ? "#FFD68A" : "#80FFFFFF"
                            Text {
                                anchors.centerIn: parent
                                text: "★"
                                color: imageCell.imageData.primary ? "#1C1304" : "white"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(15)
                            }
                            ToolTip.visible: primaryMouse.containsMouse
                            ToolTip.text: "Đặt làm ảnh chính"
                            MouseArea {
                                id: primaryMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: imagePicker.makePrimary(imageCell.index)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            z: 2
                            cursorShape: Qt.PointingHandCursor
                            onClicked: imagePicker.toggleCandidate(imageCell.index)
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: imagePicker.notice.length > 0
                text: imagePicker.notice
                color: VfTheme.amberText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "Đã chọn " + imagePicker.selectedCount() + "/" + imagePicker.candidates.length + " ảnh"
                        color: imagePicker.selectedCount() > 0 ? VfTheme.textMuted : VfTheme.amberText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11.5)
                    }
                    VfButton {
                        text: "＋ Thêm ảnh từ máy"
                        minWidth: VfTheme.dp(142)
                        onClicked: imagePicker.addImagesFromComputer()
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    VfButton {
                        text: "Bỏ chọn"
                        minWidth: VfTheme.dp(92)
                        onClicked: imagePicker.clearAll()
                    }
                    VfButton {
                        text: "Chọn tất cả"
                        minWidth: VfTheme.dp(104)
                        onClicked: imagePicker.selectAll()
                    }
                    VfButton {
                        text: "Hủy"
                        minWidth: VfTheme.dp(78)
                        onClicked: imagePicker.close()
                    }
                    VfButton {
                        text: "✓ Dùng " + imagePicker.selectedCount() + " ảnh"
                        tone: "success"
                        minWidth: VfTheme.dp(132)
                        enabled: imagePicker.selectedCount() > 0
                        onClicked: {
                            root.applyImageSelection(imagePicker.rowIndex, imagePicker.candidates)
                            imagePicker.close()
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: warehouseDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(920), VfTheme.dp(56))
        height: VfDialogMetrics.height(parent, VfTheme.dp(620), VfTheme.dp(56))
        padding: VfTheme.dp(16)
        title: ""
        standardButtons: Dialog.NoButton
        closePolicy: Popup.CloseOnEscape

        function openWarehouse() {
            warehouseNotice.text = ""
            warehouseSearch.text = ""
            workPanelController.refreshAffiliateImportLibrary("")
            warehouseDialog.open()
        }
        function requestCleanup(action, productIds, productName) {
            warehouseCleanupConfirm.action = String(action || "")
            warehouseCleanupConfirm.productIds = productIds || []
            warehouseCleanupConfirm.productName = String(productName || "")
            warehouseCleanupConfirm.open()
        }

        background: Rectangle {
            radius: VfTheme.dp(10)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(10)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(2)
                    Text {
                        Layout.fillWidth: true
                        text: "Kho sản phẩm đã nhập"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(17)
                        font.weight: Font.Bold
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Kho chỉ được tải khi mở cửa sổ này. Chọn sản phẩm → đưa vào bảng → bấm Import; không tự chạy khi khởi động app."
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        wrapMode: Text.WordWrap
                    }
                }
                BusyIndicator {
                    running: workPanelController.affiliateImportLibraryBusy
                    visible: running
                    Layout.preferredWidth: VfTheme.dp(26)
                    Layout.preferredHeight: VfTheme.dp(26)
                }
                VfButton {
                    text: "Đóng"
                    minWidth: VfTheme.dp(78)
                    onClicked: warehouseDialog.close()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)
                TextField {
                    id: warehouseSearch
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(36)
                    enabled: !workPanelController.affiliateImportLibraryBusy
                    placeholderText: "Tìm tên, thương hiệu, mô tả…"
                    color: VfTheme.text
                    placeholderTextColor: VfTheme.textSubtle
                    selectByMouse: true
                    leftPadding: VfTheme.dp(10)
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11.5)
                    background: Rectangle {
                        radius: VfTheme.radiusControl
                        color: VfTheme.surfaceSoft
                        border.color: warehouseSearch.activeFocus
                                      ? VfTheme.primary : VfTheme.borderBox
                        border.width: 1
                    }
                    onTextChanged: warehouseSearchDebounce.restart()
                }
                Timer {
                    id: warehouseSearchDebounce
                    interval: 180
                    onTriggered: workPanelController.refreshAffiliateImportLibrary(
                        warehouseSearch.text
                    )
                }
                VfButton {
                    text: "↻ Nạp lại"
                    minWidth: VfTheme.dp(96)
                    enabled: !workPanelController.affiliateImportLibraryBusy
                    onClicked: workPanelController.refreshAffiliateImportLibrary(
                        warehouseSearch.text
                    )
                }
                VfButton {
                    text: "Dọn ảnh rác"
                    minWidth: VfTheme.dp(104)
                    enabled: !workPanelController.affiliateImportLibraryBusy
                    tooltip: "Chỉ xóa ảnh staging không còn sản phẩm nào sử dụng"
                    onClicked: workPanelController.cleanupAffiliateImportLibrary(
                        "cleanup_orphans", [], root.stagedWarehouseProductIds()
                    )
                }
                VfButton {
                    text: "Xóa kho"
                    tone: "danger"
                    minWidth: VfTheme.dp(88)
                    enabled: warehouseList.count > 0
                             && !workPanelController.affiliateImportLibraryBusy
                    tooltip: "Xóa mọi sản phẩm không nằm trong workspace hoặc pipeline"
                    onClicked: warehouseDialog.requestCleanup(
                        "clear_products", [], ""
                    )
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(8)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderBox
                border.width: 1

                ListView {
                    id: warehouseList
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(6)
                    clip: true
                    reuseItems: true
                    spacing: VfTheme.dp(5)
                    model: workPanelController.affiliateImportLibraryModel
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    delegate: Rectangle {
                        id: warehouseRow
                        required property var modelData
                        width: ListView.view ? ListView.view.width : 0
                        height: VfTheme.dp(72)
                        radius: VfTheme.dp(7)
                        color: VfTheme.surface
                        border.color: modelData.completed
                                      ? VfTheme.greenBorder : VfTheme.borderBox
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(7)
                            spacing: VfTheme.dp(9)

                            Rectangle {
                                Layout.preferredWidth: VfTheme.dp(54)
                                Layout.preferredHeight: VfTheme.dp(54)
                                radius: VfTheme.dp(7)
                                color: VfTheme.surfaceSoft
                                clip: true
                                Image {
                                    anchors.fill: parent
                                    source: String(warehouseRow.modelData.thumbnail_url || "")
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    sourceSize.width: 128
                                    sourceSize.height: 128
                                }
                                Text {
                                    anchors.centerIn: parent
                                    visible: String(warehouseRow.modelData.thumbnail_url || "") === ""
                                    text: "📦"
                                    color: VfTheme.textSubtle
                                    font.pixelSize: VfTheme.dp(18)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(2)
                                Text {
                                    Layout.fillWidth: true
                                    text: String(warehouseRow.modelData.name || "Sản phẩm")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(warehouseRow.modelData.price || "—")
                                          + " · " + String(warehouseRow.modelData.platform_label || "Thủ công")
                                          + " · " + Number(warehouseRow.modelData.source_count || 0)
                                          + " ảnh gốc"
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10.5)
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(warehouseRow.modelData.category || "Chưa phân ngành")
                                          + (String(warehouseRow.modelData.brand || "")
                                             ? " · " + String(warehouseRow.modelData.brand) : "")
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9.5)
                                    elide: Text.ElideRight
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: VfTheme.dp(104)
                                Layout.preferredHeight: VfTheme.dp(24)
                                radius: VfTheme.dp(12)
                                color: warehouseRow.modelData.completed
                                       ? VfTheme.greenFill
                                       : warehouseRow.modelData.status_key === "error"
                                         ? VfTheme.redFill : VfTheme.blueFill
                                border.color: warehouseRow.modelData.completed
                                              ? VfTheme.greenBorder
                                              : warehouseRow.modelData.status_key === "error"
                                                ? VfTheme.redBorder : VfTheme.blueBorder
                                Text {
                                    anchors.centerIn: parent
                                    text: String(warehouseRow.modelData.status_label || "Đã lưu")
                                    color: warehouseRow.modelData.completed
                                           ? VfTheme.greenText
                                           : warehouseRow.modelData.status_key === "error"
                                             ? VfTheme.redText : VfTheme.blueText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9.5)
                                    font.weight: Font.Bold
                                }
                            }

                            VfButton {
                                text: warehouseRow.modelData.completed
                                      ? "↻ Làm lại" : "＋ Đưa vào bảng"
                                tone: warehouseRow.modelData.completed ? "success" : "primary"
                                minWidth: VfTheme.dp(124)
                                enabled: !!warehouseRow.modelData.can_reimport
                                         && !workPanelController.affiliateImportLibraryBusy
                                onClicked: {
                                    var added = root.appendWarehouseRow(
                                        warehouseRow.modelData
                                    )
                                    warehouseNotice.text = added
                                        ? "Đã đưa sản phẩm vào bảng Import."
                                        : "Sản phẩm này đã có trong bảng."
                                }
                                ToolTip.visible: hovered && !enabled
                                ToolTip.text: "Ảnh gốc không còn trong staging nên chưa thể làm lại nhanh."
                            }
                            VfButton {
                                text: "Xóa"
                                tone: "danger"
                                compact: true
                                minWidth: VfTheme.dp(58)
                                enabled: !workPanelController.affiliateImportLibraryBusy
                                         && !root.warehouseProductIsStaged(
                                             warehouseRow.modelData.product_id
                                         )
                                tooltip: root.warehouseProductIsStaged(
                                             warehouseRow.modelData.product_id
                                         )
                                         ? "Sản phẩm đang nằm trong bảng Import"
                                         : "Xóa khỏi kho; giữ nguyên lịch sử, video và sheet Media Library"
                                onClicked: warehouseDialog.requestCleanup(
                                    "delete_products",
                                    [String(warehouseRow.modelData.product_id || "")],
                                    String(warehouseRow.modelData.name || "Sản phẩm")
                                )
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: warehouseList.count === 0
                                 && !workPanelController.affiliateImportLibraryBusy
                        text: "Kho chưa có sản phẩm phù hợp."
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                    }
                }
            }

            Text {
                id: warehouseNotice
                Layout.fillWidth: true
                text: ""
                color: VfTheme.greenText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10.5)
            }
            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: workPanelController.affiliateImportLibraryMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10.5)
                wrapMode: Text.WordWrap
            }
        }
    }

    Dialog {
        id: warehouseCleanupConfirm
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(480), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        property string action: ""
        property var productIds: []
        property string productName: ""

        background: Rectangle {
            radius: VfTheme.radiusPanel
            color: VfTheme.panel
            border.color: VfTheme.redBorderSoft
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)
            Text {
                Layout.fillWidth: true
                text: warehouseCleanupConfirm.action === "clear_products"
                      ? "Xóa kho sản phẩm Affiliate?"
                      : "Xóa sản phẩm khỏi kho?"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(17)
                font.weight: Font.Bold
            }
            Text {
                Layout.fillWidth: true
                text: warehouseCleanupConfirm.action === "clear_products"
                      ? "Mọi sản phẩm không nằm trong workspace/pipeline sẽ bị xóa khỏi catalog cùng ảnh staging riêng."
                      : "“" + warehouseCleanupConfirm.productName
                        + "” sẽ bị xóa khỏi catalog cùng ảnh staging riêng."
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                wrapMode: Text.WordWrap
            }
            Text {
                Layout.fillWidth: true
                text: "Lịch sử, video đã tạo và sheet hoàn chỉnh trong Media Library vẫn được giữ nguyên."
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                wrapMode: Text.WordWrap
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)
                Item { Layout.fillWidth: true }
                VfButton {
                    text: "Hủy"
                    minWidth: VfTheme.dp(88)
                    onClicked: warehouseCleanupConfirm.close()
                }
                VfButton {
                    text: "Xóa"
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        workPanelController.cleanupAffiliateImportLibrary(
                            warehouseCleanupConfirm.action,
                            warehouseCleanupConfirm.productIds,
                            root.stagedWarehouseProductIds()
                        )
                        warehouseCleanupConfirm.close()
                    }
                }
            }
        }
    }

    parent: Overlay.overlay
    modal: true
    anchors.centerIn: parent
    width: VfDialogMetrics.width(parent, VfTheme.dp(1080), VfTheme.dp(48))
    padding: VfTheme.dp(18)
    title: ""
    standardButtons: Dialog.NoButton

    background: Rectangle {
        radius: VfTheme.dp(8)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(10)

        Text {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("affiliate_import.title", "Import sản phẩm"))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(18)
            font.weight: Font.Bold
        }
        Text {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("affiliate_import.hint_table",
                  "Chọn sản phẩm từ Shopee, TikTok hoặc Kho đã nhập. Mỗi thẻ bên dưới là một sản phẩm; chỉ ảnh là bắt buộc, trường trống sẽ được AI bổ sung khi chuẩn bị."))
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            wrapMode: Text.WordWrap
        }

        // KÊNH — DÃY TAB kiểu Chrome (bố chốt 23/7): mỗi tab = 1 kênh (1 profile
        // browser riêng), bấm tab = chuyển kênh + mở browser kênh đó; tab ＋ thêm
        // kênh mới; chấm ● xanh = browser kênh đang chạy. SP nhập vào nhớ kênh.
        Flow {
            Layout.fillWidth: true
            spacing: VfTheme.dp(6)
            Text {
                height: VfTheme.dp(32)
                verticalAlignment: Text.AlignVCenter
                text: (void i18n.revision, i18n.t("affiliate_import.channel", "Kênh:"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11.5)
                font.weight: VfTheme.weightStrong
            }
            Repeater {
                model: root.channelOptions
                Rectangle {
                    id: chTab
                    readonly property string chKey: String((modelData || {}).value || "")
                    readonly property bool active: chKey === root.browserAccount
                    readonly property bool browserOn: !!(root.channelStatus || ({}))[chKey]
                    width: chTabRow.implicitWidth + VfTheme.dp(20)
                    height: VfTheme.dp(32)
                    radius: VfTheme.dp(8)
                    color: active ? VfTheme.surface : VfTheme.surfaceSoft
                    border.color: active ? VfTheme.primary : (chTabMouse.containsMouse ? VfTheme.borderStrong : VfTheme.borderBox)
                    border.width: active ? 2 : 1
                    Row {
                        id: chTabRow
                        anchors.centerIn: parent
                        spacing: VfTheme.dp(6)
                        Rectangle {
                            width: VfTheme.dp(7); height: VfTheme.dp(7)
                            radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            // ● xanh = browser kênh đang chạy (poll 4s), xám = chưa mở.
                            color: chTab.browserOn ? "#1D9D6F" : VfTheme.borderStrong
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: String((modelData || {}).label || chTab.chKey)
                            color: chTab.active ? VfTheme.text : VfTheme.textMuted
                            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11.5)
                            font.weight: chTab.active ? Font.Bold : VfTheme.weightStrong
                            elide: Text.ElideRight
                            width: Math.min(implicitWidth, VfTheme.dp(150))
                        }
                    }
                    MouseArea {
                        id: chTabMouse
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectChannel(chTab.chKey)
                    }
                    ToolTip.visible: chTabMouse.containsMouse
                    ToolTip.delay: 450
                    ToolTip.text: chTab.browserOn
                                  ? (void i18n.revision, i18n.t("affiliate_import.channel_on", "Browser đang mở — bấm để chuyển sang kênh này"))
                                  : (void i18n.revision, i18n.t("affiliate_import.channel_off", "Bấm để chuyển kênh + mở browser của kênh (kênh mới cần đăng nhập sàn 1 lần)"))
                }
            }
            // Tab ＋ (như nút tab mới của Chrome) → hiện ô gõ tên kênh.
            Rectangle {
                visible: !root.addingChannel
                width: VfTheme.dp(32); height: VfTheme.dp(32)
                radius: VfTheme.dp(8)
                color: addChMouse.containsMouse ? VfTheme.surface : VfTheme.surfaceSoft
                border.color: addChMouse.containsMouse ? VfTheme.primary : VfTheme.borderBox
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "＋"
                    color: VfTheme.primary
                    font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(14); font.weight: Font.Bold
                }
                MouseArea {
                    id: addChMouse
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { newChannelField.text = ""; root.addingChannel = true; newChannelField.forceActiveFocus() }
                }
                ToolTip.visible: addChMouse.containsMouse
                ToolTip.delay: 450
                ToolTip.text: (void i18n.revision, i18n.t("affiliate_import.channel_add", "Thêm kênh mới (browser + đăng nhập riêng)"))
            }
            TextField {
                id: newChannelField
                visible: root.addingChannel
                width: VfTheme.dp(170); height: VfTheme.dp(32)
                placeholderText: (void i18n.revision, i18n.t("affiliate_import.channel_name", "Tên kênh (vd: Kênh 2)"))
                color: VfTheme.text; placeholderTextColor: VfTheme.textSubtle; selectByMouse: true
                font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11); leftPadding: VfTheme.dp(7)
                background: Rectangle { radius: VfTheme.radiusControl; color: VfTheme.surfaceSoft; border.color: VfTheme.primary; border.width: 1 }
                onAccepted: root.commitNewChannel(text)
            }
            Rectangle {
                visible: root.addingChannel
                width: VfTheme.dp(32); height: VfTheme.dp(32)
                radius: VfTheme.dp(8)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.primary; border.width: 1
                Text {
                    anchors.centerIn: parent; text: "✔"
                    color: VfTheme.primary
                    font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(12); font.weight: Font.Bold
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.commitNewChannel(newChannelField.text)
                }
            }
            Text {
                visible: root.addingChannel
                height: VfTheme.dp(32)
                verticalAlignment: Text.AlignVCenter
                text: (void i18n.revision, i18n.t("affiliate_import.channel_cancel", "Huỷ"))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11)
                MouseArea {
                    anchors.fill: parent; anchors.margins: -VfTheme.dp(4)
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addingChannel = false
                }
            }
        }

        // Ba nguồn nhập chính. Dialog vẫn mở khi browser hoạt động; sản phẩm từ
        // side panel tự xuất hiện thành thẻ để user duyệt và chỉnh ảnh.
        GridLayout {
            Layout.fillWidth: true
            columns: width >= VfTheme.dp(720) ? 3 : 1
            columnSpacing: VfTheme.dp(9)
            rowSpacing: VfTheme.dp(9)
            SourceCard {
                iconText: "S"; iconBg: "#EE4D2D"
                title: "Shopee Affiliate"
                desc: (void i18n.revision, i18n.t("affiliate_import.src_shopee",
                      "Mở trang tiếp thị Shopee (SP có hoa hồng) — mở 1 SP rồi bấm ➕ Nhập, hàng tự hiện ở bảng dưới."))
                onActivated: root.openBrowse("shopee")
            }
            // TikTok = SHOWCASE (SP user đã gắn, sync điện thoại). MỞ OVERLAY (bố 23/7:
            // overlay là trung tâm điều khiển) — panel hiện trên trang, bấm "Bắt đầu
            // cào" ở tab Cào tự động để lấy SP. KHÔNG còn harvest headless không-UI.
            SourceCard {
                iconText: "♪"; iconBg: "#111111"
                title: "TikTok Showcase"
                desc: (void i18n.revision, i18n.t("affiliate_import.src_tiktok",
                      "Mở TikTok Shop + overlay VeoFlow — đăng nhập rồi bấm “Bắt đầu cào” trên panel để lấy SP đã gắn (ảnh, giá, hoa hồng)."))
                badges: ["đã gắn", "sync phone"]
                onActivated: root.openBrowse("tiktok")
            }
            SourceCard {
                iconText: "📦"; iconBg: "#7357C8"
                title: "Kho đã nhập"
                desc: "Tìm sản phẩm cũ, kể cả sản phẩm đã làm video, rồi đưa lại vào danh sách để chạy một lượt mới."
                badges: ["không tự chạy", "làm lại nhanh"]
                onActivated: warehouseDialog.openWarehouse()
            }
        }
        Text {
            id: fileStatus
            property bool isError: false
            Layout.fillWidth: true
            visible: text.length > 0
            color: isError ? VfTheme.redText : VfTheme.greenText
            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny
            elide: Text.ElideMiddle
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: "SẢN PHẨM CHỜ NHẬP"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10.5)
                font.weight: Font.Bold
                font.letterSpacing: 0.4
            }
            Text {
                text: root.items.length + " sản phẩm"
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10.5)
            }
        }

        // Danh sách thẻ sản phẩm: ảnh và dữ liệu tách thành từng khu vực rõ ràng.
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(360)
            radius: VfTheme.dp(8)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderBox
            border.width: 1

            ListView {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(6)
                clip: true
                reuseItems: true
                spacing: VfTheme.dp(8)
                model: root.items
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                footer: Item {
                    width: ListView.view ? ListView.view.width : 0
                    height: VfTheme.dp(52)
                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: VfTheme.dp(6)
                        radius: VfTheme.dp(8)
                        color: addRowMouse.containsMouse ? VfTheme.surface : "transparent"
                        border.color: VfTheme.primary; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "＋ " + (void i18n.revision, i18n.t("affiliate_import.btn_row", "Thêm sản phẩm thủ công"))
                            color: VfTheme.primary
                            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(12.5); font.weight: Font.Bold
                        }
                        MouseArea {
                            id: addRowMouse
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root.addManualRow()
                        }
                    }
                }
                delegate: Rectangle {
                    id: productCard
                    required property int index
                    required property var modelData
                    width: ListView.view.width
                    height: VfTheme.dp(166)
                    radius: VfTheme.dp(9)
                    color: VfTheme.surface
                    border.color: Number(productCard.rowData.count || 0) > 0 ? VfTheme.border : VfTheme.amberBorder
                    border.width: 1
                    readonly property var rowData: modelData || ({})
                    readonly property var imageRows: root.imageCandidates(rowData)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(9)
                        spacing: VfTheme.dp(7)

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(22)
                            spacing: VfTheme.dp(7)
                            Text {
                                text: "SẢN PHẨM " + (productCard.index + 1)
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: Font.Bold
                            }
                            Rectangle {
                                Layout.preferredWidth: statusText.implicitWidth + VfTheme.dp(14)
                                Layout.preferredHeight: VfTheme.dp(20)
                                radius: VfTheme.dp(6)
                                color: Number(productCard.rowData.count || 0) > 0
                                       ? VfTheme.greenFill : VfTheme.amberFill
                                Text {
                                    id: statusText
                                    anchors.centerIn: parent
                                    text: Number(productCard.rowData.count || 0) > 0
                                          ? Number(productCard.rowData.count || 0) + " ảnh · sẵn sàng"
                                          : "Cần thêm ảnh"
                                    color: Number(productCard.rowData.count || 0) > 0
                                           ? VfTheme.greenText : VfTheme.amberText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9.5)
                                    font.weight: Font.Bold
                                }
                            }
                            Item { Layout.fillWidth: true }
                            NormalToolbarButton {
                                text: "✕"
                                minWidth: VfTheme.dp(28)
                                Layout.preferredWidth: VfTheme.dp(30)
                                Layout.maximumWidth: VfTheme.dp(30)
                                tooltip: "Xóa sản phẩm khỏi danh sách"
                                onClicked: root.removeAt(productCard.index)
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: VfTheme.dp(10)

                            ColumnLayout {
                                Layout.preferredWidth: VfTheme.dp(250)
                                Layout.fillHeight: true
                                spacing: VfTheme.dp(4)
                                Text {
                                    Layout.fillWidth: true
                                    text: "HÌNH ẢNH SẢN PHẨM"
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9.5)
                                    font.weight: Font.Bold
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: VfTheme.dp(7)
                                    color: VfTheme.surfaceSoft
                                    border.color: productCard.imageRows.length > 0
                                                  ? VfTheme.borderBox : VfTheme.amberBorder
                                    border.width: 1
                                    clip: true
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: VfTheme.dp(4)
                                        spacing: VfTheme.dp(4)
                                        Rectangle {
                                            Layout.preferredWidth: VfTheme.dp(82)
                                            Layout.fillHeight: true
                                            radius: VfTheme.dp(5)
                                            color: VfTheme.surface
                                            clip: true
                                            Image {
                                                anchors.fill: parent
                                                source: productCard.imageRows.length > 0
                                                        ? String(productCard.imageRows[0].source || "") : ""
                                                fillMode: Image.PreserveAspectFit
                                                asynchronous: true
                                                cache: true
                                                sourceSize.width: 180
                                                sourceSize.height: 180
                                            }
                                            Text {
                                                anchors.centerIn: parent
                                                visible: productCard.imageRows.length === 0
                                                text: "＋"
                                                color: VfTheme.primary
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.dp(22)
                                                font.weight: Font.Bold
                                            }
                                            Rectangle {
                                                visible: productCard.imageRows.length > 0
                                                anchors.left: parent.left
                                                anchors.top: parent.top
                                                anchors.margins: VfTheme.dp(4)
                                                width: primaryText.implicitWidth + VfTheme.dp(8)
                                                height: VfTheme.dp(17)
                                                radius: VfTheme.dp(5)
                                                color: VfTheme.primary
                                                Text {
                                                    id: primaryText
                                                    anchors.centerIn: parent
                                                    text: "Ảnh chính"
                                                    color: "white"
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.dp(8)
                                                    font.weight: Font.Bold
                                                }
                                            }
                                        }
                                        GridLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            columns: 2
                                            columnSpacing: VfTheme.dp(4)
                                            rowSpacing: VfTheme.dp(4)
                                            Repeater {
                                                model: productCard.imageRows.slice(1, 4)
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    radius: VfTheme.dp(5)
                                                    color: VfTheme.surface
                                                    clip: true
                                                    Image {
                                                        anchors.fill: parent
                                                        source: String((modelData || {}).source || "")
                                                        fillMode: Image.PreserveAspectFit
                                                        asynchronous: true
                                                        cache: true
                                                        sourceSize.width: 100
                                                        sourceSize.height: 100
                                                    }
                                                }
                                            }
                                            Rectangle {
                                                visible: productCard.imageRows.length > 4
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                radius: VfTheme.dp(5)
                                                color: VfTheme.surface
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "+" + (productCard.imageRows.length - 4)
                                                    color: VfTheme.textMuted
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.dp(12)
                                                    font.weight: Font.Bold
                                                }
                                            }
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.openImagePicker(productCard.index)
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: productCard.imageRows.length > 0
                                          ? "Bấm để chọn, đổi ảnh chính hoặc thêm ảnh"
                                          : "Bấm để thêm ảnh sản phẩm (tối đa 10)"
                                    color: productCard.imageRows.length > 0
                                           ? VfTheme.textSubtle : VfTheme.primary
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9.5)
                                    elide: Text.ElideRight
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                columns: 6
                                columnSpacing: VfTheme.dp(7)
                                rowSpacing: VfTheme.dp(5)
                                LabeledField {
                                    Layout.columnSpan: 3
                                    Layout.fillWidth: true
                                    label: "TÊN SẢN PHẨM"
                                    text: String(productCard.rowData.name || "")
                                    placeholderText: "Để trống nếu muốn AI đặt tên"
                                    onCommitted: value => root.setItemField(productCard.index, "name", value)
                                }
                                LabeledField {
                                    Layout.fillWidth: true
                                    label: "GIÁ"
                                    text: String(productCard.rowData.price || "")
                                    placeholderText: "199k"
                                    onCommitted: value => root.setItemField(productCard.index, "price", value)
                                }
                                LabeledField {
                                    Layout.fillWidth: true
                                    label: "THƯƠNG HIỆU"
                                    text: String(productCard.rowData.brand || "")
                                    placeholderText: "Không rõ"
                                    onCommitted: value => root.setItemField(productCard.index, "brand", value)
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: VfTheme.dp(3)
                                    Text {
                                        Layout.fillWidth: true
                                        text: "NGÀNH"
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(9.5)
                                        font.weight: VfTheme.weightStrong
                                    }
                                    NoScrollComboBox {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: VfTheme.dp(34)
                                        model: root._categories
                                        textRole: "label"
                                        valueRole: "value"
                                        currentIndex: Math.max(0, indexOfValue(String(productCard.rowData.category || "")))
                                        onActivated: idx => root.setItemField(productCard.index, "category", String(valueAt(idx)))
                                    }
                                }
                                LabeledField {
                                    Layout.columnSpan: 3
                                    Layout.fillWidth: true
                                    label: "CÔNG DỤNG / ĐIỂM NỔI BẬT"
                                    text: String(productCard.rowData.uses || "")
                                    placeholderText: "Để trống để AI phân tích từ ảnh"
                                    onCommitted: value => root.setItemField(productCard.index, "uses", value)
                                }
                                LabeledField {
                                    Layout.columnSpan: 3
                                    Layout.fillWidth: true
                                    label: "MÔ TẢ NGUỒN CHO KỊCH BẢN"
                                    text: String(productCard.rowData.description || "")
                                    placeholderText: "Thông số, chất liệu, ưu đãi…"
                                    onCommitted: value => root.setItemField(productCard.index, "description", value)
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(10)
            Text {
                Layout.fillWidth: true
                text: {
                    var total = root.items.length
                    var ready = root.readyCount()
                    if (total === 0) return ""
                    var s = ready + " SP" + (total > ready
                        ? " · " + (total - ready) + (void i18n.revision, i18n.t("affiliate_import.rows_noimg", " hàng thiếu ảnh (bị bỏ qua)"))
                        : "")
                    return s
                }
                color: root.readyCount() < root.items.length ? VfTheme.amberText : VfTheme.textSubtle
                font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11)
                elide: Text.ElideRight
            }
            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                minWidth: VfTheme.dp(86); implicitHeight: VfTheme.dp(40)
                onClicked: root.reject()
            }
            VfButton {
                text: "⚡ " + (void i18n.revision, i18n.t("affiliate_import.run", "Import")) + " " + root.readyCount() + " SP"
                tone: "success"
                minWidth: VfTheme.dp(160); implicitHeight: VfTheme.dp(40)
                enabled: root.readyCount() > 0
                onClicked: {
                    // Sản phẩm nhập tay chưa có kênh → đóng dấu kênh đang chọn.
                    var out = root.items.slice()
                    for (var i = 0; i < out.length; i++) {
                        if (!String((out[i] || {}).browser_account || "")) {
                            var it = {}
                            for (var k in out[i]) it[k] = out[i][k]
                            it.browser_account = root.browserAccount
                            out[i] = it
                        }
                    }
                    root.importRequested(out)
                    root.accept()
                }
            }
        }
    }
}
