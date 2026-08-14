"""
Test complet du système de recherche et téléchargement automatique d'images.

Tests:
1. Validation URLs d'images
2. Téléchargement et conversion Base64
3. Scraping automatique d'images
4. Gestion des erreurs et timeouts
5. Caching des résultats
"""

import asyncio
import logging
import sys
import os
from datetime import datetime

# Configuration du logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Import des modules à tester
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'app'))

from app.core.image_scraper import (
    fetch_icon_url, is_valid_image_url, clear_image_cache
)
from app.crud_cards import url_to_base64


async def test_image_url_validation():
    """Test de validation des URLs d'images"""
    print("\n" + "="*80)
    print("TEST 1: Validation des URLs d'images")
    print("="*80)
    
    test_cases = [
        ("https://example.com/image.png", True, "URL valide"),
        ("http://example.com/photo.jpg", True, "URL HTTP valide"),
        ("data:image/png;base64,iVBORw0KGgo...", True, "Data URI valide"),
        ("https://google.com/ads.png", False, "Domaine bloqué (Google)"),
        ("https://example.com", False, "Pas d'extension image"),
        ("", False, "URL vide"),
        (None, False, "None"),
        ("not-a-url", False, "Pas une URL"),
    ]
    
    passed = 0
    for url, expected, description in test_cases:
        result = is_valid_image_url(url)
        status = "✓ PASS" if result == expected else "✗ FAIL"
        print(f"{status}: {description}")
        if result == expected:
            passed += 1
    
    print(f"\nRésultat: {passed}/{len(test_cases)} tests passés")
    return passed == len(test_cases)


async def test_image_scraping():
    """Test du scraping automatique d'images"""
    print("\n" + "="*80)
    print("TEST 2: Scraping automatique d'images (DuckDuckGo + Google)")
    print("="*80)
    
    test_queries = [
        "apple",
        "computer",
        "cat",
        "xyznonexistent12345",  # Requête qui ne devrait rien trouver
    ]
    
    clear_image_cache()
    results = []
    
    for query in test_queries:
        print(f"\n🔍 Recherche: '{query}'")
        try:
            url = fetch_icon_url(query)
            if url:
                is_valid = is_valid_image_url(url)
                status = "✓ TROUVÉE" if is_valid else "✗ INVALIDE"
                print(f"{status}: {url[:70]}...")
                results.append((query, True, is_valid))
            else:
                print(f"✗ Aucune image trouvée")
                results.append((query, False, False))
        except Exception as e:
            print(f"✗ ERREUR: {e}")
            results.append((query, False, False))
    
    success_count = sum(1 for _, found, valid in results if found and valid)
    print(f"\nRésultat: {success_count}/{len(test_queries)} images valides trouvées")
    return success_count > 0


async def test_base64_conversion():
    """Test de conversion URL -> Base64"""
    print("\n" + "="*80)
    print("TEST 3: Conversion des images en Base64 (Data URI)")
    print("="*80)
    
    test_urls = [
        # Vraie image publique (petite)
        "https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4f7.svg",
        # Autre petite image
        "https://www.w3schools.com/css/img_5terre.jpg",
    ]
    
    results = []
    for idx, url in enumerate(test_urls, 1):
        print(f"\n[{idx}] URL: {url}")
        try:
            data_uri = url_to_base64(url)
            if data_uri:
                size_kb = len(data_uri) / 1024
                is_valid = data_uri.startswith('data:image/')
                status = "✓" if is_valid else "✗"
                print(f"{status} Converti en Base64 ({size_kb:.1f} KB)")
                print(f"   Prefix: {data_uri[:80]}...")
                results.append((url, True))
            else:
                print(f"✗ Conversion échouée (retorna None)")
                results.append((url, False))
        except Exception as e:
            print(f"✗ ERREUR: {type(e).__name__}: {e}")
            results.append((url, False))
    
    success_count = sum(1 for _, success in results if success)
    print(f"\nRésultat: {success_count}/{len(test_urls)} conversions réussies")
    return success_count > 0


async def test_cache():
    """Test du caching des résultats de scraping"""
    print("\n" + "="*80)
    print("TEST 4: Caching des résultats de scraping")
    print("="*80)
    
    clear_image_cache()
    
    query = "test_cache_word"
    
    print(f"🔍 Première recherche: '{query}'")
    import time
    start = time.time()
    result1 = fetch_icon_url(query)
    time1 = time.time() - start
    print(f"   Résultat: {result1[:50] if result1 else 'Pas trouvé'}...")
    print(f"   Temps: {time1:.2f}s")
    
    print(f"\n🔄 Deuxième recherche (devrait être en cache): '{query}'")
    start = time.time()
    result2 = fetch_icon_url(query)
    time2 = time.time() - start
    print(f"   Résultat: {result2[:50] if result2 else 'Pas trouvé'}...")
    print(f"   Temps: {time2:.2f}s")
    
    # Vérification
    same_result = result1 == result2
    faster = time2 < time1
    
    print(f"\nVérifications:")
    print(f"  - Résultats identiques: {same_result} ✓" if same_result else f"  - Résultats identiques: {same_result} ✗")
    print(f"  - Deuxième appel plus rapide: {faster} {'✓ (cache hit)' if faster else '✗'}")
    
    return same_result


async def test_error_handling():
    """Test de gestion des erreurs"""
    print("\n" + "="*80)
    print("TEST 5: Gestion des erreurs")
    print("="*80)
    
    error_cases = [
        ("https://nonexistent.invalid.domain.test/image.png", "Domaine invalide"),
        ("https://httpstat.us/500", "Erreur serveur (500)"),
        ("https://httpstat.us/404", "Erreur 404"),
        ("https://example.com/huge_image_fake.jpg", "Image inexistante"),
    ]
    
    results = []
    for url, description in error_cases:
        print(f"\n⚠️ Test: {description}")
        try:
            result = url_to_base64(url, max_retries=0)  # Pas de retry pour les tests
            if result is None:
                print(f"   ✓ Gracefully handled (retourna None)")
                results.append(True)
            else:
                print(f"   ✗ Devrait retourner None, got: {str(result)[:50]}")
                results.append(False)
        except Exception as e:
            print(f"   ✗ Exception non capturée: {type(e).__name__}: {e}")
            results.append(False)
    
    success_count = sum(results)
    print(f"\nRésultat: {success_count}/{len(error_cases)} erreurs gérées correctement")
    return success_count == len(error_cases)


async def main():
    """Exécute tous les tests"""
    print("""
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║     TEST COMPLET - SYSTÈME DE RECHERCHE ET TÉLÉCHARGEMENT D'IMAGES        ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
    """)
    
    try:
        results = {
            "Validation URLs": await test_image_url_validation(),
            "Scraping images": await test_image_scraping(),
            "Conversion Base64": await test_base64_conversion(),
            "Caching": await test_cache(),
            "Gestion erreurs": await test_error_handling(),
        }
        
        print("\n" + "="*80)
        print("RÉSUMÉ FINAL")
        print("="*80)
        
        for test_name, passed in results.items():
            status = "✓ PASS" if passed else "✗ FAIL"
            print(f"{status}: {test_name}")
        
        total_passed = sum(1 for v in results.values() if v)
        print(f"\nTotal: {total_passed}/{len(results)} test suites réussis")
        
        if total_passed == len(results):
            print("\n✅ TOUS LES TESTS SONT PASSÉS!")
            return 0
        else:
            print(f"\n⚠️ {len(results) - total_passed} test(s) échoué(s)")
            return 1
            
    except Exception as e:
        logger.error(f"Erreur fatale lors des tests: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)
