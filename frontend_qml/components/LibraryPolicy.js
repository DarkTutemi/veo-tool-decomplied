.pragma library

// Shared library-control matrix builder dung CHUNG cho Clone / Transcript /
// Master. charMode chi con dung de migrate config cu; UI moi dieu khien truc
// tiep tung category trong ma tran.
//
// Moi tab van TU cap nguon rieng (khac biet co chu dich, da verify o backend):
//   - categoryList   : tab tu resolve (route-prop vs master runtime key) + fallback rieng
//   - storedScopeOf  : doc scope policy da luu (route config vs masterOptionsController.config)
//   - mapping        : nhan ngu nghia rieng moi tab (clone/transcript/master)
// Chi rieng phan if/else duoi day la KHONG duoc lap lai o tung tab nua.
//
// Cong tat per-scope "Cho AI tao them phan thieu":
//   generate => hybrid (AI tao bu phan thieu), omit => library_only (khoa cung).
function build(charMode, categoryList, storedScopeOf, mapping, overrideCategory, overrideKey, overrideValue) {
    var mode = String(charMode || "full_ai")
    var categories = categoryList || []
    var scopes = ({})
    var order = ["characters", "objects", "backgrounds"]
    // Override "missing" cho 1 scope => scope do phai active: cho phep 1 cu click
    // (chon nguon hybrid/library_only) la 1 round-trip duy nhat, khong can ban
    // them scopeToggled truoc. Chen theo thu tu chuan de card khong dao vi tri.
    var oc = String(overrideCategory || "")
    if (overrideKey === "missing" && oc.length > 0 && categories.indexOf(oc) < 0) {
        var withOverride = []
        for (var k = 0; k < order.length; k += 1) {
            if (categories.indexOf(order[k]) >= 0 || order[k] === oc)
                withOverride.push(order[k])
        }
        categories = withOverride
    }
    // Override "source" (gia tri "ai" | "disabled") = trang thai KHONG active:
    // go category khoi danh sach active trong CUNG round-trip (1 click = 1 save).
    if (overrideKey === "source" && oc.length > 0 && categories.indexOf(oc) >= 0) {
        var without = []
        for (var k2 = 0; k2 < order.length; k2 += 1) {
            if (categories.indexOf(order[k2]) >= 0 && order[k2] !== oc)
                without.push(order[k2])
        }
        categories = without
    }
    var legacyLock = mode === "manual"
    var activeCount = 0
    var lockedCount = 0
    for (var i = 0; i < order.length; i += 1) {
        var category = order[i]
        var active = categories.indexOf(category) >= 0
        var stored = (typeof storedScopeOf === "function" ? storedScopeOf(category) : null) || ({})
        var storedMissing = String(stored.missing || stored.missing_policy || "")
        var allowGen = storedMissing ? (storedMissing !== "omit") : !legacyLock
        if (category === String(overrideCategory || "") && overrideKey === "missing")
            allowGen = overrideValue !== "omit"
        // "Tat" (disabled): persist qua scopes[category].source — category khong active
        // nhung khac "ai" o cho: khong entity id, khong gen, khong refs (backend gate).
        var storedSource = String(stored.source || stored.source_policy || "")
        var isDisabled = !active && storedSource === "disabled"
        if (category === oc && overrideKey === "source")
            isDisabled = String(overrideValue) === "disabled"
        var source = isDisabled ? "disabled" : (!active ? "ai" : (allowGen ? "hybrid" : "library_only"))
        var missing = (source === "library_only" || source === "disabled") ? "omit" : "generate"
        // hybrid: giu khung goc, thay entity khop bang asset da chon, con lai AI tao.
        var rewrite = source === "library_only" ? "fit_assets" : "replace_matching"
        if (active)
            activeCount += 1
        if (source === "library_only")
            lockedCount += 1
        scopes[category] = { source: source, missing: missing, rewrite: rewrite }
    }
    return {
        mode: "matrix",
        categories: categories,
        scopes: scopes,
        mapping: String(mapping || ""),
        strictness: (activeCount > 0 && lockedCount === activeCount) ? "hard_lock" : "soft_guide"
    }
}
