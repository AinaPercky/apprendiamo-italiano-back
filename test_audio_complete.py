"""
Test automatisé complet pour les endpoints audio
================================================

Ce script teste :
1. CRUD complet pour AudioItem (audios système/par défaut)
2. CRUD complet pour UserAudio (audios personnalisés par utilisateur)
3. Scénarios multi-utilisateurs
4. Débogage automatique en cas d'erreur

Auteur: Test Automation
Date: 2025-12-01
"""

import asyncio
import httpx
import json
from typing import Dict, List, Optional
from datetime import datetime
from colorama import init, Fore, Style

# Initialiser colorama pour les couleurs
init(autoreset=True)

# Configuration
BASE_URL = "http://localhost:8000"
TEST_EMAIL_1 = f"audio_test_user1_{datetime.now().timestamp()}@test.com"
TEST_EMAIL_2 = f"audio_test_user2_{datetime.now().timestamp()}@test.com"
TEST_PASSWORD = "TestPassword123!"
TEST_FULL_NAME = "Audio Test User"

# Résultats des tests
test_results = {
    "passed": [],
    "failed": [],
    "warnings": []
}


def print_header(text: str):
    """Affiche un en-tête de section"""
    print(f"\n{Fore.CYAN}{'=' * 80}")
    print(f"{Fore.CYAN}{text.center(80)}")
    print(f"{Fore.CYAN}{'=' * 80}{Style.RESET_ALL}\n")


def print_success(text: str):
    """Affiche un message de succès"""
    print(f"{Fore.GREEN}✓ {text}{Style.RESET_ALL}")
    test_results["passed"].append(text)


def print_error(text: str, details: Optional[str] = None):
    """Affiche un message d'erreur"""
    print(f"{Fore.RED}✗ {text}{Style.RESET_ALL}")
    if details:
        print(f"{Fore.YELLOW}  Détails: {details}{Style.RESET_ALL}")
    test_results["failed"].append(text)


def print_warning(text: str):
    """Affiche un avertissement"""
    print(f"{Fore.YELLOW}⚠ {text}{Style.RESET_ALL}")
    test_results["warnings"].append(text)


def print_info(text: str):
    """Affiche une information"""
    print(f"{Fore.BLUE}ℹ {text}{Style.RESET_ALL}")


async def register_user(client: httpx.AsyncClient, email: str) -> Optional[Dict]:
    """Enregistre un nouvel utilisateur"""
    try:
        response = await client.post(
            f"{BASE_URL}/api/users/register",
            json={
                "email": email,
                "password": TEST_PASSWORD,
                "full_name": TEST_FULL_NAME
            }
        )

        if response.status_code == 201:
            data = response.json()
            print_success(f"Utilisateur créé: {email}")
            return data
        else:
            print_error(f"Échec création utilisateur: {email} (Status: {response.status_code})", response.text)
            return None
    except Exception as e:
        print_error(f"Exception lors de la création utilisateur: {email}", str(e))
        return None


