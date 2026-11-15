(function () {
  'use strict';

  var button = document.querySelector('[data-about-language-toggle]');
  var biography = document.getElementById('about-biography');
  if (!button || !biography) return;

  var english = biography.querySelector('#about-en');
  var chinese = biography.querySelector('#about-zh');
  if (!english || !chinese) return;

  var metrics = english.querySelector('.profile-metrics');
  var englishSlot = metrics && metrics.parentElement;
  var chineseSlot = chinese.querySelector('p[data-profile-metrics-slot]');
  if (!englishSlot || englishSlot.tagName !== 'P' || !chineseSlot) return;

  var prose = ['lead', 'and', 'end'].map(function (key) {
    return metrics.querySelector('[data-profile-prose="' + key + '"]');
  });
  if (prose.some(function (node) { return !node; })) return;

  var englishProse = prose.map(function (node) { return node.textContent; });
  var chineseProse = [
    '\u6211\u7684\u7814\u7a76\u548c\u5f00\u6e90\u9879\u76ee\u5df2\u83b7\u5f97 ',
    ' \u548c ',
    '\u3002'
  ];
  var showingChinese = false;

  button.addEventListener('click', function () {
    showingChinese = !showingChinese;
    var nextProse = showingChinese ? chineseProse : englishProse;
    (showingChinese ? chineseSlot : englishSlot).appendChild(metrics);
    prose.forEach(function (node, index) { node.textContent = nextProse[index]; });
    english.hidden = showingChinese;
    chinese.hidden = !showingChinese;
    biography.lang = showingChinese ? 'zh-CN' : 'en';
    button.textContent = showingChinese ? 'English Version' : '\u4e2d\u6587\u7248';
    button.lang = showingChinese ? 'en' : 'zh-CN';
  });

  button.hidden = false;
})();
