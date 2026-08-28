import os
import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from PIL import Image as PILImage

from database import get_db
from models import Patient, Photo
from schemas import PhotoResponse

router = APIRouter(tags=["photos"])

STORAGE_PATH = os.getenv("STORAGE_PATH", "./storage")
MAX_FILE_SIZE_MB = int(os.getenv("MAX_FILE_SIZE_MB", "10"))

VALID_PHOTO_TYPES = [
    "frontal", "posterior", "perfil_izq", "perfil_der",
    "huella_izq", "huella_der", "pie_izq", "pie_der",
]


@router.get("/api/v1/patients/{patient_id}/photos", response_model=list[PhotoResponse])
async def list_patient_photos(
    patient_id: str,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Patient).where(Patient.id == patient_id))
    patient = result.scalar_one_or_none()
    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado",
        )

    result = await db.execute(
        select(Photo)
        .where(Photo.patient_id == patient_id)
        .order_by(Photo.created_at.desc())
    )
    photos = result.scalars().all()
    return photos


@router.post(
    "/api/v1/patients/{patient_id}/photos",
    response_model=PhotoResponse,
    status_code=status.HTTP_201_CREATED,
)
async def upload_photo(
    patient_id: str,
    photo_type: str = Form(...),
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Patient).where(Patient.id == patient_id))
    patient = result.scalar_one_or_none()
    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado",
        )

    if photo_type not in VALID_PHOTO_TYPES:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Tipo de foto inválido. Valores permitidos: {', '.join(VALID_PHOTO_TYPES)}",
        )

    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="El archivo debe ser una imagen (JPEG, PNG, etc.)",
        )

    content = await file.read()
    file_size = len(content)

    max_size_bytes = MAX_FILE_SIZE_MB * 1024 * 1024
    if file_size > max_size_bytes:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"El archivo excede el tamaño máximo de {MAX_FILE_SIZE_MB}MB",
        )

    try:
        import io
        img = PILImage.open(io.BytesIO(content))
        width, height = img.size
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="No se pudo procesar la imagen.",
        )

    if width < 200 or height < 200:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="La imagen es demasiado pequeña. Mínimo 200x200 píxeles.",
        )

    patient_dir = os.path.join(STORAGE_PATH, patient_id)
    os.makedirs(patient_dir, exist_ok=True)

    photo_id = str(uuid.uuid4())
    extension = file.filename.rsplit(".", 1)[-1] if file.filename and "." in file.filename else "jpg"
    filename = f"{photo_id}.{extension}"
    file_path = os.path.join(patient_dir, filename)

    with open(file_path, "wb") as f:
        f.write(content)

    relative_path = f"storage/{patient_id}/{filename}"

    photo = Photo(
        id=photo_id,
        patient_id=patient_id,
        photo_type=photo_type,
        file_path=relative_path,
        file_size=file_size,
        width=width,
        height=height,
        created_at=datetime.utcnow(),
    )
    db.add(photo)
    await db.commit()
    await db.refresh(photo)
    return photo


@router.delete("/api/v1/photos/{photo_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_photo(
    photo_id: str,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Photo).where(Photo.id == photo_id))
    photo = result.scalar_one_or_none()
    if not photo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Foto no encontrada",
        )

    full_path = os.path.join(STORAGE_PATH, photo.patient_id, os.path.basename(photo.file_path))
    if os.path.exists(full_path):
        os.remove(full_path)

    await db.delete(photo)
    await db.commit()
