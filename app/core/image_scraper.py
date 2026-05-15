
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

def fetch_bing_image(query: str) -> Optional[str]:
    """
    Scrape Bing Images for an image URL.
    """
    url = f"https://www.bing.com/images/search?q={query}&form=HDRSC2&first=1"
    headers = {"User-Agent": USER_AGENT}
    try:
        response = requests.get(url, headers=headers, timeout=5)
        if response.status_code == 200:
            # Bing uses <a class="iusc" m='{"murl":"...",...}'>
            matches = re.findall(r'm="({.*?})"', response.text)
            if not matches:
                matches = re.findall(r"m='({.*?})'", response.text)

            for m in matches:
                try:
                    data = json.loads(m.replace('&quot;', '"'))
                    if 'murl' in data:
                        return data['murl']
                except:
                    continue
    except Exception as e:
        logger.error(f"Bing Scraper Error for {query}: {e}")
    return None

def fetch_wikimedia_image(query: str) -> Optional[str]:
    """
    Use Wikimedia Commons API to find an image.
    """
    search_url = "https://en.wikipedia.org/w/api.php"
    headers = {"User-Agent": "FlashcardApp/1.0 (contact: info@flashcardapp.com)"}

    try:
        # 1. Search for the most relevant title
        search_params = {
            "action": "query",
            "format": "json",
            "list": "search",
            "srsearch": query,
            "srlimit": 1
        }
        r = requests.get(search_url, params=search_params, headers=headers, timeout=5)
        data = r.json()
        search_results = data.get("query", {}).get("search", [])
        if not search_results:
            return None

        title = search_results[0]['title']

        # 2. Get the thumbnail for this title
        img_params = {
            "action": "query",
            "format": "json",
            "prop": "pageimages",
            "titles": title,
            "pithumbsize": 500
        }
        r = requests.get(search_url, params=img_params, headers=headers, timeout=5)
        data = r.json()
        pages = data.get("query", {}).get("pages", {})
        for page_id in pages:
            thumbnail = pages[page_id].get("thumbnail", {}).get("source")
            if thumbnail:
                return thumbnail
    except Exception as e:
        logger.error(f"Wikimedia Scraper Error for {query}: {e}")
    return None

def fetch_google_image(query: str) -> Optional[str]:
    """
    Fallback: Scrape Google Images for a thumbnail.
    Note: Highly unreliable due to anti-bot measures.
    """
    search_query = f"{query} icon filetype:png"
    url = f"https://www.google.com/search?q={search_query}&tbm=isch"
    headers = {"User-Agent": USER_AGENT}
    
    try:
        response = requests.get(url, headers=headers, timeout=5)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            images = soup.find_all('img')
            for img in images:
                src = img.get('src')
                if src and src.startswith('http') and 'google' not in src:
                    return src
                if src and src.startswith('data:image/'):
                    return src
    except Exception as e:
        logger.error(f"Google Scraper Error for {query}: {e}")
    return None

def fetch_icon_url(query: str) -> Optional[str]:
    """
    Attempts to find an icon URL for the given query.
    Tries multiple sources and query variations.
    """
    if not query:
        return None

    # Variations to improve results
    queries = [
        f"{query} icon png",
        f"{query} clipart",
        query
    ]

    for q in queries:
        # 1. Try DuckDuckGo
        try:
            # Random delay to be polite
            time.sleep(random.uniform(0.1, 0.5))
            with DDGS() as ddgs:
                results = list(ddgs.images(keywords=q, max_results=1))
                if results:
                    return results[0]['image']
        except Exception as e:
            logger.debug(f"DuckDuckGo Scraper failed for {q}: {e}")

        # 2. Try Bing (More reliable in many environments)
        url = fetch_bing_image(q)
        if url:
            return url

    # 3. Try Wikimedia (High quality, Creative Commons) - Once, as it's less dependent on exact variation
    url = fetch_wikimedia_image(query)
    if url:
        return url

    # 4. Final Fallback to Google
    return fetch_google_image(query)
