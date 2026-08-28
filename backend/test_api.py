import pytest
import os
import sys
import io
from unittest.mock import patch

sys.path.insert(0, os.path.dirname(__file__))

import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from database import Base, get_db
from main import app

TEST_DB_URL = "sqlite+aiosqlite:///./test_biomech.db"
test_engine = create_async_engine(TEST_DB_URL, echo=False)
test_async_session = async_sessionmaker(test_engine, class_=AsyncSession, expire_on_commit=False)


async def override_get_db():
    async with test_async_session() as session:
        try:
            yield session
        finally:
            await session.close()


app.dependency_overrides[get_db] = override_get_db


@pytest_asyncio.fixture(autouse=True)
async def setup_db():
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    if os.path.exists("./test_biomech.db"):
        os.remove("./test_biomech.db")


@pytest_asyncio.fixture
async def client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


@pytest.mark.asyncio
async def test_health_check(client):
    response = await client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["version"] == "0.1.0"


@pytest.mark.asyncio
async def test_create_patient(client):
    patient_data = {
        "name": "Juan Pérez",
        "age": 45,
        "sex": "masculino",
        "weight_kg": 78.5,
        "height_cm": 175.0,
        "reason": "Dolor",
        "notes": "Dolor en el arco plantar izquierdo",
    }
    response = await client.post("/api/v1/patients", json=patient_data)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Juan Pérez"
    assert data["age"] == 45
    assert "id" in data


@pytest.mark.asyncio
async def test_create_patient_without_notes(client):
    patient_data = {
        "name": "María García",
        "age": 30,
        "sex": "femenino",
        "weight_kg": 60.0,
        "height_cm": 165.0,
        "reason": "Revisión",
    }
    response = await client.post("/api/v1/patients", json=patient_data)
    assert response.status_code == 201
    data = response.json()
    assert data["notes"] is None


@pytest.mark.asyncio
async def test_create_patient_invalid_sex(client):
    patient_data = {"name": "Test", "age": 25, "sex": "invalid", "weight_kg": 70.0, "height_cm": 170.0, "reason": "Control"}
    response = await client.post("/api/v1/patients", json=patient_data)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_list_patients_empty(client):
    response = await client.get("/api/v1/patients")
    assert response.status_code == 200
    assert response.json() == []


@pytest.mark.asyncio
async def test_list_patients(client):
    await client.post("/api/v1/patients", json={"name": "Paciente A", "age": 30, "sex": "masculino", "weight_kg": 75.0, "height_cm": 175.0, "reason": "Dolor"})
    await client.post("/api/v1/patients", json={"name": "Paciente B", "age": 40, "sex": "femenino", "weight_kg": 65.0, "height_cm": 160.0, "reason": "Control"})
    response = await client.get("/api/v1/patients")
    assert response.status_code == 200
    assert len(response.json()) == 2


@pytest.mark.asyncio
async def test_search_patients(client):
    await client.post("/api/v1/patients", json={"name": "Juan Carlos", "age": 50, "sex": "masculino", "weight_kg": 80.0, "height_cm": 180.0, "reason": "Deportista"})
    await client.post("/api/v1/patients", json={"name": "Ana López", "age": 28, "sex": "femenino", "weight_kg": 55.0, "height_cm": 160.0, "reason": "Revisión"})
    response = await client.get("/api/v1/patients?search=juan")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["name"] == "Juan Carlos"


@pytest.mark.asyncio
async def test_get_patient(client):
    create_response = await client.post("/api/v1/patients", json={"name": "Test Patient", "age": 35, "sex": "otro", "weight_kg": 70.0, "height_cm": 170.0, "reason": "Otro"})
    patient_id = create_response.json()["id"]
    response = await client.get(f"/api/v1/patients/{patient_id}")
    assert response.status_code == 200
    assert response.json()["id"] == patient_id


@pytest.mark.asyncio
async def test_get_patient_not_found(client):
    response = await client.get("/api/v1/patients/nonexistent-id")
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_update_patient(client):
    create_response = await client.post("/api/v1/patients", json={"name": "Original Name", "age": 30, "sex": "masculino", "weight_kg": 75.0, "height_cm": 175.0, "reason": "Dolor"})
    patient_id = create_response.json()["id"]
    response = await client.put(f"/api/v1/patients/{patient_id}", json={"name": "Updated Name", "age": 31})
    assert response.status_code == 200
    assert response.json()["name"] == "Updated Name"


@pytest.mark.asyncio
async def test_delete_patient(client):
    create_response = await client.post("/api/v1/patients", json={"name": "To Delete", "age": 25, "sex": "femenino", "weight_kg": 60.0, "height_cm": 165.0, "reason": "Control"})
    patient_id = create_response.json()["id"]
    assert (await client.delete(f"/api/v1/patients/{patient_id}")).status_code == 204
    assert (await client.get(f"/api/v1/patients/{patient_id}")).status_code == 404


@pytest.mark.asyncio
async def test_upload_photo(client):
    create_response = await client.post("/api/v1/patients", json={"name": "Photo Test", "age": 40, "sex": "femenino", "weight_kg": 65.0, "height_cm": 160.0, "reason": "Dolor"})
    patient_id = create_response.json()["id"]
    from PIL import Image
    img = Image.new("RGB", (300, 300), color="white")
    img_bytes = io.BytesIO()
    img.save(img_bytes, format="PNG")
    img_bytes.seek(0)
    response = await client.post(f"/api/v1/patients/{patient_id}/photos", data={"photo_type": "frontal"}, files={"file": ("test.png", img_bytes, "image/png")})
    assert response.status_code == 201
    assert response.json()["photo_type"] == "frontal"
