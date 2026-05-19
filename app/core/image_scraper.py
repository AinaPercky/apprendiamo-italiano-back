
import logging
import os
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

MAGNIFIC_API_BASE_URL = "https://api.magnific.com/v1"

# Blacklist to avoid inappropriate content
BLACKLIST_KEYWORDS = [
    "porn", "sexy", "nudity", "sex", "adult", "naked", "xxx", "zendaya", "escort", "dating", "bikini",
    "hot", "erotic", "nsfw", "playboy", "pussy", "dick", "vagina", "bra", "lingerie", "strip",
    "ass", "butt", "fuck", "cock", "blowjob", "orgasm", "penis"
]

# Map of abstract terms to concrete icon keywords
ABSTRACT_MAP = {
    "competitiveness": ["target", "award", "rocket", "success"],
    "proactive": ["lightbulb", "speed", "action", "launch"],
    "qualified": ["certificate", "verified", "badge", "check"],
    "performance": ["chart", "speedometer", "rocket"],
    "recruitment": ["hiring", "interview", "user-plus"],
    "management": ["briefcase", "users", "groups"],
    "professional": ["briefcase", "user-tie"],
    "loyal": ["heart", "handshake", "shield"],
    "sociable": ["users", "groups", "chat"],
    "funny": ["emoticon-happy", "face-smile"],
    "shy": ["face-mask", "eye-off"],
    "lazy": ["sleep", "bed", "sofa"],
    "impatient": ["clock", "timer", "speed"],
}

def is_safe_url(url: str) -> bool:
    url_lower = url.lower()
    for keyword in BLACKLIST_KEYWORDS:
        if keyword in url_lower:
            logger.warning(f"🚫 URL blocked by safety filter: {url}")
            return False
    return True

def get_magnific_headers():
    api_key = os.getenv("MAGNIFIC_API_KEY")
    if not api_key:
        return None
    return {
        "x-magnific-api-key": api_key,
        "Accept": "application/json"
    }

def fetch_magnific_icons(query: str) -> List[str]:
    headers = get_magnific_headers()
    if not headers: return []
    url = f"{MAGNIFIC_API_BASE_URL}/icons"
    params = {"term": query, "per_page": 5, "thumbnail_size": "512"}
    try:
        response = requests.get(url, headers=headers, params=params, timeout=10)
        if response.status_code == 200:
            data = response.json()
            results = []
            for icon in data.get('data', []):
                thumbnails = icon.get('thumbnails', [])
                if thumbnails:
                    thumb_url = thumbnails[0].get('url')
                    for t in thumbnails:
                        if t.get('height') == 512 or t.get('width') == 512:
                            thumb_url = t.get('url')
                            break
                    if thumb_url: results.append(thumb_url)
            return results
    except Exception: pass
    return []

def fetch_iconify_images(query: str) -> List[str]:
    url = f"https://api.iconify.design/search?query={query}&limit=5"
    results = []
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            for icon_id in data.get('icons', []):
                if ':' in icon_id:
                    prefix, name = icon_id.split(':', 1)
                    results.append(f"https://api.iconify.design/{prefix}/{name}.svg?height=512")
    except Exception: pass
    return results

def fetch_bing_images(query: str) -> List[str]:
    search_query = f"{query} flaticon icon png"
    url = f"https://www.bing.com/images/search?q={search_query}&form=HDRSC2&first=1&adlt=strict&qft=+filterui:imagesize-large"
    headers = {"User-Agent": USER_AGENT}
    results = []
    try:
        response = requests.get(url, headers=headers, timeout=5)
        if response.status_code == 200:
            matches = re.findall(r'm="({.*?})"', response.text)
            if not matches: matches = re.findall(r"m='({.*?})'", response.text)
            for m in matches[:15]:
                try:
                    data = json.loads(m.replace('&quot;', '"'))
                    if 'murl' in data:
                        murl = data['murl']
                        if is_safe_url(murl): results.append(murl)
                except: continue
    except Exception: pass
    return results

def fetch_duckduckgo_images(query: str) -> List[str]:
    results = []
    try:
        time.sleep(random.uniform(0.1, 0.2))
        with DDGS() as ddgs:
            ddgs_results = ddgs.images(keywords=f"{query} icon png high resolution", max_results=5, safesearch='strict')
            for r in ddgs_results:
                if is_safe_url(r['image']): results.append(r['image'])
    except Exception: pass
    return results

def fetch_wikimedia_images(query: str) -> List[str]:
    search_url = "https://en.wikipedia.org/w/api.php"
    headers = {"User-Agent": "FlashcardApp/1.0"}
    results = []
    try:
        search_params = {"action": "query", "format": "json", "list": "search", "srsearch": query, "srlimit": 3}
        r = requests.get(search_url, params=search_params, headers=headers, timeout=5)
        data = r.json()
        for res in data.get("query", {}).get("search", []):
            img_params = {"action": "query", "format": "json", "prop": "pageimages", "titles": res['title'], "pithumbsize": 1024}
            r_img = requests.get(search_url, params=img_params, headers=headers, timeout=5)
            pages = r_img.json().get("query", {}).get("pages", {})
            for page_id in pages:
                thumbnail = pages[page_id].get("thumbnail", {}).get("source")
                if thumbnail and is_safe_url(thumbnail): results.append(thumbnail)
    except Exception: pass
    return results

def fetch_icon_url(query: str) -> Optional[str]:
    urls = fetch_icon_urls(query)
    return urls[0] if urls else None

def fetch_icon_urls(query: str) -> List[str]:
    if not query: return []
    cleaned_query = query.lower().strip()
    all_urls = []

    # 1. Magnific (Priority #1)
    if os.getenv("MAGNIFIC_API_KEY"):
        all_urls.extend(fetch_magnific_icons(cleaned_query))

    # 2. Iconify (Priority #2 - Best free icons)
    if not all_urls:
        all_urls.extend(fetch_iconify_images(cleaned_query))
        # Abstract mapping for Iconify
        for term, substitutes in ABSTRACT_MAP.items():
            if term in cleaned_query:
                for sub in substitutes:
                    all_urls.extend(fetch_iconify_images(sub))
                break

    # 3. Fallbacks (Bing, DDG, Wikimedia)
    if not all_urls:
        all_urls.extend(fetch_bing_images(cleaned_query))
        all_urls.extend(fetch_duckduckgo_images(cleaned_query))
        all_urls.extend(fetch_wikimedia_images(cleaned_query))

    seen = set()
    final_results = []
    for url in all_urls:
        if url not in seen:
            seen.add(url)
            if is_safe_url(url): final_results.append(url)
    return final_results
