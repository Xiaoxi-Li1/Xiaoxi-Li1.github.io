#!/usr/bin/env node

import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';

const SITE_ORIGIN = 'https://xiaoxi-li1.github.io';
const SITE_TOKEN = '7717b496fc2144c7a752adbade5ad7df';
const LOADER_PATH = '/assets/js/cloudflare-web-analytics.js';
const BEACON_URL = 'https://static.cloudflareinsights.com/beacon.min.js';
const SOURCE_PATH = fileURLToPath(new URL(`..${LOADER_PATH}`, import.meta.url));

let checks = 0;
const failures = [];

function check(name, callback) {
  checks += 1;
  try {
    callback();
  } catch (error) {
    failures.push(`${name}: ${error.message}`);
  }
}

function matches(element, selector) {
  let remaining = selector.trim();
  const tag = /^[a-z][\w-]*/i.exec(remaining);
  if (tag) {
    if (element.tagName !== tag[0].toUpperCase()) return false;
    remaining = remaining.slice(tag[0].length);
  }
  while (remaining) {
    const id = /^#([\w-]+)/.exec(remaining);
    if (id) {
      if (element.id !== id[1]) return false;
      remaining = remaining.slice(id[0].length);
      continue;
    }
    const attribute = /^\[\s*([\w:-]+)\s*(?:(\^=|\$=|\*=|=)\s*(?:"([^"]*)"|'([^']*)'|([^\]\s]+))\s*)?\]/.exec(remaining);
    assert.ok(attribute, `Unsupported fake-DOM selector: ${selector}`);
    const actual = element.getAttribute(attribute[1]);
    const expected = attribute[3] ?? attribute[4] ?? attribute[5];
    if (actual === null) return false;
    if (attribute[2] === '=' && actual !== expected) return false;
    if (attribute[2] === '^=' && !actual.startsWith(expected)) return false;
    if (attribute[2] === '$=' && !actual.endsWith(expected)) return false;
    if (attribute[2] === '*=' && !actual.includes(expected)) return false;
    remaining = remaining.slice(attribute[0].length);
  }
  return true;
}

function browser(options = {}) {
  const location = new URL(options.url ?? `${SITE_ORIGIN}/`);
  const inserted = [];
  const forbiddenAccesses = [];
  let recording = false;
  const forbidden = (name) => () => {
    forbiddenAccesses.push(name);
    throw new Error(`Forbidden browser API: ${name}`);
  };

  class Element {
    constructor(tagName, attributes = {}) {
      this.tagName = tagName.toUpperCase();
      this.children = [];
      this.parentNode = null;
      this.attributes = new Map();
      for (const [name, value] of Object.entries(attributes)) {
        if (value !== null && value !== undefined) this.setAttribute(name, value);
      }
      this.dataset = new Proxy({}, {
        get: (_, name) => this.getAttribute(`data-${String(name).replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`)}`) ?? undefined,
        set: (_, name, value) => {
          this.setAttribute(`data-${String(name).replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`)}`, value);
          return true;
        }
      });
    }

    setAttribute(name, value) { this.attributes.set(name.toLowerCase(), String(value)); }
    getAttribute(name) { return this.attributes.get(name.toLowerCase()) ?? null; }
    hasAttribute(name) { return this.attributes.has(name.toLowerCase()); }
    removeAttribute(name) { this.attributes.delete(name.toLowerCase()); }
    get src() {
      const source = this.getAttribute('src');
      if (source === null) return '';
      try { return new URL(source, location.href).href; } catch { return source; }
    }
    set src(value) { this.setAttribute('src', value); }
    get type() { return this.getAttribute('type') ?? ''; }
    set type(value) { this.setAttribute('type', value); }
    get id() { return this.getAttribute('id') ?? ''; }
    set id(value) { this.setAttribute('id', value); }
    appendChild(child) {
      this.children.push(child);
      child.parentNode = this;
      if (recording) inserted.push({ parent: this, element: child });
      return child;
    }
    append(...children) { children.forEach((child) => this.appendChild(child)); }
    querySelectorAll(selector) {
      const descendants = this.children.flatMap((child) => [child, ...child.descendants()]);
      return descendants.filter((element) => selector.split(',').some((part) => matches(element, part)));
    }
    querySelector(selector) { return this.querySelectorAll(selector)[0] ?? null; }
    descendants() { return this.children.flatMap((child) => [child, ...child.descendants()]); }
  }

  const head = new Element('head');
  const body = new Element('body');
  const root = new Element('html');
  root.append(head, body);
  const loaderAttributes = {
    src: LOADER_PATH,
    defer: '',
    'data-site-token': SITE_TOKEN,
    'data-site-origin': SITE_ORIGIN,
    ...options.attributes
  };
  const loader = new Element('script', loaderAttributes);
  body.appendChild(loader);
  for (const attributes of options.existingScripts ?? []) {
    head.appendChild(new Element('script', attributes));
  }
  const document = {
    currentScript: options.missingScript ? null : loader,
    head: options.missingHead ? null : head,
    body,
    documentElement: root,
    location,
    baseURI: location.href,
    createElement: (tag) => new Element(tag),
    querySelectorAll: (selector) => root.querySelectorAll(selector),
    querySelector: (selector) => root.querySelector(selector),
    getElementsByTagName: (tag) => root.querySelectorAll(tag),
    getElementById: (id) => root.descendants().find((element) => element.id === id) ?? null,
    get scripts() { return root.querySelectorAll('script'); }
  };
  Object.defineProperty(document, 'cookie', { get: forbidden('document.cookie'), set: forbidden('document.cookie') });
  const navigator = options.missingNavigator ? undefined : {
    webdriver: false,
    globalPrivacyControl: false,
    ...options.navigator,
    sendBeacon: forbidden('navigator.sendBeacon')
  };
  const sandbox = {
    document, navigator, location, URL,
    doNotTrack: options.windowDnt,
    fetch: forbidden('fetch'),
    XMLHttpRequest: forbidden('XMLHttpRequest'),
    WebSocket: forbidden('WebSocket'),
    Image: forbidden('Image'),
    setTimeout: forbidden('setTimeout'),
    setInterval: forbidden('setInterval')
  };
  sandbox.window = sandbox;
  sandbox.self = sandbox;
  document.defaultView = sandbox;
  for (const name of ['localStorage', 'sessionStorage']) {
    Object.defineProperty(sandbox, name, { get: forbidden(name), set: forbidden(name) });
  }
  recording = true;
  const context = vm.createContext(sandbox, { microtaskMode: 'afterEvaluate' });
  return {
    document,
    inserted,
    execute(script) {
      script.runInContext(context, { timeout: 1000 });
      assert.deepEqual(forbiddenAccesses, [], 'The loader must not touch storage, cookies, timers, or networking APIs');
    },
    nextLoader() {
      recording = false;
      document.currentScript = body.appendChild(new Element('script', loaderAttributes));
      recording = true;
    }
  };
}

