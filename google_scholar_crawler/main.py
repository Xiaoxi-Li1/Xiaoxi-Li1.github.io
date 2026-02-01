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
]

first_author_citations = 0
for pub_id in first_author_ids:
    if pub_id in author['publications']:
        first_author_citations += author['publications'][pub_id].get('num_citations', 0)

author['first_author_citations'] = first_author_citations

# Get GitHub total stars
github_username = os.environ.get('GITHUB_USERNAME', 'sunnynexus')
github_token = os.environ.get('GITHUB_TOKEN', '')  # Optional: use token to avoid rate limits

try:
    headers = {}
    if github_token:
        headers['Authorization'] = f'token {github_token}'
    
    # Get all repositories
    repos_url = f'https://api.github.com/users/{github_username}/repos?per_page=100'
    response = requests.get(repos_url, headers=headers)
    
    if response.status_code == 200:
        repos = response.json()
        total_stars = sum(repo.get('stargazers_count', 0) for repo in repos)
        
        # If user has more than 100 repos, handle pagination
        page = 2
        while len(repos) == 100:
            response = requests.get(f'{repos_url}&page={page}', headers=headers)
            if response.status_code == 200:
                new_repos = response.json()
                if not new_repos:
                    break
                repos.extend(new_repos)
                total_stars += sum(repo.get('stargazers_count', 0) for repo in new_repos)
                page += 1
            else:
                break
        
        author['github_stars'] = total_stars
        print(f"GitHub total stars: {total_stars}")
    else:
        print(f"Failed to fetch GitHub data: {response.status_code}")
        author['github_stars'] = 0
except Exception as e:
    print(f"Error fetching GitHub stars: {e}")
    author['github_stars'] = 0

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