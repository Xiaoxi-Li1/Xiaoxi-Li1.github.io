(function () {
  'use strict';

  function parseCount(label) {
    if (typeof label !== 'string') return null;
    var match = label.trim().match(/^((?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?)\s*([kmb])?$/i);
    if (!match) return null;
    var scale = { k: 1000, m: 1000000, b: 1000000000 };
    var count = Number(match[1].replace(/,/g, '')) * (scale[(match[2] || '').toLowerCase()] || 1);
    return Number.isFinite(count) && count >= 0 ? count : null;
  }

  function updateStars(metric) {
    var controller = new AbortController();
    var timeout = setTimeout(function () { controller.abort(); }, 8000);
    fetch(metric.dataset.starSource, { signal: controller.signal })
      .then(function (response) {
        if (!response.ok) throw new Error('GitHub star statistics unavailable');
        return response.json();
      })
      .then(function (data) {
        var count = parseCount(data.message);
        if (count === null) return;
        metric.querySelector('[data-github-stars]').textContent = data.message;
        var threshold = Number(metric.dataset.starThreshold);
        metric.hidden = count <= (Number.isFinite(threshold) ? threshold : 0);
        var emphasisThreshold = Number(metric.dataset.emphasisThreshold);
        metric.classList.toggle('publication__metric--emphasized', count >= (Number.isFinite(emphasisThreshold) ? emphasisThreshold : 1000));
      })
      .catch(function () { /* Keep the last valid rendered snapshot, not a false zero. */ })
      .finally(function () { clearTimeout(timeout); });
  }

  var metrics = document.querySelectorAll('[data-star-metric]');
  if (!('IntersectionObserver' in window)) {
    metrics.forEach(updateStars);
    return;
  }

  // Observe the card, since a below-threshold metric itself is hidden.
  var observer = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (!entry.isIntersecting) return;
      observer.unobserve(entry.target);
      updateStars(entry.target.querySelector('[data-star-metric]'));
    });
  }, { rootMargin: '400px' });
  metrics.forEach(function (metric) {
    observer.observe(metric.closest('.publication'));
  });
})();
