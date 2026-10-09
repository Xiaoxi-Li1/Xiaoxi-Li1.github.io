(function () {
  'use strict';

  var footer = document.getElementById('footer');
  if (!footer) return;
  var siteOrigin;
  try {
    siteOrigin = new URL(footer.dataset.siteOrigin).origin;
  } catch (error) {
    return;
  }

  // Preview visits must not pollute analytics or display localhost counters.
  if (window.location.protocol !== 'https:' || window.location.origin !== siteOrigin) return;
  footer.hidden = false;

  var traffic = footer.querySelector('.site-traffic');
  var value = traffic && traffic.querySelector('#busuanzi_value_site_pv');
  if (!value) return;
  var observer = new MutationObserver(function () {
    var text = value.textContent.trim();
    if (!/^\d+$/.test(text) || !Number.isSafeInteger(Number(text))) return;
    traffic.hidden = false;
    stopWaiting();
  });
  var timeout = setTimeout(stopWaiting, 10000);
  function stopWaiting() {
    observer.disconnect();
    clearTimeout(timeout);
  }
  observer.observe(traffic, { childList: true, subtree: true, characterData: true });

  var counter = document.createElement('script');
  counter.src = 'https://busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js';
  counter.async = true;
  counter.addEventListener('error', stopWaiting, { once: true });
  document.head.appendChild(counter);

  var mapContainer = footer.querySelector('[data-visitor-map]');
  if (mapContainer && mapContainer.dataset.mapSource) {
    var map = document.createElement('script');
    map.id = 'clustrmaps';
    map.src = mapContainer.dataset.mapSource;
    map.async = true;
    mapContainer.appendChild(map);
  }
})();
