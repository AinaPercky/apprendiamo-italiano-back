
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

def fetch_iconify_image(query: str) -> Optional[str]:
    """
    Search Iconify API for a relevant icon.
    Returns a URL to the SVG or PNG representation.
    """
    url = f"https://api.iconify.design/search?query={query}&limit=5"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            if data.get('icons'):
                # Pick the first icon
                icon_id = data['icons'][0]
                if ':' in icon_id:
                    prefix, name = icon_id.split(':', 1)
                    # We can get it as SVG
                    return f"https://api.iconify.design/{prefix}/{name}.svg"
    except Exception as e:
        logger.debug(f"Iconify API error for {query}: {e}")
    return None

def fetch_bing_image(query: str) -> Optional[str]:
    """
    Scrape Bing Images for an image URL.
    """
    # Adding keywords to ensure we get an icon/clipart
    search_query = f"{query} icon png"
    url = f"https://www.bing.com/images/search?q={search_query}&form=HDRSC2&first=1"
    headers = {"User-Agent": USER_AGENT}
    try:
        response = requests.get(url, headers=headers, timeout=5)
        if response.status_code == 200:
            # Bing uses <a class="iusc" m='{"murl":"...",...}'>
            matches = re.findall(r'm="({.*?})"', response.text)
            if not matches:
                matches = re.findall(r"m='({.*?})'", response.text)

            for m in matches[:10]:
                try:
                    data = json.loads(m.replace('&quot;', '"'))
                    if 'murl' in data:
                        murl = data['murl']
                        # Basic relevance check: exclude huge photos if possible, prefer known icon extensions
                        if any(ext in murl.lower() for ext in ['.png', '.svg', '.webp']):
                            return murl
                except:
                    continue

            # If no good extension found, return first match
            if matches:
                 try:
                    data = json.loads(matches[0].replace('&quot;', '"'))
                    return data.get('murl')
                 except: pass

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
            "srlimit": 5
        }
        r = requests.get(search_url, params=search_params, headers=headers, timeout=5)
        data = r.json()
        search_results = data.get("query", {}).get("search", [])
        if not search_results:
            return None

        # Try to find an exact title match first
        title = search_results[0]['title']
        for res in search_results:
            if res['title'].lower() == query.lower():
                title = res['title']
                break

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

    # 1. Try Iconify (Best for clean icons)
    url = fetch_iconify_image(query)
    if url:
        return url

    # 2. Try DuckDuckGo
    try:
        time.sleep(random.uniform(0.1, 0.3))
        with DDGS() as ddgs:
            results = list(ddgs.images(keywords=f"{query} icon png", max_results=1))
            if results:
                return results[0]['image']
    except Exception as e:
        logger.debug(f"DuckDuckGo Scraper failed for {query}: {e}")

    # 3. Try Bing (More reliable)
    url = fetch_bing_image(query)
    if url:
        return url

    # 4. Try Wikimedia
    url = fetch_wikimedia_image(query)
    if url:
        return url

    # 5. Final Fallback to Google
    return fetch_google_image(query)
