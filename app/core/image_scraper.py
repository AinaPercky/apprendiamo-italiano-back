
import logging
import random
import time
import requests
import re
import json
from bs4 import BeautifulSoup
from typing import Optional, List
from duckduckgo_search import DDGS

logger = logging.getLogger(__name__)

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

# Blacklist of domains or keywords to avoid inappropriate content
BLACKLIST_KEYWORDS = [
    "porn", "sexy", "nudity", "sex", "adult", "naked", "xxx", "zendaya", "escort", "dating", "bikini"
]

def is_safe_url(url: str) -> bool:
    """
    Check if a URL contains any blacklisted keywords.
    """
    url_lower = url.lower()
    for keyword in BLACKLIST_KEYWORDS:
        if keyword in url_lower:
            logger.warning(f"🚫 URL blocked by safety filter: {url}")
            return False
    return True

def fetch_iconify_images(query: str) -> List[str]:
    """
    Search Iconify API for relevant icons.
    Returns a list of URLs.
    """
    url = f"https://api.iconify.design/search?query={query}&limit=5"
    results = []
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            for icon_id in data.get('icons', []):
                if ':' in icon_id:
                    prefix, name = icon_id.split(':', 1)
                    results.append(f"https://api.iconify.design/{prefix}/{name}.svg")
    except Exception as e:
        logger.debug(f"Iconify API error for {query}: {e}")
    return results

def fetch_bing_images(query: str) -> List[str]:
    """
    Scrape Bing Images for image URLs with SafeSearch.
    """
    # adlt=strict activates Bing's SafeSearch
    search_query = f"{query} icon png"
    url = f"https://www.bing.com/images/search?q={search_query}&form=HDRSC2&first=1&adlt=strict"
    headers = {"User-Agent": USER_AGENT}
    results = []
    try:
        response = requests.get(url, headers=headers, timeout=5)
        if response.status_code == 200:
            matches = re.findall(r'm="({.*?})"', response.text)
            if not matches:
                matches = re.findall(r"m='({.*?})'", response.text)

            for m in matches[:15]:
                try:
                    data = json.loads(m.replace('&quot;', '"'))
                    if 'murl' in data:
                        murl = data['murl']
                        if is_safe_url(murl):
                            results.append(murl)
                except:
                    continue
    except Exception as e:
        logger.error(f"Bing Scraper Error for {query}: {e}")
    return results

def fetch_duckduckgo_images(query: str) -> List[str]:
    """
    Search DuckDuckGo with SafeSearch.
    """
    results = []
    try:
        time.sleep(random.uniform(0.1, 0.3))
        with DDGS() as ddgs:
            # safesearch='strict' ensures safe results
            ddgs_results = ddgs.images(
                keywords=f"{query} icon png",
                max_results=5,
                safesearch='strict'
            )
            for r in ddgs_results:
                if is_safe_url(r['image']):
                    results.append(r['image'])
    except Exception as e:
        logger.debug(f"DuckDuckGo Scraper failed for {query}: {e}")
    return results

def fetch_wikimedia_images(query: str) -> List[str]:
    """
    Use Wikimedia Commons API to find images.
    """
    search_url = "https://en.wikipedia.org/w/api.php"
    headers = {"User-Agent": "FlashcardApp/1.0 (contact: info@flashcardapp.com)"}
    results = []
    try:
        search_params = {
            "action": "query",
            "format": "json",
            "list": "search",
            "srsearch": query,
            "srlimit": 5
        }
        r = requests.get(search_url, params=search_params, headers=headers, timeout=5)
        data = r.json()
        search_results = data.get("query", {}).get("search", [])

        for res in search_results:
            title = res['title']
            img_params = {
                "action": "query",
                "format": "json",
                "prop": "pageimages",
                "titles": title,
                "pithumbsize": 500
            }
            r_img = requests.get(search_url, params=img_params, headers=headers, timeout=5)
            data_img = r_img.json()
            pages = data_img.get("query", {}).get("pages", {})
            for page_id in pages:
                thumbnail = pages[page_id].get("thumbnail", {}).get("source")
                if thumbnail:
                    if is_safe_url(thumbnail):
                        results.append(thumbnail)
    except Exception as e:
        logger.error(f"Wikimedia Scraper Error for {query}: {e}")
    return results

# Map of abstract terms to concrete icon keywords
ABSTRACT_MAP = {
    "competitiveness": ["target", "award", "rocket", "success"],
    "proactive": ["lightbulb", "speed", "action", "launch"],
    "qualified": ["certificate", "verified", "badge", "check"],
    "performance": ["chart", "speedometer", "rocket"],
    "recruitment": ["hiring", "interview", "user-plus"],
    "management": ["briefcase", "users", "groups"],
    "professional": ["briefcase", "user-tie"],
}

def fetch_icon_url(query: str) -> Optional[str]:
    """
    Attempts to find an icon URL for the given query.
    """
    urls = fetch_icon_urls(query)
    return urls[0] if urls else None

def fetch_icon_urls(query: str) -> List[str]:
    """
    Returns a list of candidate image URLs for the query.
    """
    if not query:
        return []

    cleaned_query = query.lower().strip()
    all_urls = []

    # 1. Try exact matches on Iconify
    all_urls.extend(fetch_iconify_images(cleaned_query))

    # 2. If it's an abstract term, try mapping to concrete icons
    if not all_urls:
        for term, substitutes in ABSTRACT_MAP.items():
            if term in cleaned_query:
                for sub in substitutes:
                    all_urls.extend(fetch_iconify_images(sub))
                break

    # 3. If still nothing from Iconify, try safe scrapers
    if not all_urls:
        # DDG SafeSearch
        all_urls.extend(fetch_duckduckgo_images(cleaned_query))

        # Bing SafeSearch
        all_urls.extend(fetch_bing_images(cleaned_query))

        # Wikimedia
        all_urls.extend(fetch_wikimedia_images(cleaned_query))

    # Deduplicate while preserving order and ensuring safety
    seen = set()
    final_results = []
    for url in all_urls:
        if url not in seen:
            seen.add(url)
            if is_safe_url(url):
                final_results.append(url)

    return final_results
