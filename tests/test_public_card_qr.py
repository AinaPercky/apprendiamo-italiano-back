"""Tests unitaires du contrôle cryptographique des liens QR publics."""

import unittest

from app import crud_public_card_qr


class PublicCardQRSignatureTests(unittest.TestCase):
    def test_valid_signature_is_accepted(self):
        token = "un-jeton-opaque-de-test"
        signature = crud_public_card_qr._sign_token(token)
        self.assertTrue(crud_public_card_qr._valid_signature(token, signature))

    def test_modified_signature_is_rejected(self):
        token = "un-jeton-opaque-de-test"
        signature = crud_public_card_qr._sign_token(token)
        altered = ("0" if signature[-1] != "0" else "1")
        self.assertFalse(crud_public_card_qr._valid_signature(token, signature[:-1] + altered))

    def test_signature_cannot_be_reused_for_another_token(self):
        signature = crud_public_card_qr._sign_token("carte-a")
        self.assertFalse(crud_public_card_qr._valid_signature("carte-b", signature))


if __name__ == "__main__":
    unittest.main()
