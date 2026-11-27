import json
from types import SimpleNamespace

import pytest
from fastapi import HTTPException

from app.permissions import has_permission
from app.client_applications import validate_app_code, get_client_application


def test_admin_has_client_application_management_permission():
    assert has_permission(SimpleNamespace(role="admin"), "client_apps:manage")


def test_teacher_cannot_manage_client_applications():
    assert not has_permission(SimpleNamespace(role="professeur"), "client_apps:manage")


def test_student_cannot_write_reference_content():
    assert not has_permission(SimpleNamespace(role="etudiant"), "content:update")


def test_teacher_keeps_existing_content_write_role():
    assert has_permission(SimpleNamespace(role="professeur"), "content:update")


def test_unknown_role_receives_no_permissions():
    assert not has_permission(SimpleNamespace(role="perckyl_ingua"), "content:update")


@pytest.mark.parametrize("value", ["perckyl-ingua", "studio", "mobile-app-1"])
def test_valid_client_application_codes(value):
    assert validate_app_code(value) == value


@pytest.mark.parametrize("value", ["", "AStudio", "with space", "a", "bad_code"])
def test_invalid_client_application_codes(value):
    with pytest.raises(ValueError):
        validate_app_code(value)


class FakeResult:
    def __init__(self, row):
        self.row = row
    def mappings(self):
        return self
    def first(self):
        return self.row


class FakeDb:
    def __init__(self, row):
        self.row = row
    async def execute(self, _statement):
        return FakeResult(self.row)


@pytest.mark.asyncio
async def test_missing_client_header_keeps_legacy_client_compatibility():
    result = await get_client_application(x_client_app=None, origin=None, db=FakeDb(None))
    assert result is None


@pytest.mark.asyncio
async def test_unknown_client_application_is_rejected():
    with pytest.raises(HTTPException) as error:
        await get_client_application(x_client_app="unknown-app", origin=None, db=FakeDb(None))
    assert error.value.status_code == 403


@pytest.mark.asyncio
async def test_inactive_client_application_is_rejected():
    row = {"code": "studio", "is_active": False, "allowed_origins": "[]"}
    with pytest.raises(HTTPException) as error:
        await get_client_application(x_client_app="studio", origin=None, db=FakeDb(row))
    assert error.value.status_code == 403


@pytest.mark.asyncio
async def test_registered_client_origin_is_checked():
    row = {"code": "studio", "is_active": True, "allowed_origins": json.dumps(["https://studio.example"])}
    with pytest.raises(HTTPException) as error:
        await get_client_application(x_client_app="studio", origin="https://evil.example", db=FakeDb(row))
    assert error.value.status_code == 403


@pytest.mark.asyncio
async def test_registered_client_origin_is_accepted():
    row = {"code": "studio", "is_active": True, "allowed_origins": json.dumps(["https://studio.example"])}
    result = await get_client_application(x_client_app="studio", origin="https://studio.example", db=FakeDb(row))
    assert result["code"] == "studio"
