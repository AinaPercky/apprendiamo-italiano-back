
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
    Scrape Bing Images for image URLs.
    """
    search_query = f"{query} icon png"
    url = f"https://www.bing.com/images/search?q={search_query}&form=HDRSC2&first=1"
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
                        results.append(murl)
                except:
                    continue
    except Exception as e:
        logger.error(f"Bing Scraper Error for {query}: {e}")
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
                    results.append(thumbnail)
    except Exception as e:
        logger.error(f"Wikimedia Scraper Error for {query}: {e}")
    return results

def fetch_icon_url(query: str) -> Optional[str]:
    """
    Attempts to find an icon URL for the given query.
    Tries multiple sources and returns the FIRST ONE FOUND that's reachable.
    Note: Now returning a single URL for backward compatibility with current flow,
    but the internal logic could be used to return a list.
    """
    urls = fetch_icon_urls(query)
    return urls[0] if urls else None

def fetch_icon_urls(query: str) -> List[str]:
    """
    Returns a list of candidate image URLs for the query.
    """
    if not query:
        return []

    all_urls = []

    # 1. Iconify
    all_urls.extend(fetch_iconify_images(query))

    # 2. Bing
    all_urls.extend(fetch_bing_images(query))

    # 3. Wikimedia
    all_urls.extend(fetch_wikimedia_images(query))

    # Deduplicate while preserving order
    seen = set()
    return [x for x in all_urls if not (x in seen or seen.add(x))]