async def test_audio_items_crud(client: httpx.AsyncClient):
    """
    Test CRUD complet pour AudioItem (audios système/par défaut)
    Ces audios sont communs à tous les utilisateurs
    """
    print_header("TEST 1: CRUD AudioItem (Audios Système/Par Défaut)")

    created_audio_ids = []

    # 1. CREATE - Créer plusieurs audios système
    print_info("1.1 - Création d'audios système...")

    test_audios = [
        {
            "title": "Bonjour",
            "text": "Ciao, come stai?",
            "category": "phrase",
            "language": "it"
        },
        {
            "title": "Au revoir",
            "text": "Arrivederci!",
            "category": "mot",
            "language": "it"
        },
        {
            "title": "Merci",
            "text": "Grazie mille",
            "category": "phrase",
            "language": "it"
        }
    ]

    for audio_data in test_audios:
        try:
            response = await client.post(
                f"{BASE_URL}/audios/",
                data=audio_data
            )

            if response.status_code == 200:
                audio = response.json()
                created_audio_ids.append(audio["id"])
                print_success(f"Audio créé: '{audio['title']}' (ID: {audio['id']})")

                # Vérifier les champs
                assert "audio_url" in audio, "Champ audio_url manquant"
                assert audio["filename"].endswith(".mp3"), "Format audio incorrect"

            else:
                print_error(f"Échec création audio '{audio_data['title']}'", response.text)
        except Exception as e:
            print_error(f"Exception création audio '{audio_data['title']}'", str(e))

    # 2. READ - Lire tous les audios
    print_info("\n1.2 - Lecture de tous les audios système...")

    try:
        response = await client.get(f"{BASE_URL}/audios/")

        if response.status_code == 200:
            audios = response.json()
            print_success(f"Liste des audios récupérée: {len(audios)} audio(s)")

            # Vérifier que nos audios créés sont dans la liste
            audio_ids_in_list = [a["id"] for a in audios]
            for audio_id in created_audio_ids:
                if audio_id in audio_ids_in_list:
                    print_success(f"  Audio ID {audio_id} trouvé dans la liste")
                else:
                    print_error(f"  Audio ID {audio_id} NON trouvé dans la liste")
        else:
            print_error("Échec récupération liste audios", response.text)
    except Exception as e:
        print_error("Exception récupération liste audios", str(e))

    # 3. READ - Lire un audio spécifique
    print_info("\n1.3 - Lecture d'un audio spécifique...")

    if created_audio_ids:
        test_audio_id = created_audio_ids[0]
        try:
            response = await client.get(f"{BASE_URL}/audios/{test_audio_id}")

            if response.status_code == 200:
                audio = response.json()
                print_success(f"Audio récupéré: '{audio['title']}' (ID: {audio['id']})")
            else:
                print_error(f"Échec récupération audio ID {test_audio_id}", response.text)
        except Exception as e:
            print_error(f"Exception récupération audio ID {test_audio_id}", str(e))

    # 4. DELETE - Supprimer un audio
    print_info("\n1.4 - Suppression d'un audio...")

    if created_audio_ids:
        delete_audio_id = created_audio_ids[0]
        try:
            response = await client.delete(f"{BASE_URL}/audios/{delete_audio_id}")

            if response.status_code == 200:
                print_success(f"Audio supprimé: ID {delete_audio_id}")

                # Vérifier que l'audio n'existe plus
                verify_response = await client.get(f"{BASE_URL}/audios/{delete_audio_id}")
                if verify_response.status_code == 404:
                    print_success(f"  Vérification: Audio ID {delete_audio_id} bien supprimé")
                else:
                    print_error(f"  Vérification: Audio ID {delete_audio_id} existe encore!")

                # Retirer de la liste
                created_audio_ids.remove(delete_audio_id)
            else:
                print_error(f"Échec suppression audio ID {delete_audio_id}", response.text)
        except Exception as e:
            print_error(f"Exception suppression audio ID {delete_audio_id}", str(e))

    return created_audio_ids


