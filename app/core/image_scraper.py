
import logging
import random
import time
import requests
from bs4 import BeautifulSoup
from typing import Optional
from duckduckgo_search import DDGS

logger = logging.getLogger(__name__)

def fetch_google_image(query: str) -> Optional[str]:
    """
    Fallback: Scrape Google Images for a thumbnail.
    """
    search_query = f"{query} icon filetype:png"
    url = f"https://www.google.com/search?q={search_query}&tbm=isch"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    
    try:
        response = requests.get(url, headers=headers, timeout=5)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            # Look for image sources
            images = soup.find_all('img')
            for img in images:
                src = img.get('src')
                if src and src.startswith('http') and 'google' not in src:
                    return src
                # Some images are base64 in the src
                if src and src.startswith('data:image/'):
                    return src
    except Exception as e:
        logger.error(f"Google Scraper Error for {query}: {e}")
    
    return None

def fetch_icon_url(query: str) -> Optional[str]:
    """
    Attempts to find an icon URL for the given query.
    Tries DuckDuckGo first, then Google Images.
    """
    if not query:
        return None
        
    # 1. Try DuckDuckGo (High Quality)
    try:
        # Random delay to be polite
        time.sleep(random.uniform(0.5, 1.5))
        
        results = DDGS().images(
            keywords=f"{query} icon png",
            max_results=1,
            safesearch='off'
        )
        if results:
            return results[0]['image']
            
    except Exception as e:
        logger.warning(f"DuckDuckGo Scraper failed for {query}: {e}")
        
    # 2. Fallback to Google (Thumbnail/Low Quality)
    return fetch_google_image(query)
