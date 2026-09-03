import QtQuick

import "../dialogs"

Item {
    id: root

    property var config: ({})
    property bool allowAutoStyle: false
    property var applySelection: null

    width: 0
    height: 0

    function open() {
        masterOptionsController.refreshStyles("")
        styleManagerDialog.openBucket("style")
    }

    function close() {
        if (styleManagerDialog.opened)
            styleManagerDialog.close()
    }

    function styleLabelForId(styleId) {
        var wanted = String(styleId || "")
        if (!wanted.length)
            return ""
        var items = masterOptionsController.styles || []
        for (var i = 0; i < items.length; i++) {
            var item = items[i] || {}
            var candidate = String(item.id || item.style_id || "")
            if (candidate === wanted)
                return String(item.display_name || item.name || candidate)
        }
        return wanted
    }

    function selectedSummary() {
        var parts = []
        var styleId = String(
            root.config.structural_style_id || root.config.style_id || "")
        var surfaceStyleId = String(root.config.surface_style_id || "")
        var cameraId = String(
            root.config.camera_id || root.config.structural_camera_id
            || root.config.surface_camera_id || "")
        var styleLabel = root.styleLabelForId(styleId)
        var surfaceLabel = surfaceStyleId !== styleId
                         ? root.styleLabelForId(surfaceStyleId) : ""
        var cameraLabel = root.styleLabelForId(cameraId)
        if (styleLabel.length)
            parts.push(styleLabel)
        if (surfaceLabel.length)
            parts.push(surfaceLabel)
        if (cameraLabel.length)
            parts.push(cameraLabel)
        return parts.join(" + ")
    }

    StyleManagerDialog {
        id: styleManagerDialog
        styles: masterOptionsController.styles
        allowAutoStyle: root.allowAutoStyle
        topicGenerationBusy: masterOptionsController.styleTopicBusy
        previewGenerationBusy: masterOptionsController.stylePreviewBusy
        motionPreviewBusy: masterOptionsController.drawMotionPreviewBusy
        selectedId: root.config.structural_style_id
                    || root.config.style_id
                    || root.config.surface_style_id
                    || root.config.camera_id
                    || root.config.structural_camera_id
                    || ""
        selectedCameraId: root.config.camera_id
                          || root.config.structural_camera_id
                          || root.config.surface_camera_id
                          || ""
        selectedStyleId: root.config.structural_style_id
                         || root.config.style_id
                         || ""
        selectedSurfaceStyleId: (
            root.config.surface_style_id
            && root.config.surface_style_id
               !== (root.config.structural_style_id || root.config.style_id)
        ) ? root.config.surface_style_id : ""
        savedDrawHandAssignments: masterOptionsController.drawStyleHandBindings || ({})
        savedDrawMotionProfiles: masterOptionsController.drawStyleMotionProfiles || ({})
        handAssetOptions: masterOptionsController.drawMotionHandOptions || []  // perf-lint: disable=R2 static catalog
        statusMessage: masterOptionsController.statusMessage

        onRefreshRequested: function(search) {
            masterOptionsController.refreshStyles(search || "")
        }
        onApplyRequested: function(selection) {
            var result = root.applySelection
                       ? root.applySelection(selection || ({}))
                       : ({ ok: false, message: "Style target is unavailable." })
            if (!result || result.ok !== false)
                styleManagerDialog.accept()
        }
        onAddRequested: function(kind) {
            styleEditDialog.openNew(kind || "style")
        }
        onEditRequested: function(style) {
            var item = style || ({})
            var styleId = String(item.id || item.style_id || "")
            if (styleId.length > 0) {
                var previewInfo = masterOptionsController.stylePreview(styleId)
                if (previewInfo && previewInfo.ok !== false)
                    item.preview_state = previewInfo
            }
            styleEditDialog.openFor(item)
        }
        onDeleteRequested: function(styleId) {
            styleManagerDialog.applyDeleteResult(
                masterOptionsController.deleteStyle(styleId))
        }
        onDeleteTopicRequested: function(topicId) {
            styleManagerDialog.applyDeleteTopicResult(
                masterOptionsController.deleteStyleTopic(topicId))
        }
        onToggleFavoriteRequested: function(styleId) {
            styleManagerDialog.applyToggleFavoriteResult(
                masterOptionsController.toggleStyleFavorite(styleId))
        }
        onSaveHandBindingRequested: function(styleId, assetId) {
            masterOptionsController.setDrawStyleHandBinding(styleId, assetId)
        }
        onSaveDrawProfileRequested: function(styleId, actorMode, assetId) {
            masterOptionsController.setDrawStyleMotionProfile(
                styleId, actorMode, assetId)
        }
        onMotionPreviewRequested: function(styleId, actorMode, handAsset, force) {
            masterOptionsController.requestDrawMotionPreview(
                styleId, actorMode, handAsset, force)
        }
        onPreviewInfoRequested: function(styleId) {
            styleManagerDialog.applyPreviewInfoResult(
                masterOptionsController.stylePreview(styleId))
        }
        onGeneratePreviewRequested: function(style) {
            var accepted = masterOptionsController.requestStylePreviewGeneration(
                style || ({}))
            if (accepted && accepted.ok === false)
                styleManagerDialog.applyGeneratePreviewResult(accepted)
        }
        onComboPreviewRequested: function(selection) {
            var accepted =
                masterOptionsController.requestStyleComboPreviewGeneration(
                    selection || ({}))
            if (accepted && accepted.ok === false)
                styleManagerDialog.applyGeneratePreviewResult(accepted)
        }
        onBulkPreviewRequested: function(items, onlyMissing) {
            var currentStyleId = ""
            if (styleManagerDialog.currentItem
                    && styleManagerDialog.itemId(
                        styleManagerDialog.currentItem).length > 0) {
                currentStyleId = styleManagerDialog.itemId(
                    styleManagerDialog.currentItem)
            }
            var accepted = masterOptionsController.requestStylePreviewBulk(
                items || [], onlyMissing, currentStyleId)
            if (accepted && accepted.ok === false)
                styleManagerDialog.applyBulkPreviewResult(accepted, ({}))
        }
        onTopicGenerateRequested: function(payload) {
            masterOptionsController.requestStyleTopicProposal(payload || ({}))
        }

        Connections {
            target: masterOptionsController

            function onDrawMotionPreviewGenerated(result) {
                styleManagerDialog.applyMotionPreviewResult(result || ({}))
            }
            function onStylePreviewGenerated(result) {
                var payload = result || ({})
                if (String(payload.action || "")
                        === "master.config.generate_style_preview_bulk") {
                    styleManagerDialog.applyBulkPreviewResult(
                        payload, payload.refreshed_preview || ({}))
                } else {
                    styleManagerDialog.applyGeneratePreviewResult(payload)
                }
                if (styleTopicProposalDialog.visible)
                    styleTopicProposalDialog.applyPreviewResult(payload)
            }

            function onStyleTopicProposed(result) {
                styleTopicProposalDialog.openWith(result || ({}))
            }
        }
    }

    StyleTopicProposalDialog {
        id: styleTopicProposalDialog

        onCommitRequested: function(payload) {
            masterOptionsController.commitStyleTopic(payload || ({}))
        }
        onPreviewRequested: function(proposal) {
            var item = proposal || ({})
            masterOptionsController.requestStylePreviewGeneration({
                id: String(item.style_id || ""),
                style_id: String(item.style_id || ""),
                name: String(item.name || ""),
                kind: "style",
                veo3_prompt: String(item.preview_prompt || ""),
                preview_prompt: String(item.preview_prompt || "")
            })
        }
    }

    StyleEditDialog {
        id: styleEditDialog
        aiBusy: masterOptionsController.styleAiBusy
        aiPhaseKey: String(masterOptionsController.styleAiPhase || "")

        onSavePayloadRequested: function(payload) {
            var data = payload || ({})
            var result = masterOptionsController.saveStyle(
                String(data.styleId || ""),
                String(data.name || ""),
                String(data.prompt || ""),
                String(data.kind || "style"),
                String(data.description || ""),
                String(data.framework_json || "")
            )
            var savedStyle = (result && (result.style || result.item)) || ({})
            var savedStyleId = String(
                savedStyle.id || savedStyle.style_id || "")
            var savedKind = String(
                savedStyle.kind || data.kind || "style")
            var savedAsDraw = String(savedStyle.authoring_mode || data.kind || "").toLowerCase() === "draw"
                || String(savedStyle.topic_id || "").toLowerCase() === "draw_motion_2d"
            if (result && result.ok !== false && savedStyleId.length > 0) {
                styleManagerDialog.selectedId = savedStyleId
                if (savedKind === "camera") {
                    styleManagerDialog.activeBucketIndex = styleManagerDialog.bucketIndexForKey("style")
                    styleManagerDialog.selectedCameraId = savedStyleId
                } else {
                    styleManagerDialog.activeBucketIndex = styleManagerDialog.bucketIndexForKey(savedAsDraw ? "draw" : "style")
                    if (styleManagerDialog.selectedStyleId.length > 0
                            && styleManagerDialog.selectedStyleId
                               !== savedStyleId) {
                        styleManagerDialog.selectedSurfaceStyleId = savedStyleId
                    } else {
                        styleManagerDialog.selectedStyleId = savedStyleId
                    }
                }
                styleManagerDialog.selectFromCurrentId()
            }
            styleEditDialog.applySaveResult(result, data)
        }
        onAiGeneratePreviewRequested: function(payload) {
            masterOptionsController.requestStyleAiGeneration(
                payload || ({}), true)
        }
        onChooseReferenceRequested: {
            var picked = nativeShell.pickFiles(
                "Choose reference image",
                "Images (*.png *.jpg *.jpeg *.webp);;All Files (*.*)",
                styleEditDialog.referenceImagePath || ""
            )
            if (picked && picked.ok && picked.paths
                    && picked.paths.length > 0) {
                styleEditDialog.referenceImagePath = String(
                    picked.paths[0] || "")
                styleEditDialog.statusText = "Reference image selected."
            }
        }
        onPasteReferenceRequested: {
            var pasted = nativeShell.pasteImageFromClipboard(
                "veoflow-style-reference-", ".png")
            if (pasted && pasted.ok
                    && String(pasted.path || "").length > 0) {
                styleEditDialog.referenceImagePath = String(pasted.path || "")
                styleEditDialog.statusText = "Reference image pasted."
            } else {
                styleEditDialog.statusText = String(
                    (pasted || {}).message
                    || "Clipboard does not contain a usable image.")
            }
        }
    }

    Connections {
        target: masterOptionsController

        function onStyleAiGenerated(result) {
            if (styleEditDialog.visible)
                styleEditDialog.applyAiPayload(result || ({}))
        }

        function onStyleTopicGenerated(result) {
            if (styleManagerDialog.visible)
                styleManagerDialog.applyTopicGenerateResult(result || ({}))
        }
    }
}