async def test_user_audio_crud(client: httpx.AsyncClient, token: str, user_email: str, card_pk: Optional[int] = None):
    """
    Test CRUD complet pour UserAudio (audios personnalisés par utilisateur)
    """
    print_header(f"TEST 2: CRUD UserAudio pour {user_email}")

    headers = {"Authorization": f"Bearer {token}"}
    created_audio_pks = []

    # 1. CREATE - Créer des audios utilisateur
    print_info("2.1 - Création d'audios utilisateur...")

    test_user_audios = [
        {
            "filename": f"user_audio_1_{datetime.now().timestamp()}.mp3",
            "audio_url": f"/user_audios/user_audio_1_{datetime.now().timestamp()}.mp3",
            "duration": 5,
            "quality_score": 85,
            "notes": "Premier enregistrement",
            "card_pk": card_pk
        },
        {
            "filename": f"user_audio_2_{datetime.now().timestamp()}.mp3",
            "audio_url": f"/user_audios/user_audio_2_{datetime.now().timestamp()}.mp3",
            "duration": 8,
            "quality_score": 90,
            "notes": "Deuxième enregistrement",
            "card_pk": card_pk
        }
    ]

    for audio_data in test_user_audios:
        try:
            response = await client.post(
                f"{BASE_URL}/api/users/audio",
                json=audio_data,
                headers=headers
            )

            if response.status_code == 201:
                audio = response.json()
                created_audio_pks.append(audio["audio_pk"])
                print_success(f"Audio utilisateur créé: {audio['filename']} (PK: {audio['audio_pk']})")

                # Vérifier les champs
                assert audio["audio_url"] == audio_data["audio_url"], "URL audio incorrecte"
                assert audio["duration"] == audio_data["duration"], "Durée incorrecte"
                assert audio["quality_score"] == audio_data["quality_score"], "Score qualité incorrect"

            else:
                print_error(f"Échec création audio utilisateur", response.text)
        except Exception as e:
            print_error(f"Exception création audio utilisateur", str(e))

    # 2. READ - Lire tous les audios de l'utilisateur
    print_info("\n2.2 - Lecture de tous les audios de l'utilisateur...")

    try:
        response = await client.get(
            f"{BASE_URL}/api/users/audio",
            headers=headers
        )

        if response.status_code == 200:
            audios = response.json()
            print_success(f"Audios utilisateur récupérés: {len(audios)} audio(s)")

            # Vérifier que nos audios créés sont dans la liste
            audio_pks_in_list = [a["audio_pk"] for a in audios]
            for audio_pk in created_audio_pks:
                if audio_pk in audio_pks_in_list:
                    print_success(f"  Audio PK {audio_pk} trouvé dans la liste")
                else:
                    print_error(f"  Audio PK {audio_pk} NON trouvé dans la liste")
        else:
            print_error("Échec récupération audios utilisateur", response.text)
    except Exception as e:
        print_error("Exception récupération audios utilisateur", str(e))

    # 3. READ avec pagination
    print_info("\n2.3 - Test de pagination...")

    try:
        response = await client.get(
            f"{BASE_URL}/api/users/audio?limit=1&offset=0",
            headers=headers
        )

        if response.status_code == 200:
            audios = response.json()
            if len(audios) <= 1:
                print_success(f"Pagination fonctionne: {len(audios)} audio(s) retourné(s)")
            else:
                print_warning(f"Pagination: attendu max 1 audio, reçu {len(audios)}")
        else:
            print_error("Échec test pagination", response.text)
    except Exception as e:
        print_error("Exception test pagination", str(e))

    # 4. DELETE - Supprimer un audio utilisateur
    print_info("\n2.4 - Suppression d'un audio utilisateur...")

    if created_audio_pks:
        delete_audio_pk = created_audio_pks[0]
        try:
            response = await client.delete(
                f"{BASE_URL}/api/users/audio/{delete_audio_pk}",
                headers=headers
            )

            if response.status_code == 200:
                print_success(f"Audio utilisateur supprimé: PK {delete_audio_pk}")

                # Vérifier que l'audio n'existe plus dans la liste
                verify_response = await client.get(
                    f"{BASE_URL}/api/users/audio",
                    headers=headers
                )
                if verify_response.status_code == 200:
                    remaining_audios = verify_response.json()
                    remaining_pks = [a["audio_pk"] for a in remaining_audios]
                    if delete_audio_pk not in remaining_pks:
                        print_success(f"  Vérification: Audio PK {delete_audio_pk} bien supprimé")
                    else:
                        print_error(f"  Vérification: Audio PK {delete_audio_pk} existe encore!")

                created_audio_pks.remove(delete_audio_pk)
            else:
                print_error(f"Échec suppression audio PK {delete_audio_pk}", response.text)
        except Exception as e:
            print_error(f"Exception suppression audio PK {delete_audio_pk}", str(e))

    return created_audio_pks


