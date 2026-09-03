// side_panel.js — WS transport + bridge window.__vf cho app.js (P1).
//
// Chạy TRƯỚC app.js: định nghĩa window.__vf (send/on/recv) backed bằng WebSocket, để
// app.js gặp __vf sẵn → dùng bridge WS thay vì poll (dòng `window.__vf = window.__vf || …`).
// Protocol v2 giữ nguyên → app router (_route_overlay_message) không đổi.
//
// Bảo mật: app WS chỉ nhận Origin chrome-extension://<id-cố-định> (xem panel_ws_server.py).
// Panel chỉ cần biết PORT; không token.

(() => {
  "use strict";
  const WS_URL = "ws://127.0.0.1:47821";
  const RECONNECT_MS = 1500;

  let ws = null;
  let seq = 1;
  let closedByUs = false;
  let attempts = 0;               // backoff: origin sai → giãn dần, không spam 1.5s/lần
  const outbox = [];              // hàng đợi khi WS chưa mở
  const handlers = {};            // type -> [fn]
  let observedPageFingerprint = "";
  let pageProbeBusy = false;

  // ── bridge window.__vf (app.js dùng) ──────────────────────────────────────
  const BRIDGE = window.__vf = {
    send(type, payload) {
      const frame = JSON.stringify({ v: 2, id: seq++, type, payload: payload || {}, ok: true });
      if (ws && ws.readyState === WebSocket.OPEN) ws.send(frame);
      else { if (outbox.length >= 500) outbox.shift(); outbox.push(frame); }  // cap: WS chết không phình RAM
    },
    on(type, fn) { (handlers[type] = handlers[type] || []).push(fn); },
    recv(msg) {
      try { msg = typeof msg === "string" ? JSON.parse(msg) : msg; } catch { return; }
      if (!msg || msg.v !== 2) return;
      (handlers[msg.type] || []).forEach(fn => { try { fn(msg.payload || {}); } catch (e) {} });
    },
  };

  // ── bóc SP trên TAB đang xem qua content-script (async, read-only) ─────────
  window.__vfExtract = async function () {
    try {
      const tabs = await chrome.tabs.query({ active: true, lastFocusedWindow: true });
      const tab = tabs && tabs[0];
      if (!tab || !tab.id) return null;
      const resp = await chrome.tabs.sendMessage(tab.id, { type: "PAGE_EXTRACT" });
      return resp && resp.ok ? resp.data : null;
    } catch (e) {
      return null;   // content-script chưa inject / tab không match host
    }
  };

  // ── connection status (header nhỏ trong html shell) ───────────────────────
  const dot = document.getElementById("vf-conn-dot");
  const stateEl = document.getElementById("vf-conn-state");
  function setConn(cls, text) {
    if (dot) dot.className = cls;
    if (stateEl) stateEl.textContent = text;
  }

  function connect() {
    setConn("", "đang nối app…");
    try { ws = new WebSocket(WS_URL); }
    catch (e) { scheduleReconnect(); return; }

    ws.onopen = () => {
      attempts = 0;               // nối được → reset backoff
      setConn("on", "đã nối app");
      while (outbox.length && ws.readyState === WebSocket.OPEN) ws.send(outbox.shift());
      BRIDGE.send("OVERLAY_READY", { panel: "affiliate", url: "side-panel" });
    };
    ws.onmessage = (ev) => BRIDGE.recv(ev.data);
    ws.onclose = () => { setConn("off", "mất kết nối"); if (!closedByUs) scheduleReconnect(); };
    ws.onerror = () => { try { ws.close(); } catch {} };
  }
  function scheduleReconnect() {
    attempts++;
    // Giãn dần 1.5s → tối đa 30s (origin sai/ext chưa load thì đừng hammer mỗi 1.5s).
    const delay = Math.min(RECONNECT_MS * Math.pow(1.7, Math.min(attempts, 8)), 30000);
    setTimeout(() => { if (!closedByUs) connect(); }, delay);
  }
  window.addEventListener("beforeunload", () => { closedByUs = true; try { ws && ws.close(); } catch {} });

  // Active tab/navigation → panel tự đọc lại, không bắt user bấm "Quét" mỗi lần.
  // Chỉ phát event nội bộ; app.js quyết định trang nào cần tải catalog.
  let tabNotifyTimer = 0;
  function notifyTabChanged() {
    clearTimeout(tabNotifyTimer);
    tabNotifyTimer = setTimeout(() => window.dispatchEvent(new CustomEvent("vf-active-tab-changed")), 450);
  }
  function pageFingerprint(data) {
    if (!data) return "";
    const kind = String(data.kind || "");
    const url = String(data.url || "");
    if (kind === "shopee_offer_list") {
      const ids = (data.products || []).map((row) => String(row && row.offer_item_id || "")).filter(Boolean);
      return [kind, url, String(data.list_api_url || ""), ids.join(",")].join("|");
    }
    return [
      kind,
      url,
      String(data.name || ""),
      (data.image_urls || []).slice(0, 3).join(","),
    ].join("|");
  }
  async function probeActivePage() {
    if (pageProbeBusy) return;
    pageProbeBusy = true;
    try {
      const data = await window.__vfExtract();
      const next = pageFingerprint(data);
      if (!next) return;
      if (observedPageFingerprint && next !== observedPageFingerprint) notifyTabChanged();
      observedPageFingerprint = next;
    } catch {}
    finally { pageProbeBusy = false; }
  }
  try {
    chrome.tabs.onActivated.addListener(notifyTabChanged);
    chrome.tabs.onUpdated.addListener((_id, info, tab) => {
      if (tab && tab.active && (info.status === "complete" || info.url)) notifyTabChanged();
    });
  } catch {}

  connect();
  // Shopee đổi All/XTRA/Top Performing bằng SPA, không kích hoạt Chrome tab
  // event. Probe thưa, chỉ đọc DOM và chỉ rescan khi fingerprint thực sự đổi.
  // app.js đã tự quét lần đầu nên không phát thêm event khởi động trùng lặp.
  setInterval(probeActivePage, 3000);
})();
