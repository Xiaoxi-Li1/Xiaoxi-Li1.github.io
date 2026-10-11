(function () {
  'use strict';

  var SITE_ORIGIN = 'https://xiaoxi-li1.github.io';
  var SITE_HOST = 'xiaoxi-li1.github.io';
  var SESSION_KEY = 'visitor-observatory:tab:v1';
  var SESSION_IDLE_MS = 30 * 60 * 1000;
  var HEARTBEAT_MS = 30 * 1000;
  var RETRY_MS = 1000;
  var UUID_V4 = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  var script = document.currentScript;
  var endpoint;
  var session = null;
  var pageviewIssued = false;
  var heartbeatTimer = null;
  var pageActive = true;

  function localHostname(host) {
    return host === 'localhost' || /\.localhost$/.test(host) ||
      /^127\./.test(host) || host === '[::1]' || host === '0.0.0.0';
  }

  function allowed() {
    var nav = window.navigator;
    var dnt = [nav.doNotTrack, nav.msDoNotTrack, window.doNotTrack];
    return window.location.protocol === 'https:' &&
      window.location.origin === SITE_ORIGIN &&
      window.location.pathname === '/' &&
      nav.webdriver !== true && nav.globalPrivacyControl !== true &&
      !dnt.some(function (value) {
        return value === true || /^(1|yes)$/i.test(String(value));
      });
  }

  // A fixed production origin prevents Jekyll previews from becoming collectors.
  if (!script || script.getAttribute('data-site-origin') !== SITE_ORIGIN || !allowed()) return;
  if (window.__visitorObservatoryTrackerV1 || typeof window.fetch !== 'function') return;

  try {
    endpoint = new URL(script.getAttribute('data-endpoint'));
    var endpointHost = endpoint.hostname.toLowerCase().replace(/\.$/, '');
    if (endpoint.protocol !== 'https:' || endpoint.pathname !== '/collect' ||
        endpoint.username || endpoint.password || /[?#]/.test(endpoint.href) ||
        localHostname(endpointHost)) return;
    if (!window.crypto ||
        (typeof window.crypto.randomUUID !== 'function' &&
         typeof window.crypto.getRandomValues !== 'function')) return;
  } catch (error) {
    return;
  }

  window.__visitorObservatoryTrackerV1 = true;

  function randomId() {
    if (typeof window.crypto.randomUUID === 'function') return window.crypto.randomUUID();
    var bytes = new Uint8Array(16);
    window.crypto.getRandomValues(bytes);
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    var hex = Array.prototype.map.call(bytes, function (byte) {
      return ('0' + byte.toString(16)).slice(-2);
    }).join('');
    return hex.slice(0, 8) + '-' + hex.slice(8, 12) + '-' + hex.slice(12, 16) +
      '-' + hex.slice(16, 20) + '-' + hex.slice(20);
  }

  function sessionId(now) {
    if (!session) {
      try {
        session = JSON.parse(window.sessionStorage.getItem(SESSION_KEY));
      } catch (error) {
        session = null;
      }
    }
    if (!session || !UUID_V4.test(session.id) ||
        typeof session.lastSeen !== 'number' || !isFinite(session.lastSeen) ||
        session.lastSeen > now || now - session.lastSeen >= SESSION_IDLE_MS) {
      session = { id: randomId(), lastSeen: now };
    }
    session.lastSeen = now;
    try {
      window.sessionStorage.setItem(SESSION_KEY, JSON.stringify(session));
    } catch (error) {
      // Storage denial leaves only this document's short-lived, in-memory session.
    }
    return session.id;
  }

  function webAddress(raw, base) {
    try {
      var url = base ? new URL(raw, base) : new URL(raw);
      var host = url.hostname.toLowerCase().replace(/\.$/, '');
      if ((url.protocol !== 'http:' && url.protocol !== 'https:') ||
          url.username || url.password || !host || host.length > 253 ||
          localHostname(host) || host.charAt(0) === '[' ||
          /^\d+(?:\.\d+){3}$/.test(host)) return null;
      return host;
    } catch (error) {
      return null;
    }
  }

  var referrer = webAddress(document.referrer);
  var source = referrer && referrer !== SITE_HOST ? referrer : 'direct';

  function visibleAndAllowed() {
    return pageActive && document.visibilityState === 'visible' && allowed();
  }

  function send(payload, mayRetry) {
    if (!visibleAndAllowed()) return;

    function retry() {
      if (!mayRetry) return;
      window.setTimeout(function () {
        // Never retry a hidden page or mint a new event ID for a network retry.
        if (visibleAndAllowed()) send(payload, false);
      }, RETRY_MS);
    }

    try {
      Promise.resolve(window.fetch(endpoint.href, {
        method: 'POST',
        headers: { 'Content-Type': 'text/plain' },
        body: JSON.stringify(payload),
        mode: 'cors',
        credentials: 'omit',
        referrerPolicy: 'no-referrer',
        cache: 'no-store',
        keepalive: true
      })).then(function (response) {
        if (!response.ok && (response.status === 408 ||
            response.status === 429 || response.status >= 500)) retry();
      }, retry);
    } catch (error) {
      retry();
    }
  }

  function emit(type, target) {
    if (!visibleAndAllowed()) return;
    var now = Date.now();
    var payload;
    try {
      payload = {
        v: 1,
        type: type,
        eventId: randomId(),
        sessionId: sessionId(now),
        sentAt: now,
        path: '/',
        referrer: source,
        target: target || ''
      };
    } catch (error) {
      return;
    }
    send(payload, type === 'pageview');
  }

  function stopHeartbeat() {
    if (heartbeatTimer !== null) {
      window.clearInterval(heartbeatTimer);
      heartbeatTimer = null;
    }
  }

  function syncVisibility() {
    stopHeartbeat();
    if (!visibleAndAllowed()) return;
    if (!pageviewIssued) {
      pageviewIssued = true;
      emit('pageview');
    }
    heartbeatTimer = window.setInterval(function () {
      if (visibleAndAllowed()) emit('heartbeat');
      else stopHeartbeat();
    }, HEARTBEAT_MS);
  }

  document.addEventListener('visibilitychange', syncVisibility);
  window.addEventListener('pagehide', function () {
    pageActive = false;
    stopHeartbeat();
  });
  window.addEventListener('pageshow', function () {
    pageActive = true;
    syncVisibility();
  });
  document.addEventListener('click', function (event) {
    if (!visibleAndAllowed() || event.isTrusted === false || event.defaultPrevented ||
        (typeof event.button === 'number' && event.button !== 0)) return;
    var element = event.target;
    if (element && typeof element.closest !== 'function') element = element.parentElement;
    var anchor = element && typeof element.closest === 'function' ? element.closest('a[href]') : null;
    if (!anchor) return;
    var target = webAddress(anchor.getAttribute('href'), document.baseURI || window.location.href);
    if (target && target !== SITE_HOST) emit('click', target);
  }, { passive: true });

  syncVisibility();
})();