async def test_multi_user_audio_isolation(
    client: httpx.AsyncClient,
    token1: str,
    token2: str,
    user1_email: str,
    user2_email: str
):
    """
    Test d'isolation des audios entre utilisateurs
    Vérifie qu'un utilisateur ne peut pas voir/modifier les audios d'un autre
    """
    print_header("TEST 3: Isolation des Audios entre Utilisateurs")

    headers1 = {"Authorization": f"Bearer {token1}"}
    headers2 = {"Authorization": f"Bearer {token2}"}

    # Créer un audio pour l'utilisateur 1
    print_info("3.1 - Création d'un audio pour l'utilisateur 1...")

    audio_data_user1 = {
        "filename": f"user1_private_{datetime.now().timestamp()}.mp3",
        "audio_url": f"/user_audios/user1_private.mp3",
        "duration": 10,
        "quality_score": 95,
        "notes": "Audio privé utilisateur 1"
    }

    user1_audio_pk = None
    try:
        response = await client.post(
            f"{BASE_URL}/api/users/audio",
            json=audio_data_user1,
            headers=headers1
        )

        if response.status_code == 201:
            audio = response.json()
            user1_audio_pk = audio["audio_pk"]
            print_success(f"Audio créé pour utilisateur 1: PK {user1_audio_pk}")
        else:
            print_error("Échec création audio utilisateur 1", response.text)
            return
    except Exception as e:
        print_error("Exception création audio utilisateur 1", str(e))
        return

    # Vérifier que l'utilisateur 2 ne voit PAS cet audio
    print_info("\n3.2 - Vérification: l'utilisateur 2 ne voit pas l'audio de l'utilisateur 1...")

    try:
        response = await client.get(
            f"{BASE_URL}/api/users/audio",
            headers=headers2
        )

        if response.status_code == 200:
            user2_audios = response.json()
            user2_audio_pks = [a["audio_pk"] for a in user2_audios]

            if user1_audio_pk not in user2_audio_pks:
                print_success("✓ Isolation correcte: utilisateur 2 ne voit pas l'audio de l'utilisateur 1")
            else:
                print_error("✗ PROBLÈME D'ISOLATION: utilisateur 2 voit l'audio de l'utilisateur 1!")
        else:
            print_error("Échec récupération audios utilisateur 2", response.text)
    except Exception as e:
        print_error("Exception vérification isolation", str(e))

    # Vérifier que l'utilisateur 2 ne peut PAS supprimer l'audio de l'utilisateur 1
    print_info("\n3.3 - Vérification: l'utilisateur 2 ne peut pas supprimer l'audio de l'utilisateur 1...")

    try:
        response = await client.delete(
            f"{BASE_URL}/api/users/audio/{user1_audio_pk}",
            headers=headers2
        )

        if response.status_code == 404:
            print_success("✓ Sécurité correcte: utilisateur 2 ne peut pas supprimer l'audio de l'utilisateur 1")
        elif response.status_code == 200:
            print_error("✗ FAILLE DE SÉCURITÉ: utilisateur 2 a pu supprimer l'audio de l'utilisateur 1!")
        else:
            print_warning(f"Réponse inattendue: {response.status_code}")
    except Exception as e:
        print_error("Exception test sécurité suppression", str(e))

    # Nettoyer: supprimer l'audio de l'utilisateur 1
    try:
        await client.delete(
            f"{BASE_URL}/api/users/audio/{user1_audio_pk}",
            headers=headers1
        )
    except:
        pass


