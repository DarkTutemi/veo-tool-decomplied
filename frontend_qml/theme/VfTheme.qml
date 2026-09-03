pragma Singleton

import QtQuick

QtObject {
    // ── Motion budget (auto perf tier) ──────────────────────────────────────
    // Python probe (utils/perf_tier.py → qml_app/main.py gán perfMotionEnabled)
    // flip flag này=false trên máy yếu (GPU WARP/software, iGPU-only với RAM
    // hoặc core thấp). Mọi infinite animation (loops: Animation.Infinite) PHẢI
    // gate `running` theo flag này. Hiệu ứng transient (hover color, dialog
    // spinner, fade chuyển screen) được giữ nguyên.
    property bool motion: true

    // ── Dark mode ───────────────────────────────────────────────────────────
    // Cấu trúc (nền/surface/border/chữ) đổi theo `dark`. Accent (primary, cyan,
    // amber, violet, các fill) giữ nguyên vì hoạt động trên cả 2 nền.
    property bool dark: false

    readonly property color appBackground: dark ? "#0B111E" : "#F5F7FB"
    readonly property color appBackground2: dark ? "#0E1626" : "#EAF0F8"
    readonly property color canvas: dark ? "#131C2B" : "#FFFFFF"
    readonly property color surface: dark ? "#131C2B" : "#FFFFFF"
    readonly property color surfaceSoft: dark ? "#1B2638" : "#F8FAFC"
    readonly property color panel: dark ? "#131C2B" : "#FFFFFF"
    readonly property color panelRaised: dark ? "#1B2638" : "#F8FAFC"
    readonly property color panelGlass: dark ? "#131C2B" : "#FFFFFF"
    readonly property color border: dark ? "#2B3850" : "#E2E8F0"
    readonly property color borderBox: dark ? "#324155" : "#D6E0EC"
    readonly property color borderSoft: dark ? "#243044" : "#E8EEF5"
    readonly property color borderStrong: dark ? "#415066" : "#CBD5E1"

    readonly property color text: dark ? "#E6EAF2" : "#0F172A"
    readonly property color textMuted: dark ? "#9AA8BD" : "#475569"
    readonly property color textSubtle: dark ? "#7E8DA3" : "#64748B"

    readonly property color primary: "#3B82F6"
    readonly property color primaryHover: "#2563EB"
    readonly property color primaryPressed: "#1D4ED8"
    readonly property color cyan: "#0891B2"
    readonly property color amber: "#D97706"
    readonly property color violet: "#7C3AED"

    readonly property color greenFill: dark ? "#10271F" : "#ECFDF5"
    readonly property color greenBorder: "#10B981"
    readonly property color blueFill: dark ? "#14233A" : "#EFF6FF"
    readonly property color blueBorder: "#3B82F6"
    readonly property color redFill: dark ? "#2A191B" : "#FEF2F2"
    readonly property color redBorder: "#EF4444"
    readonly property color violetFill: dark ? "#1E1733" : "#F5F3FF"
    readonly property color violetBorder: "#7C3AED"
    readonly property color amberFill: dark ? "#2A2110" : "#FFFBEB"
    readonly property color amberBorder: "#D97706"
    readonly property color indigoFill: dark ? "#1A1F3A" : "#EEF2FF"
    readonly property color indigoBorder: "#6366F1"
    readonly property color cyanFill: dark ? "#0E2A30" : "#ECFEFF"
    readonly property color cyanBorder: "#0891B2"

    // ── Semantic TONE — on-tint TEXT (dark shade in light theme, light shade in
    // dark theme) so colored badges/chips/headers stay readable on both. ──────
    readonly property color blueText: dark ? "#93C5FD" : "#1E40AF"
    readonly property color greenText: dark ? "#6EE7B7" : "#047857"
    readonly property color redText: dark ? "#FCA5A5" : "#B91C1C"
    readonly property color amberText: dark ? "#FCD34D" : "#92400E"
    readonly property color indigoText: dark ? "#C7D2FE" : "#4338CA"
    readonly property color violetText: dark ? "#D8B4FE" : "#6B21A8"
    readonly property color cyanText: dark ? "#7DD3FC" : "#0369A1"
    readonly property color tealText: dark ? "#5EEAD4" : "#0F766E"

    // ── Semantic TONE — soft tint BORDER (pastel in light, muted-deep in dark). ─
    readonly property color blueBorderSoft: dark ? "#27496D" : "#BFDBFE"
    readonly property color greenBorderSoft: dark ? "#1B5E48" : "#A7F3D0"
    readonly property color redBorderSoft: dark ? "#6E2B2B" : "#FECACA"
    readonly property color amberBorderSoft: dark ? "#5C4715" : "#FDE68A"
    readonly property color indigoBorderSoft: dark ? "#34356B" : "#C7D2FE"
    readonly property color violetBorderSoft: dark ? "#44306B" : "#E9D5FF"
    readonly property color cyanBorderSoft: dark ? "#1E4A5E" : "#BAE6FD"
    readonly property color pinkFill: dark ? "#2E1622" : "#FCE7F3"
    readonly property color pinkText: dark ? "#F9A8D4" : "#9D174D"
    readonly property color pinkBorder: "#EC4899"
    readonly property color pinkBorderSoft: dark ? "#5E2742" : "#FBCFE8"

    // ── Uniform design-unit scaling ─────────────────────────────────────────
    // Window sets scaleFactor = clamp(min(width/1920, height/1080)). Every
    // dimension below is dp(base) = base * scaleFactor, so the WHOLE UI keeps
    // the exact same proportions on every screen (like a video) but is rendered
    // fresh at the target size (always sharp — never a raster zoom, never crowd/clip).
    property real scaleFactor: 1.0
    function dp(value) { return value * scaleFactor }

    readonly property int radiusShell: dp(16)
    readonly property int radiusPanel: dp(13)
    readonly property int radiusControl: dp(10)
    readonly property int gap: dp(12)
    readonly property int outerMargin: 0

    readonly property string fontFamily: "Segoe UI"
    readonly property real fontTiny: dp(10)
    readonly property real fontSmall: dp(11)
    readonly property real fontControl: dp(12)
    readonly property real fontBody: dp(12)
    readonly property real fontSection: dp(14)
    readonly property real fontTitle: dp(18)
    readonly property real fontHero: dp(32)

    readonly property int weightRegular: Font.Medium
    readonly property int weightControl: Font.DemiBold
    readonly property int weightStrong: Font.Bold
    readonly property int weightTitle: Font.Bold

    readonly property int controlHeight: dp(34)
    readonly property int toolbarChipHeight: dp(40)
    readonly property int toolbarButtonHeight: dp(32)
    readonly property int fieldHeight: dp(56)
    readonly property int compactFieldHeight: dp(42)
    readonly property int actionIconSize: dp(18)
    readonly property int headerIconSize: dp(16)
    readonly property int buttonMinWidth: dp(88)
    readonly property int chipHeight: dp(32)

    // Job/monitor rail width — SINGLE source shared by EVERY screen that embeds a
    // JobPanelWidget (WorkPanel · MasterPrompt · VoiceStudio) so the rail is IDENTICAL on
    // every tab. Trước đây mỗi screen tự chế công thức → lệch (2K: 360 / 400 / 507). Derive
    // từ nhu cầu THẬT của job card: thumbnail(cap dp220) + gap dp8 + cột nút dp96 + margin
    // dp16 ≈ dp(340) + panel chrome dp(28) = dp(368). CAP theo LOGICAL px (không dp) vì rail
    // là MONITOR dày đặc, không phải content chính → không được full-dp-scale thành dải trống
    // rộng trên 2K/4K. Floor 300 để card không bị bóp, cap 400 để không phình.
    readonly property int jobRailWidth: Math.round(Math.max(300, Math.min(400, dp(368))))

    // Compact variant: the floating job-rail DRAWER shown on narrow (<1280) windows where
    // the inline rail doesn't fit. Single source shared by WorkPanel + MasterPrompt drawers
    // (was 390 vs 380 → lệch). Takes the window width (a drawer IS a fraction of the narrow
    // viewport, unlike the content-derived inline rail); same floor/cap as jobRailWidth so
    // the drawer never gets wider than the inline rail nor narrower than a card needs.
    function jobRailWidthCompact(availWidth) {
        return Math.round(Math.max(300, Math.min(400, availWidth * 0.86)))
    }
}
