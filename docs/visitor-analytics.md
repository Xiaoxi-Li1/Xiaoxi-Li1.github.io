# Private Visitor Analytics

The homepage has a write-only event collector for the separate Private Visitor
Observatory. The configuration is prepared for its verified Cloudflare backend;
it takes effect on the live homepage only after these changes are published by
GitHub Pages. It adds no visible widget or dashboard link. Existing visitor
badges and their historical counts are independent and unchanged.

## Safety Boundary

The private dashboard, database, owner login, and read APIs belong in the
separate `visitor-observatory` application, never in this public repository.
Do not copy its owner key, session secret, database credentials, access cookies,
exports, or visitor data here. GitHub Pages is public and cannot protect a
private dashboard merely by hiding its URL or navigation link.

The public collector endpoint accepts writes only. It contains **no secret**.
An endpoint or site-origin check does not authenticate an owner and does not
make submissions trustworthy. Private reads must require an authenticated,
HttpOnly owner session at the separate application.

## Activation Checklist

1. Deploy and secure the separate application with collection still disabled.
2. Verify unauthenticated requests cannot read the dashboard, private assets,
   dashboard JSON, CSV exports, or raw visitor records. Test login, logout,
   session expiry, and incorrect owner credentials before connecting the site.
3. Verify the collector accepts only the exact production homepage origin and
   allowed payload, rejects disabled collection and invalid requests, enforces
   rate limits, and deduplicates repeated event IDs.
4. Review retention, privacy obligations, and access controls. Do not place any
   private key in an HTML attribute, JavaScript file, query parameter, or this
   repository's configuration.
5. With explicit approval, enable collection in the separate backend and set
   the public config below to its real HTTPS `/collect` endpoint, then enable
   `visitor_analytics.enabled` and publish the homepage.
6. Confirm real data through the authenticated dashboard. Empty or stale data
   must not be described as live, and no data should be manufactured to fill it.

The backend access checks have passed. The prepared publication settings are:

```yaml
visitor_analytics:
  enabled: true
  endpoint: "https://xiaoxi-visitor-observatory.private-visitor-observatory.workers.dev/collect"
  site_origin: "https://xiaoxi-li1.github.io"
```

Use a bare HTTPS endpoint ending exactly in `/collect`, with no username,
password, query string, or fragment. The endpoint is public and needs no API
key. Set `enabled: false` to stop injecting the tracker on the next site build;
disable collection at the backend as well to reject already-loaded clients.

## Browser Behavior

`assets/js/visitor-analytics.js` is a byte-identical copy of the separate
application's `tracker.js`. `_includes/scripts.html` injects it only when
explicitly enabled, configured with a nonempty endpoint, and rendering `/`.
The script reads `data-endpoint` and `data-site-origin` from its own script tag.

The production origin is fixed to `https://xiaoxi-li1.github.io`, separately
from Jekyll's `site.url`. Do not replace it with `site.url`: local Jekyll previews
may rewrite that variable to localhost. The tracker independently rejects
other origins, non-HTTPS pages, non-homepage paths, local endpoints, and invalid
endpoint URLs. No preview-origin bypass is supported.

The collector records one logical pageview per visible document, a heartbeat
every 30 seconds while visible, and trusted clicks on external HTTP(S) anchors.
Repeated script loading, page restoration, visibility changes, and heartbeats
do not add pageviews. A transient pageview network failure may retry once after
one second using the same event ID and timestamp. Clicks and heartbeats are
not retried. Hidden pages do not send events.

Each tab uses a cryptographically random UUIDv4 session in `sessionStorage`,
renewed after 30 minutes without a collected event. Visible heartbeats keep
that session active. If storage is blocked, the session stays only in memory
for that document; reloading may start a new session. No localStorage,
fingerprint, persistent person ID, raw IP, or user-agent payload is used.
Session counts represent tab sessions, not identified people or unique humans.
After an idle tab resumes, its first heartbeat or click can start a new session
without recording another pageview; subsequent heartbeats do not add sessions.

Payloads contain only the event type, random event/session IDs, version,
freshness timestamp, fixed page path `/`, referrer hostname, and outbound
target hostname. Hostnames are lowercased and a trailing DNS dot is removed;
`www` is retained. IP literal targets are ignored. Self, local, IP literal,
invalid, or unavailable referrers become
`direct`. URL paths, ports, queries, fragments, credentials, and link text
are not transmitted. The backend may derive broad device and geographic
categories from normal request metadata; a server still receives the network
connection, so avoiding IP storage is a backend obligation too.

The tracker honors Do Not Track and Global Privacy Control, rejects browsers
reporting `navigator.webdriver === true`, and rechecks these flags before
events. It uses `fetch` with a `text/plain` body, `keepalive`,
`credentials: "omit"`, and `referrerPolicy: "no-referrer"`. Collection failures
never block navigation or change visible homepage content.

## Verification

In the separate application's checkout, run:

```sh
node --test tests/tracker.test.mjs
```

The tests use a simulated browser and mocked network, never a real collector.
They cover production and script guards, privacy flags, visible-only timing,
session expiry, hostname trimming, retries, and duplicate pageviews. When this
public repository is a sibling checkout, they also verify the public tracker
copy, approved production endpoint, and opt-in Jekyll integration. Keep both tracker copies in
sync when updating the implementation.