function expectBeacon(page, token = SITE_TOKEN) {
  assert.equal(page.inserted.length, 1, 'Expected exactly one dynamically inserted element');
  const [{ parent, element }] = page.inserted;
  assert.equal(parent, page.document.head, 'The beacon belongs in document.head');
  assert.equal(element.tagName, 'SCRIPT');
  assert.equal(element.type, 'module', 'Use the official module script');
  assert.equal(element.src, BEACON_URL, 'Use only the official Cloudflare Web Analytics script URL');
  assert.deepEqual(JSON.parse(element.getAttribute('data-cf-beacon')), { token }, 'Send only the public site token');
}

function testLoader(script) {
  for (const [name, options] of [
    ['production homepage', {}],
    ['homepage query and fragment', { url: `${SITE_ORIGIN}/?utm_source=test#publications` }],
    ['explicit HTTPS default port', { url: `${SITE_ORIGIN}:443/` }],
    ['another valid public token', { attributes: { 'data-site-token': 'ABCDEF0123456789ABCDEF0123456789' } }],
    ['DNT opt-in values', { navigator: { doNotTrack: '0', msDoNotTrack: 'no' }, windowDnt: '0' }],
    ['unspecified privacy preferences', { navigator: { webdriver: undefined, globalPrivacyControl: undefined } }]
  ]) {
    check(name, () => {
      const page = browser(options);
      page.execute(script);
      expectBeacon(page, options.attributes?.['data-site-token'] ?? SITE_TOKEN);
    });
  }

  const blocked = [
    ['missing currentScript', { missingScript: true }],
    ['missing document.head', { missingHead: true }],
    ['missing navigator', { missingNavigator: true }],
    ['webdriver opt-out', { navigator: { webdriver: true } }],
    ['GPC opt-out', { navigator: { globalPrivacyControl: true } }]
  ];
  for (const url of [
    'http://localhost:4000/', 'http://127.0.0.1:4000/', 'https://localhost/',
    'file:///tmp/index.html', 'about:blank', 'https://preview.example/',
    'http://xiaoxi-li1.github.io/', 'https://xiaoxi-li1.github.io:8443/',
    'https://www.xiaoxi-li1.github.io/', 'https://xiaoxi-li1.github.io.evil.example/',
    `${SITE_ORIGIN}/index.html`, `${SITE_ORIGIN}/posts/`, `${SITE_ORIGIN}/visitor-statistics/`,
    `${SITE_ORIGIN}/%2f`
  ]) blocked.push([`blocked page ${url}`, { url }]);
  for (const token of [null, '', ' ', 'not-a-token', SITE_TOKEN.slice(1), `${SITE_TOKEN}0`, 'g'.repeat(32), ` ${SITE_TOKEN}`, `${SITE_TOKEN}\n`]) {
    blocked.push(['invalid or missing public token', { attributes: { 'data-site-token': token } }]);
  }
  for (const origin of [null, '', 'http://xiaoxi-li1.github.io', 'https://preview.example', `${SITE_ORIGIN}/`, `${SITE_ORIGIN}/posts/`]) {
    blocked.push(['invalid or missing configured origin', { attributes: { 'data-site-origin': origin } }]);
  }
  blocked.push(['matching foreign origin still blocked', {
    url: 'https://preview.example/', attributes: { 'data-site-origin': 'https://preview.example' }
  }]);
  for (const value of ['1', 1, 'yes', 'YES', true]) {
    blocked.push([`navigator DNT opt-out (${value})`, { navigator: { doNotTrack: value } }]);
    blocked.push([`Microsoft DNT opt-out (${value})`, { navigator: { msDoNotTrack: value } }]);
    blocked.push([`window DNT opt-out (${value})`, { windowDnt: value }]);
  }
  blocked.push(['window DNT wins over navigator opt-in', { navigator: { doNotTrack: '0' }, windowDnt: '1' }]);
  blocked.push(['Microsoft DNT wins over navigator opt-in', { navigator: { doNotTrack: '0', msDoNotTrack: '1' } }]);
  for (const [name, options] of blocked) {
    check(name, () => {
      const page = browser(options);
      page.execute(script);
      assert.equal(page.inserted.length, 0, 'A blocked page must not insert a beacon or any other element');
    });
  }

  check('repeated execution and separate loader instances are idempotent', () => {
    const page = browser();
    page.execute(script);
    page.execute(script);
    page.nextLoader();
    page.execute(script);
    expectBeacon(page);
  });
  for (const src of [BEACON_URL, `${BEACON_URL}?v=1`, '//static.cloudflareinsights.com/beacon.min.js']) {
    check('existing official beacon prevents insertion', () => {
      const page = browser({ existingScripts: [{ src }] });
      page.execute(script);
      assert.equal(page.inserted.length, 0, 'Do not duplicate an existing official beacon');
    });
  }
  check('unrelated scripts do not prevent a valid beacon', () => {
    const page = browser({ existingScripts: [
      { src: '/assets/js/main.min.js' },
      { src: 'https://other.example/beacon.min.js' },
      { src: 'https://static.cloudflareinsights.com/other.js' }
    ] });
    page.execute(script);
    expectBeacon(page);
  });
}