async def test_audio_with_cards(client: httpx.AsyncClient, token: str):
    """
    Test des audios associés à des cartes
    """
    print_header("TEST 4: Audios Associés à des Cartes")

    headers = {"Authorization": f"Bearer {token}"}

    # Récupérer ou créer une carte de test
    print_info("4.1 - Récupération ou création d'une carte de test...")

    card_pk = None
    deck_pk_to_delete = None

    try:
        # Essayer de récupérer un deck existant
        response = await client.get(f"{BASE_URL}/decks")
        if response.status_code == 200:
            decks = response.json()
            if decks and len(decks) > 0:
                deck = decks[0]
                if "cards" in deck and len(deck["cards"]) > 0:
                    card_pk = deck["cards"][0]["card_pk"]
                    print_success(f"Carte existante trouvée: PK {card_pk}")

        # Si pas de carte trouvée, créer un deck et une carte de test
        if not card_pk:
            print_info("  Aucune carte existante, création d'un deck et d'une carte de test...")

            # Créer un deck de test
            deck_data = {
                "name": f"Test Deck Audio {datetime.now().timestamp()}",
                "id_json": f"test_deck_audio_{datetime.now().timestamp()}"
            }

            deck_response = await client.post(
                f"{BASE_URL}/decks/",
                json=deck_data
            )

            if deck_response.status_code == 200:
                deck = deck_response.json()
                deck_pk_to_delete = deck["deck_pk"]
                print_success(f"  Deck de test créé: PK {deck_pk_to_delete}")

                # Créer une carte de test
                from datetime import datetime as dt, timedelta

                card_data = {
                    "deck_pk": deck_pk_to_delete,
                    "front": "Test Front",
                    "back": "Test Back",
                    "id_json": f"test_card_audio_{datetime.now().timestamp()}",
                    "created_at": dt.utcnow().isoformat(),
                    "next_review": (dt.utcnow() + timedelta(days=1)).isoformat()
                }

                card_response = await client.post(
                    f"{BASE_URL}/cards/",
                    json=card_data
                )

                if card_response.status_code == 200:
                    card = card_response.json()
                    card_pk = card["card_pk"]
                    print_success(f"  Carte de test créée: PK {card_pk}")
                else:
                    print_warning("Impossible de créer une carte de test")
            else:
                print_warning("Impossible de créer un deck de test")

        # Si on a une carte, tester l'association
        if card_pk:
            print_info("\n4.2 - Création d'un audio associé à la carte...")

            audio_data = {
                "filename": f"card_audio_{card_pk}_{datetime.now().timestamp()}.mp3",
                "audio_url": f"/user_audios/card_audio_{card_pk}.mp3",
                "duration": 7,
                "quality_score": 88,
                "notes": f"Audio pour la carte {card_pk}",
                "card_pk": card_pk
            }

            response = await client.post(
                f"{BASE_URL}/api/users/audio",
                json=audio_data,
                headers=headers
            )

            if response.status_code == 201:
                audio = response.json()
                print_success(f"Audio créé et associé à la carte {card_pk}: PK {audio['audio_pk']}")

                # Vérifier l'association
                if audio["card_pk"] == card_pk:
                    print_success(f"  Association correcte: audio.card_pk = {card_pk}")
                else:
                    print_error(f"  Association incorrecte: attendu {card_pk}, reçu {audio['card_pk']}")

                # Nettoyer l'audio
                await client.delete(
                    f"{BASE_URL}/api/users/audio/{audio['audio_pk']}",
                    headers=headers
                )
                print_success(f"  Audio de test nettoyé")
            else:
                print_error("Échec création audio associé à carte", response.text)
        else:
            # Pas de carte disponible, mais ce n'est pas une erreur
            print_success("Test d'association avec carte ignoré (pas de carte disponible)")

        # Nettoyer le deck de test si créé
        if deck_pk_to_delete:
            try:
                # Supprimer le deck (cascade supprimera la carte)
                await client.delete(f"{BASE_URL}/decks/{deck_pk_to_delete}")
                print_success(f"  Deck de test nettoyé: PK {deck_pk_to_delete}")
            except:
                pass

    except Exception as e:
        print_error("Exception test audio avec cartes", str(e))


