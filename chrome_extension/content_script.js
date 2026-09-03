// content_script.js — phần DUY NHẤT chạm trang. Isolated world.
//
// NGUYÊN TẮC: READ-ONLY, KHÔNG chèn node cố định vào DOM trang (isolated world giấu
// BIẾN chứ không giấu NODE — chèn node là trang thấy). P0 chỉ đọc URL/title khi panel
// hỏi. Việc chọn SP diễn ra trong side panel, trang chỉ bị ĐỌC.
//
// Kênh: content-script ↔ panel qua chrome.runtime (nội bộ extension, app không thấy).
// PAGE_EXTRACT = đọc DOM trang trả về panel. Không gọi ra app.

(() => {
  "use strict";

  const txt = (el) => String((el && (el.innerText || el.textContent)) || "").trim();
  const abs = (u) => {
    try { return new URL(String(u || ""), location.href).href; } catch { return String(u || ""); }
  };

  function latestOfferListApi() {
    try {
      const urls = performance.getEntriesByType("resource")
        .map((e) => String(e.name || ""))
        .filter((u) => u.includes("/api/v3/offer/product/list?"));
      return urls.length ? urls[urls.length - 1] : "";
    } catch { return ""; }
  }

  function extractOfferList() {
    const cards = Array.from(document.querySelectorAll(".AffiliateItemCard"));
    if (!cards.length) return null;
    const products = cards.map((card, index) => {
      const anchor = card.querySelector('a[target="_blank"], a[href*="/offer/product_offer/"]');
      const href = abs(anchor && anchor.getAttribute("href"));
      const idMatch = href.match(/\/offer\/product_offer\/(\d+)/);
      const commText = txt(card.querySelector(".commRate"));
      const commMatch = commText.replace(",", ".").match(/([\d.]+)\s*%/);
      const img = card.querySelector(".ItemCard__image img, img");
      const soldText = txt(card.querySelector(".ItemCardSold__wrap"));
      const soldMatch = soldText.toLowerCase().replace(",", ".").match(/([\d.]+)\s*([km]?)/);
      const soldScale = soldMatch && soldMatch[2] === "m" ? 1000000 : (soldMatch && soldMatch[2] === "k" ? 1000 : 1);
      const priceText = txt(card.querySelector(".ItemCard__price"));
      return {
        offer_item_id: idMatch ? idMatch[1] : "",
        name: txt(card.querySelector(".ItemCard__name")),
        price: Number(priceText.replace(/[^\d]/g, "") || 0),
        price_text: priceText,
        sold: soldText,
        sold_count: soldMatch ? Math.round(Number(soldMatch[1]) * soldScale) : 0,
        commission: commText,
        commission_rate: commMatch ? Number(commMatch[1]) : 0,
        discount: txt(card.querySelector(".DiscountBadge__discount")),
        image: abs(img && (img.currentSrc || img.src)),
        offer_url: href,
        dom_index: index,
      };
    }).filter((p) => p.offer_item_id && p.name);
    products.sort((a, b) => b.commission_rate - a.commission_rate || a.dom_index - b.dom_index);
    return {
      kind: "shopee_offer_list",
      products,
      list_api_url: latestOfferListApi(),
    };
  }

  function extractProductPage() {
    const metas = {};
    document.querySelectorAll("meta[property], meta[name]").forEach((m) => {
      const key = m.getAttribute("property") || m.getAttribute("name");
      if (key) metas[key] = m.getAttribute("content") || "";
    });
    let ld = {};
    for (const node of document.querySelectorAll('script[type="application/ld+json"]')) {
      try {
        const raw = JSON.parse(node.textContent || "{}");
        const rows = Array.isArray(raw) ? raw : [raw];
        const hit = rows.find((x) => x && (x["@type"] === "Product" || x.name));
        if (hit) { ld = hit; break; }
      } catch {}
    }
    const images = [];
    const pushImage = (u) => {
      u = abs(u);
      if (/^https?:/i.test(u) && !images.includes(u)) images.push(u);
    };
    const ldImages = Array.isArray(ld.image) ? ld.image : [ld.image];
    ldImages.forEach(pushImage);
    pushImage(metas["og:image"]);
    document.querySelectorAll('img[src], img[srcset]').forEach((img) => {
      const r = img.getBoundingClientRect();
      if (r.width >= 180 && r.height >= 180) pushImage(img.currentSrc || img.src);
    });
    const name = String(ld.name || metas["og:title"] || txt(document.querySelector("h1")) || document.title).trim();
    const desc = String(ld.description || metas.description || metas["og:description"] || "").trim();
    const offers = ld.offers || {};
    return {
      kind: "product",
      name,
      price: String(offers.price || metas["product:price:amount"] || ""),
      brand: typeof ld.brand === "object" ? String(ld.brand.name || "") : String(ld.brand || ""),
      description: desc,
      image_urls: images.slice(0, 20),
      url: location.href,
    };
  }

  function shopeePageState() {
    const host = String(location.host || "").toLowerCase();
    const path = String(location.pathname || "").replace(/\/+$/, "") || "/";
    if (!host.includes("shopee.")) return null;
    if (/^\/(?:verify|buyer\/login)(?:\/|$)/i.test(path)) {
      return {
        kind: "shopee_page_unavailable",
        reason: path.toLowerCase().includes("/verify/") ? "traffic_error" : "login",
      };
    }
    if (host.startsWith("affiliate.") && path === "/offer/product_offer") {
      return {
        kind: "shopee_offer_pending",
        list_api_url: latestOfferListApi(),
      };
    }
    return null;
  }

  function extractReadOnly() {
    const offer = /affiliate\.shopee\./i.test(location.host) &&
      /\/offer\/product_offer\/?$/.test(location.pathname) ? extractOfferList() : null;
    if (offer) return { ...offer, url: location.href, host: location.host, title: document.title, ts: Date.now() };
    const pageState = shopeePageState();
    if (pageState) {
      return {
        ...pageState,
        url: location.href,
        host: location.host,
        title: document.title,
        ts: Date.now(),
      };
    }
    const product = extractProductPage();
    return {
      ...product,
      url: location.href,
      host: location.host,
      title: document.title,
      ts: Date.now(),
    };
  }

  chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
    if (!msg || msg.type !== "PAGE_EXTRACT") return false;
    try {
      sendResponse({ ok: true, data: extractReadOnly() });
    } catch (e) {
      sendResponse({ ok: false, error: String(e) });
    }
    return true; // async-safe
  });
})();