function decodeAttribute(value) {
  const entities = { amp: '&', quot: '"', apos: "'", lt: '<', gt: '>' };
  return value.replace(/&(?:#(\d+)|#x([\da-f]+)|(amp|quot|apos|lt|gt));/gi, (_, decimal, hex, named) => {
    if (named) return entities[named.toLowerCase()];
    const codepoint = parseInt(decimal ?? hex, decimal ? 10 : 16);
    return codepoint <= 0x10ffff ? String.fromCodePoint(codepoint) : '\uFFFD';
  });
}

function scriptsFromHtml(html) {
  const scripts = [];
  const uncommented = html.replace(/<!--[\s\S]*?-->/g, '');
  // Attribute-aware scanning handles generated HTML without a DOM dependency.
  const scriptPattern = /<script\b((?:"[^"]*"|'[^']*'|[^'">])*)>([\s\S]*?)<\/script\s*>/gi;
  for (const match of uncommented.matchAll(scriptPattern)) {
    const attributes = new Map();
    const attributePattern = /([^\s=/>]+)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+)))?/g;
    for (const attribute of match[1].matchAll(attributePattern)) {
      const name = attribute[1].toLowerCase();
      assert.ok(!attributes.has(name), 'Script tags must not contain duplicate attributes');
      attributes.set(name, decodeAttribute(attribute[2] ?? attribute[3] ?? attribute[4] ?? ''));
    }
    const src = attributes.get('src');
    let url = null;
    if (src) {
      try { url = new URL(src, `${SITE_ORIGIN}/`); } catch { /* Invalid sources cannot be approved loaders. */ }
    }
    scripts.push({ attributes, body: match[2], url });
  }
  return scripts;
}

