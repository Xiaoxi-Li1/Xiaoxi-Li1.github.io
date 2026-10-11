# Visitor Analytics

The homepage uses the owner's Cloudflare Web Analytics site. Reports are viewed
in the authenticated Cloudflare dashboard, not on a public homepage widget or
the former `workers.dev` dashboard. The official beacon's site token is a public
ingestion identifier, not an account API token, password, or reporting credential.

## Current Integration

```yaml
cloudflare_web_analytics:
  enabled: true
  token: "7717b496fc2144c7a752adbade5ad7df"
  site_origin: "https://xiaoxi-li1.github.io"
```

`_includes/scripts.html` emits one deferred, first-party loader on `/` only,
unless the page explicitly sets `analytics: false`. The managed integration takes
precedence over the legacy collector, so the same rendered page cannot inject both.
`assets/js/cloudflare-web-analytics.js` checks the exact production HTTPS origin,
the homepage path, and the public token format before creating the supplied
official module script:

```html
<script type="module" src="https://static.cloudflareinsights.com/beacon.min.js"
        data-cf-beacon='{"token":"7717b496fc2144c7a752adbade5ad7df"}'></script>
```

The loader skips local previews, browser automation, and browsers reporting DNT
or GPC when the loader runs. It adds no cookie or browser-storage identifier of its
own. Repeated execution or an existing official beacon does not create a second
beacon. The vendor script, rather than our loader, handles measurements after it
loads; the loader's initial privacy check is not a continuous interception of
vendor requests.

Keep the loader's attributes as `data-site-token` and `data-site-origin`. Only the
official script receives `data-cf-beacon`: the module locates its configuration
using the first matching element when `document.currentScript` is null. The vendor
script supports loading after the page's load event. Do not pin a fixed SRI hash
to this unversioned, automatically updated script.

The script loads from `static.cloudflareinsights.com`; manual installations report
to `https://cloudflareinsights.com/cdn-cgi/rum`. These are separate from the old
`workers.dev` collector, but network policies, privacy tools, and ad blockers can
still prevent collection. Loading the script does not prove a real visit was
accepted or that account reports have refreshed. Data generally takes a few
minutes to appear. Confirm this in the owner's Cloudflare dashboard after a real
visit; do not manufacture events or upload historical totals as new visits.

Cloudflare currently documents six months of accessible history, adaptive
aggregation/sampling, country and referrer-host dimensions, and no custom events.
Visits are not a count of uniquely identified people. This managed panel is not
an exact replacement for the legacy session, outbound-click, or annual-history
reports. Review applicable privacy disclosure requirements when using analytics.

## Legacy Data

`visitor_analytics.enabled` is now `false`. Its source file and configuration remain
available for a deliberate future rollback, but it is not injected by the current
homepage. Existing public visitor badges and their counters are unchanged.

The separate private application and its D1 database have not been deleted,
exported to this repository, or imported into Cloudflare Web Analytics. Existing
D1 aggregates remain subject to that application's retention rules. A page opened
before publication can continue running its old tracker until reloaded; disabling
the page integration does not remotely stop an already-loaded script.

Never put private application code, owner keys, API tokens, access cookies,
database files, report exports, or raw visitor records into this public repository.
Cloudflare account permissions protect managed reports. Knowing the public site
token does not grant report access.

## Verification

```sh
node docs/check_web_analytics.mjs /path/to/built/index.html
```

The checker uses a simulated DOM and never contacts the real collector. It checks
the official module configuration, privacy and origin guards, duplicate prevention,
and the rendered page's single integration. Browser verification must also block
all analytics ingestion requests so synthetic tests do not inflate real counts.

Official references: [setup](https://developers.cloudflare.com/web-analytics/get-started/),
[dimensions](https://developers.cloudflare.com/web-analytics/data-metrics/dimensions/),
and [retention and sampling](https://developers.cloudflare.com/web-analytics/faq/#functionality).
