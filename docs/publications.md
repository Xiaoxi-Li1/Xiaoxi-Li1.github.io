# Maintaining Publications

The selected-work section is data-driven. Keep factual updates separate from layout changes, and use the checked-in `Gemfile.lock` with Ruby 3.1. No additional gems are needed for the regression checker.

## Data and Ordering

- `_data/publications.json` stores each paper's stable `id`, complete ordered `authors`, title, venue, links, figure metadata, and optional presentation fields.
- `_data/publication_groups.yml` controls section and paper order. Every ID must appear exactly once. The approved selection is 24 papers: Agents 13, Retrieval 6, and Reward/ML 5.
- The retrieval section title is exactly `Retrieval-Augmented LLMs`.
- Keep `rag-critic` immediately after `longrefiner`, and `time-series-survey` immediately after `causal-rm`. The latter's approved title is `Deep Time-Series Forecasting in 10 Years: A Survey`, with `IEEE TPAMI 2026` and `JCR Q1, IF=20.4`.
- Changing the approved selection, team wording, or journal facts requires confirmation and a corresponding intentional update to the expectations in `docs/check_publications.rb`. Do not relax assertions merely to obtain a passing result.

## Authors and Figures

Store the full author list in publication order, without ellipses. `_includes/publication-authors.html` renders native `details`/`summary` for long lists. A collapsed summary always highlights Xiaoxi Li; when his zero-based author index exceeds 2, it begins `..., Xiaoxi Li` and retains the final authors. The expanded list must exactly match the data. Short lists remain fully visible.

Only `seed2-1` and `agent-world` use `display_authors`, with this exact approved wording:

```text
ByteDance Seed Team (core contributors including Xiaoxi Li).
```

The override controls presentation only; retain the underlying source authors. These two cards intentionally show the team wording instead of an individual-author toggle.

Use a real figure from the paper's PDF, not an AI-generated substitute or a screenshot of an entire text page. Inspect the crop and both exports, preserve complete diagram boundaries and aspect ratio, and save white-background WebP files as `images/publications/<id>.webp` (about 600px wide) and `<id>-full.webp` (about 1800px wide). Record the thumbnail's actual `image_width` and `image_height`.

Preserve `pdf_url`, one-based `figure_page`, `figure_label`, the source `figure_caption`, and meaningful `figure_alt` in the paper record. Keep any available crop coordinates and PDF SHA-256 metadata as well. The original PDFs, extraction scripts, contact sheets, and additional provenance for this revision are in `/opt/tiger/homepage-review-20261009/`; these large review artifacts are not runtime dependencies and should not be added to the site repository. Paper, code, project, and other external links must use HTTPS.

## Metric Updates

`_config.yml` controls the independent thresholds under `publication_metrics`: `stars_over: 50` and `citations_over: 20`. Both comparisons are **strictly greater than**: exactly 50 stars or 20 citations stays hidden, as does an unknown value. When intentionally changing approved thresholds, update the config and the checker's approved expectations together. Keep low/unknown metric elements in the DOM with `hidden`, so runtime updates can show them later or hide a formerly high count. Never suppress a paper's metric permanently by ID, and never hide its Code or Paper links because of a low count.

Citation counts in `_data/publications.json` are build-time fallback snapshots. The existing crawler workflow runs on `page_build` and a daily `0 0 * * *` schedule (00:00 UTC / 08:00 Beijing), then writes JSON to the `google-scholar-stats` branch, not back into the main publication data. A page load fetches that JSON once and replaces valid per-paper counts; failure, timeout, or a missing record preserves the rendered snapshot. This is not continuous polling. The crawler can fall back to old Scholar data while still advancing its `updated` field, so neither that field nor a successful workflow alone guarantees fresh Scholar results.

Stars use `stars_url` (a Shields GitHub-stars `.json` endpoint), `stars_count` (a finite approximate count for threshold comparison, or `null` when unknown), `stars_label` (the original text such as `1.1k`), and `stars_as_of` (snapshot retrieval time). Each card fetches Stars once as it approaches the viewport, or immediately if IntersectionObserver is unavailable. A valid result updates both text and visibility; network errors or invalid messages preserve the snapshot, not a false zero. Shields and upstream/browser caches mean updates are not second-by-second. Abbreviations such as `1.1k` are rounded labels, not proof of an exact count of 1,100.

Keep each Stars source aligned with its authoritative Code repository. HiRA uses `RUC-NLPIR/HiRA`: GitHub identifies `ignorejjj/HiRA` as its fork, despite legacy clone links in older materials. Do not choose a repository merely because it has more stars.

## Preview Analytics

Footer visitor analytics are production-only. Set the fixed production HTTPS origin in `_config.yml` under `visitor_statistics_origin`; the footer exposes that dedicated value through `data-site-origin`. Do not substitute `site.url`: `jekyll serve` may rewrite it to localhost, making an origin guard accidentally accept the preview. `assets/js/site-traffic.js` requires HTTPS and an exact match between the browser `location.origin` and the configured analytics origin before loading Busuanzi or ClustrMaps. Localhost, alternate-port, and other preview origins deliberately keep the visitor footer hidden and do not load these services. A localhost referrer bucket can contain unrelated traffic; its numbers must never be presented as this homepage's visits.

On the canonical origin, show only `Total Visitors`, using Busuanzi's PV (total page visits), not UV (deduplicated visitors). The Unique Visitors markup is commented out. A valid nonnegative safe-integer PV displays independently of UV; failure, timeout, or an invalid PV leaves the count hidden. Do not hardcode production-looking numbers, add placeholder totals, or bypass the origin guard to populate a preview screenshot. A local preview without visitor totals is intentional. The checker validates the HTTPS configuration, rendered origin, and PV-only markup; separate browser tests cover runtime behavior, including `jekyll serve` previews.

## Build and Review

In the current shared environment, first run `export BUNDLE_PATH=/opt/tiger/homepage-review-20261009/bundle` to reuse the installed locked gems. On another machine, install the locked bundle normally instead of relying on this local path.

From the repository root, build and check the default output:

```bash
bundle exec jekyll build --safe
bundle exec ruby docs/check_publications.rb
```

To check a custom preview build in the current shared environment:

```bash
bundle exec jekyll build --safe --destination /opt/tiger/homepage-review-20261009/preview
bundle exec ruby docs/check_publications.rb /opt/tiger/homepage-review-20261009/preview/index.html
```

The checker is offline. It validates approved counts and ordering, source metadata and assets, HTTPS syntax, complete and collapsed authors, team overrides, journal labels, thumbnails, local navigation, duplicate DOM IDs, and the native image dialog. It also checks metric sources, compact snapshot labels, configured thresholds, and each metric's initial `hidden` state against the strict comparison, independently for Stars and citations. A failure prints specific reasons and exits nonzero. It does not crawl unrelated legacy links, verify remote availability or acceptance claims, execute runtime network updates, or replace a visual review.

Before **every push**, show the local preview to the user and obtain confirmation. Check desktop and mobile layout, author expansion, section navigation, and figure enlargement with keyboard and pointer input. A passing build/check is necessary but is not permission to publish. Work on `main` as requested; do not push automatically after running these commands.
