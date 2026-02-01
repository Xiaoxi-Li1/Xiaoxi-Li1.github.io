from scholarly import scholarly, ProxyGenerator
import jsonpickle
import json
from datetime import datetime
import os
import requests

# Setup proxy
pg = ProxyGenerator()
pg.FreeProxies()  # Use free rotating proxies
scholarly.use_proxy(pg)

author: dict = scholarly.search_author_id(os.environ['GOOGLE_SCHOLAR_ID'])
scholarly.fill(author, sections=['basics', 'indices', 'counts', 'publications'])
name = author['name']
author['updated'] = str(datetime.now())
author['publications'] = {v['author_pub_id']:v for v in author['publications']}

# Calculate first-author citations
# List of first-author paper IDs (update this list if needed)
first_author_ids = [
    'XDljV4YAAAAJ:YsMSGLbcyi4C',  # Search-o1
    'XDljV4YAAAAJ:qjMakFHDy7sC',  # From Matching to Generation
    'XDljV4YAAAAJ:LkGwnXOMwfcC',  # WebThinker
    'XDljV4YAAAAJ:W7OEmFMy1HYC',  # RetroLLM
    'XDljV4YAAAAJ:IjCSPb-OGe4C',  # CorpusLM
    'XDljV4YAAAAJ:9yKSN-GCB0IC',  # UniGen
    'XDljV4YAAAAJ:QIV2ME_5wuYC',  # DeepAgent
    'XDljV4YAAAAJ:d1gkVwhDpl0C',  # Immersion and invariance-based adaptive control... (quadrotor)
]

first_author_citations = 0
for pub_id in first_author_ids:
    if pub_id in author['publications']:
        first_author_citations += author['publications'][pub_id].get('num_citations', 0)

author['first_author_citations'] = first_author_citations

# Get GitHub total stars (include organization repos)
github_username = os.environ.get('GITHUB_USERNAME', 'sunnynexus')
github_pat = os.environ.get('GITHUB_PAT', '')
github_token = github_pat or os.environ.get('GITHUB_TOKEN', '')
github_orgs_env = os.environ.get('GITHUB_ORGS', '')
github_orgs = [org.strip() for org in github_orgs_env.split(',') if org.strip()]


def fetch_paginated(url: str, headers: dict) -> list:
    results = []
    page = 1
    while True:
        sep = '&' if '?' in url else '?'
        response = requests.get(
            f'{url}{sep}page={page}',
            headers=headers,
            timeout=20,
        )
        if response.status_code != 200:
            print(f"Failed to fetch {url}: {response.status_code}")
            break
        batch = response.json()
        if not batch:
            break
        results.extend(batch)
        if len(batch) < 100:
            break
        page += 1
    return results


def sum_stars(repos: list, seen: set) -> int:
    total = 0
    for repo in repos:
        full_name = repo.get('full_name')
        if not full_name or full_name in seen:
            continue
        seen.add(full_name)
        total += repo.get('stargazers_count', 0)
    return total


try:
    headers = {}
    if github_token:
        headers['Authorization'] = f'token {github_token}'

    total_stars = 0
    seen_repos = set()

    if github_pat:
        # Use user-scoped token to include organization repos the user can access
        repos_url = (
            'https://api.github.com/user/repos'
            '?per_page=100&affiliation=owner,organization_member'
        )
        repos = fetch_paginated(repos_url, headers)
        total_stars += sum_stars(repos, seen_repos)
    else:
        # Public fallback: user repos + public org repos
        user_repos_url = (
            f'https://api.github.com/users/{github_username}/repos'
            '?per_page=100&type=public'
        )
        repos = fetch_paginated(user_repos_url, headers)
        total_stars += sum_stars(repos, seen_repos)

        orgs_url = f'https://api.github.com/users/{github_username}/orgs?per_page=100'
        orgs = fetch_paginated(orgs_url, headers)
        orgs_from_api = [org.get('login') for org in orgs if org.get('login')]
        orgs_all = sorted(set(github_orgs + orgs_from_api))

        for org in orgs_all:
            org_repos_url = (
                f'https://api.github.com/orgs/{org}/repos'
                '?per_page=100&type=public'
            )
            org_repos = fetch_paginated(org_repos_url, headers)
            total_stars += sum_stars(org_repos, seen_repos)

    author['github_stars'] = total_stars
    print(f"GitHub total stars (with orgs): {total_stars}")

    # GitHub stars for first-author-paper repos (selected)
    first_author_repos = [
        ("RUC-NLPIR", "DeepAgent"),
        ("RUC-NLPIR", "WebThinker"),
        ("sunnynexus", "Search-o1"),
        ("sunnynexus", "RetroLLM"),
        ("RUC-NLPIR", "GenIR-Survey"),
    ]
    first_author_repo_stars = 0
    for owner, repo in first_author_repos:
        repo_resp = requests.get(
            f"https://api.github.com/repos/{owner}/{repo}",
            headers=headers,
            timeout=20,
        )
        if repo_resp.status_code == 200:
            repo_json = repo_resp.json()
            first_author_repo_stars += repo_json.get("stargazers_count", 0)
        else:
            print(f"Failed to fetch repo {owner}/{repo}: {repo_resp.status_code}")
    author["first_author_repo_stars"] = first_author_repo_stars
    print(f"First-author repos stars (selected): {first_author_repo_stars}")
except Exception as e:
    print(f"Error fetching GitHub stars: {e}")
    author['github_stars'] = 0
    author["first_author_repo_stars"] = 0

print(json.dumps(author, indent=2))
os.makedirs('results', exist_ok=True)
with open(f'results/gs_data.json', 'w') as outfile:
    json.dump(author, outfile, ensure_ascii=False)

shieldio_data = {
  "schemaVersion": 1,
  "label": "citations",
  "message": f"{author['citedby']}",
}
with open(f'results/gs_data_shieldsio.json', 'w') as outfile:
    json.dump(shieldio_data, outfile, ensure_ascii=False)