function auditHtml(html) {
  const scripts = scriptsFromHtml(html);
  const loaders = scripts.filter(({ url }) => url && /(?:^|\/)cloudflare-web-analytics\.js$/i.test(url.pathname));
  assert.equal(loaders.length, 1, 'HTML must emit exactly one Cloudflare Web Analytics loader');
  const [{ attributes, url }] = loaders;
  assert.ok(url.origin === SITE_ORIGIN && url.pathname === LOADER_PATH && !url.username && !url.password, 'The analytics loader must be a first-party production asset');
  assert.ok(attributes.has('defer'), 'The first-party analytics loader must be deferred');
  assert.notEqual(attributes.get('type')?.toLowerCase(), 'module', 'The first-party IIFE needs document.currentScript, not a module tag');
  assert.ok(attributes.get('data-site-token') === SITE_TOKEN, 'HTML must contain the approved public site token');
  assert.ok(attributes.get('data-site-origin') === SITE_ORIGIN, 'HTML must contain the approved production origin');
  assert.ok(!scripts.some(({ url }) => url && /(?:^|\/)visitor-analytics\.js$/i.test(url.pathname)), 'HTML must not inject the legacy visitor-analytics.js tracker');
  assert.ok(!scripts.some(({ url }) => url && url.origin === 'https://static.cloudflareinsights.com' && url.pathname === '/beacon.min.js'), 'HTML must not inject a direct beacon that bypasses the first-party guards');

  const activeScriptContent = scripts.map(({ attributes, body }) => `${body}\n${[...attributes].map(([name, value]) => `${name}=${value}`).join('\n')}`).join('\n');
  const credentialAssignment = /\b(?:(?:cf|cloudflare)[_-]?)?(?:api[_-]?(?:key|token)|client[_-]?secret|secret[_-]?key|access[_-]?token|refresh[_-]?token|private[_-]?key|authorization)\b\s*["']?\s*[:=]\s*["'`]?\S+/i;
  assert.ok(!credentialAssignment.test(activeScriptContent), 'Emitted scripts must not contain secret or administrative credential assignments');
  assert.ok(!/-----BEGIN (?:[A-Z]+ )?PRIVATE KEY-----|\bBearer\s+[\w.~+/-]+/i.test(activeScriptContent), 'Emitted scripts must not contain private keys or bearer credentials');
  assert.ok(!/https?:\/\/(?:api\.cloudflare\.com\b|[\w.-]+\.workers\.dev\b)/i.test(activeScriptContent), 'Emitted scripts must not contain administrative or private analytics backend URLs');
  assert.ok(!/https?:\/\/(?:localhost\b|[\w.-]+\.(?:localhost|internal|local)\b|127(?:\.\d{1,3}){3}\b|0\.0\.0\.0\b|10(?:\.\d{1,3}){3}\b|192\.168(?:\.\d{1,3}){2}\b|172\.(?:1[6-9]|2\d|3[01])(?:\.\d{1,3}){2}\b|169\.254(?:\.\d{1,3}){2}\b|\[::1\])/i.test(activeScriptContent), 'Emitted scripts must not contain local or private-network backend URLs');
}

function testHtmlAudit() {
  const valid = `<script defer src="${LOADER_PATH}" data-site-token="${SITE_TOKEN}" data-site-origin="${SITE_ORIGIN}"></script>`;
  for (const [name, html] of [
    ['canonical markup', valid],
    ['attribute order, case, whitespace, and single quotes', `<SCRIPT\n data-site-origin='${SITE_ORIGIN}' data-site-token='${SITE_TOKEN}' src='${SITE_ORIGIN}${LOADER_PATH}' defer='defer'></SCRIPT>`],
    ['unquoted attributes and escaped URL', `<script data-site-token=${SITE_TOKEN} data-site-origin=https:&#47;&#47;xiaoxi-li1.github.io src=${LOADER_PATH}?v=1&amp;safe=1 defer></script>`],
    ['documentation links are not injected scripts', `${valid}<a href="https://legacy.example.workers.dev/collect">Legacy documentation</a>`]
  ]) check(`HTML audit accepts ${name}`, () => auditHtml(html));

  const rejected = [
    ['missing loader', ''],
    ['commented-out loader', `<!-- ${valid} -->`],
    ['duplicate loader', valid + valid],
    ['missing defer', valid.replace(' defer ', ' ')],
    ['module first-party loader', valid.replace('<script ', '<script type="module" ')],
    ['wrong public token', valid.replace(SITE_TOKEN, '0'.repeat(32))],
    ['wrong configured origin', valid.replace(SITE_ORIGIN, 'https://preview.example')],
    ['missing public token', valid.replace(` data-site-token="${SITE_TOKEN}"`, '')],
    ['foreign loader source', valid.replace(LOADER_PATH, `https://foreign.example${LOADER_PATH}`)],
    ['wrong loader path', valid.replace('/assets/js/', '/vendor/')],
    ['legacy tracker injection', `${valid}<script src="/assets/js/visitor-analytics.js?v=1"></script>`],
    ['unguarded official beacon', `${valid}<script type="module" src="${BEACON_URL}"></script>`],
    ['inline API credential', `${valid}<script>const CLOUDFLARE_API_TOKEN = "fake-test-credential";</script>`],
    ['inline bearer credential', `${valid}<script>const headers = {Authorization: "Bearer fake-test-credential"};</script>`],
    ['inline private key marker', `${valid}<script>const key = "-----BEGIN PRIVATE KEY-----";</script>`],
    ['inline worker backend', `${valid}<script>const endpoint = "https://legacy.example.workers.dev/collect";</script>`],
    ['backend in a script attribute', valid.replace('<script ', '<script data-endpoint="https://legacy.example.workers.dev/collect" ')],
    ['inline administrative API', `${valid}<script>fetch("https://api.cloudflare.com/client/v4/accounts");</script>`],
    ['inline localhost backend', `${valid}<script>fetch("http://localhost:8000/events");</script>`],
    ['inline private-network backend', `${valid}<script>fetch("https://192.168.1.2/events");</script>`]
  ];
  for (const [name, html] of rejected) {
    check(`HTML audit rejects ${name}`, () => assert.throws(() => auditHtml(html)));
  }
}

function main() {
  const args = process.argv.slice(2);
  assert.ok(args.length <= 1, 'Usage: node docs/check_web_analytics.mjs [generated-index.html]');
  const script = new vm.Script(readFileSync(SOURCE_PATH, 'utf8'), { filename: SOURCE_PATH });
  testLoader(script);
  testHtmlAudit();
  if (args[0]) check('generated homepage HTML', () => auditHtml(readFileSync(resolve(args[0]), 'utf8')));
  if (failures.length) {
    console.error(`FAIL: ${failures.length} of ${checks} Web Analytics checks failed.`);
    failures.forEach((failure) => console.error(`  - ${failure}`));
    process.exitCode = 1;
    return;
  }
  console.log(`PASS: ${checks} Web Analytics checks; no network, cookies, or browser storage used.`);
  if (args[0]) console.log(`HTML: ${resolve(args[0])}`);
}

try {
  main();
} catch (error) {
  console.error(`FAIL: ${error.message}`);
  process.exitCode = 1;
}