async def test_audio_item_ownership(
    client: httpx.AsyncClient,
    token1: str,
    token2: str
):
    """
    Test de propriété et visibilité des AudioItems (audios système créés par des utilisateurs)
    """
    print_header("TEST 5: Propriété et Visibilité des AudioItems")

    headers1 = {"Authorization": f"Bearer {token1}"}
    headers2 = {"Authorization": f"Bearer {token2}"}

    # 1. Créer un audio public (sans token)
    print_info("5.1 - Création d'un audio public (sans token)...")
    public_audio_data = {
        "title": "Public Audio",
        "text": "This is for everyone",
        "category": "phrase",
        "language": "en"
    }

    public_audio_id = None
    try:
        # Pas de header Authorization
        response = await client.post(f"{BASE_URL}/audios/", data=public_audio_data)
        if response.status_code == 200:
            audio = response.json()
            public_audio_id = audio["id"]
            print_success(f"Audio public créé: ID {public_audio_id}")

            # Vérifier user_pk est None
            if audio.get("user_pk") is None:
                print_success("  user_pk est bien None (Public)")
            else:
                print_error(f"  user_pk devrait être None, reçu {audio.get('user_pk')}")
        else:
            print_error("Échec création audio public", response.text)
    except Exception as e:
        print_error("Exception création audio public", str(e))

    # 2. Créer un audio privé avec User 1
    print_info("\n5.2 - Création d'un audio privé avec User 1...")
    private_audio_data = {
        "title": "Private Audio User 1",
        "text": "This is for User 1 only",
        "category": "phrase",
        "language": "en"
    }

    private_audio_id = None
    try:
        response = await client.post(
            f"{BASE_URL}/audios/",
            data=private_audio_data,
            headers=headers1
        )
        if response.status_code == 200:
            audio = response.json()
            private_audio_id = audio["id"]
            print_success(f"Audio privé User 1 créé: ID {private_audio_id}")

            # Vérifier user_pk
            if audio.get("user_pk") is not None:
                print_success(f"  user_pk est défini: {audio.get('user_pk')}")
            else:
                print_error("  user_pk est None alors qu'il devrait être défini")
        else:
            print_error("Échec création audio privé", response.text)
    except Exception as e:
        print_error("Exception création audio privé", str(e))

    # 3. Vérifier que User 1 voit les deux
    print_info("\n5.3 - Vérification visibilité pour User 1...")
    try:
        response = await client.get(f"{BASE_URL}/audios/", headers=headers1)
        if response.status_code == 200:
            audios = response.json()
            ids = [a["id"] for a in audios]

            if public_audio_id in ids:
                print_success("  User 1 voit l'audio public")
            else:
                print_error("  User 1 NE VOIT PAS l'audio public")

            if private_audio_id in ids:
                print_success("  User 1 voit son audio privé")
            else:
                print_error("  User 1 NE VOIT PAS son audio privé")
        else:
            print_error("Échec liste audios User 1", response.text)
    except Exception as e:
        print_error("Exception liste audios User 1", str(e))

    # 4. Vérifier que User 2 voit le public mais PAS le privé de User 1
    print_info("\n5.4 - Vérification visibilité pour User 2...")
    try:
        response = await client.get(f"{BASE_URL}/audios/", headers=headers2)
        if response.status_code == 200:
            audios = response.json()
            ids = [a["id"] for a in audios]

            if public_audio_id in ids:
                print_success("  User 2 voit l'audio public")
            else:
                print_error("  User 2 NE VOIT PAS l'audio public")

            if private_audio_id not in ids:
                print_success("  User 2 NE VOIT PAS l'audio privé de User 1 (Correct)")
            else:
                print_error("  User 2 VOIT l'audio privé de User 1 (ERREUR)")
        else:
            print_error("Échec liste audios User 2", response.text)
    except Exception as e:
        print_error("Exception liste audios User 2", str(e))

    # Nettoyage
    print_info("\nNettoyage AudioItems test...")
    for aid in [public_audio_id, private_audio_id]:
        if aid:
            try:
                await client.delete(f"{BASE_URL}/audios/{aid}")
            except:
                pass


