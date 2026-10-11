(function () {
  'use strict';

  var SITE_ORIGIN = 'https://xiaoxi-li1.github.io';
  var BEACON_ORIGIN = 'https://static.cloudflareinsights.com';
  var BEACON_PATH = '/beacon.min.js';
  var script = document.currentScript;
  var nav = window.navigator;
  if (!script || !nav || !document.head) return;

  var token = script.getAttribute('data-site-token');
  var dnt = [nav.doNotTrack, nav.msDoNotTrack, window.doNotTrack];
  if (script.getAttribute('data-site-origin') !== SITE_ORIGIN ||
      window.location.protocol !== 'https:' || window.location.origin !== SITE_ORIGIN ||
      window.location.pathname !== '/' || !/^[a-f0-9]{32}$/i.test(token || '') ||
      nav.webdriver === true || nav.globalPrivacyControl === true ||
      dnt.some(function (value) {
        return value === true || /^(1|yes)$/i.test(String(value));
      })) return;
  if (window.__homepageCloudflareAnalytics) return;

  var scripts = document.querySelectorAll('script[src]');
  for (var index = 0; index < scripts.length; index++) {
    try {
      var url = new URL(scripts[index].src || scripts[index].getAttribute('src'), window.location.href);
      if (url.origin === BEACON_ORIGIN && url.pathname === BEACON_PATH) return;
    } catch (error) {}
  }

  var beacon = document.createElement('script');
  beacon.type = 'module';
  beacon.src = BEACON_ORIGIN + BEACON_PATH;
  beacon.setAttribute('data-cf-beacon', JSON.stringify({ token: token }));
  window.__homepageCloudflareAnalytics = true;
  document.head.appendChild(beacon);
})();
