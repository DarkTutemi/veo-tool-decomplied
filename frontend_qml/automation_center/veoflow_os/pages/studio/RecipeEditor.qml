pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "studioRecipeEditor"
    property var recipeData: ({})
    property var draftDefinition: ({})
    property string activeTab: "recipe"
    property string aspectRatio: "9:16"
    property bool draftDirty: false
    property bool canEdit: false
    property var assetModel: null
    property var channelOptions: []
    property string selectedChannelId: ""
    property string assignmentOverridePolicy: "allow_manual"
    readonly property var editorData: root.recipeData.editor || ({})
    readonly property var outputData: root.editorData.output || ({})
    readonly property var draftOutput: root.draftDefinition.output || root.outputData
    readonly property var affiliateData: root.draftDefinition.affiliate
        || root.editorData.affiliate || ({})
    readonly property var affiliateEditor: root.editorData.affiliate || ({})
    readonly property var deliveryData: root.draftDefinition.delivery
        || root.editorData.delivery || ({})
    readonly property var timingEditor: root.editorData.timing || ({})
    readonly property var cropEditor: root.editorData.crop || ({})
    readonly property var brandingEditor: root.editorData.branding || ({})
    readonly property var subtitleEditor: root.editorData.subtitles || ({})
    readonly property var audioEditor: root.editorData.audio || ({})
    readonly property int timelineDurationMs: Number(
        (root.draftDefinition.timeline || {}).duration_ms || 0
    )
    readonly property bool definitionEditable: Number(root.draftDefinition.schema_version || 0) >= 2
    readonly property bool v3Editable: Number(root.draftDefinition.schema_version || 0) === 3
        && Boolean((root.editorData.delivery || {}).available)
    signal tabRequested(string key)
    signal definitionChanged(var definition)
    signal channelRequested(string channelId)
    signal assignmentRequested()
    signal assignmentOverrideRequested(string policy)
    color: Theme.panel
    radius: Theme.radiusMedium
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.role: Accessible.Pane
    Accessible.name: "Trình chỉnh sửa recipe"

    function cloneValue(value) {
        return JSON.parse(JSON.stringify(value || ({})))
    }

    function firstVideoLayer() {
        const layers = root.draftDefinition.layers || []
        for (let index = 0; index < layers.length; index++) {
            if (String((layers[index] || {}).type || "") === "video") return layers[index]
        }
        return ({})
    }

    function fitValue() {
        return String((root.firstVideoLayer().transform || {}).fit || "cover")
    }

    function setFit(value: string): bool {
        const next = root.cloneValue(root.draftDefinition)
        const layers = next.layers || []
        for (let index = 0; index < layers.length; index++) {
            if (String((layers[index] || {}).type || "") !== "video") continue
            if (!layers[index].transform) layers[index].transform = ({})
            layers[index].transform.fit = String(value)
            root.definitionChanged(next)
            return true
        }
        return false
    }

    function layerIndex(layerId) {
        const identity = String(layerId || "")
        const layers = root.draftDefinition.layers || []
        for (let index = 0; index < layers.length; index++) {
            if (String((layers[index] || {}).id || "") === identity) return index
        }
        return -1
    }

    function timingLayerIndex() {
        return root.layerIndex(String((root.timingEditor.current || {}).layer_id || ""))
    }

    function setTimingInt(field: string, value: int): bool {
        if (!root.definitionEditable || !Boolean(root.timingEditor.supported)) return false
        if (["start_ms", "source_in_ms", "duration_ms"].indexOf(field) < 0) return false
        const index = root.timingLayerIndex()
        if (index < 0 || value < 0 || (field === "duration_ms" && value < 1)) return false
        const layer = (root.draftDefinition.layers || [])[index] || ({})
        const timeline = Number((root.draftDefinition.timeline || {}).duration_ms || 0)
        const start = field === "start_ms" ? value : Number(layer.start_ms || 0)
        const duration = field === "duration_ms" ? value : Number(layer.duration_ms || 0)
        if (timeline < 1 || start + duration > timeline) return false
        if (field === "source_in_ms" && value > 86400000) return false
        const next = root.cloneValue(root.draftDefinition)
        next.layers[index][field] = value
        root.definitionChanged(next)
        return true
    }

    function setTransformField(field: string, value: real): bool {
        if (!root.definitionEditable || !Boolean(root.timingEditor.supported)) return false
        const ranges = root.timingEditor.ranges || ({})
        const rangeKey = field === "x" || field === "y" ? "position"
            : field === "width" || field === "height" ? "size" : field
        if (["x", "y", "width", "height", "rotation_degrees", "opacity"].indexOf(field) < 0)
            return false
        const range = ranges[rangeKey] || ({})
        const minimum = Number(range.min)
        const maximum = Number(range.max)
        if (!isFinite(value) || !isFinite(minimum) || !isFinite(maximum)
                || value < minimum || value > maximum) return false
        const index = root.timingLayerIndex()
        if (index < 0) return false
        const next = root.cloneValue(root.draftDefinition)
        if (!next.layers[index].transform) next.layers[index].transform = ({})
        next.layers[index].transform[field] = value
        root.definitionChanged(next)
        return true
    }

    function setTransformFade(field: string, value: int): bool {
        if (["fade_in_ms", "fade_out_ms"].indexOf(field) < 0 || value < 0) return false
        const index = root.timingLayerIndex()
        if (index < 0) return false
        const layer = (root.draftDefinition.layers || [])[index] || ({})
        const transform = layer.transform || ({})
        const other = field === "fade_in_ms"
            ? Number(transform.fade_out_ms || 0) : Number(transform.fade_in_ms || 0)
        if (value + other > Number(layer.duration_ms || 0)) return false
        const next = root.cloneValue(root.draftDefinition)
        if (!next.layers[index].transform) next.layers[index].transform = ({})
        next.layers[index].transform[field] = value
        root.definitionChanged(next)
        return true
    }

    function setLayerAudioField(field: string, value: real): bool {
        if (field !== "volume_db" || !root.definitionEditable
                || !Boolean(root.timingEditor.supported)) return false
        const range = (root.timingEditor.ranges || {}).volume_db || ({})
        if (!isFinite(value) || value < Number(range.min) || value > Number(range.max))
            return false
        const index = root.timingLayerIndex()
        if (index < 0) return false
        const next = root.cloneValue(root.draftDefinition)
        if (!next.layers[index].audio) next.layers[index].audio = ({"enabled": true})
        next.layers[index].audio[field] = value
        root.definitionChanged(next)
        return true
    }

    function setLayerAudioFade(field: string, value: int): bool {
        if (["fade_in_ms", "fade_out_ms"].indexOf(field) < 0 || value < 0) return false
        const index = root.timingLayerIndex()
        if (index < 0) return false
        const layer = (root.draftDefinition.layers || [])[index] || ({})
        const audio = layer.audio || ({})
        const other = field === "fade_in_ms"
            ? Number(audio.fade_out_ms || 0) : Number(audio.fade_in_ms || 0)
        if (value + other > Number(layer.duration_ms || 0)) return false
        const next = root.cloneValue(root.draftDefinition)
        if (!next.layers[index].audio) next.layers[index].audio = ({"enabled": true})
        next.layers[index].audio[field] = value
        root.definitionChanged(next)
        return true
    }

    function optionIndex(options, value, key) {
        const identity = String(value === undefined ? "" : value)
        const role = String(key || "value")
        for (let index = 0; index < (options || []).length; index++) {
            if (String(((options[index] || ({}))[role]) || "") === identity) return index
        }
        return -1
    }

    function setCropEdge(edge: string, value: real): bool {
        if (!root.definitionEditable || !Boolean(root.cropEditor.manual_crop_supported))
            return false
        if (["left", "right", "top", "bottom"].indexOf(edge) < 0) return false
        const current = root.cropEditor.current || ({})
        const index = root.layerIndex(current.layer_id)
        if (index < 0) return false
        const next = root.cloneValue(root.draftDefinition)
        if (!next.layers[index].transform) next.layers[index].transform = ({})
        if (!next.layers[index].transform.crop) next.layers[index].transform.crop = ({})
        next.layers[index].transform.crop[edge] = Math.max(0, Math.min(0.45, Number(value)))
        root.definitionChanged(next)
        return true
    }

    function setBinding(slot, assetId) {
        const slotValue = String(slot || "")
        const assetValue = String(assetId || "")
        if (!root.definitionEditable || !slotValue || !assetValue) return false
        const next = root.cloneValue(root.draftDefinition)
        if (!next.default_bindings) next.default_bindings = ({})
        next.default_bindings[slotValue] = assetValue
        root.definitionChanged(next)
        return true
    }

    function setBrandingAsset(assetId: string): bool {
        return root.setBinding(String((root.brandingEditor.current || {}).slot || ""), assetId)
    }

    function setSubtitleAsset(assetId: string): bool {
        return root.setBinding(String((root.subtitleEditor.current || {}).slot || ""), assetId)
    }

    function setBrandingAnchor(value: string): bool {
        if (!root.definitionEditable || !Boolean(root.brandingEditor.available)
                || !Boolean(root.brandingEditor.supported)) return false
        const anchors = ["top_left", "top_center", "top_right", "middle_left",
            "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"]
        const anchor = String(value || "")
        if (anchors.indexOf(anchor) < 0) return false
        const current = root.brandingEditor.current || ({})
        const index = root.layerIndex(current.layer_id)
        if (index < 0) return false
        const next = root.cloneValue(root.draftDefinition)
        const transform = next.layers[index].transform || ({})
        const width = Math.max(0.02, Number(transform.width || current.width || 0.15))
        const height = Math.max(0.02, Number(transform.height || current.height || 0.15))
        const margin = 0.025
        if (anchor.endsWith("_left")) transform.x = margin
        else if (anchor.endsWith("_right")) transform.x = 1 - width - margin
        else transform.x = (1 - width) / 2
        if (anchor.startsWith("top_")) transform.y = margin
        else if (anchor.startsWith("bottom_")) transform.y = 1 - height - margin
        else transform.y = (1 - height) / 2
        next.layers[index].transform = transform
        root.definitionChanged(next)
        return true
    }

    function setBrandingOpacity(value: real): bool {
        if (!root.definitionEditable || !Boolean(root.brandingEditor.available)
                || !Boolean(root.brandingEditor.supported)) return false
        const current = root.brandingEditor.current || ({})
        const index = root.layerIndex(current.layer_id)
        if (index < 0) return false
        const range = root.brandingEditor.opacity_range || ({})
        const minimum = Number(range.min === undefined ? 0.05 : range.min)
        const maximum = Number(range.max === undefined ? 1 : range.max)
        const next = root.cloneValue(root.draftDefinition)
        if (!next.layers[index].transform) next.layers[index].transform = ({})
        next.layers[index].transform.opacity = Math.max(minimum, Math.min(maximum, Number(value)))
        root.definitionChanged(next)
        return true
    }

    function setSubtitleStyle(field: string, value): bool {
        if (!root.definitionEditable || !Boolean(root.subtitleEditor.available)
                || !Boolean(root.subtitleEditor.supported)) return false
        const allowed = ["font_name", "font_size", "primary_color", "outline_color",
            "outline_width", "shadow_depth", "alignment", "margin_vertical"]
        if (allowed.indexOf(field) < 0) return false
        if ((field === "primary_color" || field === "outline_color")
                && !/^#[0-9A-Fa-f]{6}$/.test(String(value || ""))) return false
        if (field === "alignment"
                && ["bottom_center", "middle_center", "top_center"].indexOf(String(value)) < 0)
            return false
        if (field === "font_size") value = Math.max(12, Math.min(160, Number(value)))
        if (field === "outline_width" || field === "shadow_depth")
            value = Math.max(0, Math.min(12, Number(value)))
        if (field === "margin_vertical") value = Math.max(0, Math.min(800, Number(value)))
        const current = root.subtitleEditor.current || ({})
        const index = root.layerIndex(current.layer_id)
        if (index < 0) return false
        const next = root.cloneValue(root.draftDefinition)
        if (!next.layers[index].style) next.layers[index].style = ({})
        next.layers[index].style[field] = value
        root.definitionChanged(next)
        return true
    }

    function setSubtitleFontName(value: string): bool {
        return root.setSubtitleStyle("font_name", value)
    }

    function setSubtitleFontSize(value: int): bool {
        return root.setSubtitleStyle("font_size", value)
    }

    function setSubtitleAlignment(value: string): bool {
        return root.setSubtitleStyle("alignment", value)
    }

    function setSubtitleOutlineWidth(value: int): bool {
        return root.setSubtitleStyle("outline_width", value)
    }

    function setSubtitleMarginVertical(value: int): bool {
        return root.setSubtitleStyle("margin_vertical", value)
    }

    function setTargetLufs(value: real): bool {
        if (!root.definitionEditable || !Boolean(root.audioEditor.available)
                || !Boolean(root.audioEditor.supported)) return false
        const range = root.audioEditor.lufs_range || ({})
        const minimum = Number(range.min === undefined ? -24 : range.min)
        const maximum = Number(range.max === undefined ? -5 : range.max)
        const next = root.cloneValue(root.draftDefinition)
        if (!next.output) next.output = ({})
        next.output.loudness_lufs = Math.max(minimum, Math.min(maximum, Number(value)))
        root.definitionChanged(next)
        return true
    }

    function setOutputField(field: string, value): bool {
        if (!root.definitionEditable || !Boolean(root.outputData.available)
                || !Boolean(root.outputData.supported)) return false
        const allowed = ["profile", "fps", "video_codec", "audio_codec", "audio_bitrate", "crf"]
        if (allowed.indexOf(field) < 0) return false
        const next = root.cloneValue(root.draftDefinition)
        if (!next.output) next.output = ({})
        next.output[field] = value
        if (field === "profile") {
            if (value === "short_vertical_1080") {
                next.output.width = 1080; next.output.height = 1920; next.output.fps = 30
            } else if (value === "youtube_1080p") {
                next.output.width = 1920; next.output.height = 1080; next.output.fps = 30
            } else if (value === "square_1080") {
                next.output.width = 1080; next.output.height = 1080; next.output.fps = 30
            }
        }
        root.definitionChanged(next)
        return true
    }

    function setOutputProfile(value: string): bool {
        return root.setOutputField("profile", value)
    }

    function setOutputFps(value: int): bool {
        return root.setOutputField("fps", value)
    }

    function setOutputCrf(value: int): bool {
        return root.setOutputField("crf", value)
    }

    function setOutputAudioBitrate(value: string): bool {
        return root.setOutputField("audio_bitrate", value)
    }

    function assetIndex(assetId) {
        const identity = String(assetId || "")
        if (!root.assetModel) return -1
        for (let index = 0; index < root.assetModel.count; index++) {
            if (String((root.assetModel.get(index) || {}).asset_id || "") === identity)
                return index
        }
        return -1
    }

    function assetThumbnail(assetId) {
        const index = root.assetIndex(assetId)
        if (index < 0 || !root.assetModel) return ""
        return String((root.assetModel.get(index) || {}).thumbnail_uri || "")
    }

    function channelIndex(channelId) {
        const identity = String(channelId || "")
        for (let index = 0; index < root.channelOptions.length; index++) {
            if (String((root.channelOptions[index] || {}).id || "") === identity)
                return index
        }
        return -1
    }

    function bindingFor(slot) {
        return String(((root.draftDefinition.default_bindings || ({}))[String(slot || "")]) || "")
    }

    function layerLabel(layer) {
        const safe = layer || ({})
        const slot = String(safe.slot || safe.id || "layer")
        if (slot === "primary") return "Video chính"
        if (slot === "affiliate") return "Video ghép"
        if (slot === "branding_logo") return "Logo / watermark"
        if (slot === "subtitles") return "Phụ đề"
        return slot
    }

    function layerIcon(layer) {
        const kind = String((layer || {}).type || "")
        if (kind === "subtitle") return "ui/list"
        if (kind === "image") return "ui/camera"
        return "semantic/video"
    }

    function layerTone(layer) {
        const kind = String((layer || {}).type || "")
        if (kind === "subtitle") return Theme.warning
        if (kind === "image") return Theme.success
        return Theme.accent
    }

    function formatTimelineMs(value) {
        const seconds = Math.max(0, Math.round(Number(value || 0) / 1000))
        return Math.floor(seconds / 60) + ":" + String(seconds % 60).padStart(2, "0")
    }

    function setAffiliateBinding(slot, assetId) {
        if (!root.v3Editable || !slot || !assetId) return false
        const next = root.cloneValue(root.draftDefinition)
        if (!next.default_bindings) next.default_bindings = ({})
        next.default_bindings[String(slot)] = String(assetId)
        root.definitionChanged(next)
        return true
    }

    function videoLayerIndex(definition, slot) {
        const layers = definition.layers || []
        for (let index = 0; index < layers.length; index++) {
            const layer = layers[index] || ({})
            if (String(layer.type || "") === "video" && String(layer.slot || "") === slot)
                return index
        }
        return -1
    }

    function applyAffiliateGeometry(definition) {
        const config = definition.affiliate || ({})
        const aIndex = root.videoLayerIndex(definition, String(config.source_a_slot || ""))
        const bIndex = root.videoLayerIndex(definition, String(config.source_b_slot || ""))
        if (aIndex < 0 || bIndex < 0) return false
        const timeline = Number((definition.timeline || {}).duration_ms || 0)
        const ratio = Math.max(0.2, Math.min(0.8, Number(config.split_ratio || 0.5)))
        const layout = String(config.layout || "top_bottom")
        const a = definition.layers[aIndex]
        const b = definition.layers[bIndex]
        if (!a.transform) a.transform = ({})
        if (!b.transform) b.transform = ({})
        a.transform.x = 0; a.transform.y = 0; a.transform.width = 1; a.transform.height = 1
        b.transform.x = 0; b.transform.y = 0; b.transform.width = 1; b.transform.height = 1
        a.start_ms = 0; a.duration_ms = timeline
        b.start_ms = 0; b.duration_ms = timeline
        a.transform.fade_in_ms = 0; a.transform.fade_out_ms = 0
        b.transform.fade_in_ms = 0; b.transform.fade_out_ms = 0
        if (layout === "top_bottom") {
            a.transform.height = ratio
            b.transform.y = ratio; b.transform.height = 1 - ratio
        } else if (layout === "bottom_top") {
            a.transform.y = 1 - ratio; a.transform.height = ratio
            b.transform.height = 1 - ratio
        } else if (layout === "side_by_side") {
            a.transform.width = ratio
            b.transform.x = ratio; b.transform.width = 1 - ratio
        } else if (layout === "overlay") {
            b.transform.x = 1 - ratio; b.transform.y = 1 - ratio
            b.transform.width = ratio; b.transform.height = ratio
        } else if (layout === "sequential") {
            const splitMs = Math.round(timeline * ratio)
            a.duration_ms = splitMs
            b.start_ms = splitMs; b.duration_ms = timeline - splitMs
            const transition = config.transition || ({})
            if (String(transition.type || "cut") === "fade") {
                const duration = Number(transition.duration_ms || 500)
                a.transform.fade_out_ms = duration
                b.transform.fade_in_ms = duration
            }
        }
        return true
    }

    function setAffiliateLayout(value: string): bool {
        if (!root.v3Editable) return false
        const layout = String(value || "")
        const allowed = ["top_bottom", "bottom_top", "side_by_side", "overlay", "sequential"]
        if (allowed.indexOf(layout) < 0) return false
        const next = root.cloneValue(root.draftDefinition)
        next.affiliate.layout = layout
        if (layout !== "sequential" && String(next.affiliate.transition.type) === "fade")
            next.affiliate.transition = {"type": "cut", "duration_ms": 0}
        if (!root.applyAffiliateGeometry(next)) return false
        root.definitionChanged(next)
        return true
    }

    function setAffiliateSplitRatio(value: real): bool {
        if (!root.v3Editable) return false
        const ratio = Math.max(0.2, Math.min(0.8, Number(value)))
        const next = root.cloneValue(root.draftDefinition)
        next.affiliate.split_ratio = Math.round(ratio * 100) / 100
        if (!root.applyAffiliateGeometry(next)) return false
        root.definitionChanged(next)
        return true
    }

    function setAffiliateTransition(value: string): bool {
        const supported = ((root.affiliateEditor.supported || {}).transitions) || []
        if (!root.v3Editable || supported.indexOf(String(value)) < 0) return false
        const next = root.cloneValue(root.draftDefinition)
        if (value === "fade" && next.affiliate.layout !== "sequential")
            next.affiliate.layout = "sequential"
        next.affiliate.transition.type = String(value)
        next.affiliate.transition.duration_ms = value === "fade"
            ? Math.max(100, Number(next.affiliate.transition.duration_ms || 500)) : 0
        if (!root.applyAffiliateGeometry(next)) return false
        root.definitionChanged(next)
        return true
    }

    function supportedTransitionOptions() {
        const projected = root.affiliateEditor.transition_options || []
        if (projected.length > 0)
            return projected.filter(function(option) { return Boolean((option || {}).supported) })
        const supported = ((root.affiliateEditor.supported || {}).transitions) || []
        return supported.map(function(value) {
            return {"value": value, "label": value === "fade" ? "Fade" : "Cut"}
        })
    }

    function transitionUnavailableReason() {
        const options = root.affiliateEditor.transition_options || []
        for (let index = 0; index < options.length; index++) {
            const option = options[index] || ({})
            if (Boolean(option.supported) || !option.reason_code) continue
            if (String(option.reason_code) === "STUDIO_FADE_REQUIRES_SEQUENTIAL_LAYOUT")
                return "Fade chỉ khả dụng với bố cục nối tiếp"
            return String(option.label || option.value) + " hiện chưa khả dụng"
        }
        return ""
    }

    function transitionUnavailableReasonCode() {
        const options = root.affiliateEditor.transition_options || []
        for (let index = 0; index < options.length; index++) {
            const option = options[index] || ({})
            if (!Boolean(option.supported) && option.reason_code)
                return String(option.reason_code)
        }
        return ""
    }

    function setAffiliateTransitionDuration(value: int): bool {
        if (!root.v3Editable || String((root.affiliateData.transition || {}).type) !== "fade")
            return false
        const next = root.cloneValue(root.draftDefinition)
        next.affiliate.transition.duration_ms = Math.max(100, Math.min(3000, Number(value)))
        if (!root.applyAffiliateGeometry(next)) return false
        root.definitionChanged(next)
        return true
    }

    function setAffiliateCtaDuration(value: int): bool {
        if (!root.v3Editable || !Boolean((root.affiliateData.cta || {}).enabled)) return false
        const next = root.cloneValue(root.draftDefinition)
        const duration = Math.max(250, Math.min(30000, Number(value)))
        const slot = String(next.affiliate.cta.slot || "")
        next.affiliate.cta.duration_ms = duration
        const layers = next.layers || []
        const timeline = Number((next.timeline || {}).duration_ms || 0)
        for (let index = 0; index < layers.length; index++) {
            if (String((layers[index] || {}).type) !== "image"
                    || String((layers[index] || {}).slot) !== slot) continue
            layers[index].duration_ms = duration
            layers[index].start_ms = Math.max(0, timeline - duration)
            root.definitionChanged(next)
            return true
        }
        return false
    }

    function setOutputNamingTemplate(value: string): bool {
        if (!root.v3Editable) return false
        const next = root.cloneValue(root.draftDefinition)
        next.delivery.output_naming.template = String(value || "")
        root.definitionChanged(next)
        return true
    }

    function outputNameExample() {
        const projected = ((root.editorData.delivery || {}).output_naming) || ({})
        const values = projected.example_values || ({})
        let rendered = String((root.deliveryData.output_naming || {}).template || "")
        for (const key in values)
            rendered = rendered.split("{" + key + "}").join(String(values[key]))
        return rendered || String(projected.example || "—")
    }

    function setPublishVisibility(value: string): bool {
        if (!root.v3Editable || ["private", "unlisted", "public"].indexOf(String(value)) < 0)
            return false
        const next = root.cloneValue(root.draftDefinition)
        next.delivery.publish_policy.visibility = String(value)
        root.definitionChanged(next)
        return true
    }

    component FactRow: Rectangle {
        id: fact
        property string label: ""
        property string value: "—"
        property string reasonCode: ""
        property bool compact: false
        implicitHeight: compact ? 34 : 43
        color: Theme.elevated
        radius: 7
        border.width: 1
        border.color: Theme.borderSoft
        Accessible.role: Accessible.StaticText
        Accessible.name: label + ": " + value + (reasonCode ? ". " + reasonCode : "")
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: fact.compact ? 7 : 10
            anchors.rightMargin: fact.compact ? 7 : 10
            Text { Layout.preferredWidth: fact.compact ? 76 : 120; text: fact.label; color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
            Text { Layout.fillWidth: true; text: fact.value; color: fact.value === "—" ? Theme.textFaint : Theme.text; font.pixelSize: 11; elide: Text.ElideRight }
            Text { visible: !fact.compact && fact.reasonCode.length > 0; text: fact.reasonCode; color: Theme.warning; font.pixelSize: 11; elide: Text.ElideRight; Layout.maximumWidth: 150 }
        }
    }

    component SemanticSpinBox: SpinBox {
        id: spin
        implicitHeight: 32
        activeFocusOnTab: true
        editable: true
        contentItem: TextInput {
            z: 2
            text: spin.textFromValue(spin.value, spin.locale)
            color: spin.enabled ? Theme.text : Theme.textFaint
            selectionColor: Theme.accent
            selectedTextColor: "white"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            readOnly: !spin.editable
            validator: spin.validator
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            font.pixelSize: 11
        }
        up.indicator: Rectangle {
            x: spin.width - width
            height: spin.height
            width: 28
            color: spin.up.pressed ? Theme.accentSoft : "transparent"
            UiIcon { anchors.centerIn: parent; name: "ui/plus"; tone: Theme.textMuted; iconSize: 13 }
        }
        down.indicator: Rectangle {
            x: 0
            height: spin.height
            width: 28
            color: spin.down.pressed ? Theme.accentSoft : "transparent"
            UiIcon { anchors.centerIn: parent; name: "ui/minus"; tone: Theme.textMuted; iconSize: 13 }
        }
        background: Rectangle {
            radius: 7
            color: Theme.panel
            border.width: 1
            border.color: spin.activeFocus ? Theme.accent : Theme.borderSoft
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Cấu hình theo kênh"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
            Item { Layout.fillWidth: true }
            Text {
                text: root.draftDirty ? "Bản nháp chưa lưu" : "Đã đồng bộ"
                color: root.draftDirty ? Theme.warning : Theme.success
                font.pixelSize: 11
            }
        }

        RowLayout {
            id: tabs
            Layout.fillWidth: true
            spacing: 3
            Repeater {
                model: root.recipeData.tabs || []
                delegate: StudioButton {
                    id: tabButton
                    required property var modelData
                    readonly property string tabKey: String(tabButton.modelData.key || "")
                    objectName: "studioRecipeTab_" + tabKey
                    Layout.fillWidth: true
                    Layout.preferredHeight: 31
                    text: String(tabButton.modelData.label || tabKey)
                    checkable: true
                    checked: root.activeTab === tabKey
                    enabled: Boolean(tabButton.modelData.available)
                    activeFocusOnTab: true
                    Accessible.role: Accessible.PageTab
                    Accessible.name: text
                    Accessible.description: String(tabButton.modelData.reason || "")
                    onClicked: root.tabRequested(tabKey)
                    contentItem: Text {
                        text: tabButton.text
                        color: tabButton.checked ? Theme.text : Theme.textMuted
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 11
                        font.weight: tabButton.checked ? Font.DemiBold : Font.Normal
                    }
                    background: Rectangle {
                        radius: 6
                        color: tabButton.checked ? Theme.accentSoft : tabButton.hovered ? Theme.hover : "transparent"
                        border.width: tabButton.checked ? 1 : 0
                        border.color: Theme.accent
                    }
                }
            }
        }

        ScrollView {
            id: recipeScroll
            objectName: "studioRecipeScroll"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: Math.max(0, recipeScroll.availableWidth)
                spacing: 6

                Rectangle {
                    objectName: "studioRecipeChannel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    color: Theme.elevated
                    radius: 7
                    border.width: 1
                    border.color: Theme.borderSoft
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 7
                        Text {
                            Layout.preferredWidth: 120
                            text: "Kênh"
                            color: Theme.textFaint
                            font.pixelSize: 11
                        }
                        StudioComboBox {
                            objectName: "studioChannelSelector"
                            Layout.fillWidth: true
                            model: root.channelOptions
                            textRole: "label"
                            valueRole: "id"
                            currentIndex: root.channelIndex(root.selectedChannelId)
                            enabled: root.canEdit && !root.draftDirty
                                && root.channelOptions.length > 0
                            activeFocusOnTab: true
                            Accessible.name: "Chọn kênh và recipe Studio"
                            Accessible.description: root.draftDirty
                                ? "Lưu hoặc hủy thay đổi recipe trước khi đổi kênh" : ""
                            onActivated: root.channelRequested(String(currentValue || ""))
                        }
                    }
                }
                GridLayout {
                    objectName: "studioRecipeSummaryGrid"
                    Layout.fillWidth: true
                    Layout.minimumHeight: 148
                    Layout.preferredHeight: 148
                    visible: root.activeTab === "recipe"
                    columns: 2
                    columnSpacing: 5
                    rowSpacing: 4

                    FactRow {
                        objectName: "studioRecipeIdentity"
                        Layout.fillWidth: true
                        compact: true
                        label: "Recipe"
                        value: root.recipeData.state === "available"
                            ? String(root.recipeData.name || root.recipeData.pipeline_key || "—")
                                + " · v" + Number(root.recipeData.version || 0)
                            : "—"
                        reasonCode: root.recipeData.state === "available" ? "" : String(root.recipeData.reason_code || "STUDIO_RECIPE_NOT_SELECTED")
                    }
                    FactRow {
                        objectName: "studioRecipeOutputProfile"
                        Layout.fillWidth: true
                        compact: true
                        label: "Đầu ra"
                        value: root.outputData.profile
                            ? Number(root.outputData.width || 0) + "×" + Number(root.outputData.height || 0)
                                + " · " + String(root.outputData.video_codec || "—")
                            : "—"
                        reasonCode: root.outputData.profile ? "" : "STUDIO_OUTPUT_PROFILE_UNAVAILABLE"
                    }
                    FactRow {
                        objectName: "studioRecipeCropSummary"
                        Layout.fillWidth: true
                        compact: true
                        label: "Cắt khung"
                        value: Boolean(root.cropEditor.supported)
                            ? String(((root.cropEditor.current || {}).fit) || "—") + " · Thủ công"
                            : "—"
                        reasonCode: Boolean(root.cropEditor.supported) ? "" : String(root.cropEditor.reason_code || "STUDIO_CROP_UNAVAILABLE")
                    }
                    FactRow {
                        objectName: "studioRecipeBranding"
                        Layout.fillWidth: true
                        compact: true
                        label: "Logo"
                        value: Boolean((root.editorData.branding || {}).configured)
                            ? Number((root.editorData.branding || {}).layer_count || 0) + " layer"
                            : "—"
                        reasonCode: Boolean((root.editorData.branding || {}).configured) ? "" : "STUDIO_BRANDING_NOT_CONFIGURED"
                    }
                    FactRow {
                        objectName: "studioRecipeSubtitles"
                        Layout.fillWidth: true
                        compact: true
                        label: "Phụ đề"
                        value: Boolean((root.editorData.subtitles || {}).configured)
                            ? Number((root.editorData.subtitles || {}).layer_count || 0) + " layer"
                            : "—"
                        reasonCode: Boolean((root.editorData.subtitles || {}).configured) ? "" : "STUDIO_SUBTITLE_NOT_CONFIGURED"
                    }
                    FactRow {
                        objectName: "studioRecipeAudio"
                        Layout.fillWidth: true
                        compact: true
                        label: "Âm lượng"
                        value: (root.editorData.audio || {}).target_lufs !== undefined
                            && (root.editorData.audio || {}).target_lufs !== null
                            ? Number((root.editorData.audio || {}).target_lufs) + " LUFS"
                            : "—"
                        reasonCode: value === "—" ? "STUDIO_AUDIO_PROFILE_UNAVAILABLE" : ""
                    }
                    FactRow {
                        objectName: "studioRecipeOutputName"
                        Layout.fillWidth: true
                        compact: true
                        label: "Tên file"
                        value: root.v3Editable ? root.outputNameExample() : "—"
                        reasonCode: root.v3Editable ? "" : "STUDIO_DELIVERY_V3_REQUIRED"
                    }
                    FactRow {
                        objectName: "studioRecipePublishPolicy"
                        Layout.fillWidth: true
                        compact: true
                        label: "Đăng"
                        value: root.v3Editable
                            ? (Boolean((root.deliveryData.publish_policy || {}).approval_required)
                                ? "Cần duyệt · " : "")
                                + String((root.deliveryData.publish_policy || {}).visibility || "—")
                            : "—"
                        reasonCode: root.v3Editable ? "" : "STUDIO_DELIVERY_V3_REQUIRED"
                    }
                }
                Rectangle {
                    objectName: "studioAssignmentPanel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    visible: root.activeTab === "output"
                    color: Theme.elevated
                    radius: 7
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.role: Accessible.Grouping
                    Accessible.name: "Gán recipe mặc định cho kênh và tỷ lệ hiện tại"
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 7
                        StudioComboBox {
                            id: overrideSelector
                            objectName: "studioAssignmentOverridePolicy"
                            Layout.fillWidth: true
                            model: [
                                {"label": "Cho phép thủ công", "value": "allow_manual"},
                                {"label": "Khóa tự động", "value": "locked_auto"}
                            ]
                            textRole: "label"
                            valueRole: "value"
                            currentIndex: root.assignmentOverridePolicy === "locked_auto" ? 1 : 0
                            enabled: root.canEdit && root.v3Editable
                            Accessible.name: "Chính sách ghi đè recipe tự động"
                            onActivated: root.assignmentOverrideRequested(String(currentValue))
                        }
                        StudioButton {
                            objectName: "studioSetChannelDefaultButton"
                            text: "Đặt mặc định"
                            enabled: root.canEdit && root.v3Editable && !root.draftDirty
                                && Boolean((root.recipeData.channel || {}).id)
                            activeFocusOnTab: true
                            Accessible.role: Accessible.Button
                            Accessible.name: "Đặt version recipe hiện tại làm mặc định cho kênh"
                            Accessible.description: enabled ? "" : "Lưu bản nháp trước khi gán"
                            onClicked: root.assignmentRequested()
                        }
                    }
                }
                Rectangle {
                    objectName: "studioTimingEditorPanel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: Boolean(root.timingEditor.supported) ? 330 : 84
                    visible: root.activeTab === "timing"
                    color: Theme.elevated
                    radius: 7
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.role: Accessible.Grouping
                    Accessible.name: "Cắt thời gian, biến đổi khung và trộn âm thanh"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 8
                        visible: Boolean(root.timingEditor.supported)

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Theme.panel
                            radius: 8
                            border.width: 1
                            border.color: Theme.borderSoft
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 9
                                spacing: 6
                                Text { text: "Cắt & timeline"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                                Text { text: "Mốc lấy nguồn và vị trí trên timeline"; color: Theme.textFaint; font.pixelSize: 11; wrapMode: Text.Wrap }
                                Text { text: "In-point (ms)"; color: Theme.textFaint; font.pixelSize: 11 }
                                SemanticSpinBox {
                                    objectName: "studioTimingSourceIn"
                                    Layout.fillWidth: true
                                    from: 0; to: 86400000; stepSize: 100
                                    value: Number(root.firstVideoLayer().source_in_ms || 0)
                                    enabled: root.canEdit
                                    Accessible.name: "Mốc bắt đầu đọc nguồn theo mili giây"
                                    onValueModified: root.setTimingInt("source_in_ms", value)
                                }
                                Text { text: "Bắt đầu trên timeline (ms)"; color: Theme.textFaint; font.pixelSize: 11 }
                                SemanticSpinBox {
                                    objectName: "studioTimingStart"
                                    Layout.fillWidth: true
                                    from: 0
                                    to: Math.max(0, Number((root.draftDefinition.timeline || {}).duration_ms || 0)
                                        - Number(root.firstVideoLayer().duration_ms || 1))
                                    stepSize: 100
                                    value: Number(root.firstVideoLayer().start_ms || 0)
                                    enabled: root.canEdit
                                    Accessible.name: "Vị trí bắt đầu layer trên timeline theo mili giây"
                                    onValueModified: root.setTimingInt("start_ms", value)
                                }
                                Text { text: "Thời lượng (ms)"; color: Theme.textFaint; font.pixelSize: 11 }
                                SemanticSpinBox {
                                    objectName: "studioTimingDuration"
                                    Layout.fillWidth: true
                                    from: 1
                                    to: Math.max(1, Number((root.draftDefinition.timeline || {}).duration_ms || 1)
                                        - Number(root.firstVideoLayer().start_ms || 0))
                                    stepSize: 100
                                    value: Number(root.firstVideoLayer().duration_ms || 1)
                                    enabled: root.canEdit
                                    Accessible.name: "Thời lượng layer theo mili giây"
                                    onValueModified: root.setTimingInt("duration_ms", value)
                                }
                                Item { Layout.fillHeight: true }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Theme.panel
                            radius: 8
                            border.width: 1
                            border.color: Theme.borderSoft
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 9
                                spacing: 5
                                Text { text: "Khung hình"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                                Text { text: "Tọa độ và kích thước theo % canvas"; color: Theme.textFaint; font.pixelSize: 11 }
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    columnSpacing: 6
                                    rowSpacing: 5
                                    Text { text: "X %"; color: Theme.textFaint; font.pixelSize: 11 }
                                    Text { text: "Y %"; color: Theme.textFaint; font.pixelSize: 11 }
                                    SemanticSpinBox { objectName: "studioTransformX"; Layout.fillWidth: true; from: -200; to: 200; value: Math.round(Number((root.firstVideoLayer().transform || {}).x || 0) * 100); enabled: root.canEdit; Accessible.name: "Vị trí ngang phần trăm"; onValueModified: root.setTransformField("x", value / 100) }
                                    SemanticSpinBox { objectName: "studioTransformY"; Layout.fillWidth: true; from: -200; to: 200; value: Math.round(Number((root.firstVideoLayer().transform || {}).y || 0) * 100); enabled: root.canEdit; Accessible.name: "Vị trí dọc phần trăm"; onValueModified: root.setTransformField("y", value / 100) }
                                    Text { text: "Rộng %"; color: Theme.textFaint; font.pixelSize: 11 }
                                    Text { text: "Cao %"; color: Theme.textFaint; font.pixelSize: 11 }
                                    SemanticSpinBox { objectName: "studioTransformWidth"; Layout.fillWidth: true; from: 1; to: 400; value: Math.round(Number((root.firstVideoLayer().transform || {}).width || 1) * 100); enabled: root.canEdit; Accessible.name: "Chiều rộng phần trăm"; onValueModified: root.setTransformField("width", value / 100) }
                                    SemanticSpinBox { objectName: "studioTransformHeight"; Layout.fillWidth: true; from: 1; to: 400; value: Math.round(Number((root.firstVideoLayer().transform || {}).height || 1) * 100); enabled: root.canEdit; Accessible.name: "Chiều cao phần trăm"; onValueModified: root.setTransformField("height", value / 100) }
                                    Text { text: "Xoay °"; color: Theme.textFaint; font.pixelSize: 11 }
                                    Text { text: "Độ mờ %"; color: Theme.textFaint; font.pixelSize: 11 }
                                    SemanticSpinBox { objectName: "studioTransformRotation"; Layout.fillWidth: true; from: -360; to: 360; value: Math.round(Number((root.firstVideoLayer().transform || {}).rotation_degrees || 0)); enabled: root.canEdit; Accessible.name: "Góc xoay layer"; onValueModified: root.setTransformField("rotation_degrees", value) }
                                    SemanticSpinBox { objectName: "studioTransformOpacity"; Layout.fillWidth: true; from: 0; to: 100; value: Math.round(Number((root.firstVideoLayer().transform || {}).opacity ?? 1) * 100); enabled: root.canEdit; Accessible.name: "Độ mờ layer phần trăm"; onValueModified: root.setTransformField("opacity", value / 100) }
                                }
                                Item { Layout.fillHeight: true }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Theme.panel
                            radius: 8
                            border.width: 1
                            border.color: Theme.borderSoft
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 9
                                spacing: 5
                                Text { text: "Chuyển cảnh & âm thanh"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                                Text { text: "Fade hình và mix audio được compiler áp dụng"; color: Theme.textFaint; font.pixelSize: 11; wrapMode: Text.Wrap }
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    columnSpacing: 6
                                    rowSpacing: 5
                                    Text { text: "Hình vào (ms)"; color: Theme.textFaint; font.pixelSize: 11 }
                                    Text { text: "Hình ra (ms)"; color: Theme.textFaint; font.pixelSize: 11 }
                                    SemanticSpinBox { objectName: "studioVideoFadeIn"; Layout.fillWidth: true; from: 0; to: Number(root.firstVideoLayer().duration_ms || 0); stepSize: 100; value: Number((root.firstVideoLayer().transform || {}).fade_in_ms || 0); enabled: root.canEdit; Accessible.name: "Fade hình vào mili giây"; onValueModified: root.setTransformFade("fade_in_ms", value) }
                                    SemanticSpinBox { objectName: "studioVideoFadeOut"; Layout.fillWidth: true; from: 0; to: Number(root.firstVideoLayer().duration_ms || 0); stepSize: 100; value: Number((root.firstVideoLayer().transform || {}).fade_out_ms || 0); enabled: root.canEdit; Accessible.name: "Fade hình ra mili giây"; onValueModified: root.setTransformFade("fade_out_ms", value) }
                                    Text { text: "Âm lượng dB"; color: Theme.textFaint; font.pixelSize: 11; Layout.columnSpan: 2 }
                                    SemanticSpinBox { objectName: "studioAudioVolume"; Layout.fillWidth: true; Layout.columnSpan: 2; from: -60; to: 12; value: Math.round(Number((root.firstVideoLayer().audio || {}).volume_db || 0)); enabled: root.canEdit; Accessible.name: "Âm lượng layer decibel"; onValueModified: root.setLayerAudioField("volume_db", value) }
                                    Text { text: "Âm vào (ms)"; color: Theme.textFaint; font.pixelSize: 11 }
                                    Text { text: "Âm ra (ms)"; color: Theme.textFaint; font.pixelSize: 11 }
                                    SemanticSpinBox { objectName: "studioAudioFadeIn"; Layout.fillWidth: true; from: 0; to: Number(root.firstVideoLayer().duration_ms || 0); stepSize: 100; value: Number((root.firstVideoLayer().audio || {}).fade_in_ms || 0); enabled: root.canEdit; Accessible.name: "Fade âm thanh vào mili giây"; onValueModified: root.setLayerAudioFade("fade_in_ms", value) }
                                    SemanticSpinBox { objectName: "studioAudioFadeOut"; Layout.fillWidth: true; from: 0; to: Number(root.firstVideoLayer().duration_ms || 0); stepSize: 100; value: Number((root.firstVideoLayer().audio || {}).fade_out_ms || 0); enabled: root.canEdit; Accessible.name: "Fade âm thanh ra mili giây"; onValueModified: root.setLayerAudioFade("fade_out_ms", value) }
                                }
                                Item { Layout.fillHeight: true }
                            }
                        }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.margins: 12
                        visible: !Boolean(root.timingEditor.supported)
                        text: String(root.timingEditor.reason_code || "STUDIO_TIMING_EDITOR_UNAVAILABLE")
                        color: Theme.warning
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                }

                Rectangle {
                    objectName: "studioRecipeCropMode"
                    Layout.fillWidth: true
                    Layout.preferredHeight: Boolean(root.cropEditor.supported) ? 194 : 68
                    visible: root.activeTab === "crop"
                    color: Theme.elevated
                    radius: 7
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.role: Accessible.Grouping
                    Accessible.name: "Chế độ cắt khung"
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 6
                        RowLayout {
                            Layout.fillWidth: true
                            Text { Layout.fillWidth: true; text: "Cắt khung video chính"; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                            Text { text: Boolean(root.cropEditor.smart_crop_supported) ? "Smart Crop" : "Thủ công"; color: Boolean(root.cropEditor.smart_crop_supported) ? Theme.success : Theme.textFaint; font.pixelSize: 11 }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Text { Layout.preferredWidth: 94; text: "Chế độ fit"; color: Theme.textFaint; font.pixelSize: 11 }
                            StudioComboBox {
                                id: fitSelector
                                objectName: "studioRecipeFitMode"
                                Layout.fillWidth: true
                                model: root.cropEditor.fit_options || []
                                textRole: "label"
                                valueRole: "value"
                                currentIndex: root.optionIndex(model, root.fitValue(), "value")
                                enabled: root.canEdit && Boolean(root.cropEditor.supported)
                                activeFocusOnTab: true
                                Accessible.name: "Chế độ fit video chính"
                                Accessible.description: enabled ? "" : String(root.cropEditor.reason_code || "STUDIO_CROP_UNAVAILABLE")
                                onActivated: root.setFit(currentValue)
                            }
                        }
                        GridLayout {
                            visible: Boolean(root.cropEditor.manual_crop_supported)
                            Layout.fillWidth: true
                            columns: 4
                            columnSpacing: 5
                            rowSpacing: 5
                            Text { text: "Trái %"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: "Phải %"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: "Trên %"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: "Dưới %"; color: Theme.textFaint; font.pixelSize: 11 }
                            SemanticSpinBox { objectName: "studioCropLeft"; Layout.fillWidth: true; from: 0; to: 45; value: Math.round(Number((((root.cropEditor.current || {}).crop || {}).left) || 0) * 100); enabled: root.canEdit; Accessible.name: "Cắt mép trái phần trăm"; onValueModified: root.setCropEdge("left", value / 100) }
                            SemanticSpinBox { objectName: "studioCropRight"; Layout.fillWidth: true; from: 0; to: 45; value: Math.round(Number((((root.cropEditor.current || {}).crop || {}).right) || 0) * 100); enabled: root.canEdit; Accessible.name: "Cắt mép phải phần trăm"; onValueModified: root.setCropEdge("right", value / 100) }
                            SemanticSpinBox { objectName: "studioCropTop"; Layout.fillWidth: true; from: 0; to: 45; value: Math.round(Number((((root.cropEditor.current || {}).crop || {}).top) || 0) * 100); enabled: root.canEdit; Accessible.name: "Cắt mép trên phần trăm"; onValueModified: root.setCropEdge("top", value / 100) }
                            SemanticSpinBox { objectName: "studioCropBottom"; Layout.fillWidth: true; from: 0; to: 45; value: Math.round(Number((((root.cropEditor.current || {}).crop || {}).bottom) || 0) * 100); enabled: root.canEdit; Accessible.name: "Cắt mép dưới phần trăm"; onValueModified: root.setCropEdge("bottom", value / 100) }
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: !Boolean(root.cropEditor.smart_crop_supported)
                            text: "Smart Crop chưa được compiler hỗ trợ; các giá trị cắt thủ công được lưu vào recipe."
                            color: Theme.textFaint
                            font.pixelSize: 11
                            wrapMode: Text.Wrap
                        }
                    }
                }

                Rectangle {
                    objectName: "studioBrandingEditorPanel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: Boolean(root.brandingEditor.configured) ? 188 : 84
                    visible: root.activeTab === "branding"
                    color: Theme.elevated
                    radius: 7
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.role: Accessible.Grouping
                    Accessible.name: "Thiết lập logo và watermark"
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 6
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Logo / Watermark"; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                            Item { Layout.fillWidth: true }
                            Text { text: Boolean(root.brandingEditor.configured) ? "Compiler hỗ trợ" : "Chưa cấu hình"; color: Boolean(root.brandingEditor.configured) ? Theme.success : Theme.warning; font.pixelSize: 11 }
                        }
                        GridLayout {
                            visible: Boolean(root.brandingEditor.configured)
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 8
                            rowSpacing: 6
                            Text { text: "Asset"; color: Theme.textFaint; font.pixelSize: 11 }
                            StudioComboBox {
                                objectName: "studioBrandingAsset"
                                Layout.fillWidth: true
                                model: root.brandingEditor.asset_options || []
                                textRole: "label"
                                valueRole: "id"
                                currentIndex: root.optionIndex(model, String((root.brandingEditor.current || {}).asset_id || ""), "id")
                                enabled: root.canEdit && Boolean(root.brandingEditor.supported) && count > 0
                                activeFocusOnTab: true
                                Accessible.name: "Asset logo hoặc watermark"
                                onActivated: root.setBinding(String((root.brandingEditor.current || {}).slot || ""), String(currentValue || ""))
                            }
                            Text { text: "Vị trí"; color: Theme.textFaint; font.pixelSize: 11 }
                            StudioComboBox {
                                objectName: "studioBrandingAnchor"
                                Layout.fillWidth: true
                                model: root.brandingEditor.anchor_options || []
                                textRole: "label"
                                valueRole: "value"
                                currentIndex: root.optionIndex(model, String((root.brandingEditor.current || {}).anchor || ""), "value")
                                enabled: root.canEdit && Boolean(root.brandingEditor.supported)
                                activeFocusOnTab: true
                                Accessible.name: "Vị trí logo trên khung"
                                onActivated: root.setBrandingAnchor(String(currentValue || ""))
                            }
                            Text { text: "Độ mờ " + Math.round(brandingOpacity.value * 100) + "%"; color: Theme.textFaint; font.pixelSize: 11 }
                            Slider {
                                id: brandingOpacity
                                objectName: "studioBrandingOpacity"
                                Layout.fillWidth: true
                                from: Number((root.brandingEditor.opacity_range || {}).min || 0)
                                to: Number((root.brandingEditor.opacity_range || {}).max || 1)
                                stepSize: Number((root.brandingEditor.opacity_range || {}).step || 0.05)
                                value: Number((root.brandingEditor.current || {}).opacity || 0)
                                enabled: root.canEdit && Boolean(root.brandingEditor.supported)
                                activeFocusOnTab: true
                                Accessible.role: Accessible.Slider
                                Accessible.name: "Độ mờ logo " + Math.round(value * 100) + "%"
                                onMoved: root.setBrandingOpacity(value)
                                background: Rectangle { x: brandingOpacity.leftPadding; y: brandingOpacity.topPadding + brandingOpacity.availableHeight / 2 - 2; width: brandingOpacity.availableWidth; height: 4; radius: 2; color: Theme.panel; Rectangle { width: brandingOpacity.visualPosition * parent.width; height: parent.height; radius: 2; color: Theme.accent } }
                                handle: Rectangle { x: brandingOpacity.leftPadding + brandingOpacity.visualPosition * (brandingOpacity.availableWidth - width); y: brandingOpacity.topPadding + brandingOpacity.availableHeight / 2 - height / 2; implicitWidth: 12; implicitHeight: 12; radius: 6; color: brandingOpacity.enabled ? Theme.accent : Theme.textFaint; border.width: 2; border.color: Theme.panel }
                            }
                        }
                        Text { Layout.fillWidth: true; visible: !Boolean(root.brandingEditor.configured); text: String(root.brandingEditor.reason_code || "STUDIO_BRANDING_NOT_CONFIGURED"); color: Theme.warning; font.pixelSize: 11; wrapMode: Text.Wrap }
                    }
                }

                Rectangle {
                    objectName: "studioSubtitleEditorPanel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: Boolean(root.subtitleEditor.configured) ? 260 : 84
                    visible: root.activeTab === "subtitles"
                    color: Theme.elevated
                    radius: 7
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.role: Accessible.Grouping
                    Accessible.name: "Thiết lập phụ đề"
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 6
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Phụ đề"; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                            Item { Layout.fillWidth: true }
                            Text { text: Boolean(root.subtitleEditor.configured) ? "SRT quản lý" : "Thiếu layer"; color: Boolean(root.subtitleEditor.configured) ? Theme.success : Theme.warning; font.pixelSize: 11 }
                        }
                        GridLayout {
                            visible: Boolean(root.subtitleEditor.configured)
                            Layout.fillWidth: true
                            columns: 4
                            columnSpacing: 6
                            rowSpacing: 6
                            Text { text: "Tệp SRT"; color: Theme.textFaint; font.pixelSize: 11 }
                            StudioComboBox {
                                objectName: "studioSubtitleAsset"
                                Layout.columnSpan: 3
                                Layout.fillWidth: true
                                model: root.subtitleEditor.asset_options || []
                                textRole: "label"
                                valueRole: "id"
                                currentIndex: root.optionIndex(model, String((root.subtitleEditor.current || {}).asset_id || ""), "id")
                                enabled: root.canEdit && Boolean(root.subtitleEditor.supported) && count > 0
                                activeFocusOnTab: true
                                Accessible.name: "Tệp phụ đề SRT"
                                onActivated: root.setBinding(String((root.subtitleEditor.current || {}).slot || ""), String(currentValue || ""))
                            }
                            Text { text: "Font"; color: Theme.textFaint; font.pixelSize: 11 }
                            TextField {
                                id: subtitleFont
                                objectName: "studioSubtitleFont"
                                Layout.fillWidth: true
                                text: String((((root.subtitleEditor.current || {}).style || {}).font_name) || "")
                                enabled: root.canEdit && Boolean(root.subtitleEditor.supported)
                                color: Theme.text
                                activeFocusOnTab: true
                                Accessible.name: "Tên font phụ đề"
                                onEditingFinished: root.setSubtitleStyle("font_name", text)
                                background: Rectangle { radius: 7; color: Theme.panel; border.width: 1; border.color: subtitleFont.activeFocus ? Theme.accent : Theme.borderSoft }
                            }
                            Text { text: "Cỡ"; color: Theme.textFaint; font.pixelSize: 11 }
                            SemanticSpinBox {
                                objectName: "studioSubtitleFontSize"
                                Layout.fillWidth: true
                                from: Number((root.subtitleEditor.font_size_range || {}).min || 12)
                                to: Number((root.subtitleEditor.font_size_range || {}).max || 160)
                                stepSize: Number((root.subtitleEditor.font_size_range || {}).step || 1)
                                value: Number((((root.subtitleEditor.current || {}).style || {}).font_size) || 44)
                                enabled: root.canEdit && Boolean(root.subtitleEditor.supported)
                                Accessible.name: "Cỡ chữ phụ đề"
                                onValueModified: root.setSubtitleStyle("font_size", value)
                            }
                            Text { text: "Căn"; color: Theme.textFaint; font.pixelSize: 11 }
                            StudioComboBox {
                                objectName: "studioSubtitleAlignment"
                                Layout.fillWidth: true
                                model: root.subtitleEditor.alignment_options || []
                                textRole: "label"
                                valueRole: "value"
                                currentIndex: root.optionIndex(model, String((((root.subtitleEditor.current || {}).style || {}).alignment) || ""), "value")
                                enabled: root.canEdit && Boolean(root.subtitleEditor.supported)
                                activeFocusOnTab: true
                                Accessible.name: "Căn phụ đề"
                                onActivated: root.setSubtitleStyle("alignment", String(currentValue || ""))
                            }
                            Text { text: "Viền"; color: Theme.textFaint; font.pixelSize: 11 }
                            SemanticSpinBox {
                                objectName: "studioSubtitleOutlineWidth"
                                Layout.fillWidth: true
                                from: 0
                                to: 12
                                value: Math.round(Number((((root.subtitleEditor.current || {}).style || {}).outline_width) || 0))
                                enabled: root.canEdit && Boolean(root.subtitleEditor.supported)
                                Accessible.name: "Độ dày viền phụ đề"
                                onValueModified: root.setSubtitleStyle("outline_width", value)
                            }
                            Text { text: "Lề dọc"; color: Theme.textFaint; font.pixelSize: 11 }
                            SemanticSpinBox {
                                objectName: "studioSubtitleMarginVertical"
                                Layout.fillWidth: true
                                from: 0
                                to: 800
                                stepSize: 4
                                value: Number((((root.subtitleEditor.current || {}).style || {}).margin_vertical) || 72)
                                enabled: root.canEdit && Boolean(root.subtitleEditor.supported)
                                Accessible.name: "Lề dọc vùng an toàn phụ đề"
                                onValueModified: root.setSubtitleStyle("margin_vertical", value)
                            }
                        }
                        Text { Layout.fillWidth: true; visible: !Boolean(root.subtitleEditor.configured); text: String(root.subtitleEditor.reason_code || "STUDIO_SUBTITLE_NOT_CONFIGURED"); color: Theme.warning; font.pixelSize: 11; wrapMode: Text.Wrap }
                    }
                }

                Rectangle {
                    objectName: "studioAudioEditorPanel"
                    Layout.fillWidth: true
                    Layout.preferredHeight: Boolean(root.audioEditor.supported) ? 142 : 78
                    visible: root.activeTab === "audio"
                    color: Theme.elevated
                    radius: 7
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.role: Accessible.Grouping
                    Accessible.name: "Thiết lập âm thanh đầu ra"
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 6
                        Text { text: "Mục tiêu loudness"; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                        RowLayout {
                            visible: Boolean(root.audioEditor.supported)
                            Layout.fillWidth: true
                            Text { text: "LUFS"; color: Theme.textFaint; font.pixelSize: 11 }
                            Slider {
                                id: loudnessSlider
                                objectName: "studioAudioTargetLufs"
                                Layout.fillWidth: true
                                from: Number((root.audioEditor.lufs_range || {}).min || -24)
                                to: Number((root.audioEditor.lufs_range || {}).max || -5)
                                stepSize: Number((root.audioEditor.lufs_range || {}).step || 0.5)
                                value: Number(root.audioEditor.target_lufs || -14)
                                enabled: root.canEdit
                                activeFocusOnTab: true
                                Accessible.name: "Mục tiêu âm lượng " + value.toFixed(1) + " LUFS"
                                onMoved: root.setTargetLufs(value)
                            }
                            Text { text: loudnessSlider.value.toFixed(1); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                        }
                        RowLayout {
                            visible: Boolean(root.audioEditor.supported)
                            Layout.fillWidth: true
                            Text { text: String(root.audioEditor.codec || "—") + " · " + String(root.audioEditor.bitrate || "—"); color: Theme.textMuted; font.pixelSize: 11 }
                            Item { Layout.fillWidth: true }
                            Text { text: "True Peak " + Number(root.audioEditor.target_true_peak_db || 0).toFixed(1) + " dBTP"; color: Theme.textFaint; font.pixelSize: 11 }
                        }
                        Text { Layout.fillWidth: true; text: Boolean(root.audioEditor.true_peak_editable) ? "True Peak có thể chỉnh" : "True Peak do profile compiler khóa"; color: Boolean(root.audioEditor.true_peak_editable) ? Theme.success : Theme.textFaint; font.pixelSize: 11 }
                    }
                }
                Rectangle {
                    id: affiliatePanel
                    objectName: "studioAffiliatePanel"
                    Layout.fillWidth: true
                    Layout.minimumHeight: root.v3Editable ? 340 : 68
                    Layout.preferredHeight: root.v3Editable
                        ? Math.max(340, recipeScroll.availableHeight - 212) : 68
                    visible: root.activeTab === "recipe"
                    color: Theme.elevated
                    radius: 7
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.role: Accessible.Grouping
                    Accessible.name: "Ghép video affiliate"
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 5
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Ghép video affiliate"; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: root.v3Editable ? "Compiler v3" : "Chỉ đọc"
                                color: root.v3Editable ? Theme.success : Theme.warning
                                font.pixelSize: 11
                            }
                        }
                        Rectangle {
                            id: layerWorkspace
                            objectName: "studioRecipeLayerWorkspace"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 160
                            Layout.minimumHeight: 150
                            color: Theme.panel
                            radius: 8
                            border.width: 1
                            border.color: Theme.borderSoft
                            clip: true
                            Accessible.role: Accessible.Grouping
                            Accessible.name: "Timeline layer FFmpeg của recipe hiện tại"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 7
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "TIMELINE & LAYER"
                                        color: Theme.text
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        text: "FFmpeg · "
                                            + root.formatTimelineMs(root.timelineDurationMs)
                                            + " · " + Number((root.draftDefinition.layers || []).length)
                                            + " lớp"
                                        color: Theme.textFaint
                                        font.pixelSize: 11
                                    }
                                    Item { Layout.fillWidth: true }
                                    StudioButton {
                                        objectName: "studioRecipeEditTiming"
                                        text: "Cắt & thời gian"
                                        enabled: Boolean(root.timingEditor.supported)
                                        availabilityReason: enabled ? "" : String(
                                            root.timingEditor.reason_code
                                                || "STUDIO_TIMING_EDITOR_UNAVAILABLE"
                                        )
                                        onClicked: root.tabRequested("timing")
                                    }
                                    StudioButton {
                                        objectName: "studioRecipeEditBranding"
                                        text: "Logo"
                                        enabled: Boolean(root.brandingEditor.supported)
                                        availabilityReason: enabled ? "" : String(
                                            root.brandingEditor.reason_code
                                                || "STUDIO_BRANDING_EDITOR_UNAVAILABLE"
                                        )
                                        onClicked: root.tabRequested("branding")
                                    }
                                    StudioButton {
                                        objectName: "studioRecipeEditSubtitles"
                                        text: "Phụ đề"
                                        enabled: Boolean(root.subtitleEditor.supported)
                                        availabilityReason: enabled ? "" : String(
                                            root.subtitleEditor.reason_code
                                                || "STUDIO_SUBTITLE_EDITOR_UNAVAILABLE"
                                        )
                                        onClicked: root.tabRequested("subtitles")
                                    }
                                }

                                Item {
                                    id: timelineRuler
                                    objectName: "studioRecipeTimelineRuler"
                                    readonly property int durationMs: root.timelineDurationMs
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 16
                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "0:00"
                                        color: Theme.textFaint
                                        font.pixelSize: 11
                                    }
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.leftMargin: 92
                                        anchors.rightMargin: 38
                                        anchors.verticalCenter: parent.verticalCenter
                                        height: 1
                                        color: Theme.border
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: root.formatTimelineMs(root.timelineDurationMs)
                                        color: Theme.textFaint
                                        font.pixelSize: 11
                                    }
                                }

                                Repeater {
                                    model: root.draftDefinition.layers || []
                                    delegate: Item {
                                        id: layerRow
                                        required property var modelData
                                        required property int index
                                        objectName: "studioRecipeLayer_" + String(layerRow.modelData.id || layerRow.index)
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 21
                                        readonly property real totalMs: Math.max(1, root.timelineDurationMs)

                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: 5
                                            UiIcon {
                                                Layout.preferredWidth: 13
                                                name: root.layerIcon(layerRow.modelData)
                                                tone: root.layerTone(layerRow.modelData)
                                                iconSize: 11
                                            }
                                            Text {
                                                Layout.preferredWidth: 72
                                                text: root.layerLabel(layerRow.modelData)
                                                color: Theme.textMuted
                                                font.pixelSize: 11
                                                elide: Text.ElideRight
                                            }
                                            Item {
                                                id: layerTrack
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                Rectangle {
                                                    anchors.fill: parent
                                                    anchors.topMargin: 3
                                                    anchors.bottomMargin: 3
                                                    radius: 3
                                                    color: Theme.elevated
                                                }
                                                Rectangle {
                                                    id: layerClip
                                                    objectName: "studioRecipeLayerClip_"
                                                        + String(layerRow.modelData.id || layerRow.index)
                                                    readonly property real normalizedStart: Math.max(
                                                        0, Math.min(1, Number(layerRow.modelData.start_ms || 0)
                                                            / layerRow.totalMs)
                                                    )
                                                    readonly property real normalizedDuration: Math.max(
                                                        0, Math.min(1 - normalizedStart,
                                                            Number(layerRow.modelData.duration_ms || 0)
                                                                / layerRow.totalMs)
                                                    )
                                                    x: Math.round(parent.width * normalizedStart)
                                                    y: 2
                                                    width: Math.max(4, Math.round(parent.width * normalizedDuration))
                                                    height: parent.height - 4
                                                    radius: 4
                                                    color: Qt.rgba(
                                                        root.layerTone(layerRow.modelData).r,
                                                        root.layerTone(layerRow.modelData).g,
                                                        root.layerTone(layerRow.modelData).b,
                                                        0.32
                                                    )
                                                    border.width: 1
                                                    border.color: root.layerTone(layerRow.modelData)
                                                    Text {
                                                        anchors.fill: parent
                                                        anchors.leftMargin: 5
                                                        anchors.rightMargin: 5
                                                        text: root.formatTimelineMs(
                                                            layerRow.modelData.duration_ms
                                                        )
                                                        color: Theme.text
                                                        font.pixelSize: 11
                                                        verticalAlignment: Text.AlignVCenter
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        RowLayout {
                            visible: root.v3Editable
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10

                            ColumnLayout {
                                objectName: "studioAffiliateControls"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 3

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { Layout.preferredWidth: 66; text: "Nguồn A"; color: Theme.textFaint; font.pixelSize: 11 }
                                    StudioComboBox {
                                        objectName: "studioAffiliateSourceA"
                                        Layout.fillWidth: true
                                        model: root.assetModel
                                        textRole: "file_name"
                                        valueRole: "asset_id"
                                        currentIndex: root.assetIndex(root.bindingFor(String(root.affiliateData.source_a_slot || "")))
                                        enabled: root.canEdit && root.v3Editable
                                        Accessible.name: "Nguồn A video chính"
                                        onActivated: root.setAffiliateBinding(
                                            String(root.affiliateData.source_a_slot || ""),
                                            String(currentValue || "")
                                        )
                                    }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { Layout.preferredWidth: 66; text: "Nguồn B"; color: Theme.textFaint; font.pixelSize: 11 }
                                    StudioComboBox {
                                        objectName: "studioAffiliateSourceB"
                                        Layout.fillWidth: true
                                        model: root.assetModel
                                        textRole: "file_name"
                                        valueRole: "asset_id"
                                        currentIndex: root.assetIndex(root.bindingFor(String(root.affiliateData.source_b_slot || "")))
                                        enabled: root.canEdit && root.v3Editable
                                        Accessible.name: "Nguồn B video affiliate"
                                        onActivated: root.setAffiliateBinding(
                                            String(root.affiliateData.source_b_slot || ""),
                                            String(currentValue || "")
                                        )
                                    }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { Layout.preferredWidth: 66; text: "Bố cục"; color: Theme.textFaint; font.pixelSize: 11 }
                                    StudioComboBox {
                                        objectName: "studioAffiliateLayout"
                                        Layout.fillWidth: true
                                        model: [
                                            {"label": "Trên / dưới", "value": "top_bottom"},
                                            {"label": "Dưới / trên", "value": "bottom_top"},
                                            {"label": "Cạnh nhau", "value": "side_by_side"},
                                            {"label": "Lớp phủ", "value": "overlay"},
                                            {"label": "Tuần tự", "value": "sequential"}
                                        ]
                                        textRole: "label"
                                        valueRole: "value"
                                        currentIndex: {
                                            const values = ["top_bottom", "bottom_top", "side_by_side", "overlay", "sequential"]
                                            return Math.max(0, values.indexOf(String(root.affiliateData.layout || "top_bottom")))
                                        }
                                        enabled: root.canEdit && root.v3Editable
                                        Accessible.name: "Bố cục ghép affiliate"
                                        onActivated: root.setAffiliateLayout(String(currentValue))
                                    }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { Layout.preferredWidth: 66; text: "Tỷ lệ chia"; color: Theme.textFaint; font.pixelSize: 11 }
                                    Slider {
                                        id: splitSlider
                                        objectName: "studioAffiliateSplitRatio"
                                        Layout.fillWidth: true
                                        from: 0.2
                                        to: 0.8
                                        stepSize: 0.05
                                        value: Number(root.affiliateData.split_ratio || 0.5)
                                        enabled: root.canEdit && root.v3Editable
                                        activeFocusOnTab: true
                                        Accessible.role: Accessible.Slider
                                        Accessible.name: "Tỷ lệ chia nguồn A " + Math.round(value * 100) + "%"
                                        onMoved: root.setAffiliateSplitRatio(value)
                                    }
                                    Text { Layout.preferredWidth: 42; text: Math.round(splitSlider.value * 100) + "/" + Math.round((1 - splitSlider.value) * 100); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { Layout.preferredWidth: 66; text: "Chuyển cảnh"; color: Theme.textFaint; font.pixelSize: 11 }
                                    StudioComboBox {
                                        objectName: "studioAffiliateTransition"
                                        Layout.fillWidth: true
                                        model: root.supportedTransitionOptions()
                                        textRole: "label"
                                        valueRole: "value"
                                        currentIndex: root.optionIndex(model, String((root.affiliateData.transition || {}).type || "cut"), "value")
                                        enabled: root.canEdit && root.v3Editable
                                        Accessible.name: "Kiểu chuyển cảnh affiliate"
                                        onActivated: root.setAffiliateTransition(String(currentValue))
                                    }
                                    SemanticSpinBox {
                                        objectName: "studioAffiliateTransitionDuration"
                                        Layout.preferredWidth: 112
                                        from: 100
                                        to: 3000
                                        stepSize: 100
                                        value: Math.max(100, Number((root.affiliateData.transition || {}).duration_ms || 500))
                                        enabled: root.canEdit && root.v3Editable
                                            && String((root.affiliateData.transition || {}).type || "cut") === "fade"
                                        activeFocusOnTab: true
                                        Accessible.role: Accessible.SpinBox
                                        Accessible.name: "Thời lượng fade mili giây"
                                        onValueModified: root.setAffiliateTransitionDuration(value)
                                    }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { Layout.preferredWidth: 66; text: "CTA"; color: Theme.textFaint; font.pixelSize: 11 }
                                    SemanticSpinBox {
                                        objectName: "studioAffiliateCtaDuration"
                                        Layout.fillWidth: true
                                        from: 250
                                        to: 30000
                                        stepSize: 250
                                        value: Number((root.affiliateData.cta || {}).duration_ms || 1500)
                                        enabled: root.canEdit && root.v3Editable
                                            && Boolean((root.affiliateData.cta || {}).enabled)
                                        activeFocusOnTab: true
                                        Accessible.role: Accessible.SpinBox
                                        Accessible.name: "Thời lượng CTA asset mili giây"
                                        Accessible.description: enabled ? "" : "CTA asset layer chưa được cấu hình"
                                        onValueModified: root.setAffiliateCtaDuration(value)
                                    }
                                }
                                Text {
                                    objectName: "studioAffiliateTransitionNotice"
                                    Layout.fillWidth: true
                                    visible: root.transitionUnavailableReason().length > 0
                                    text: root.transitionUnavailableReason()
                                    color: Theme.warning
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Accessible.role: Accessible.StaticText
                                    Accessible.name: text
                                    Accessible.description: root.transitionUnavailableReasonCode()
                                }
                            }

                            Item {
                                id: miniPreview
                                objectName: "studioAffiliateMiniPreview"
                                Layout.preferredWidth: 148
                                Layout.minimumWidth: 148
                                Layout.fillHeight: true
                                Accessible.role: Accessible.Graphic
                                Accessible.name: "Xem trước bố cục " + String(root.affiliateData.layout || "unavailable")
                                Rectangle {
                                    id: miniFrame
                                    objectName: "studioAffiliateMiniFrame"
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 112
                                    height: Math.max(292, Math.min(360, parent.height - 4))
                                    radius: 5
                                    color: Theme.panel
                                    border.width: 1
                                    border.color: Theme.border
                                    clip: true
                                    property real split: Math.max(0.2, Math.min(0.8, Number(root.affiliateData.split_ratio || 0.5)))
                                    Rectangle {
                                        x: 2
                                        y: 2
                                        width: parent.width - 4
                                        height: Math.max(24, (parent.height - 4) * miniFrame.split)
                                        color: Theme.accentSoft
                                        clip: true
                                        Image {
                                            anchors.fill: parent
                                            source: root.assetThumbnail(root.bindingFor(String(root.affiliateData.source_a_slot || "")))
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                        }
                                        Rectangle { anchors.centerIn: parent; width: 28; height: 28; radius: 14; color: Qt.rgba(0.05, 0.06, 0.09, 0.72) }
                                        Text { anchors.centerIn: parent; text: "A"; color: "white"; font.pixelSize: 14; font.weight: Font.Bold }
                                    }
                                    Rectangle {
                                        x: 2
                                        y: 2 + Math.max(24, (parent.height - 4) * miniFrame.split)
                                        width: parent.width - 4
                                        height: Math.max(24, parent.height - y - 2)
                                        color: Theme.hover
                                        clip: true
                                        Image {
                                            anchors.fill: parent
                                            source: root.assetThumbnail(root.bindingFor(String(root.affiliateData.source_b_slot || "")))
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                        }
                                        Rectangle { anchors.centerIn: parent; width: 28; height: 28; radius: 14; color: Qt.rgba(0.05, 0.06, 0.09, 0.72) }
                                        Text { anchors.centerIn: parent; text: "B"; color: "white"; font.pixelSize: 14; font.weight: Font.Bold }
                                    }
                                }
                                Text {
                                    anchors.left: miniFrame.right
                                    anchors.leftMargin: 6
                                    y: miniFrame.y + miniFrame.height * miniFrame.split / 2 - height / 2
                                    text: Math.round(miniFrame.split * 100) + "%"
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                }
                                Text {
                                    anchors.left: miniFrame.right
                                    anchors.leftMargin: 6
                                    y: miniFrame.y + miniFrame.height * (miniFrame.split + (1 - miniFrame.split) / 2) - height / 2
                                    text: Math.round((1 - miniFrame.split) * 100) + "%"
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    objectName: "studioOutputWorkspace"
                    Layout.fillWidth: true
                    implicitHeight: Math.max(500, recipeScroll.availableHeight - 104)
                    Layout.minimumHeight: 500
                    Layout.preferredHeight: Math.max(500, recipeScroll.availableHeight - 104)
                    visible: root.activeTab === "output"
                    spacing: 8
                    Accessible.role: Accessible.Grouping
                    Accessible.name: "Thiết lập đầu ra và phát hành"

                    Rectangle {
                        objectName: "studioOutputEncodingCard"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 390
                        color: Theme.elevated
                        radius: 9
                        border.width: 1
                        border.color: Theme.borderSoft
                        Accessible.role: Accessible.Grouping
                        Accessible.name: "Mã hóa video đầu ra"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 9

                            RowLayout {
                                Layout.fillWidth: true
                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    radius: 9
                                    color: Theme.accentSoft
                                    UiIcon { anchors.centerIn: parent; name: "ui/camera"; tone: Theme.accent; iconSize: 17 }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { text: "Mã hóa & chất lượng"; color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold }
                                    Text { text: "Thông số compiler cho tệp phát hành"; color: Theme.textFaint; font.pixelSize: 11 }
                                }
                                Text {
                                    text: String(root.draftOutput.profile || "—")
                                    color: Theme.success
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }

                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

                        GridLayout {
                            Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 8
                                rowSpacing: 8
                                Text { text: "Profile"; color: Theme.textFaint; font.pixelSize: 11 }
                            StudioComboBox {
                                objectName: "studioOutputProfile"
                                Layout.fillWidth: true
                                model: root.outputData.profile_options || []
                                textRole: "label"
                                valueRole: "value"
                                currentIndex: root.optionIndex(model, String(root.draftOutput.profile || ""), "value")
                                enabled: root.canEdit && root.definitionEditable && Boolean(root.outputData.supported)
                                activeFocusOnTab: true
                                Accessible.name: "Profile đầu ra"
                                onActivated: root.setOutputField("profile", String(currentValue || ""))
                            }
                                Text { text: "Khung hình / giây"; color: Theme.textFaint; font.pixelSize: 11 }
                            SemanticSpinBox {
                                objectName: "studioOutputFps"
                                Layout.fillWidth: true
                                from: Number((root.outputData.fps_range || {}).min || 1)
                                to: Number((root.outputData.fps_range || {}).max || 120)
                                stepSize: Number((root.outputData.fps_range || {}).step || 1)
                                value: Math.round(Number(root.draftOutput.fps || 30))
                                enabled: root.canEdit && root.definitionEditable && Boolean(root.outputData.supported)
                                Accessible.name: "Tốc độ khung hình đầu ra"
                                onValueModified: root.setOutputField("fps", value)
                            }
                                Text { text: "Codec video"; color: Theme.textFaint; font.pixelSize: 11 }
                            StudioComboBox {
                                objectName: "studioOutputVideoCodec"
                                Layout.fillWidth: true
                                model: root.outputData.video_codec_options || []
                                currentIndex: (model || []).indexOf(String(root.draftOutput.video_codec || ""))
                                enabled: root.canEdit && root.definitionEditable && count > 1
                                activeFocusOnTab: true
                                Accessible.name: "Codec video đầu ra"
                                Accessible.description: count > 1 ? "" : "Compiler hiện chỉ hỗ trợ H.264"
                                onActivated: root.setOutputField("video_codec", String(currentValue || currentText || ""))
                            }
                                Text { text: "Chất lượng CRF"; color: Theme.textFaint; font.pixelSize: 11 }
                            SemanticSpinBox {
                                objectName: "studioOutputCrf"
                                Layout.fillWidth: true
                                from: Number((root.outputData.crf_range || {}).min || 14)
                                to: Number((root.outputData.crf_range || {}).max || 32)
                                stepSize: Number((root.outputData.crf_range || {}).step || 1)
                                value: Number(root.draftOutput.crf || 20)
                                enabled: root.canEdit && root.definitionEditable && Boolean(root.outputData.supported)
                                Accessible.name: "Chất lượng CRF đầu ra"
                                onValueModified: root.setOutputField("crf", value)
                            }
                                Text { text: "Bitrate âm thanh"; color: Theme.textFaint; font.pixelSize: 11 }
                            StudioComboBox {
                                objectName: "studioOutputAudioBitrate"
                                Layout.fillWidth: true
                                model: root.outputData.audio_bitrate_options || []
                                currentIndex: (model || []).indexOf(String(root.draftOutput.audio_bitrate || ""))
                                enabled: root.canEdit && root.definitionEditable && count > 0
                                activeFocusOnTab: true
                                Accessible.name: "Bitrate âm thanh đầu ra"
                                onActivated: root.setOutputField("audio_bitrate", String(currentValue || currentText || ""))
                            }
                        }

                            Item { Layout.fillHeight: true; Layout.minimumHeight: 8 }

                            FactRow {
                                Layout.fillWidth: true
                                label: "Khung hình"
                                value: Number(root.draftOutput.width || 0) + "×"
                                    + Number(root.draftOutput.height || 0)
                                    + " · " + Number(root.draftOutput.fps || 0) + " fps"
                            }
                            FactRow {
                                Layout.fillWidth: true
                                label: "Chuẩn mã hóa"
                                value: String(root.draftOutput.video_codec || "—").toUpperCase()
                                    + " · CRF " + Number(root.draftOutput.crf || 0)
                            }
                            FactRow {
                                Layout.fillWidth: true
                                label: "Âm thanh"
                                value: String(root.draftOutput.audio_bitrate || "—")
                                    + " · " + String(root.audioEditor.codec || "AAC").toUpperCase()
                            }
                        }
                    }

                    Rectangle {
                        objectName: "studioOutputDeliveryCard"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 270
                        color: Theme.elevated
                        radius: 9
                        border.width: 1
                        border.color: Theme.borderSoft
                        Accessible.role: Accessible.Grouping
                        Accessible.name: "Quy tắc phát hành an toàn"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 9

                            RowLayout {
                                Layout.fillWidth: true
                                Rectangle {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    radius: 9
                                    color: Theme.successSoft
                                    UiIcon { anchors.centerIn: parent; name: "ui/lock"; tone: Theme.success; iconSize: 17 }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { text: "Phát hành an toàn"; color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold }
                                    Text { text: "Tên tệp, quyền riêng tư và phê duyệt"; color: Theme.textFaint; font.pixelSize: 11 }
                                }
                            }

                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

                            Text { text: "Mẫu tên tệp"; color: Theme.textFaint; font.pixelSize: 11 }
                            TextArea {
                                id: outputNamingField
                                objectName: "studioOutputNamingTemplate"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 58
                                text: String((root.deliveryData.output_naming || {}).template || "")
                                placeholderText: "{channel}_{date}_{title}_v{version}_{preset}.mp4"
                                enabled: root.canEdit && root.v3Editable
                                color: Theme.text
                                placeholderTextColor: Theme.textFaint
                                font.pixelSize: 11
                                wrapMode: TextEdit.WrapAnywhere
                                selectByMouse: true
                                activeFocusOnTab: true
                                Accessible.role: Accessible.EditableText
                                Accessible.name: "Mẫu tên file đầu ra"
                                Accessible.description: "Token: channel, date, title, version, preset"
                                onActiveFocusChanged: {
                                    if (!activeFocus) {
                                        cursorPosition = 0
                                        root.setOutputNamingTemplate(text)
                                    }
                                }
                                onTextChanged: {
                                    if (!activeFocus) cursorPosition = 0
                                }
                                background: Rectangle {
                                    radius: 7
                                    color: Theme.panel
                                    border.width: 1
                                    border.color: outputNamingField.activeFocus
                                        ? Theme.accent : Theme.borderSoft
                                }
                            }

                            Text { text: "Mức hiển thị sau khi duyệt"; color: Theme.textFaint; font.pixelSize: 11 }
                            StudioComboBox {
                            objectName: "studioPublishVisibility"
                            Layout.fillWidth: true
                            model: [
                                {"label": "Riêng tư", "value": "private"},
                                {"label": "Không công khai", "value": "unlisted"},
                                {"label": "Công khai", "value": "public"}
                            ]
                            textRole: "label"
                            valueRole: "value"
                            currentIndex: {
                                const visibility = String((root.deliveryData.publish_policy || {}).visibility || "private")
                                return visibility === "public" ? 2 : visibility === "unlisted" ? 1 : 0
                            }
                            enabled: root.canEdit && root.v3Editable
                            Accessible.name: "Mức hiển thị khi phát hành"
                            Accessible.description: "Phát hành luôn cần phê duyệt phía server"
                            onActivated: root.setPublishVisibility(String(currentValue))
                        }

                            FactRow {
                                Layout.fillWidth: true
                                label: "Tên tệp mẫu"
                                value: root.outputNameExample()
                            }
                            FactRow {
                                objectName: "studioOutputPlatformFact"
                                Layout.fillWidth: true
                                label: "Nền tảng"
                                value: String((((root.editorData.delivery || {}).publish_policy || {}).platform)
                                    || ((root.recipeData.channel || {}).platform) || "—")
                            }
                            FactRow {
                                Layout.fillWidth: true
                                label: "Phê duyệt"
                                value: Boolean((root.deliveryData.publish_policy || {}).approval_required)
                                    ? "Bắt buộc phía server" : "Không bắt buộc"
                            }

                            Item { Layout.fillHeight: true; Layout.minimumHeight: 8 }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 68
                                radius: 8
                                color: Theme.warningSoft
                                border.width: 1
                                border.color: Theme.warning
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    UiIcon { name: "ui/lock"; tone: Theme.warning; iconSize: 18 }
                                    Text {
                                        Layout.fillWidth: true
                                        text: "Render không tự đăng. Lệnh publish vẫn phải qua policy và approval của control plane."
                                        color: Theme.textMuted
                                        font.pixelSize: 11
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }
                }
                Item { Layout.fillHeight: true; Layout.minimumHeight: 2 }
            }
        }
    }
}