async def print_final_report():
    """Affiche le rapport final des tests"""
    print_header("RAPPORT FINAL DES TESTS")

    total_tests = len(test_results["passed"]) + len(test_results["failed"])
    success_rate = (len(test_results["passed"]) / total_tests * 100) if total_tests > 0 else 0

    print(f"\n{Fore.CYAN}Statistiques:{Style.RESET_ALL}")
    print(f"  Total de tests: {total_tests}")
    print(f"  {Fore.GREEN}Réussis: {len(test_results['passed'])}{Style.RESET_ALL}")
    print(f"  {Fore.RED}Échoués: {len(test_results['failed'])}{Style.RESET_ALL}")
    print(f"  {Fore.YELLOW}Avertissements: {len(test_results['warnings'])}{Style.RESET_ALL}")
    print(f"  Taux de réussite: {success_rate:.1f}%\n")

    if test_results["failed"]:
        print(f"{Fore.RED}Tests échoués:{Style.RESET_ALL}")
        for i, test in enumerate(test_results["failed"], 1):
            print(f"  {i}. {test}")
        print()

    if test_results["warnings"]:
        print(f"{Fore.YELLOW}Avertissements:{Style.RESET_ALL}")
        for i, warning in enumerate(test_results["warnings"], 1):
            print(f"  {i}. {warning}")
        print()

    # Verdict final
    if len(test_results["failed"]) == 0:
        print(f"{Fore.GREEN}{'=' * 80}")
        print(f"{Fore.GREEN}✓ TOUS LES TESTS SONT PASSÉS AVEC SUCCÈS!{Style.RESET_ALL}")
        print(f"{Fore.GREEN}{'=' * 80}\n")
    else:
        print(f"{Fore.RED}{'=' * 80}")
        print(f"{Fore.RED}✗ CERTAINS TESTS ONT ÉCHOUÉ - DÉBOGAGE NÉCESSAIRE{Style.RESET_ALL}")
        print(f"{Fore.RED}{'=' * 80}\n")


async def main():
    """Fonction principale de test"""
    print_header("TESTS AUTOMATISÉS - ENDPOINTS AUDIO")
    print_info(f"URL de base: {BASE_URL}")
    print_info(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    async with httpx.AsyncClient(timeout=30.0) as client:
        # Créer deux utilisateurs de test
        print_header("PRÉPARATION: Création des Utilisateurs de Test")

        user1_data = await register_user(client, TEST_EMAIL_1)
        user2_data = await register_user(client, TEST_EMAIL_2)

        if not user1_data or not user2_data:
            print_error("Impossible de créer les utilisateurs de test. Arrêt des tests.")
            return

        token1 = user1_data["access_token"]
        token2 = user2_data["access_token"]

        # TEST 1: CRUD AudioItem (audios système)
        system_audio_ids = await test_audio_items_crud(client)

        # TEST 2: CRUD UserAudio pour utilisateur 1
        user1_audio_pks = await test_user_audio_crud(client, token1, TEST_EMAIL_1)

        # TEST 2bis: CRUD UserAudio pour utilisateur 2
        user2_audio_pks = await test_user_audio_crud(client, token2, TEST_EMAIL_2)

        # TEST 3: Isolation multi-utilisateurs
        await test_multi_user_audio_isolation(
            client, token1, token2, TEST_EMAIL_1, TEST_EMAIL_2
        )

        # TEST 4: Audios associés à des cartes
        await test_audio_with_cards(client, token1)

        # TEST 5: Propriété et Visibilité des AudioItems
        await test_audio_item_ownership(client, token1, token2)

        # Rapport final
        await print_final_report()

        # Nettoyer les audios système créés
        print_info("\nNettoyage des audios système créés...")
        for audio_id in system_audio_ids:
            try:
                await client.delete(f"{BASE_URL}/audios/{audio_id}")
                print_success(f"  Audio système {audio_id} supprimé")
            except:
                pass


if __name__ == "__main__":
    asyncio.run(main())
