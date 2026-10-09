(function () {
  'use strict';

  var dialog = document.getElementById('publication-figure');
  if (!dialog || typeof dialog.showModal !== 'function') return;
  var trigger = null;

  document.querySelectorAll('.publication__figure').forEach(function (link) {
    link.addEventListener('click', function (event) {
      if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
      event.preventDefault();
      trigger = link;
      dialog.querySelector('#figure-title').textContent = link.dataset.figureTitle;
      dialog.querySelector('#figure-caption').textContent = link.dataset.figureCaption;
      dialog.querySelector('#figure-source').href = link.dataset.figureSource;
      var image = dialog.querySelector('.figure-dialog__image');
      image.src = link.href;
      image.alt = link.querySelector('img').alt;
      dialog.showModal();
      document.body.classList.add('figure-open');
    });
  });

  dialog.querySelector('.figure-dialog__close').addEventListener('click', function () {
    dialog.close();
  });
  dialog.addEventListener('click', function (event) {
    if (event.target === dialog) dialog.close();
  });
  dialog.addEventListener('close', function () {
    document.body.classList.remove('figure-open');
    if (trigger) trigger.focus({ preventScroll: true });
  });
})();
