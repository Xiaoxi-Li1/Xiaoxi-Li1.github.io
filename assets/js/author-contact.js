(function () {
  'use strict';

  function legacyCopy(value) {
    var active = document.activeElement;
    var selection = window.getSelection();
    var ranges = [];
    for (var index = 0; selection && index < selection.rangeCount; index++) {
      ranges.push(selection.getRangeAt(index).cloneRange());
    }
    var field = document.createElement('textarea');
    field.value = value;
    field.readOnly = true;
    field.style.cssText = 'position:fixed;top:0;left:0;width:1px;height:1px;padding:0;border:0;opacity:0;font-size:16px';
    document.body.appendChild(field);
    try {
      field.focus({ preventScroll: true });
      field.select();
      field.setSelectionRange(0, value.length);
      return document.execCommand('copy') === true;
    } catch (error) {
      return false;
    } finally {
      field.remove();
      if (active && typeof active.focus === 'function') active.focus({ preventScroll: true });
      if (selection) {
        selection.removeAllRanges();
        ranges.forEach(function (range) { selection.addRange(range); });
      }
    }
  }

  document.querySelectorAll('[data-copy-wechat]').forEach(function (button) {
    var status = button.closest('[data-wechat-contact]').querySelector('[data-copy-status]');
    var resetTimer;
    var pending = false;

    function finish(copied) {
      pending = false;
      status.textContent = copied ? 'Copied: ' + button.dataset.copyWechat : 'Copy manually:';
      status.dataset.copyState = copied ? 'success' : 'manual';
      if (copied) {
        resetTimer = window.setTimeout(function () { status.textContent = ''; }, 3000);
      } else {
        var field = document.createElement('input');
        field.type = 'text';
        field.readOnly = true;
        field.value = button.dataset.copyWechat;
        field.className = 'author__copy-value';
        field.setAttribute('aria-label', 'WeChat ID, select and copy manually');
        field.addEventListener('focus', function () { field.select(); });
        status.appendChild(field);
        if (document.activeElement === button) {
          field.focus({ preventScroll: true });
          field.select();
        }
      }
    }

    button.addEventListener('click', function () {
      if (pending) return;
      pending = true;
      window.clearTimeout(resetTimer);
      status.textContent = '';
      var value = button.dataset.copyWechat;
      try {
        if (navigator.clipboard && typeof navigator.clipboard.writeText === 'function') {
          navigator.clipboard.writeText(value).then(function () {
            finish(true);
          }, function () {
            finish(legacyCopy(value));
          });
          return;
        }
      } catch (error) {
        finish(legacyCopy(value));
        return;
      }
      finish(legacyCopy(value));
    });
  });
})();
