
import logging
import os
import requests
from typing import Optional, List

logger = logging.getLogger(__name__)

MAGNIFIC_API_BASE_URL = "https://api.magnific.com/v1"

def get_magnific_headers():
    # Fetch key dynamically to allow updating env vars without restart if needed (or for testing)
    api_key = os.getenv("MAGNIFIC_API_KEY")
    if not api_key:
        logger.error("❌ MAGNIFIC_API_KEY is not set in environment variables.")
        return None
    return {
        "x-magnific-api-key": api_key,
        "Accept": "application/json"
    }

def fetch_magnific_icons(query: str) -> List[str]:
    """
    Search Magnific Icons API for relevant icons.
    """
    headers = get_magnific_headers()
    if not headers:
        return []

    url = f"{MAGNIFIC_API_BASE_URL}/icons"
    params = {
        "term": query,
        "per_page": 5,
        "thumbnail_size": "512"
    }

    try:
        response = requests.get(url, headers=headers, params=params, timeout=10)
        if response.status_code == 200:
            data = response.json()
            results = []
            for icon in data.get('data', []):
                thumbnails = icon.get('thumbnails', [])
                if thumbnails:
                    # Prefer 512px if available, otherwise first one
                    thumb_url = thumbnails[0].get('url')
                    for t in thumbnails:
                        if t.get('height') == 512 or t.get('width') == 512:
                            thumb_url = t.get('url')
                            break
                    if thumb_url:
                        results.append(thumb_url)
            return results
        elif response.status_code == 429:
            logger.error("⚠️ Magnific API Quota Exceeded (429). Please check your plan.")
        elif response.status_code == 401:
            logger.error("❌ Magnific API Unauthorized (401). Please check your MAGNIFIC_API_KEY.")
        else:
            logger.error(f"Magnific Icons API error: {response.status_code} - {response.text}")
    except Exception as e:
        logger.error(f"Magnific Icons API Exception for {query}: {e}")
    return []

def fetch_magnific_stock(query: str) -> List[str]:
    """
    Search Magnific Stock Resources (images) as a fallback.
    """
    headers = get_magnific_headers()
    if not headers:
        return []

    url = f"{MAGNIFIC_API_BASE_URL}/resources"
    params = {
        "term": query,
        "per_page": 5
    }

    try:
        response = requests.get(url, headers=headers, params=params, timeout=10)
        if response.status_code == 200:
            data = response.json()
            results = []
            for resource in data.get('data', []):
                thumbnails = resource.get('thumbnails', [])
                if thumbnails:
                    results.append(thumbnails[0].get('url'))
            return results
        elif response.status_code == 429:
            logger.error("⚠️ Magnific API Quota Exceeded (429).")
    except Exception as e:
        logger.error(f"Magnific Stock API Exception for {query}: {e}")
    return []

def fetch_icon_url(query: str) -> Optional[str]:
    """
    Attempts to find an icon URL for the given query using Magnific exclusively.
    """
    urls = fetch_icon_urls(query)
    return urls[0] if urls else None

def fetch_icon_urls(query: str) -> List[str]:
    """
    Returns a list of candidate image URLs for the query using Magnific API exclusively.
    """
    if not query:
        return []

    # Check key presence before attempting
    if not os.getenv("MAGNIFIC_API_KEY"):
        logger.warning("⚠️ MAGNIFIC_API_KEY is missing. Cannot fetch images from Magnific.")
        return []

    all_urls = []

    # 1. Search Icons (Priority)
    all_urls.extend(fetch_magnific_icons(query))

    # 2. Search Stock Content (Fallback)
    if not all_urls:
        all_urls.extend(fetch_magnific_stock(query))

    # Deduplicate while preserving order
    seen = set()
    return [x for x in all_urls if not (x in seen or seen.add(x))]
