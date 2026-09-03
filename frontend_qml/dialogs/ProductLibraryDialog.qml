import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "productLibraryDialog"

    property var products: []
    property var selectedProduct: ({})
    property var selectedProductIds: []
    property bool selectMode: false
    property bool multiSelect: true
    property string formName: ""
    property string formBrand: ""
    property string formPrice: ""
    property string formDescription: ""
    property var formFeatures: []
    property string formMainImageMediaId: ""
    property var formExtraImageIds: []
    property string formMainImagePreview: ""
    property var formExtraImagePreviews: []
    property string pendingDeleteProductId: ""
    property string pendingDeleteProductName: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property var categoryOptions: [
        { label: (void i18n.revision, i18n.t("common.all", "All")), value: "" },
        { label: (void i18n.revision, i18n.t("product_library.category.cosmetics", "Cosmetics")), value: "cosmetics" },
        { label: (void i18n.revision, i18n.t("product_library.category.fashion", "Fashion")), value: "fashion" },
        { label: (void i18n.revision, i18n.t("product_library.category.electronics", "Electronics")), value: "electronics" },
        { label: (void i18n.revision, i18n.t("product_library.category.home", "Home")), value: "home" },
        { label: (void i18n.revision, i18n.t("product_library.category.food", "Food")), value: "food" },
        { label: (void i18n.revision, i18n.t("product_library.category.sports", "Sports")), value: "sports" },
        { label: (void i18n.revision, i18n.t("product_library.category.beauty", "Beauty")), value: "beauty" },
        { label: (void i18n.revision, i18n.t("product_library.category.health", "Health")), value: "health" },
        { label: (void i18n.revision, i18n.t("product_library.category.baby", "Baby")), value: "baby" },
        { label: (void i18n.revision, i18n.t("product_library.category.other", "Other")), value: "other" }
    ]

    signal refreshRequested(string search, string category)
    signal productSelected(var product)
    signal productsSelected(var products)
    signal addRequested()
    signal importRequested()
    signal saveRequested(var product)
    signal cancelEditRequested()
    signal chooseMainImageRequested(string productId)
    signal chooseExtraImagesRequested(string productId)
    signal deleteRequested(string productId)

    function requestImport() {
        root.importRequested()
    }

    title: root.selectMode ? (void i18n.revision, i18n.t("product_library.title_select", "Select product")) : (void i18n.revision, i18n.t("product_library.title_manage", "Manage products"))
    header: null
    parent: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(1200), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(800), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: VfTheme.dp(12)

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(10)
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    onOpened: {
        if (root.selectMode) {
            var seedIds = [].concat(root.selectedProductIds || [])
            var seedId = root.selectedId()
            if (!root.multiSelect) {
                if (seedId.length > 0)
                    seedIds = [seedId]
                else if (seedIds.length > 0)
                    seedIds = [String(seedIds[0] || "")]
                else
                    seedIds = []
            } else if (seedIds.length === 0 && seedId.length > 0) {
                seedIds = [seedId]
            }
            root.selectedProductIds = root.normalizeSelectionIds(seedIds)
        }
        root.refreshRequested(searchInput.text, String(categoryFilter.currentValue || ""))
        if ((!root.selectedProduct || !root.productId(root.selectedProduct)) && root.products && root.products.length > 0)
            root.selectedProduct = root.products[0]
        root.syncFormFromSelected()
    }

    onSelectedProductChanged: root.syncFormFromSelected()

    onProductsChanged: {
        var currentId = root.selectedId()
        if (root.selectMode) {
            var nextSelected = []
            var ids = [].concat(root.selectedProductIds || [])
            for (var i = 0; i < ids.length; i++) {
                var candidate = root.findProductById(String(ids[i] || ""))
                if (candidate)
                    nextSelected.push(root.productId(candidate))
            }
            root.selectedProductIds = root.normalizeSelectionIds(nextSelected)
        }
        if (currentId.length > 0) {
            var refreshed = root.findProductById(currentId)
            if (refreshed)
                root.selectedProduct = refreshed
        } else if (root.products && root.products.length > 0) {
            root.selectedProduct = root.products[0]
        }
    }

    function productId(product) {
        return String(product.product_id || product.id || "")
    }

    function selectedId() {
        return root.productId(root.selectedProduct || ({}))
    }

    function selectedCount() {
        if (root.selectMode) {
            var ids = root.normalizeSelectionIds([].concat(root.selectedProductIds || []))
            if (!root.multiSelect && ids.length === 0 && root.selectedId().length > 0)
                return 1
            return ids.length
        }
        return root.selectedId().length > 0 ? 1 : 0
    }

    function isProductSelected(productId) {
        var targetId = String(productId || "")
        var ids = [].concat(root.selectedProductIds || [])
        return ids.indexOf(targetId) >= 0
    }

    function normalizeSelectionIds(ids) {
        var values = []
        var seen = {}
        var list = [].concat(ids || [])
        for (var i = 0; i < list.length; i++) {
            var productId = String(list[i] || "")
            if (!productId.length || seen[productId])
                continue
            seen[productId] = true
            values.push(productId)
        }
        if (!root.multiSelect && values.length > 1)
            values = [values[0]]
        return values
    }

    function selectProduct(product) {
        var item = product || ({})
        var productId = root.productId(item)
        root.selectedProduct = item
        root.selectedProductIds = productId.length > 0 ? [productId] : []
    }

    function toggleSelectedProduct(product) {
        var item = product || ({})
        var productId = root.productId(item)
        if (!productId.length)
            return
        if (!root.multiSelect) {
            root.selectProduct(item)
            return
        }
        var ids = [].concat(root.selectedProductIds || [])
        var index = ids.indexOf(productId)
        if (index >= 0)
            ids.splice(index, 1)
        else
            ids.push(productId)
        root.selectedProductIds = root.normalizeSelectionIds(ids)
        root.selectedProduct = item
    }

    function selectedProductsPayload() {
        var out = []
        var ids = root.normalizeSelectionIds(root.selectedProductIds)
        for (var i = 0; i < ids.length; i++) {
            var product = root.findProductById(String(ids[i] || ""))
            if (product)
                out.push(product)
        }
        return out
    }

    function selectedProductPayload() {
        var product = root.selectedProduct
        if (product && root.productId(product).length > 0)
            return product
        var items = root.selectedProductsPayload()
        return items.length > 0 ? items[0] : null
    }

    function applySelection() {
        if (root.selectMode) {
            if (root.multiSelect) {
                root.productsSelected(root.selectedProductsPayload())
                return
            }
            var product = root.selectedProductPayload()
            if (product)
                root.productSelected(product)
            return
        }
        var current = root.selectedProductPayload()
        if (current)
            root.productSelected(current)
    }

    function findProductById(productId) {
        var list = root.products || []
        for (var i = 0; i < list.length; i++) {
            if (root.productId(list[i]) === String(productId || ""))
                return list[i]
        }
        return null
    }

    function imageSource(value) {
        var raw = String(value || "")
        if (raw.length === 0)
            return ""
        if (raw.indexOf("data:") === 0 || raw.indexOf("qrc:") === 0)
            return raw
        if (raw.indexOf("http://") === 0 || raw.indexOf("https://") === 0)
            return raw
        if (root.looksLikeImageBase64(raw))
            return "data:image/png;base64," + raw
        return "file:///" + raw.replace(/\\/g, "/")
    }

    function looksLikeImageBase64(value) {
        var raw = String(value || "").trim()
        if (raw.length < 80 || raw.indexOf("\\") >= 0 || raw.indexOf("://") >= 0)
            return false
        if (raw.indexOf("iVBOR") === 0 || raw.indexOf("/9j/") === 0 || raw.indexOf("R0lGOD") === 0 || raw.indexOf("UklGR") === 0)
            return true
        return raw.indexOf("/") < 0 && /^[A-Za-z0-9+/]+={0,2}$/.test(raw)
    }

    function productMainImageId(product) {
        return String(product.main_image_media_id || "")
    }

    function productMainImagePreview(product) {
        return String(product.main_image_preview || product.thumbnail_base64 || product.main_image_base64 || product.image_base64 || product.thumbnail || product.image_path || "")
    }

    function productExtraImageIds(product) {
        return [].concat(product.extra_image_ids || [])
    }

    function productExtraImagePreviews(product) {
        return [].concat(product.extra_image_previews || product.extra_images || product.extra_image_base64 || [])
    }

    function productFeatures(product) {
        return [].concat(product.key_features || product.features || [])
    }

    function categoryIndexForValue(value) {
        var current = String(value || "")
        var opts = root.categoryOptions.slice(1)
        for (var i = 0; i < opts.length; i++) {
            if (String(opts[i].value || "") === current)
                return i
        }
        return 0
    }

    function categoryValueAt(index) {
        var opts = root.categoryOptions.slice(1)
        if (index >= 0 && index < opts.length)
            return String(opts[index].value || "")
        return "other"
    }

    function syncFormFromSelected() {
        var product = root.selectedProduct || ({})
        root.formName = String(product.name || "")
        root.formBrand = String(product.brand || "")
        root.formPrice = String(product.price || "")
        root.formDescription = String(product.description || "")
        root.formFeatures = root.productFeatures(product)
        root.formMainImageMediaId = root.productMainImageId(product)
        root.formExtraImageIds = root.productExtraImageIds(product)
        root.formMainImagePreview = root.productMainImagePreview(product)
        root.formExtraImagePreviews = root.productExtraImagePreviews(product)
        categoryCombo.currentIndex = root.categoryIndexForValue(product.category || "cosmetics")
        if (nameInput.text !== root.formName)
            nameInput.text = root.formName
        if (brandInput.text !== root.formBrand)
            brandInput.text = root.formBrand
        if (priceInput.text !== root.formPrice)
            priceInput.text = root.formPrice
        if (descriptionInput.text !== root.formDescription)
            descriptionInput.text = root.formDescription
        featureInput.text = ""
    }

    function addFeature() {
        var feature = String(featureInput.text || "").trim()
        if (!feature.length)
            return
        var next = [].concat(root.formFeatures || [])
        next.push(feature)
        root.formFeatures = next
        featureInput.text = ""
    }

    function removeFeature(index) {
        if (index < 0 || index >= root.formFeatures.length)
            return
        var next = [].concat(root.formFeatures || [])
        next.splice(index, 1)
        root.formFeatures = next
    }

    function requestDeleteProduct(product) {
        var item = product || root.selectedProduct || ({})
        root.pendingDeleteProductId = root.productId(item)
        if (root.pendingDeleteProductId.length === 0) {
            root.feedbackTitle = (void i18n.revision, i18n.t("product_library.no_selection_title", "No selection"))
            root.feedbackMessage = (void i18n.revision, i18n.t("product_library.select_product_delete", "Please select a product to delete."))
            feedbackDialog.open()
            return
        }
        root.pendingDeleteProductName = String(item.name || item.title || "")
        deleteConfirmDialog.open()
    }

    function formPayload() {
        var product = root.selectedProduct || ({})
        return {
            product_id: root.productId(product),
            id: root.productId(product),
            name: String(root.formName || "").trim(),
            brand: String(root.formBrand || "").trim(),
            category: root.categoryValueAt(categoryCombo.currentIndex),
            price: String(root.formPrice || "").trim(),
            description: String(root.formDescription || "").trim(),
            key_features: [].concat(root.formFeatures || []),
            main_image_media_id: String(root.formMainImageMediaId || ""),
            extra_image_ids: [].concat(root.formExtraImageIds || [])
        }
    }

    function requestSave() {
        if (!String(root.formName || "").trim().length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("product_library.missing_info_title", "Missing information"))
            root.feedbackMessage = (void i18n.revision, i18n.t("product_library.name_required_warning", "Please enter a product name."))
            nameInput.forceActiveFocus()
            feedbackDialog.open()
            return
        }
        root.saveRequested(root.formPayload())
    }

    function applySaveResult(result, fallbackPayload) {
        var response = result || ({})
        if (!response.ok) {
            var errorCode = String(response.error || "")
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            if (errorCode === "product_not_found") {
                root.feedbackMessage = (void i18n.revision, i18n.t("product_library.update_not_found", "Could not find the product to update."))
            } else if (errorCode === "missing_product_id") {
                root.feedbackMessage = (void i18n.revision, i18n.t("product_library.missing_product_id", "Missing product id for update."))
            } else if (errorCode === "missing_name") {
                root.feedbackMessage = (void i18n.revision, i18n.t("product_library.name_required_warning", "Please enter a product name."))
                nameInput.forceActiveFocus()
            } else {
                root.feedbackMessage = (void i18n.revision, i18n.t("product_library.save_failed_generic", "Could not save product."))
            }
            feedbackDialog.open()
            return
        }

        var product = response.product || fallbackPayload || ({})
        if (product && typeof product === "object") {
            root.selectedProduct = product
            root.pendingDeleteProductId = ""
            root.pendingDeleteProductName = ""
        }
    }

    function applyAddResult(result) {
        var response = result || ({})
        if (!response.ok) {
            var errorCode = String(response.error || "")
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            if (errorCode === "missing_name") {
                root.feedbackMessage = (void i18n.revision, i18n.t("product_library.name_required_warning", "Please enter a product name."))
            } else {
                root.feedbackMessage = (void i18n.revision, i18n.t("product_library.create_failed_generic", "Could not create draft product."))
            }
            feedbackDialog.open()
            return
        }

        var product = response.product || root.findProductById(String(response.product_id || "")) || ({})
        if (product && typeof product === "object")
            root.selectedProduct = product
        root.syncFormFromSelected()
    }

    function applyDeleteResult(result) {
        var response = result || ({})
        if (!response.ok) {
            var errorCode = String(response.error || "")
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            if (errorCode === "product_not_found") {
                root.feedbackMessage = (void i18n.revision, i18n.t("product_library.delete_not_found", "Could not find the product to delete."))
            } else if (errorCode === "missing_product_id") {
                root.feedbackMessage = (void i18n.revision, i18n.t("product_library.missing_product_id", "Missing product id for update."))
            } else {
                root.feedbackMessage = (void i18n.revision, i18n.t("product_library.delete_failed_generic", "Could not delete product."))
            }
            feedbackDialog.open()
            return
        }

        root.feedbackTitle = (void i18n.revision, i18n.t("product_library.delete_done_title", "Delete complete"))
        root.feedbackMessage = (void i18n.revision, i18n.t("product_library.delete_done_message", "Product deleted successfully."))
        root.selectedProduct = null
        root.pendingDeleteProductId = ""
        root.pendingDeleteProductName = ""
        feedbackDialog.open()
    }

    function applySelectionResult(result) {
        var response = result || ({})
        if (!response.ok) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = String(
                response.message
                || response.error
                || (response.blocker && (response.blocker.message || response.blocker.code))
                || (void i18n.revision, i18n.t("product_library.select_failed_generic", "Could not use the selected product."))
            )
            feedbackDialog.open()
            return false
        }
        root.accept()
        return true
    }

    function applyMainImageResult(result) {
        var response = result || ({})
        if (!response.ok) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = String(
                response.message
                || response.error
                || (void i18n.revision, i18n.t("product_library.main_image_failed", "Could not update the main product image."))
            )
            feedbackDialog.open()
            return false
        }
        var product = response.product || root.findProductById(String(response.product_id || "")) || ({})
        if (product && typeof product === "object")
            root.selectedProduct = product
        root.syncFormFromSelected()
        return true
    }

    function applyExtraImagesResult(result) {
        var response = result || ({})
        if (!response.ok) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = String(
                response.message
                || response.error
                || (void i18n.revision, i18n.t("product_library.extra_images_failed", "Could not update the extra product images."))
            )
            feedbackDialog.open()
            return false
        }
        var product = response.product || root.findProductById(String(response.product_id || "")) || ({})
        if (product && typeof product === "object")
            root.selectedProduct = product
        root.syncFormFromSelected()
        return true
    }

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(8)

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            TextField {
                id: searchInput
                Layout.preferredWidth: VfTheme.dp(200)
                Layout.preferredHeight: VfTheme.dp(40)
                placeholderText: (void i18n.revision, i18n.t("product_library.search_placeholder", "Search products..."))
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                onAccepted: root.refreshRequested(text, String(categoryFilter.currentValue || ""))

                background: Rectangle {
                    radius: VfTheme.dp(6)
                    color: VfTheme.surface
                    border.color: searchInput.activeFocus ? VfTheme.primary : VfTheme.borderStrong
                }
            }

            Text {
                text: (void i18n.revision, i18n.t("product_library.category_label", "Category:"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
            }

            NoScrollComboBox {
                id: categoryFilter
                Layout.preferredWidth: VfTheme.dp(160)
                Layout.preferredHeight: VfTheme.dp(40)
                model: root.categoryOptions
                textRole: "label"
                valueRole: "value"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                onActivated: root.refreshRequested(searchInput.text, String(categoryFilter.currentValue || ""))
            }

            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("product_library.add_new", "+ Add new"))
                tone: "success"
                minWidth: VfTheme.dp(112)
                onClicked: root.addRequested()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("product_library.import", "Import"))
                showLeadingIcon: false
                minWidth: VfTheme.dp(86)
                onClicked: root.importRequested()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: VfTheme.border
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            Rectangle {
                SplitView.preferredWidth: Math.min(VfTheme.dp(340), Math.max(VfTheme.dp(260), Math.round(root.width * 0.32)))
                SplitView.minimumWidth: Math.min(VfTheme.dp(300), Math.max(VfTheme.dp(220), Math.round(root.width * 0.26)))
                SplitView.maximumWidth: 360
                color: VfTheme.surface

                ColumnLayout {
                    anchors.fill: parent
                    anchors.rightMargin: VfTheme.dp(8)
                    spacing: VfTheme.dp(6)

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("product_library.list_title", "PRODUCT LIST"))
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightTitle
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: VfTheme.surface
                        border.color: VfTheme.borderStrong
                        radius: VfTheme.dp(4)
                        clip: true

                        ListView {
                            id: productList
                            anchors.fill: parent
                            model: root.products || []
                            clip: true
                            reuseItems: true

                            delegate: ProductListRow {
                                width: productList.width
                                product: modelData
                                selected: root.selectMode
                                    ? root.isProductSelected(root.productId(modelData))
                                    : (root.selectedId() === root.productId(modelData))
                                onClicked: {
                                    if (root.selectMode)
                                        root.multiSelect ? root.toggleSelectedProduct(product) : root.selectProduct(product)
                                    else
                                        root.selectedProduct = product
                                }
                            }
                        }
                    }

                    VfButton {
                        Layout.fillWidth: true
                        actionId: "delete"
                        tone: "danger"
                        text: (void i18n.revision, i18n.t("product_library.delete_product", "Delete product"))
                        onClicked: root.requestDeleteProduct(root.selectedProduct)
                    }
                }
            }

            ScrollView {
                id: detailScroll
                SplitView.fillWidth: true
                SplitView.fillHeight: true
                contentWidth: availableWidth
                contentHeight: detailBody.implicitHeight
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    id: detailBody
                    width: detailScroll.availableWidth
                    spacing: VfTheme.dp(6)
                    anchors.leftMargin: VfTheme.dp(8)

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("product_library.detail_title", "PRODUCT DETAILS"))
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightTitle
                    }

                    FieldLabel { text: (void i18n.revision, i18n.t("product_library.name_required", "Product name *")) }
                    TextFieldBox {
                        id: nameInput
                        placeholder: (void i18n.revision, i18n.t("product_library.name_placeholder", "Enter product name"))
                        onTextChanged: root.formName = text
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(2)

                            FieldLabel { text: (void i18n.revision, i18n.t("product_library.brand", "Brand")) }
                            TextFieldBox {
                                id: brandInput
                                placeholder: "Nike, Apple, ..."
                                onTextChanged: root.formBrand = text
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(2)

                            FieldLabel { text: (void i18n.revision, i18n.t("product_library.price", "Price")) }
                            TextFieldBox {
                                id: priceInput
                                placeholder: (void i18n.revision, i18n.t("product_library.price_placeholder", "299.000d"))
                                onTextChanged: root.formPrice = text
                            }
                        }
                    }

                    FieldLabel { text: (void i18n.revision, i18n.t("product_library.category_label_plain", "Category")) }
                    NoScrollComboBox {
                        id: categoryCombo
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(40)
                        model: root.categoryOptions.slice(1)
                        textRole: "label"
                        valueRole: "value"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                    }

                    FieldLabel { text: (void i18n.revision, i18n.t("product_library.description", "Description")) }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(112)
                        radius: VfTheme.dp(4)
                        color: VfTheme.surface
                        border.color: VfTheme.border

                        TextArea {
                            id: descriptionInput
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(6)
                            placeholderText: (void i18n.revision, i18n.t("product_library.description_placeholder", "Describe this product..."))
                            wrapMode: TextArea.Wrap
                            color: VfTheme.text
                            placeholderTextColor: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            onTextChanged: root.formDescription = text
                            background: Rectangle {
                                color: VfTheme.surface
                                border.color: VfTheme.borderBox
                                border.width: 1
                                radius: VfTheme.radiusControl
                            }
                        }
                    }

                    FieldLabel { text: (void i18n.revision, i18n.t("product_library.features", "Key features")) }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)

                        TextFieldBox {
                            id: featureInput
                            Layout.fillWidth: true
                            placeholder: (void i18n.revision, i18n.t("product_library.feature_placeholder", "Add a feature then press +"))
                            onAccepted: root.addFeature()
                        }

                        VfButton {
                            text: "+"
                            tone: "success"
                            minWidth: VfTheme.dp(36)
                            onClicked: root.addFeature()
                        }
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)

                        Repeater {
                            model: root.formFeatures || []

                            Rectangle {
                                required property int index
                                required property var modelData

                                height: VfTheme.dp(24)
                                width: Math.max(48, featureText.implicitWidth + 28)
                                radius: VfTheme.dp(12)
                                color: VfTheme.blueFill
                                border.color: VfTheme.blueBorderSoft

                                Text {
                                    id: featureText
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: VfTheme.dp(10)
                                    text: String(modelData)
                                    color: VfTheme.blueText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: VfTheme.weightStrong
                                }

                                MouseArea {
                                    anchors.right: parent.right
                                    anchors.rightMargin: VfTheme.dp(6)
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: VfTheme.dp(14)
                                    height: VfTheme.dp(14)
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.removeFeature(index)
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: VfTheme.dp(9)
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "x"
                                    color: VfTheme.blueText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                    font.weight: VfTheme.weightStrong
                                }
                            }
                        }
                    }

                    FieldLabel { text: (void i18n.revision, i18n.t("product_library.images", "Product images")) }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(148)
                        radius: VfTheme.radiusControl
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        RowLayout {
                            anchors.fill: parent
                            spacing: VfTheme.dp(10)

                            ColumnLayout {
                                spacing: VfTheme.dp(4)

                                Text {
                                    text: (void i18n.revision, i18n.t("product_library.main_image", "Main image"))
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                }

                                ImageSlot {
                                    width: VfTheme.dp(80)
                                    height: VfTheme.dp(80)
                                    sourceValue: root.formMainImagePreview
                                    placeholder: "?"
                                }

                                VfButton {
                                    text: (void i18n.revision, i18n.t("product_library.choose_main_image", "Choose main image"))
                                    showLeadingIcon: false
                                    minWidth: VfTheme.dp(130)
                                    enabled: root.selectedId().length > 0
                                    onClicked: root.chooseMainImageRequested(root.selectedId())
                                }
                            }

                            ColumnLayout {
                                spacing: VfTheme.dp(4)

                                Text {
                                    text: (void i18n.revision, i18n.t("product_library.extra_images", "Extra images (max 3)"))
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                }

                                Row {
                                    spacing: VfTheme.dp(4)

                                    Repeater {
                                        model: 3

                                        ImageSlot {
                                            width: VfTheme.dp(70)
                                            height: VfTheme.dp(70)
                                            sourceValue: {
                                                var imgs = root.formExtraImagePreviews || []
                                                return imgs && imgs.length > index ? String(imgs[index]) : ""
                                            }
                                            placeholder: "+"
                                        }
                                    }
                                }

                                VfButton {
                                    text: (void i18n.revision, i18n.t("product_library.add_extra_images", "Add extra images"))
                                    showLeadingIcon: false
                                    minWidth: VfTheme.dp(128)
                                    enabled: root.selectedId().length > 0
                                    onClicked: root.chooseExtraImagesRequested(root.selectedId())
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        spacing: VfTheme.dp(8)

                        Item { Layout.fillWidth: true }

                        VfButton {
                            text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                            showLeadingIcon: false
                            minWidth: VfTheme.dp(86)
                            onClicked: {
                                root.syncFormFromSelected()
                                root.cancelEditRequested()
                            }
                        }

                        VfButton {
                            text: (void i18n.revision, i18n.t("common.save", "Save"))
                            showLeadingIcon: false
                            tone: "primary"
                            minWidth: VfTheme.dp(86)
                            onClicked: root.requestSave()
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            Item { Layout.fillWidth: true }

            VfButton {
                text: root.selectMode
                    ? (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    : (void i18n.revision, i18n.t("common.close", "Close"))
                showLeadingIcon: false
                minWidth: VfTheme.dp(90)
                onClicked: {
                    if (root.selectMode)
                        root.reject()
                    else
                        root.close()
                }
            }

                VfButton {
                    text: (void i18n.revision, i18n.t("product_library.select_count", "Select ({count})"))
                        .replace("{count}", String(root.selectedCount()))
                    tone: "primary"
                    minWidth: VfTheme.dp(104)
                    visible: root.selectMode
                    Layout.preferredWidth: visible ? implicitWidth : 0
                    enabled: root.selectedCount() > 0
                    onClicked: root.applySelection()
                }
        }
    }

    Dialog {
        id: deleteConfirmDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(360), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("product_library.delete_confirm_title", "Confirm delete"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t(
                    "product_library.delete_confirm_message",
                    "Delete product '%1'?"
                )).arg(root.pendingDeleteProductName.length > 0 ? root.pendingDeleteProductName : (void i18n.revision, i18n.t("common.untitled", "Untitled")))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: deleteConfirmDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.delete", "Delete"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        deleteConfirmDialog.close()
                        root.deleteRequested(root.pendingDeleteProductId)
                    }
                }
            }
        }

        onClosed: {
            root.pendingDeleteProductId = ""
            root.pendingDeleteProductName = ""
        }
    }

    Dialog {
        id: feedbackDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(360), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }

    component ProductListRow: Rectangle {
        id: row

        property var product: ({})
        property bool selected: false

        signal clicked()

        height: VfTheme.dp(44)
        color: row.selected ? VfTheme.blueFill : (rowMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
        border.color: VfTheme.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(4)
            spacing: VfTheme.dp(7)

            ImageSlot {
                width: VfTheme.dp(36)
                height: VfTheme.dp(36)
                sourceValue: root.productMainImagePreview(row.product)
                placeholder: ""
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: String(row.product.name || row.product.title || (void i18n.revision, i18n.t("common.untitled", "Untitled")))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    property string _info: [String(row.product.brand || ""), String(row.product.price || "")].filter(function(x) { return x.length > 0 }).join(" | ")
                    text: _info
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.clicked()
        }
    }

    component FieldLabel: Text {
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        font.weight: VfTheme.weightStrong
    }

    component TextFieldBox: TextField {
        property string placeholder: ""

        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(40)
        placeholderText: placeholder
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontControl
        selectByMouse: true

                        background: Rectangle {
                            radius: VfTheme.dp(4)
                            color: VfTheme.surface
                            border.color: parent.activeFocus ? VfTheme.primary : VfTheme.borderStrong
                        }
    }

    component ImageSlot: Rectangle {
        property string sourceValue: ""
        property string placeholder: "?"

        radius: VfTheme.dp(4)
        color: VfTheme.surfaceSoft
        border.color: sourceValue.length > 0 ? VfTheme.greenBorderSoft : VfTheme.borderStrong
        border.width: 1
        clip: true

        Image {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(2)
            source: root.imageSource(parent.sourceValue)
            fillMode: Image.PreserveAspectFit
            visible: source.toString().length > 0
            asynchronous: true
            sourceSize.width: 320
            sourceSize.height: 240
        }

        Text {
            anchors.centerIn: parent
            text: parent.placeholder
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: parent.width <= 56 ? 16 : 20
            visible: parent.sourceValue.length === 0
        }
    }
}
