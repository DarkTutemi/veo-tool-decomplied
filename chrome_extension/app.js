// app.js — UI VeoFlow Panel bằng Preact. TÁCH RIÊNG TikTok vs Shopee, tự nhận theo host.
//   TikTok (accent cyan/hồng): Catalog showcase + preview PDP + quản trị + Đơn hàng.
//   Shopee (accent cam):       Catalog + preview sản phẩm + Đơn hàng; link sinh khi import.
// State + bridge window.__vf DÙNG CHUNG (đăng ký 1 lần ở Root, không leak khi đổi sàn);
// presentation (tab/màu/chữ/logo) tách theo sàn → nhìn là 2 UI riêng. Contract v2 giữ nguyên.

import { html, render, useState, useEffect, useRef } from "./vendor/preact-standalone.js";

const BRIDGE = window.__vf || (window.__vf = { send() {}, on() {}, recv() {} });
// Catalog selection is an automation admission window. Browser/controller split it
// into API-safe chunks (20 detail rows, 50 Shopee links); images remain max 10/SP.
const MAX_PRODUCT_SEL = 500;
const MAX_IMAGE_SEL = 10;
const OFFER_FILTER_KEY = "veoflow.shopee.offer_filters.v1";
const TIKTOK_FILTER_KEY = "veoflow.tiktok.showcase_filters.v1";
const UI_THEME_KEY = "veoflow.panel.theme.v1";
const DEFAULT_OFFER_FILTERS = {
  text: "", minCommission: 10, minSold: 1000, minRating: 0,
  minPrice: 0, maxPrice: 0, shop: "", sort: "opportunity",
  hideDone: true, hideKnown: false, work: "all",
};
const DEFAULT_TIKTOK_FILTERS = {
  text: "", minCommission: 0, maxCommission: 0, minStock: 0,
  stock: "all", visibility: "all", work: "all", sort: "commission_desc",
};
const cleanUrl = (u) => String(u || "").split("?")[0];
const money = (v) => { const n = String(v || "").trim(); return n || "—"; };
const numPrice = (v) => {
  if (typeof v === "number") return v;
  const digits = String(v || "").replace(/[^\d]/g, "");
  return Number(digits || 0);
};
const fold = (v) => String(v || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
const loadOfferFilters = () => {
  try { return { ...DEFAULT_OFFER_FILTERS, ...JSON.parse(localStorage.getItem(OFFER_FILTER_KEY) || "{}") }; }
  catch { return { ...DEFAULT_OFFER_FILTERS }; }
};
const loadTikTokFilters = () => {
  try { return { ...DEFAULT_TIKTOK_FILTERS, ...JSON.parse(localStorage.getItem(TIKTOK_FILTER_KEY) || "{}") }; }
  catch { return { ...DEFAULT_TIKTOK_FILTERS }; }
};
const normalizePolicy = (p = {}) => ({
  known_item_ids: p.known_item_ids || [],
  done_item_ids: p.done_item_ids || [],
  in_progress_item_ids: p.in_progress_item_ids || [],
  campaign_complete_item_ids: p.campaign_complete_item_ids || [],
  partial_item_ids: p.partial_item_ids || [],
  publish_ready_item_ids: p.publish_ready_item_ids || [],
});
const effectiveDone = (policy = {}) => {
  const inProgress = new Set((policy.in_progress_item_ids || []).map(String));
  const completed = [
    ...(policy.campaign_complete_item_ids || []),
    ...(policy.publish_ready_item_ids || []),
  ].map(String);
  const done = new Set(completed.filter((id) => !inProgress.has(id)));
  // Backward-compatible history rows have no workflow record. A product with a
  // live campaign is not "done" merely because its first A/B variant completed.
  for (const id of (policy.done_item_ids || []).map(String)) {
    if (!inProgress.has(id)) done.add(id);
  }
  return done;
};
const rankOffers = (rows, filters, policy) => {
  const done = effectiveDone(policy);
  const known = new Set((policy.known_item_ids || []).map(String));
  return (rows || []).filter((x) => {
    const id = String(x.offer_item_id || "");
    const query = fold(filters.text).trim();
    if (query && !fold(`${x.name || ""} ${x.shop_name || ""} ${x.category_name || ""}`).includes(query)) return false;
    if (Number(x.commission_rate || 0) < Number(filters.minCommission || 0)) return false;
    if (Number(x.sold_count || 0) < Number(filters.minSold || 0)) return false;
    if (Number(x.rating || 0) < Number(filters.minRating || 0)) return false;
    if (Number(filters.minPrice || 0) > 0 && numPrice(x.price) < Number(filters.minPrice)) return false;
    if (Number(filters.maxPrice || 0) > 0 && numPrice(x.price) > Number(filters.maxPrice)) return false;
    if (filters.shop && String(x.shop_id || "") !== String(filters.shop)) return false;
    if (filters.work === "done" && !done.has(id)) return false;
    if (filters.work === "todo" && done.has(id)) return false;
    if (filters.work === "known" && !known.has(id)) return false;
    if (filters.hideDone && done.has(id)) return false;
    if (filters.hideKnown && known.has(id)) return false;
    return true;
  }).map((x) => ({
    ...x,
    opportunity_score: Number(x.commission_rate || 0) * Math.log10(Number(x.sold_count || 0) + 10),
    is_done: done.has(String(x.offer_item_id || "")),
    is_known: known.has(String(x.offer_item_id || "")),
  })).sort((a, b) => {
    const sort = String(filters.sort || "opportunity");
    if (sort === "commission") return Number(b.commission_rate || 0) - Number(a.commission_rate || 0);
    if (sort === "sold") return Number(b.sold_count || 0) - Number(a.sold_count || 0);
    if (sort === "rating") return Number(b.rating || 0) - Number(a.rating || 0);
    if (sort === "price_asc") return numPrice(a.price) - numPrice(b.price);
    if (sort === "price_desc") return numPrice(b.price) - numPrice(a.price);
    return b.opportunity_score - a.opportunity_score
      || Number(b.commission_rate || 0) - Number(a.commission_rate || 0)
      || Number(b.sold_count || 0) - Number(a.sold_count || 0);
  });
};
const diversePick = (rows, limit) => {
  const selected = [], shopUse = new Map(), catUse = new Map();
  for (const row of rows || []) {
    const shop = String(row.shop_id || row.shop_name || "unknown");
    const cat = String(row.category_id || row.category_name || "unknown");
    if ((shopUse.get(shop) || 0) >= 2 || (catUse.get(cat) || 0) >= 4) continue;
    selected.push(row);
    shopUse.set(shop, (shopUse.get(shop) || 0) + 1);
    catUse.set(cat, (catUse.get(cat) || 0) + 1);
    if (selected.length >= limit) break;
  }
  if (selected.length < limit) {
    for (const row of rows || []) {
      if (!selected.includes(row)) selected.push(row);
      if (selected.length >= limit) break;
    }
  }
  return selected;
};
const rankTikTok = (rows, filters, policy) => {
  const done = effectiveDone(policy);
  const known = new Set((policy.known_item_ids || []).map(String));
  return (rows || []).filter((x) => {
    const id = String(x.tiktok_product_id || x.product_id || "");
    const q = fold(filters.text).trim();
    if (q && !fold(`${x.name || ""} ${x.brand || ""} ${x.tiktok_category || ""} ${id}`).includes(q)) return false;
    const rate = Number(x.commission_rate || 0), stock = Number(x.stock || 0);
    if (rate < Number(filters.minCommission || 0)) return false;
    if (Number(filters.maxCommission || 0) > 0 && rate > Number(filters.maxCommission)) return false;
    if (stock < Number(filters.minStock || 0)) return false;
    if (filters.stock === "out" && stock > 0) return false;
    if (filters.stock === "in" && stock <= 0) return false;
    if (filters.stock === "low" && (stock <= 0 || stock > 50)) return false;
    if (filters.visibility === "visible" && x.is_hide) return false;
    if (filters.visibility === "hidden" && !x.is_hide) return false;
    if (filters.work === "done" && !done.has(id)) return false;
    if (filters.work === "todo" && done.has(id)) return false;
    if (filters.work === "known" && !known.has(id)) return false;
    return true;
  }).map((x) => {
    const id = String(x.tiktok_product_id || x.product_id || "");
    return { ...x, is_done: done.has(id), is_known: known.has(id) };
  }).sort((a, b) => {
    const sort = String(filters.sort || "commission_desc");
    if (sort === "commission_asc") return Number(a.commission_rate || 0) - Number(b.commission_rate || 0);
    if (sort === "amount_desc") return Number(b.commission_amount || 0) - Number(a.commission_amount || 0);
    if (sort === "stock_asc") return Number(a.stock || 0) - Number(b.stock || 0);
    if (sort === "stock_desc") return Number(b.stock || 0) - Number(a.stock || 0);
    if (sort === "price_asc") return numPrice(a.price) - numPrice(b.price);
    return Number(b.commission_rate || 0) - Number(a.commission_rate || 0)
      || Number(b.commission_amount || 0) - Number(a.commission_amount || 0);
  });
};

/* ── icons ── */
const ic = (inner) => html`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"
  stroke-linecap="round" stroke-linejoin="round" dangerouslySetInnerHTML=${{ __html: inner }}></svg>`;
const IC = {
  grid: ic('<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>'),
  harvest: ic('<path d="M21 12a9 9 0 1 1-3-6.7"/><path d="M21 4v4h-4"/>'),
  link: ic('<path d="M9 15l6-6"/><path d="M11 6l1-1a4 4 0 0 1 6 6l-1 1"/><path d="M13 18l-1 1a4 4 0 0 1-6-6l1-1"/>'),
  receipt: ic('<path d="M5 3h14v18l-3-2-2 2-2-2-2 2-2-2-3 2Z"/><path d="M8 8h8M8 12h8M8 16h5"/>'),
  play: ic('<path d="M7 5l12 7-12 7Z"/>'), pause: ic('<path d="M8 5v14M16 5v14"/>'),
  copy: ic('<rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a2 2 0 0 1 2-2h8"/>'),
  down: ic('<path d="M12 4v12m0 0l-4-4m4 4l4-4M5 20h14"/>'),
  chev: ic('<path d="M6 9l6 6 6-6"/>'), send: ic('<path d="M4 12l16-8-6 16-2.5-5.5L4 12Z"/>'),
  hand: ic('<path d="M8 12V5a1.5 1.5 0 0 1 3 0v6M11 11V4a1.5 1.5 0 0 1 3 0v7M14 11V6a1.5 1.5 0 0 1 3 0v8a6 6 0 0 1-6 6h-1a5 5 0 0 1-4-2l-2.5-3a1.6 1.6 0 0 1 2.4-2L8 13"/>'),
  plus: ic('<path d="M12 5v14M5 12h14"/>'),
  eye: ic('<path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6S2 12 2 12Z"/><circle cx="12" cy="12" r="2.5"/>'),
  redo: ic('<path d="M20 7v5h-5"/><path d="M19 12a7 7 0 1 0-2 5"/>'),
  trash: ic('<path d="M4 7h16M9 7V4h6v3M7 7l1 13h8l1-13M10 11v5M14 11v5"/>'),
  search: ic('<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>'),
  filter: ic('<path d="M4 5h16l-6 7v6l-4 2v-8Z"/>'),
  dots: ic('<circle cx="12" cy="5" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="12" cy="19" r="1"/>'),
  info: ic('<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>'),
  cart: ic('<path d="M3 4h2l2 11h10l3-8H6"/><circle cx="9" cy="20" r="1"/><circle cx="17" cy="20" r="1"/>'),
  save: ic('<path d="M5 3h11l3 3v15H5Z"/><path d="M8 3v5h7M8 21v-6h8v6"/>'),
  music: ic('<path d="M9 18V6l10-2v12"/><circle cx="6" cy="18" r="3"/><circle cx="16" cy="16" r="3"/>'),
  bag: ic('<path d="M6 8h12l-1 11a2 2 0 0 1-2 1.8H9A2 2 0 0 1 7 19L6 8Z"/><path d="M9 8V6a3 3 0 0 1 6 0v2"/>'),
  sun: ic('<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>'),
  moon: ic('<path d="M20 15.2A8.5 8.5 0 0 1 8.8 4 8.5 8.5 0 1 0 20 15.2Z"/>'),
};

/* Cấu hình 2 sàn — tab + logo + tên + theme + tab mặc định */
const PLATFORMS = {
  tiktok: {
    theme: "vf-tt", logo: IC.music, name: "TikTok Affiliate", sub: "Showcase · preview PDP tại chỗ",
    tabs: [{ k: "showcase", ic: IC.grid, t: "Sản phẩm" }, { k: "orders", ic: IC.receipt, t: "Đơn hàng" }],
    def: "showcase",
  },
  shopee: {
    theme: "vf-shp", logo: IC.bag, name: "Shopee Affiliate", sub: "Catalog · chọn cơ hội tốt",
    tabs: [{ k: "product", ic: IC.grid, t: "Sản phẩm" }, { k: "link", ic: IC.link, t: "Link" }, { k: "orders", ic: IC.receipt, t: "Đơn hàng" }],
    def: "product",
  },
};

async function detectPlatform() {
  try {
    const p = window.__vfExtract ? await window.__vfExtract() : null;
    const host = String((p && p.host) || "").toLowerCase();
    if (host.includes("tiktok")) return "tiktok";
    if (host.includes("shopee")) return "shopee";
  } catch (e) {}
  return null;
}

/* ── state + bridge + actions DÙNG CHUNG (hook, đăng ký handler 1 lần) ── */
function useVf() {
  const [tab, setTab] = useState("showcase");
  const [conn, setConn] = useState({ connected: false, auth: null, name: "" });
  const [channel, setChannel] = useState({ key: "affiliate", label: "Kênh chính" });
  const [harvest, setHarvest] = useState({ running: false, done: 0, total: 0, current: "", captcha: false, items: [] });
  const [ttProducts, setTtProducts] = useState([]);
  const [ttPicks, setTtPicks] = useState([]);
  const [ttFilters, setTtFilters] = useState(loadTikTokFilters);
  const [ttPolicy, setTtPolicy] = useState(normalizePolicy());
  const [ttBusy, setTtBusy] = useState(false);
  const [ttAction, setTtAction] = useState({ running: false, action: "", count: 0 });
  const [ttImport, setTtImport] = useState({ running: false, done: 0, total: 0, current: "" });
  const [reimport, setReimport] = useState({ running: false, platform: "", itemIds: [] });
  const [ttPreview, setTtPreview] = useState({
    id: "", requestId: "", loading: false, product: null, error: "",
  });
  const [ttStatus, setTtStatus] = useState("");
  const [ttConfirm, setTtConfirm] = useState(null);
  const [product, setProduct] = useState(null);
  const [offers, setOffers] = useState([]);
  const [offerSource, setOfferSource] = useState({ list_api_url: "", url: "" });
  const [offerPicks, setOfferPicks] = useState([]);
  const [offerBusy, setOfferBusy] = useState(false);
  const [offerProgress, setOfferProgress] = useState({ done: 0, total: 0, current: "" });
  const [offerPreview, setOfferPreview] = useState({
    id: "", requestId: "", loading: false, product: null, error: "",
  });
  const [offerPolicy, setOfferPolicy] = useState(normalizePolicy());
  const [offerFilters, setOfferFilters] = useState(loadOfferFilters);
  const [catalogBusy, setCatalogBusy] = useState(false);
  const [catalogStatus, setCatalogStatus] = useState({ count: 0, total: 0, message: "" });
  const [catalogQuery, setCatalogQuery] = useState("");
  const [displayLimit, setDisplayLimit] = useState(60);
  const [picks, setPicks] = useState([]);
  const [cart, setCart] = useState([]);
  const [links, setLinks] = useState([]);
  const [orders, setOrders] = useState([]);
  const [toast, setToastRaw] = useState("");
  const toastTimer = useRef(0);
  const offerPolicyRef = useRef(offerPolicy);
  const offerFiltersRef = useRef(offerFilters);
  const ttPolicyRef = useRef(ttPolicy);
  const ttPreviewRef = useRef(ttPreview);
  const catalogRescanPendingRef = useRef(false);
  const catalogRequestRef = useRef({ key: "", at: 0 });
  const showToast = (m) => { setToastRaw(m); clearTimeout(toastTimer.current); toastTimer.current = setTimeout(() => setToastRaw(""), 2200); };

  useEffect(() => {
    BRIDGE.on("CONNECTION", (p) => setConn({ connected: !!p.connected, auth: p.auth === undefined ? null : (p.auth === null ? null : !!p.auth), name: String(p.account_name || "") }));
    BRIDGE.on("CHANNELS", (p) => { if (p.current) setChannel(p.current); });
    BRIDGE.on("HARVEST_PROGRESS", (p) => setHarvest((h) => ({ ...h, ...p })));
    BRIDGE.on("HARVEST_ITEM", (p) => setHarvest((h) => ({ ...h, items: [p.item || p, ...h.items] })));
    BRIDGE.on("TIKTOK_SHOWCASE_POLICY", (p) => setTtPolicy(normalizePolicy(p)));
    BRIDGE.on("TIKTOK_CATALOG_PROGRESS", (p) => {
      setTtBusy(!!p.running);
      setTtStatus(String(p.message || ""));
    });
    BRIDGE.on("TIKTOK_CATALOG_DATA", (p) => {
      const rows = (p.products || []).filter((x) => x && (x.tiktok_product_id || x.product_id));
      const policy = p.policy || ttPolicyRef.current;
      setTtProducts(rows);
      setTtPolicy(normalizePolicy(policy));
      setTtPicks((old) => old.filter((id) => rows.some((x) => String(x.tiktok_product_id || x.product_id) === String(id))));
      setTtStatus(`Đã đồng bộ ${rows.length}/${Number(p.total_count || rows.length)} sản phẩm`);
    });
    BRIDGE.on("TIKTOK_ACTION_PROGRESS", (p) => setTtAction({
      running: !!p.running, action: String(p.action || ""), count: Number(p.count || 0),
    }));
    BRIDGE.on("TIKTOK_ACTION_DONE", (p) => {
      setTtAction({ running: false, action: "", count: 0 });
      setTtConfirm(null);
      if (p.ok) setTtPicks([]);
      showToast(p.message || "Đã cập nhật showcase");
    });
    BRIDGE.on("TIKTOK_PRODUCT_PREVIEW_DATA", (p) => {
      const current = ttPreviewRef.current;
      if (String(current.requestId || "") !== String(p.request_id || "")) return;
      const product = p.ok && p.product ? p.product : current.product;
      if (p.ok && product) {
        const id = String(product.tiktok_product_id || product.product_id || p.item_id || "");
        setTtProducts((rows) => rows.map((row) =>
          String(row.tiktok_product_id || row.product_id || "") === id ? { ...row, ...product } : row));
      }
      const nextPreview = {
        id: String(p.item_id || current.id || ""),
        requestId: String(p.request_id || ""),
        loading: false,
        product,
        error: p.ok ? "" : String(p.error || "Không đọc được chi tiết TikTok"),
      };
      ttPreviewRef.current = nextPreview;
      setTtPreview(nextPreview);
    });
    BRIDGE.on("TIKTOK_IMPORT_PROGRESS", (p) => setTtImport({
      running: p.running !== false,
      done: Number(p.done || 0),
      total: Number(p.total || 0),
      current: String(p.current || ""),
    }));
    BRIDGE.on("TIKTOK_IMPORT_DONE", (p) => {
      setTtImport({ running: false, done: Number(p.imported || 0), total: Number(p.total || 0), current: "" });
      if (p.imported) setTtPicks([]);
      showToast(p.message || `Đã nhập ${Number(p.imported || 0)} sản phẩm TikTok`);
    });
    BRIDGE.on("AFFILIATE_REIMPORT_DONE", (p) => {
      const platform = String(p.platform || "");
      const ids = (p.item_ids || []).map(String).filter(Boolean);
      setReimport({ running: false, platform: "", itemIds: [] });
      if (p.ok && platform === "tiktok") {
        setTtPicks((old) => Array.from(new Set([...old, ...ids])).slice(0, MAX_PRODUCT_SEL));
        setTtFilters((f) => ({ ...f, work: "todo" }));
      }
      if (p.ok && platform === "shopee") {
        setOfferPicks((old) => Array.from(new Set([...old, ...ids])).slice(0, MAX_PRODUCT_SEL));
        setOfferFilters((f) => ({ ...f, hideDone: false }));
      }
      showToast(p.message || (p.ok ? "Đã cho phép làm lại" : "Không mở lại được sản phẩm"));
    });
    BRIDGE.on("LINKS_RESULT", (p) => setLinks(p.links || []));
    BRIDGE.on("SHOPEE_OFFER_PROGRESS", (p) => {
      setOfferProgress({ done: Number(p.done || 0), total: Number(p.total || 0), current: String(p.current || "") });
      if (p.running === false) setOfferBusy(false);
    });
    BRIDGE.on("SHOPEE_OFFER_DONE", (p) => {
      setOfferBusy(false);
      showToast(p.message || `Đã nhập ${Number(p.imported || 0)} sản phẩm`);
    });
    BRIDGE.on("SHOPEE_OFFER_PREVIEW_DATA", (p) => {
      setOfferPreview((current) => {
        if (String(current.requestId || "") !== String(p.request_id || "")) return current;
        return {
          id: String(p.item_id || current.id || ""),
          requestId: String(p.request_id || ""),
          loading: false,
          product: p.ok && p.product ? p.product : current.product,
          error: p.ok ? "" : String(p.error || "Không đọc được chi tiết"),
        };
      });
    });
    BRIDGE.on("SHOPEE_OFFER_POLICY", (p) => setOfferPolicy(normalizePolicy(p)));
    BRIDGE.on("SHOPEE_CATALOG_PROGRESS", (p) => {
      setCatalogBusy(!!p.running);
      setCatalogStatus((s) => ({ ...s, message: String(p.message || "") }));
    });
    BRIDGE.on("SHOPEE_CATALOG_DATA", (p) => {
      const rows = (p.products || []).filter((x) => x && x.offer_item_id);
      const policy = p.policy || offerPolicyRef.current;
      setOffers(rows);
      setProduct(null);
      setPicks([]);
      setOfferPolicy(normalizePolicy(policy));
      setOfferSource((s) => ({ ...s, list_api_url: String(p.source_url || s.list_api_url || "") }));
      setCatalogStatus({ count: Number(p.count || rows.length), total: Number(p.total_count || rows.length), message: "" });
      setDisplayLimit(60);
      const ranked = rankOffers(rows, offerFiltersRef.current, policy);
      setOfferPicks(diversePick(ranked, Math.min(10, MAX_PRODUCT_SEL)).map((x) => x.offer_item_id));
    });
    BRIDGE.on("ORDERS_DATA", (p) => setOrders(p.orders || []));
    BRIDGE.on("TOAST", (p) => showToast(p.message || ""));
    BRIDGE.send("OVERLAY_READY", { panel: "affiliate", url: "side-panel" });
  }, []);
  useEffect(() => {
    try { localStorage.setItem(OFFER_FILTER_KEY, JSON.stringify(offerFilters)); } catch {}
    offerFiltersRef.current = offerFilters;
  }, [offerFilters]);
  useEffect(() => { offerPolicyRef.current = offerPolicy; }, [offerPolicy]);
  useEffect(() => {
    try { localStorage.setItem(TIKTOK_FILTER_KEY, JSON.stringify(ttFilters)); } catch {}
  }, [ttFilters]);
  useEffect(() => { ttPolicyRef.current = ttPolicy; }, [ttPolicy]);
  useEffect(() => { ttPreviewRef.current = ttPreview; }, [ttPreview]);

  const send = (t, p) => BRIDGE.send(t, p || {});
  const togglePick = (i) => setPicks((ps) => ps.includes(i) ? ps.filter((x) => x !== i) : (ps.length < MAX_IMAGE_SEL ? [...ps, i] : ps));
  const toggleOffer = (id) => setOfferPicks((ps) => ps.includes(id) ? ps.filter((x) => x !== id) : (ps.length < MAX_PRODUCT_SEL ? [...ps, id] : ps));
  const toggleTt = (id) => setTtPicks((ps) => ps.includes(id) ? ps.filter((x) => x !== id) : (ps.length < MAX_PRODUCT_SEL ? [...ps, id] : ps));
  const requestShopeeCatalog = (source, force = false) => {
    const listApiUrl = String((source && source.list_api_url) || "");
    const pageUrl = String((source && source.url) || "");
    const signature = String((source && source.signature) || "");
    const key = [listApiUrl, pageUrl, catalogQuery.trim(), signature].join("|");
    const now = Date.now();
    const previous = catalogRequestRef.current;
    if (!force && key === previous.key && now - previous.at < 15000) return false;
    catalogRequestRef.current = { key, at: now };
    setCatalogBusy(true);
    send("SHOPEE_CATALOG_FETCH", {
      list_api_url: listApiUrl,
      page_url: pageUrl,
      keyword: catalogQuery,
      max_items: 500,
    });
    return true;
  };
  const rescan = async () => {
    try {
      const p = window.__vfExtract ? await window.__vfExtract() : null;
      if (p && p.kind === "shopee_offer_list" && (p.products || []).length) {
        const rows = (p.products || []).slice().sort((a, b) => Number(b.commission_rate || 0) - Number(a.commission_rate || 0));
        setOffers(rows);
        setOfferSource({ list_api_url: String(p.list_api_url || ""), url: String(p.url || "") });
        const smart = rankOffers(rows, offerFilters, offerPolicy);
        setOfferPicks(smart.slice(0, MAX_PRODUCT_SEL).map((x) => x.offer_item_id));
        setProduct(null);
        const requested = requestShopeeCatalog({
          list_api_url: p.list_api_url,
          url: p.url,
          signature: rows.slice(0, 20).map((x) => x.offer_item_id).join(","),
        });
        showToast(requested
          ? `Đã thấy ${rows.length} SP · đang tải toàn bộ catalog…`
          : `Đã đồng bộ ${rows.length} SP trên trang`);
      }
      else if (p && p.kind === "shopee_offer_pending") {
        setProduct(null);
        requestShopeeCatalog({
          list_api_url: p.list_api_url,
          url: p.url,
          signature: "pending",
        });
      }
      else if (p && p.kind === "shopee_page_unavailable") {
        setCatalogBusy(false);
        showToast(p.reason === "login"
          ? "Shopee đang ở trang đăng nhập · giữ nguyên catalog đã tải"
          : "Shopee đang chặn trang tạm thời · giữ nguyên catalog đã tải");
      }
      else if (p && p.kind === "product" && (p.image_urls || []).length) {
        setProduct(p); setOffers([]); setPicks([]); showToast("Đã bóc sản phẩm");
      }
      else if (!offers.length) showToast("Trang hiện tại không có dữ liệu sản phẩm");
    } catch (e) { showToast("Không bóc được trang"); }
  };
  useEffect(() => {
    let pendingTimer = 0;
    const onTabChanged = () => {
      if (catalogBusy || offerBusy) {
        catalogRescanPendingRef.current = true;
        return;
      }
      catalogRescanPendingRef.current = false;
      rescan();
    };
    window.addEventListener("vf-active-tab-changed", onTabChanged);
    if (!catalogBusy && !offerBusy && catalogRescanPendingRef.current) {
      catalogRescanPendingRef.current = false;
      pendingTimer = setTimeout(rescan, 0);
    }
    return () => {
      clearTimeout(pendingTimer);
      window.removeEventListener("vf-active-tab-changed", onTabChanged);
    };
  }, [catalogBusy, offerBusy, catalogQuery, offerFilters, offerPolicy, offers.length]);
  const addCart = () => {
    if (!product) return;
    const imgs = product.image_urls || [];
    const chosen = (picks.length ? picks : imgs.map((_, i) => i)).map((i) => imgs[i]).filter(Boolean).slice(0, MAX_IMAGE_SEL);
    setCart((c) => [...c, { name: product.name, price: product.price, brand: product.brand, description: product.description,
      image_urls: chosen, count: chosen.length, product_url: product.url || product.product_url || "",
      tiktok_product_id: product.tiktok_product_id || "", browser_account: channel.key }]);
    showToast("Đã thêm vào giỏ");
  };
  const act = {
    channel: () => { send("CHANNEL_PICK"); showToast("Chọn kênh ở app"); },
    rescan, addCart,
    importOffers: () => {
      if (!offerPicks.length || offerBusy) return;
      const selected = rankOffers(offers, offerFilters, offerPolicy)
        .filter((x) => offerPicks.includes(x.offer_item_id) && !x.is_done);
      if (!selected.length) { showToast("Không còn SP đã chọn nào đạt bộ lọc"); return; }
      setOfferBusy(true);
      setOfferProgress({ done: 0, total: selected.length, current: "" });
      send("SHOPEE_OFFER_IMPORT", { products: selected, list_api_url: offerSource.list_api_url, page_url: offerSource.url });
      showToast(`Đang chuẩn bị ${selected.length} SP · link sẽ tạo theo một batch…`);
    },
    previewOffer: (row) => {
      const id = String((row && row.offer_item_id) || "");
      if (!id) return;
      const requestId = `${id}:${Date.now()}`;
      setOfferPreview({ id, requestId, loading: true, product: { ...(row || {}) }, error: "" });
      send("SHOPEE_OFFER_PREVIEW", {
        product: row || {}, list_api_url: offerSource.list_api_url, request_id: requestId,
      });
    },
    closeOfferPreview: () => setOfferPreview({
      id: "", requestId: "", loading: false, product: null, error: "",
    }),
    loadCatalog: () => {
      if (catalogBusy) return;
      requestShopeeCatalog({
        list_api_url: offerSource.list_api_url,
        url: offerSource.url,
        signature: "manual",
      }, true);
    },
    pickN: (n) => setOfferPicks(rankOffers(offers, offerFilters, offerPolicy)
      .slice(0, Math.min(MAX_PRODUCT_SEL, Number(n || 10))).map((x) => x.offer_item_id)),
    pickDiverse: () => setOfferPicks(diversePick(
      rankOffers(offers, offerFilters, offerPolicy), Math.min(10, MAX_PRODUCT_SEL)
    ).map((x) => x.offer_item_id)),
    clearOfferPicks: () => setOfferPicks([]),
    setOfferFilter: (key, value) => setOfferFilters((f) => ({ ...f, [key]: value })),
    setOfferFilterPreset: (kind) => setOfferFilters((f) => {
      if (kind === "all") {
        return { ...DEFAULT_OFFER_FILTERS, minCommission: 0, minSold: 0,
          hideDone: false, hideKnown: false, sort: f.sort };
      }
      return {
        ...f,
        minCommission: kind === "commission" ? 10 : f.minCommission,
        minSold: kind === "sold" ? 1000 : f.minSold,
        work: kind === "done" ? "done" : (kind === "known" ? "known" : "all"),
        hideDone: false,
        hideKnown: false,
      };
    }),
    setCatalogQuery,
    showMoreOffers: () => setDisplayLimit((n) => n + 60),
    loadTikTok: () => {
      if (ttBusy || ttAction.running) return;
      setTtBusy(true);
      send("TIKTOK_CATALOG_FETCH", { max_items: 2000 });
    },
    setTtFilter: (key, value) => setTtFilters((f) => ({ ...f, [key]: value })),
    setTtFilterPreset: (kind) => setTtFilters((f) => {
      if (kind === "all") return { ...DEFAULT_TIKTOK_FILTERS, sort: f.sort };
      return {
        ...f,
        visibility: kind === "visible" ? "visible" : (kind === "hidden" ? "hidden" : "all"),
        stock: kind === "out" ? "out" : "all",
        work: kind === "done" ? "done" : "all",
      };
    }),
    pickTikTok: (kind) => {
      const rows = rankTikTok(ttProducts, ttFilters, ttPolicy);
      let picked = rows;
      if (kind === "top5") picked = rows.slice().sort((a, b) => Number(b.commission_rate || 0) - Number(a.commission_rate || 0)).slice(0, 5);
      if (kind === "top10") picked = rows.slice().sort((a, b) => Number(b.commission_rate || 0) - Number(a.commission_rate || 0)).slice(0, 10);
      if (kind === "low") picked = rows.filter((x) => Number(x.commission_rate || 0) < 5);
      if (kind === "out") picked = rows.filter((x) => Number(x.stock || 0) <= 0);
      if (kind === "hidden") picked = rows.filter((x) => !!x.is_hide);
      if (kind === "done") picked = rows.filter((x) => !!x.is_done);
      setTtPicks(picked.slice(0, MAX_PRODUCT_SEL)
        .map((x) => String(x.tiktok_product_id || x.product_id)));
    },
    clearTikTok: () => setTtPicks([]),
    importTikTok: () => {
      if (ttImport.running) return;
      const done = effectiveDone(ttPolicy);
      const selected = rankTikTok(ttProducts, ttFilters, ttPolicy).filter((x) => {
        const id = String(x.tiktok_product_id || x.product_id || "");
        return ttPicks.includes(id) && !done.has(id);
      });
      if (!selected.length) {
        showToast("Không còn sản phẩm TikTok hợp lệ để nhập");
        return;
      }
      setTtImport({ running: true, done: 0, total: selected.length, current: "" });
      send("TIKTOK_SHOWCASE_IMPORT", { products: selected });
      showToast(`Đang lấy ảnh + thông tin PDP cho ${selected.length} sản phẩm…`);
    },
    allowReimport: (platform, ids) => {
      const clean = Array.from(new Set((ids || []).map(String).filter(Boolean))).slice(0, MAX_PRODUCT_SEL);
      if (!clean.length || reimport.running || ttImport.running || offerBusy) return;
      setReimport({ running: true, platform, itemIds: clean });
      send("AFFILIATE_ALLOW_REIMPORT", { platform, item_ids: clean });
      showToast(`Đang mở lại ${clean.length} sản phẩm…`);
    },
    previewTikTok: (row) => {
      const id = String((row && (row.tiktok_product_id || row.product_id)) || "");
      if (!id) return;
      const requestId = `${id}:${Date.now()}`;
      const nextPreview = { id, requestId, loading: true, product: { ...(row || {}) }, error: "" };
      ttPreviewRef.current = nextPreview;
      setTtPreview(nextPreview);
      send("TIKTOK_PRODUCT_PREVIEW", { product: row || {}, request_id: requestId });
    },
    closeTikTokPreview: () => {
      const nextPreview = { id: "", requestId: "", loading: false, product: null, error: "" };
      ttPreviewRef.current = nextPreview;
      setTtPreview(nextPreview);
    },
    manageTikTok: (action, ids = ttPicks) => {
      const selected = ttProducts.filter((x) => ids.includes(String(x.tiktok_product_id || x.product_id)));
      if (!selected.length || ttAction.running || ttImport.running) return;
      if (action === "delete") {
        setTtConfirm({ action, ids: selected.map((x) => String(x.tiktok_product_id || x.product_id)) });
        return;
      }
      setTtAction({ running: true, action, count: selected.length });
      send("TIKTOK_SHOWCASE_ACTION", {
        action,
        product_ids: selected.map((x) => String(x.tiktok_product_id || x.product_id)),
        source_map: Object.fromEntries(selected.map((x) => [String(x.tiktok_product_id || x.product_id), Number(x.source_from == null ? 2 : x.source_from)])),
      });
    },
    confirmTikTokDelete: () => {
      const ids = (ttConfirm && ttConfirm.ids) || [];
      if (!ids.length || ttAction.running || ttImport.running) return;
      const selected = ttProducts.filter((x) => ids.includes(String(x.tiktok_product_id || x.product_id)));
      setTtAction({ running: true, action: "delete", count: ids.length });
      send("TIKTOK_SHOWCASE_ACTION", {
        action: "delete", product_ids: ids, delete_confirmation: `DELETE:${ids.length}`,
        source_map: Object.fromEntries(selected.map((x) => [String(x.tiktok_product_id || x.product_id), Number(x.source_from == null ? 2 : x.source_from)])),
      });
    },
    cancelTikTokDelete: () => setTtConfirm(null),
    sendCart: () => { send("IMPORT_PRODUCTS", { products: cart }); showToast(`Đã gửi ${cart.length} SP về app`); setCart([]); },
    harvestStart: () => { setHarvest({ running: true, done: 0, total: 0, current: "", captcha: false, items: [] }); send("HARVEST_START", { channel: channel.key }); },
    harvestStop: () => { setHarvest((h) => ({ ...h, running: false })); send("HARVEST_STOP"); },
    exportHarvest: () => { send("IMPORT_PRODUCTS", { products: harvest.items.filter((i) => i.status === "done") }); showToast("Xuất SP đã cào về app"); },
    linksCreate: () => { send("LINKS_CREATE"); showToast("Đang tạo link…"); },
    exportLinks: () => { send("EXPORT_SAVE", { kind: "links" }); showToast("Đã xuất CSV link"); },
    ordersFetch: () => { send("ORDERS_FETCH", { channel: channel.key }); showToast("Đang tải đơn…"); },
    exportOrders: () => { send("IMPORT_PRODUCTS", { orders }); showToast("Xuất đơn về app"); },
    exportSave: () => { send("EXPORT_SAVE", { kind: "snapshot" }); showToast("Đã lưu snapshot"); },
  };
  return { tab, setTab, conn, channel, harvest, product, offers,
    ttProducts, visibleTikTok: rankTikTok(ttProducts, ttFilters, ttPolicy),
    ttPicks, toggleTt, ttFilters, ttPolicy, ttBusy, ttAction, ttImport, ttPreview,
    ttStatus, ttConfirm, reimport,
    visibleOffers: rankOffers(offers, offerFilters, offerPolicy), offerPicks, toggleOffer,
    offerBusy, offerProgress, offerPreview, offerPolicy, offerFilters, catalogBusy, catalogStatus,
    catalogQuery, displayLimit, picks, togglePick,
    cart, links, orders, toast, act, showToast };
}

/* ── components dùng chung ── */
function Empty({ icon, t, d, cta, onCta }) {
  return html`<div class="empty">
    <div class="glyph">${icon}</div><div class="et">${t}</div><div class="e2">${d}</div>
    ${cta ? html`<button class="btn primary empty-cta" onClick=${onCta}>${IC.play}${cta}</button>` : null}
  </div>`;
}
function ItemRow(it) {
  const map = { done: ["ok", "XONG"], run: ["run", "PDP…"], skip: ["skip", "ĐÃ CÓ"], error: ["err", "LỖI"] };
  const st = map[it.status] || ["run", "…"];
  return html`<div class="item">
    <div class="thumb" style="background-image:url('${cleanUrl(it.image || "")}')"></div>
    <div class="ib2"><div class="n">${it.name || "Sản phẩm"}</div>
      <div class="m"><span>${money(it.price)}</span><span>${it.count || 0} ảnh</span>${it.id ? html`<span class="id">·${String(it.id).slice(0, 7)}…</span>` : null}</div></div>
    <span class="st ${st[0]}">${st[1]}</span></div>`;
}
function connLine(c) {
  if (!c.connected) return html`<span class="cdot"></span>Chưa kết nối app`;
  if (c.auth === false) return html`<span class="cdot bad"></span>Chưa đăng nhập`;
  if (c.auth === true) return html`<span class="cdot on"></span>Đã đăng nhập${c.name ? " · " + c.name : ""}`;
  return html`<span class="cdot on"></span>Đã kết nối`;
}
function FilterToggle({ count, open, onClick }) {
  return html`<button type="button" class="filter-toggle ${open ? "active" : ""}" onClick=${onClick}>
    ${IC.filter}<span>Bộ lọc</span>${count ? html`<b>${count}</b>` : null}${IC.chev}
  </button>`;
}
function QuickChip({ active, danger, onClick, children }) {
  return html`<button type="button" class="quick-chip ${active ? "active" : ""} ${danger ? "danger" : ""}"
    onClick=${onClick}>${children}</button>`;
}
function ProductStatus({ kind, children }) {
  return html`<span class="product-status ${kind || ""}">${children}</span>`;
}
function RowMenu({ actions }) {
  return html`<details class="row-menu" onClick=${(e) => e.stopPropagation()}>
    <summary title="Thao tác">${IC.dots}</summary>
    <div class="row-menu-pop">
      ${(actions || []).filter(Boolean).map((action) => html`<button class=${action.danger ? "danger" : ""}
        disabled=${!!action.disabled} onClick=${(e) => {
          e.preventDefault();
          e.stopPropagation();
          const details = e.currentTarget.closest("details");
          if (details) details.removeAttribute("open");
          action.run();
        }}>${action.icon || null}<span>${action.label}</span></button>`)}
    </div>
  </details>`;
}
function ProductThumb({ image, label }) {
  return html`<div class="product-thumb ${image ? "" : "no-image"}"
    style=${image ? `background-image:url('${cleanUrl(image)}')` : ""}>
    ${image ? null : html`<span>${String(label || "SP").slice(0, 2).toUpperCase()}</span>`}
  </div>`;
}

/* ── tab bodies (platform-aware copy) ── */
function ProductTab({ vf, platform }) {
  const [filtersOpen, setFiltersOpen] = useState(false);
  const { product, offers, visibleOffers, offerPicks, toggleOffer, offerBusy, offerProgress,
    offerPreview, offerPolicy, offerFilters, catalogBusy, catalogStatus, catalogQuery, displayLimit,
    reimport,
    picks, togglePick, act } = vf;
  const site = platform === "tiktok" ? "TikTok Shop" : "Shopee";
  const visibleIds = new Set((visibleOffers || []).map((x) => x.offer_item_id));
  const selectedVisible = offerPicks.filter((id) => visibleIds.has(id)).length;
  const shopCounts = new Map();
  for (const row of offers || []) {
    const id = String(row.shop_id || "");
    if (!id) continue;
    const cur = shopCounts.get(id) || { id, name: String(row.shop_name || `Shop ${id}`), count: 0 };
    cur.count++;
    shopCounts.set(id, cur);
  }
  const shops = Array.from(shopCounts.values()).sort((a, b) => b.count - a.count).slice(0, 50);
  const shownOffers = (visibleOffers || []).slice(0, displayLimit);
  const preview = offerPreview && offerPreview.product;
  const previewImages = preview
    ? ((preview.image_urls && preview.image_urls.length) ? preview.image_urls : [preview.image].filter(Boolean))
    : [];
  const previewDone = effectiveDone(offerPolicy).has(String((offerPreview && offerPreview.id) || ""));
  const doneCount = effectiveDone(offerPolicy).size;
  const knownCount = (offerPolicy.known_item_ids || []).length;
  const offerFilterCount = [
    Number(offerFilters.minCommission || 0) > 0,
    Number(offerFilters.minSold || 0) > 0,
    Number(offerFilters.minRating || 0) > 0,
    Number(offerFilters.minPrice || 0) > 0,
    Number(offerFilters.maxPrice || 0) > 0,
    !!offerFilters.shop,
    offerFilters.work !== "all",
    !!offerFilters.hideDone,
    !!offerFilters.hideKnown,
  ].filter(Boolean).length;
  const allOffersActive = offerFilterCount === 0 && !(offerFilters.text || "").trim();
  if (platform === "shopee" && offers.length) return html`
    <section class="catalog-command">
      <div class="catalog-title-row">
        <div class="catalog-title">${IC.cart}<div><b>Cơ hội sản phẩm</b>
          <span>${offers.length}/${catalogStatus.total || offers.length} sản phẩm · ${selectedVisible} đã chọn</span></div></div>
        <div class="catalog-sync"><span>${catalogBusy ? "Đang đồng bộ…" : "Catalog Shopee"}</span>
          <button class="refresh-button ${catalogBusy ? "busy" : ""}" onClick=${act.loadCatalog}
            disabled=${catalogBusy || offerBusy}>${IC.harvest}<span>Quét lại</span></button></div>
      </div>
      <form class="catalog-tools" onSubmit=${(e) => { e.preventDefault(); act.loadCatalog(); }}>
        <label class="search-box">${IC.search}<input value=${offerFilters.text || ""}
          onInput=${(e) => {
            const value = e.currentTarget.value;
            act.setOfferFilter("text", value);
            act.setCatalogQuery(value);
          }} placeholder="Tìm tên sản phẩm, shop hoặc từ khóa…"/></label>
        <select class="sort-select" value=${offerFilters.sort}
          onChange=${(e) => act.setOfferFilter("sort", e.currentTarget.value)}>
          <option value="opportunity">Cơ hội tốt nhất</option>
          <option value="commission">Hoa hồng cao → thấp</option>
          <option value="sold">Bán nhiều nhất</option>
          <option value="rating">Đánh giá cao nhất</option>
          <option value="price_asc">Giá thấp → cao</option>
          <option value="price_desc">Giá cao → thấp</option>
        </select>
        ${FilterToggle({ count: offerFilterCount, open: filtersOpen, onClick: () => setFiltersOpen((v) => !v) })}
      </form>
      <div class="quick-chip-row">
        ${QuickChip({ active: allOffersActive, onClick: () => act.setOfferFilterPreset("all"),
          children: html`Tất cả <b>${offers.length}</b>` })}
        ${QuickChip({ active: Number(offerFilters.minCommission || 0) >= 10 && offerFilters.work === "all",
          onClick: () => act.setOfferFilterPreset("commission"), children: "HH ≥ 10%" })}
        ${QuickChip({ active: Number(offerFilters.minSold || 0) >= 1000 && offerFilters.work === "all",
          onClick: () => act.setOfferFilterPreset("sold"), children: "Bán ≥ 1k" })}
        ${QuickChip({ active: offerFilters.work === "done",
          onClick: () => act.setOfferFilterPreset("done"), children: html`Đã làm <b>${doneCount}</b>` })}
        ${QuickChip({ active: offerFilters.work === "known",
          onClick: () => act.setOfferFilterPreset("known"), children: html`Trong kho <b>${knownCount}</b>` })}
      </div>
      ${filtersOpen ? html`<div class="advanced-filters">
        <label><span>Hoa hồng tối thiểu</span><div><input type="number" min="0" max="100" step="1"
          value=${offerFilters.minCommission} onInput=${(e) => act.setOfferFilter("minCommission", Number(e.currentTarget.value || 0))}/><b>%</b></div></label>
        <label><span>Lượt bán tối thiểu</span><input type="number" min="0" step="100"
          value=${offerFilters.minSold} onInput=${(e) => act.setOfferFilter("minSold", Number(e.currentTarget.value || 0))}/></label>
        <label><span>Đánh giá tối thiểu</span><div><input type="number" min="0" max="5" step=".1"
          value=${offerFilters.minRating} onInput=${(e) => act.setOfferFilter("minRating", Number(e.currentTarget.value || 0))}/><b>★</b></div></label>
        <label><span>Giá từ</span><input type="number" min="0" step="10000"
          value=${offerFilters.minPrice} onInput=${(e) => act.setOfferFilter("minPrice", Number(e.currentTarget.value || 0))}/></label>
        <label><span>Giá đến</span><input type="number" min="0" step="10000"
          value=${offerFilters.maxPrice} onInput=${(e) => act.setOfferFilter("maxPrice", Number(e.currentTarget.value || 0))}/></label>
        <label><span>Shop</span><select value=${offerFilters.shop}
          onChange=${(e) => act.setOfferFilter("shop", e.currentTarget.value)}>
          <option value="">Tất cả shop</option>
          ${shops.map((s) => html`<option value=${s.id}>${s.name} (${s.count})</option>`)}
        </select></label>
        <label><span>Tiến độ video</span><select value=${offerFilters.work}
          onChange=${(e) => act.setOfferFilter("work", e.currentTarget.value)}>
          <option value="all">Tất cả</option><option value="todo">Chưa làm</option>
          <option value="done">Đã làm</option><option value="known">Đã vào kho</option>
        </select></label>
        <label class="check-filter"><input type="checkbox" checked=${offerFilters.hideDone}
          onChange=${(e) => act.setOfferFilter("hideDone", !!e.currentTarget.checked)}/><span>Ẩn sản phẩm đã làm</span></label>
        <label class="check-filter"><input type="checkbox" checked=${offerFilters.hideKnown}
          onChange=${(e) => act.setOfferFilter("hideKnown", !!e.currentTarget.checked)}/><span>Ẩn sản phẩm trong kho</span></label>
      </div>` : null}
      ${catalogBusy || catalogStatus.message ? html`<div class="catalog-state ${catalogBusy ? "busy" : ""}">
        ${catalogBusy ? html`<span class="spin tiny"></span>` : null}${catalogStatus.message || "Đang tải các trang catalog…"}
      </div>` : null}
      ${offerBusy ? html`<div class="bar"><i style="width:${offerProgress.total ? Math.round(offerProgress.done / offerProgress.total * 100) : 8}%"></i></div>
        <div class="now">${offerProgress.current || "Đang đọc API Shopee…"}</div>` : null}
      <div class="catalog-summary"><span>${visibleOffers.length}/${offers.length} đạt bộ lọc</span>
        <button onClick=${() => act.pickN(5)}>Top 5</button><button onClick=${() => act.pickN(10)}>Top 10</button>
        <button onClick=${act.pickDiverse}>Đa dạng 10</button><button onClick=${act.clearOfferPicks}>Bỏ chọn</button></div>
    </section>
    ${offerPreview && offerPreview.id ? html`<div class="card offer-preview">
      <div class="preview-head">
        <div><span class="preview-kicker">CHI TIẾT SẢN PHẨM</span>
          <b>${(preview && preview.name) || "Đang đọc thông tin…"}</b></div>
        <button title="Đóng" onClick=${act.closeOfferPreview}>×</button>
      </div>
      ${offerPreview.loading ? html`<div class="preview-loading"><span class="spin tiny"></span>
        Đang lấy ảnh và thông tin trực tiếp từ API Shopee…</div>` : null}
      ${offerPreview.error ? html`<div class="banner err">Không đọc đủ chi tiết: ${offerPreview.error}</div>` : null}
      ${preview ? html`
        <div class="preview-gallery">
          ${previewImages.slice(0, 12).map((url, index) => html`<div class="preview-image"
            title=${`Ảnh ${index + 1}`} style="background-image:url('${cleanUrl(url)}')"></div>`)}
          ${!previewImages.length ? html`<div class="preview-no-image">Chưa có ảnh</div>` : null}
        </div>
        <div class="preview-stats">
          <span><small>Giá</small><b>${money(preview.price_text || preview.price)}</b></span>
          <span><small>Hoa hồng</small><b>${Number(preview.commission_rate || 0).toLocaleString("vi-VN")}%</b></span>
          <span><small>Đã bán</small><b>${Number(preview.sold_count || preview.sold || 0).toLocaleString("vi-VN")}</b></span>
          <span><small>Tồn kho</small><b>${Number(preview.stock || 0).toLocaleString("vi-VN")}</b></span>
        </div>
        <div class="preview-meta">
          ${preview.brand ? html`<span>Thương hiệu: <b>${preview.brand}</b></span>` : null}
          ${preview.shop_name ? html`<span>Shop: <b>${preview.shop_name}</b></span>` : null}
          ${preview.category ? html`<span>Ngành: <b>${preview.category}</b></span>` : null}
          ${preview.rating ? html`<span>Đánh giá: <b>★${Number(preview.rating).toFixed(1)}</b></span>` : null}
          <span>Ảnh lấy được: <b>${previewImages.length}</b></span>
          <span>Mô tả: <b>${preview.description_source === "shopee_api" ? "Shopee API" : "Tổng hợp dữ liệu thật"}</b></span>
        </div>
        <div class="preview-description">${preview.description || "Shopee không trả mô tả cho sản phẩm này."}</div>
        <div class="preview-actions">
          ${previewDone ? html`<button class="reimport" disabled=${reimport.running}
            onClick=${() => act.allowReimport("shopee", [offerPreview.id])}>
            ${IC.redo}${reimport.running ? "Đang mở lại…" : "Bỏ ĐÃ LÀM · nhập lại"}</button>`
            : html`<button class=${offerPicks.includes(offerPreview.id) ? "selected" : ""}
              onClick=${() => toggleOffer(offerPreview.id)}>
              ${offerPicks.includes(offerPreview.id) ? "✓ Đã chọn để nhập" : "＋ Chọn để nhập"}
            </button>`}
          <span>${previewDone ? "History và video cũ vẫn được giữ; sản phẩm được mở cho một lượt video mới." : "Link hoa hồng sẽ tự tạo theo batch khi bấm Import."}</span>
        </div>` : null}
    </div>` : null}
    <div class="product-list">
    ${shownOffers.map((it) => {
      const picked = offerPicks.includes(it.offer_item_id);
      const active = offerPreview && offerPreview.id === it.offer_item_id;
      const commissionValue = Math.round(numPrice(it.price) * Number(it.commission_rate || 0) / 100);
      const actions = [
        { label: "Xem chi tiết", icon: IC.info, run: () => act.previewOffer(it) },
        { label: picked ? "Bỏ chọn" : "Chọn để nhập", icon: IC.cart, run: () => toggleOffer(it.offer_item_id) },
        it.is_done ? { label: "Làm lại sản phẩm", icon: IC.redo, disabled: reimport.running,
          run: () => act.allowReimport("shopee", [it.offer_item_id]) } : null,
      ];
      return html`<article class="catalog-row shopee-row ${picked ? "picked" : ""} ${active ? "active" : ""}"
        onClick=${() => act.previewOffer(it)}>
        <button class="select-box ${picked ? "checked" : ""}" title="Chọn để nhập"
          onClick=${(e) => { e.stopPropagation(); toggleOffer(it.offer_item_id); }}>${picked ? "✓" : ""}</button>
        ${ProductThumb({ image: it.image, label: it.name })}
        <div class="product-main"><b>${it.name || "Sản phẩm"}</b>
          <span>${it.shop_name || "Shopee"}${it.offer_item_id ? ` · ID ${it.offer_item_id}` : ""}</span>
          <div class="product-tags">${it.is_done ? ProductStatus({ kind: "done", children: "ĐÃ LÀM" }) : null}
            ${it.is_known ? ProductStatus({ kind: "known", children: "TRONG KHO" }) : null}</div></div>
        <div class="product-price"><b>${money(it.price_text || it.price)}</b>
          <span>${it.sold_count ? Number(it.sold_count).toLocaleString("vi-VN") + " đã bán" : (it.sold || "Chưa có lượt bán")}</span>
          ${it.rating ? html`<small>★ ${Number(it.rating).toFixed(1)}</small>` : null}</div>
        <div class="product-commission"><b>${Number(it.commission_rate || 0).toLocaleString("vi-VN")}%</b>
          <span>${commissionValue ? `${commissionValue.toLocaleString("vi-VN")}₫` : "—"}</span></div>
        ${RowMenu({ actions })}
      </article>`;
    })}
    </div>
    ${visibleOffers.length > shownOffers.length ? html`<button class="load-more" onClick=${act.showMoreOffers}>
      Hiện thêm ${Math.min(60, visibleOffers.length - shownOffers.length)} SP · còn ${visibleOffers.length - shownOffers.length}</button>` : null}
    ${!visibleOffers.length ? html`<div class="banner">Không có SP đạt bộ lọc hiện tại — hạ ngưỡng hoa hồng/lượt bán hoặc bỏ ẩn.</div>` : null}`;
  if (!product) return Empty({ icon: IC.grid, t: platform === "shopee" ? "Quét danh sách Product Offer" : "Mở một trang sản phẩm",
    d: platform === "shopee"
      ? "Ngay tại Product Offer, VeoFlow đọc danh sách, xếp theo hoa hồng và lấy link theo lô."
      : `Vào 1 SP trên ${site} rồi bấm Quét — bóc tên, giá, mô tả và ảnh để bạn duyệt.`,
    cta: "Quét trang", onCta: act.rescan });
  const imgs = product.image_urls || [];
  return html`
    <div class="sec"><div class="lbl">Tên sản phẩm</div><textarea class="tname" value=${product.name || ""}></textarea></div>
    <div class="row2">
      <div class="sec"><div class="lbl">Giá</div><input value=${product.price || ""}/></div>
      <div class="sec"><div class="lbl">Thương hiệu</div><input value=${product.brand || ""}/></div></div>
    <div class="sec"><div class="lbl">Mô tả <span class="hint">nguồn cho AI viết kịch bản</span></div><textarea class="tdesc" value=${product.description || ""}></textarea></div>
    <div class="sec"><div class="lbl">Ảnh <span class="hint">bấm theo thứ tự (tối đa ${MAX_IMAGE_SEL})</span><span class="a" style="margin-left:auto" onClick=${act.rescan}>${IC.harvest}Quét lại</span></div>
      <div id="grid">${imgs.map((u, i) => html`<div class="cell ${picks.includes(i) ? "pick" : ""}" onClick=${() => togglePick(i)}
        style="background-image:url('${cleanUrl(u)}')">${picks.includes(i) ? html`<span class="bdg">${picks.indexOf(i) + 1}</span>` : null}</div>`)}</div>
    </div>`;
}

function ShowcaseTab({ vf }) {
  const [filtersOpen, setFiltersOpen] = useState(false);
  const { conn, ttProducts, visibleTikTok, ttPicks, toggleTt, ttFilters, ttPolicy,
    ttBusy, ttAction, ttImport, ttPreview, ttStatus, ttConfirm, reimport, act } = vf;
  const done = effectiveDone(ttPolicy);
  const stats = {
    total: ttProducts.length,
    visible: ttProducts.filter((x) => !x.is_hide).length,
    hidden: ttProducts.filter((x) => x.is_hide).length,
    out: ttProducts.filter((x) => Number(x.stock || 0) <= 0).length,
    done: ttProducts.filter((x) => done.has(String(x.tiktok_product_id || x.product_id))).length,
  };
  const ttFilterCount = [
    Number(ttFilters.minCommission || 0) > 0,
    Number(ttFilters.maxCommission || 0) > 0,
    Number(ttFilters.minStock || 0) > 0,
    ttFilters.stock !== "all",
    ttFilters.visibility !== "all",
    ttFilters.work !== "all",
  ].filter(Boolean).length;
  const allTikTokActive = ttFilterCount === 0 && !(ttFilters.text || "").trim();
  return html`
    ${conn.auth === false ? html`<div class="banner err">${IC.hand}<div>Chưa đăng nhập TikTok — đăng nhập trên trang rồi bấm Đồng bộ.</div></div>` : null}
    <section class="catalog-command">
      <div class="catalog-title-row">
        <div class="catalog-title">${IC.cart}<div><b>Danh sách sản phẩm</b>
          <span>${visibleTikTok.length}/${ttProducts.length} đang hiển thị · ${ttPicks.length} đã chọn</span></div></div>
        <div class="catalog-sync"><span>${ttBusy ? "Đang đồng bộ…" : (ttStatus || "Tự đồng bộ")}</span>
          <button class="refresh-button ${ttBusy ? "busy" : ""}" onClick=${act.loadTikTok}
            disabled=${ttBusy || ttAction.running}>${IC.harvest}<span>Quét lại</span></button></div>
      </div>
      <div class="catalog-tools">
        <label class="search-box">${IC.search}<input value=${ttFilters.text}
          onInput=${(e) => act.setTtFilter("text", e.currentTarget.value)}
          placeholder="Tìm tên sản phẩm, shop hoặc ID…"/></label>
        <select class="sort-select" value=${ttFilters.sort} onChange=${(e) => act.setTtFilter("sort", e.currentTarget.value)}>
          <option value="commission_desc">Hoa hồng cao → thấp</option>
          <option value="commission_asc">Hoa hồng thấp → cao</option>
          <option value="amount_desc">Tiền HH cao nhất</option>
          <option value="stock_desc">Tồn kho nhiều</option>
          <option value="stock_asc">Tồn kho ít</option>
          <option value="price_asc">Giá thấp → cao</option>
        </select>
        ${FilterToggle({ count: ttFilterCount, open: filtersOpen, onClick: () => setFiltersOpen((v) => !v) })}
      </div>
      <div class="quick-chip-row">
        ${QuickChip({ active: allTikTokActive, onClick: () => act.setTtFilterPreset("all"),
          children: html`Tất cả <b>${stats.total}</b>` })}
        ${QuickChip({ active: ttFilters.visibility === "visible" && ttFilters.stock === "all" && ttFilters.work === "all",
          onClick: () => act.setTtFilterPreset("visible"), children: html`Đang hiện <b>${stats.visible}</b>` })}
        ${QuickChip({ active: ttFilters.stock === "out", danger: ttFilters.stock === "out",
          onClick: () => act.setTtFilterPreset("out"), children: html`Hết hàng <b>${stats.out}</b>` })}
        ${QuickChip({ active: ttFilters.work === "done",
          onClick: () => act.setTtFilterPreset("done"), children: html`Đã làm <b>${stats.done}</b>` })}
        ${QuickChip({ active: Number(ttFilters.minCommission || 0) >= 5,
          onClick: () => act.setTtFilter("minCommission", Number(ttFilters.minCommission || 0) >= 5 ? 0 : 5),
          children: "HH ≥ 5%" })}
      </div>
      ${filtersOpen ? html`<div class="advanced-filters">
        <label><span>Hoa hồng từ</span><input type="number" min="0" max="100" step=".5"
          value=${ttFilters.minCommission} onInput=${(e) => act.setTtFilter("minCommission", Number(e.currentTarget.value || 0))}/><b>%</b></label>
        <label><span>Hoa hồng đến (0 = ∞)</span><input type="number" min="0" max="100" step=".5"
          value=${ttFilters.maxCommission} onInput=${(e) => act.setTtFilter("maxCommission", Number(e.currentTarget.value || 0))}/><b>%</b></label>
        <label><span>Tồn kho tối thiểu</span><input type="number" min="0" step="10"
          value=${ttFilters.minStock} onInput=${(e) => act.setTtFilter("minStock", Number(e.currentTarget.value || 0))}/></label>
        <label><span>Tồn kho</span><select value=${ttFilters.stock} onChange=${(e) => act.setTtFilter("stock", e.currentTarget.value)}>
          <option value="all">Tất cả</option><option value="in">Còn hàng</option>
          <option value="low">Sắp hết (≤50)</option><option value="out">Hết hàng</option></select></label>
        <label><span>Hiển thị</span><select value=${ttFilters.visibility} onChange=${(e) => act.setTtFilter("visibility", e.currentTarget.value)}>
          <option value="all">Tất cả</option><option value="visible">Đang hiện</option><option value="hidden">Đã ẩn</option></select></label>
        <label><span>Tiến độ video</span><select value=${ttFilters.work} onChange=${(e) => act.setTtFilter("work", e.currentTarget.value)}>
          <option value="all">Tất cả</option><option value="todo">Chưa làm</option>
          <option value="done">Đã làm</option><option value="known">Đã vào kho</option></select></label>
      </div>` : null}
      <div class="catalog-summary"><span>${visibleTikTok.length}/${ttProducts.length} đạt bộ lọc</span>
        <button onClick=${() => act.pickTikTok("top5")}>Top 5</button>
        <button onClick=${() => act.pickTikTok("top10")}>Top 10</button>
        <button onClick=${act.clearTikTok}>Bỏ chọn</button>
      </div>
    </section>
    ${ttConfirm ? html`<div class="danger-confirm">
      <div><b>Xóa ${ttConfirm.ids.length} sản phẩm khỏi showcase?</b><span>Không thể hoàn tác trong VeoFlow.</span></div>
      <button onClick=${act.cancelTikTokDelete}>Hủy</button>
      <button class="danger" onClick=${act.confirmTikTokDelete}>Xóa thật</button>
    </div>` : null}
    ${ttAction.running ? html`<div class="catalog-state busy"><span class="spin tiny"></span>
      Đang ${ttAction.action === "delete" ? "xóa" : (ttAction.action === "hide" ? "ẩn" : "hiện")} ${ttAction.count} SP…</div>` : null}
    ${ttImport.running ? html`<div class="catalog-state busy"><span class="spin tiny"></span>
      Đang lấy PDP ${ttImport.done}/${ttImport.total}${ttImport.current ? ` · ${ttImport.current}` : ""}</div>` : null}
    ${ttPreview.product ? (() => {
      const preview = ttPreview.product || {};
      const id = String(preview.tiktok_product_id || preview.product_id || ttPreview.id || "");
      const selected = ttPicks.includes(id);
      const previewDone = done.has(id);
      const images = (preview.image_urls || []).slice(0, 10);
      const source = preview.description_source === "tiktok_pdp"
        ? "TikTok PDP" : (preview.description_source === "tiktok_showcase" ? "Showcase API" : "Tổng hợp dữ liệu thật");
      return html`<div class="card offer-preview tt-preview">
        <div class="preview-head"><div><span class="preview-kicker">CHI TIẾT SẢN PHẨM TIKTOK</span>
          <b>${preview.name || "Sản phẩm TikTok"}</b></div>
          <button onClick=${act.closeTikTokPreview}>×</button></div>
        ${ttPreview.loading ? html`<div class="preview-loading"><span class="spin tiny"></span>Đang fetch PDP ngay tại tab hiện tại…</div>` : null}
        ${ttPreview.error ? html`<div class="catalog-state">${ttPreview.error}</div>` : null}
        <div class="preview-gallery">
          ${images.length ? images.map((url) => html`<div class="preview-image" style="background-image:url('${cleanUrl(url)}')"></div>`)
            : html`<div class="preview-no-image">Chưa có ảnh sản phẩm</div>`}
        </div>
        <div class="preview-stats">
          <span><small>Giá</small><b>${money(preview.price)}</b></span>
          <span><small>Hoa hồng</small><b>${Number(preview.commission_rate || 0).toLocaleString("vi-VN")}%</b></span>
          <span><small>Tiền HH</small><b>${preview.commission_display || preview.commission || "—"}</b></span>
          <span><small>Tồn kho</small><b>${Number(preview.stock || 0).toLocaleString("vi-VN")}</b></span>
        </div>
        <div class="preview-meta">
          <span>Shop: <b>${preview.brand || "—"}</b></span>
          <span>Ngành: <b>${preview.tiktok_category || "—"}</b></span>
          <span>Ảnh lấy được: <b>${images.length}</b></span>
          <span>Mô tả: <b>${source}</b></span>
          <span>ID: <b>${id}</b></span>
          ${preview.is_hide ? html`<span><b>ĐANG ẨN</b></span>` : null}
        </div>
        <div class="preview-description">${preview.description || "TikTok không trả mô tả cho sản phẩm này."}</div>
        <div class="preview-actions">
          ${previewDone ? html`<button class="reimport" disabled=${reimport.running}
            onClick=${() => act.allowReimport("tiktok", [id])}>
            ${IC.redo}${reimport.running ? "Đang mở lại…" : "Bỏ ĐÃ LÀM · nhập lại"}</button>`
            : html`<button class="${selected ? "selected" : ""}" onClick=${() => toggleTt(id)}>
              ${selected ? "✓ Đã chọn để nhập" : "+ Chọn để nhập"}</button>`}
          <span>${previewDone ? "History và video cũ vẫn được giữ; sản phẩm được mở cho một lượt video mới." : "Import dùng dữ liệu PDP này; sản phẩm chưa preview sẽ được fetch tự động."}</span>
        </div>
      </div>`;
    })() : null}
    <div class="product-list">
    ${visibleTikTok.map((it) => {
      const id = String(it.tiktok_product_id || it.product_id || "");
      const picked = ttPicks.includes(id);
      const out = Number(it.stock || 0) <= 0;
      const active = String(ttPreview.id || "") === id;
      const actions = [
        { label: "Xem chi tiết PDP", icon: IC.info, run: () => act.previewTikTok(it) },
        { label: picked ? "Bỏ chọn" : "Chọn để nhập", icon: IC.cart, run: () => toggleTt(id) },
        { label: it.is_hide ? "Hiện lại sản phẩm" : "Ẩn sản phẩm", icon: IC.eye,
          disabled: ttAction.running, run: () => act.manageTikTok(it.is_hide ? "unhide" : "hide", [id]) },
        it.is_done ? { label: "Làm lại sản phẩm", icon: IC.redo, disabled: reimport.running,
          run: () => act.allowReimport("tiktok", [id]) } : null,
        { label: "Xóa khỏi showcase", icon: IC.trash, danger: true, disabled: ttAction.running,
          run: () => act.manageTikTok("delete", [id]) },
      ];
      const status = it.is_done
        ? ProductStatus({ kind: "done", children: "ĐÃ LÀM" })
        : (out ? ProductStatus({ kind: "out", children: "HẾT HÀNG" })
          : (it.is_hide ? ProductStatus({ kind: "hidden", children: "ĐÃ ẨN" })
            : ProductStatus({ kind: "live", children: "ĐANG HIỆN" })));
      return html`<article class="catalog-row tiktok-row ${picked ? "picked" : ""} ${active ? "active" : ""} ${it.is_hide ? "muted" : ""}"
        onClick=${() => act.previewTikTok(it)}>
        <button class="select-box ${picked ? "checked" : ""}"
          onClick=${(e) => { e.stopPropagation(); toggleTt(id); }}>${picked ? "✓" : ""}</button>
        ${ProductThumb({ image: (it.image_urls || [])[0] || "", label: it.name })}
        <div class="product-main"><b>${it.name || "Sản phẩm"}</b>
          <span>${it.brand || "TikTok Shop"} · ID ${id}</span>
          <div class="product-tags">${status}${it.is_known && !it.is_done
            ? ProductStatus({ kind: "known", children: "TRONG KHO" }) : null}</div></div>
        <div class="product-price"><b>${money(it.price)}</b>
          <span class=${out ? "danger-text" : ""}>${out ? "Không còn tồn kho" : `${Number(it.stock || 0).toLocaleString("vi-VN")} tồn`}</span></div>
        <div class="product-commission"><b>${Number(it.commission_rate || 0).toLocaleString("vi-VN")}%</b>
          <span>${it.commission_display || money(it.commission_amount ? `${Number(it.commission_amount).toLocaleString("vi-VN")}₫` : it.commission)}</span></div>
        ${RowMenu({ actions })}
      </article>`;
    })}
    </div>
    ${!visibleTikTok.length && !ttBusy ? Empty({ icon: IC.grid, t: "Không có sản phẩm phù hợp",
      d: ttProducts.length ? "Nới bộ lọc hoặc chọn lại trạng thái." : "Showcase sẽ tự tải khi browser kết nối." }) : null}`;
}

function LinkTab({ vf }) {
  const { links, act } = vf;
  if (!links.length) return Empty({ icon: IC.link, t: "Kho link hoa hồng",
    d: "Không cần tạo link trước. Hãy chọn sản phẩm ở tab Sản phẩm; khi Import, VeoFlow tự gọi Batch Get Link một lần cho cả lô. Tab này chỉ dùng để xem hoặc tạo lại link thủ công.",
    cta: "Tạo lại link cho kho đang chọn", onCta: act.linksCreate });
  return html`<div class="qh"><div class="lbl">Link tiếp thị · ${links.length}</div><span class="a" onClick=${act.exportLinks}>${IC.down}Xuất CSV</span></div>
    ${links.map((l) => html`<div class="item"><div class="ib2"><div class="n">${l.name || l.url}</div>
      <div class="m"><span class="id" style="color:var(--acc)">${l.short || "chưa tạo"}</span></div></div>
      <button class="miniib" title="Copy" onClick=${() => { navigator.clipboard && navigator.clipboard.writeText(l.short || ""); vf.showToast("Đã copy link"); }}>${IC.copy}</button></div>`)}`;
}

function OrdersTab({ vf, platform }) {
  const { orders, act } = vf;
  const site = platform === "tiktok" ? "TikTok" : "Shopee";
  if (!orders.length) return Empty({ icon: IC.receipt, t: "Chưa tải đơn hàng",
    d: `Đọc đơn affiliate từ dashboard ${site} của kênh đang chọn. Chỉ đọc, không đặt/sửa đơn.`, cta: "Tải đơn của kênh này", onCta: act.ordersFetch });
  return html`<div class="qh"><div class="lbl">Đơn hàng · ${orders.length}</div><span class="a" onClick=${act.exportOrders}>${IC.send}Xuất về app</span></div>
    ${orders.map((o) => html`<div class="item"><div class="ib2"><div class="n">${o.product || o.id}</div>
      <div class="m"><span>${money(o.amount)}</span><span>${o.status || ""}</span><span class="id">·${o.id || ""}</span></div></div>
      <span class="st ${o.status === "Hoàn thành" ? "ok" : "run"}">${o.commission || ""}</span></div>`)}`;
}

function Footer({ vf, platform }) {
  const { tab, product, offers, visibleOffers, offerPicks, offerBusy, cart,
    visibleTikTok, ttPicks, ttPolicy, ttAction, ttImport, offerPolicy, reimport, links, act } = vf;
  const offerDone = effectiveDone(offerPolicy);
  const offerDonePicks = offerPicks.filter((id) => offerDone.has(String(id)));
  const eligiblePicks = (visibleOffers || []).filter((x) =>
    offerPicks.includes(x.offer_item_id) && !offerDone.has(String(x.offer_item_id))).length;
  const ttDone = effectiveDone(ttPolicy);
  const ttDonePicks = ttPicks.filter((id) => ttDone.has(String(id)));
  const eligibleTtPicks = (visibleTikTok || []).filter((x) => {
    const id = String(x.tiktok_product_id || x.product_id || "");
    return ttPicks.includes(id) && !ttDone.has(id);
  }).length;
  if (tab === "product" && platform === "shopee" && offers.length) return html`<div class="foot selection-foot">
    <div class="selection-count"><b>${offerPicks.length}</b><span>sản phẩm đã chọn</span></div>
    <button class="btn secondary grow0" disabled=${!offerPicks.length || offerBusy}
      onClick=${act.clearOfferPicks}>Bỏ chọn</button>
    ${offerDonePicks.length ? html`<button class="btn reimport grow0" disabled=${reimport.running || offerBusy}
      onClick=${() => act.allowReimport("shopee", offerDonePicks)}>${IC.redo}Làm lại (${offerDonePicks.length})</button>` : null}
    <button class="btn primary import-button" disabled=${!eligiblePicks || offerBusy} onClick=${act.importOffers}>
      ${IC.send}${offerBusy ? "Đang chuẩn bị…" : `Import ${eligiblePicks} sản phẩm · Auto link`}</button></div>`;
  if (tab === "product" && product) return html`<div class="foot">
    <button class="btn" onClick=${act.addCart}>${IC.plus}Thêm vào giỏ</button>
    <button class="btn primary" disabled=${!cart.length} onClick=${act.sendCart}>${IC.send}Gửi giỏ (${cart.length})</button></div>`;
  if (tab === "showcase") return html`<div class="foot selection-foot">
    <div class="selection-count"><b>${ttPicks.length}</b><span>sản phẩm đã chọn</span></div>
    <button class="btn secondary grow0" title="Ẩn đã chọn"
      disabled=${!ttPicks.length || ttAction.running || ttImport.running}
      onClick=${() => act.manageTikTok("hide")}>${IC.eye}Ẩn</button>
    <details class="bulk-menu">
      <summary class="btn secondary">${IC.dots}Khác</summary>
      <div>
        <button disabled=${!ttPicks.length || ttAction.running || ttImport.running}
          onClick=${() => act.manageTikTok("unhide")}>${IC.eye}Hiện lại đã chọn</button>
        <button class="danger" disabled=${!ttPicks.length || ttAction.running || ttImport.running}
          onClick=${() => act.manageTikTok("delete")}>${IC.trash}Xóa khỏi showcase</button>
      </div>
    </details>
    ${ttDonePicks.length ? html`<button class="btn reimport grow0" disabled=${reimport.running || ttAction.running || ttImport.running}
      onClick=${() => act.allowReimport("tiktok", ttDonePicks)}>${IC.redo}Làm lại (${ttDonePicks.length})</button>` : null}
    <button class="btn primary import-button" disabled=${!eligibleTtPicks || ttAction.running || ttImport.running || reimport.running} onClick=${act.importTikTok}>
      ${IC.send}${ttImport.running ? `Đang lấy PDP ${ttImport.done}/${ttImport.total}` : `Import ${eligibleTtPicks} sản phẩm · Auto PDP`}</button>
  </div>`;
  if (tab === "link" && links.length) return html`<div class="foot"><button class="btn primary" onClick=${act.linksCreate}>${IC.link}Tạo lại link còn thiếu</button></div>`;
  return null;
}

/* ── Root: nhận diện sàn → theme + tab riêng ── */
function Root() {
  const vf = useVf();
  const [platform, setPlatform] = useState(null);
  const [uiTheme, setUiTheme] = useState(() => {
    try { return localStorage.getItem(UI_THEME_KEY) === "light" ? "light" : "dark"; }
    catch { return "dark"; }
  });

  useEffect(() => {
    let alive = true;
    const tick = async () => { const p = await detectPlatform(); if (alive && p) setPlatform((cur) => cur || p); };
    tick();
    const iv = setInterval(tick, 2500);
    return () => { alive = false; clearInterval(iv); };
  }, []);

  useEffect(() => {
    const el = document.getElementById("vf-app");
    el.classList.remove("vf-tt", "vf-shp");
    if (platform) {
      el.classList.add(PLATFORMS[platform].theme);
      vf.setTab(PLATFORMS[platform].def);
      if (platform === "tiktok") setTimeout(vf.act.loadTikTok, 80);
      if (platform === "shopee") setTimeout(vf.act.rescan, 120);
    }
  }, [platform]);

  useEffect(() => {
    const el = document.getElementById("vf-app");
    el.classList.toggle("theme-light", uiTheme === "light");
    el.classList.toggle("theme-dark", uiTheme !== "light");
    try { localStorage.setItem(UI_THEME_KEY, uiTheme); } catch {}
  }, [uiTheme]);

  if (!platform) {
    return html`<div class="panel"><div class="detect">
      <div class="spin"></div>
      <div class="dt">Đang nhận diện trang…</div>
      <div class="dd">Mở tab <b>TikTok Shop</b> hoặc <b>Shopee Affiliate</b> — panel tự đổi theo sàn. Hoặc chọn tay:</div>
      <div class="picks">
        <div class="pk tt" onClick=${() => setPlatform("tiktok")}><span class="dot"></span>TikTok</div>
        <div class="pk shp" onClick=${() => setPlatform("shopee")}><span class="dot"></span>Shopee</div>
      </div>
    </div></div>`;
  }

  const P = PLATFORMS[platform], tab = vf.tab;
  const cnt = (k) => k === "product" ? (vf.offerPicks.length || vf.cart.length)
    : (k === "showcase" ? vf.ttPicks.length : (k === "orders" ? vf.orders.length : 0));

  return html`<div class="panel">
    <div class="head">
      <div class="logo">${P.logo}</div>
      <div class="htx"><div class="t">${P.name}</div><div class="s">${connLine(vf.conn)}</div></div>
      <button class="theme-toggle" title=${uiTheme === "light" ? "Chuyển sang nền tối" : "Chuyển sang nền sáng"}
        onClick=${() => setUiTheme((cur) => cur === "light" ? "dark" : "light")}>
        ${uiTheme === "light" ? IC.moon : IC.sun}
      </button>
      <div class="chan" onClick=${vf.act.channel}><span class="cditem"></span>${vf.channel.label}${IC.chev}</div>
    </div>
    <div class="tabs">
      ${P.tabs.map((tb) => html`<div class="tab ${tab === tb.k ? "on" : ""}" onClick=${() => vf.setTab(tb.k)}>
        ${tb.ic}${tb.t}${cnt(tb.k) ? html`<span class="cnt">${cnt(tb.k)}</span>` : null}${tab === tb.k ? html`<span class="ink"></span>` : null}
      </div>`)}
    </div>
    <div class="body stagger" key=${tab}>
      ${tab === "showcase" && ShowcaseTab({ vf })}
      ${tab === "link" && LinkTab({ vf })}
      ${tab === "product" && ProductTab({ vf, platform })}
      ${tab === "orders" && OrdersTab({ vf, platform })}
    </div>
    ${Footer({ vf, platform })}
    <div class="toast ${vf.toast ? "show" : ""}">${vf.toast}</div>
  </div>`;
}

render(html`<${Root} />`, document.getElementById("vf-app"));
