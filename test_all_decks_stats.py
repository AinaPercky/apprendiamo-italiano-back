import requests
import random
import string
import json

BASE_URL = "http://localhost:8000"

def generate_random_string(length=10):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

def create_user():
    email = f"{generate_random_string()}@example.com"
    password = "password123"
    full_name = f"User {generate_random_string()}"
    
    payload = {
        "email": email,
        "password": password,
        "full_name": full_name
    }
    
    response = requests.post(f"{BASE_URL}/api/users/register", json=payload)
    if response.status_code != 201:
        print(f"Failed to create user: {response.text}")
        return None, None
        
    return email, password

def login(email, password):
    payload = {
        "email": email,
        "password": password
    }
    response = requests.post(f"{BASE_URL}/api/users/login", json=payload)
    if response.status_code != 200:
        print(f"Failed to login: {response.text}")
        return None
    
    return response.json()["access_token"]

def test_new_user_decks():
    print("--- Testing New User Scenario ---")
    email, password = create_user()
    if not email:
        return
    
    token = login(email, password)
    if not token:
        return
    
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/api/users/decks/all", headers=headers)
    
    if response.status_code != 200:
        print(f"Failed to get decks: {response.text}")
        return

    decks = response.json()
    print(f"Number of decks returned: {len(decks)}")
    
    # Check if 45 decks are returned (or whatever the total system decks count is, user said 45)
    if len(decks) != 45:
        print(f"WARNING: Expected 45 decks, got {len(decks)}")
    else:
        print("SUCCESS: 45 decks returned.")

    # Check stats
    all_zero = True
    for deck in decks:
        if deck['success_rate'] != 0:
            print(f"FAILURE: Deck {deck['deck']['name']} has success_rate {deck['success_rate']} != 0")
            all_zero = False
        if deck['progress'] != 0:
            print(f"FAILURE: Deck {deck['deck']['name']} has progress {deck['progress']} != 0")
            all_zero = False
            
    if all_zero:
        print("SUCCESS: All decks have 0% stats for new user.")

def test_existing_user_scenario():
    print("\n--- Testing Existing User Scenario (Simulated) ---")
    # 1. Create User
    email, password = create_user()
    token = login(email, password)
    headers = {"Authorization": f"Bearer {token}"}
    
    # 2. Get decks to find a deck ID (e.g. first one)
    response = requests.get(f"{BASE_URL}/api/users/decks/all", headers=headers)
    decks = response.json()
    if not decks:
        print("No decks found to test with.")
        return
        
    target_deck = decks[0]
    deck_pk = target_deck['deck']['deck_pk']
    print(f"Testing with Deck ID: {deck_pk} ({target_deck['deck']['name']})")
    
    # 3. Submit a score for this deck
    # We explicitly add the deck first to mimic user starting a deck, although score submission might handle it.
    # But let's be explicit to ensure 'user_deck' exists for stats update.
    requests.post(f"{BASE_URL}/api/users/decks/{deck_pk}", headers=headers)
    
    score_payload = {
        "score": 100,
        "is_correct": True,
        "deck_pk": deck_pk,
        "quiz_type": "classique"
    }
    
    score_res = requests.post(f"{BASE_URL}/api/users/scores", json=score_payload, headers=headers)
    if score_res.status_code != 201:
        print(f"Failed to submit score: {score_res.text}")
        return

    print("Score submitted successfully.")
    
    # 4. Fetch decks again
    response = requests.get(f"{BASE_URL}/api/users/decks/all", headers=headers)
    if response.status_code != 200:
        print(f"Failed to get decks after score: Status {response.status_code}, Body: {response.text}")
        return
    print(f"DEBUG: Response text: '{response.text}'")
    decks = response.json()
    
    # 5. Verify only target deck has stats
    target_deck_updated = next((d for d in decks if d['deck']['deck_pk'] == deck_pk), None)
    if not target_deck_updated:
        print("Target deck not found in response.")
        return
        
    print(f"Target Deck Success Rate: {target_deck_updated['success_rate']}%")
    
    if target_deck_updated['success_rate'] > 0:
        print("SUCCESS: Target deck has updated stats.")
    else:
        print("FAILURE: Target deck stats did not update.")
        
    # Check others are still 0
    others_zero = True
    for deck in decks:
        if deck['deck']['deck_pk'] != deck_pk:
            if deck['success_rate'] != 0:
                print(f"FAILURE: Other deck {deck['deck']['name']} has success_rate {deck['success_rate']} != 0")
                others_zero = False
    
    if others_zero:
        print("SUCCESS: Other decks remain at 0%.")

if __name__ == "__main__":
    try:
        test_new_user_decks()
        test_existing_user_scenario()
    except Exception as e:
        print(f"An error occurred: {e}")
