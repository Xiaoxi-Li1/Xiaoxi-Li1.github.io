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
  if (footer.dataset.trafficLoaded === 'true') return;
  footer.dataset.trafficLoaded = 'true';

  var counter = document.createElement('script');
  counter.src = 'https://busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js';
  counter.async = true;
  document.head.appendChild(counter);

  var badge = footer.querySelector('[data-visitor-badge]');
  if (badge && badge.dataset.badgeSource) {
    badge.addEventListener('load', function () {
      if (badge.naturalWidth > 0) badge.parentElement.hidden = false;
    }, { once: true });
    badge.src = badge.dataset.badgeSource;
  }
})();
