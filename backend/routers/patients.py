import uuid
from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete as sa_delete
from sqlalchemy.orm import selectinload

from database import get_db
from models import Patient, Photo
from schemas import PatientCreate, PatientUpdate, PatientResponse

import os
import shutil

router = APIRouter(prefix="/api/v1/patients", tags=["patients"])

STORAGE_PATH = os.getenv("STORAGE_PATH", "./storage")


@router.get("", response_model=list[PatientResponse])
async def list_patients(
    search: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    query = select(Patient).order_by(Patient.created_at.desc())
    if search:
        query = query.where(Patient.name.ilike(f"%{search}%"))
    result = await db.execute(query)
    patients = result.scalars().all()
    return patients


@router.post("", response_model=PatientResponse, status_code=status.HTTP_201_CREATED)
async def create_patient(
    patient_data: PatientCreate,
    db: AsyncSession = Depends(get_db),
):
    patient = Patient(
        id=str(uuid.uuid4()),
        name=patient_data.name,
        age=patient_data.age,
        sex=patient_data.sex,
        weight_kg=patient_data.weight_kg,
        height_cm=patient_data.height_cm,
        reason=patient_data.reason,
        notes=patient_data.notes,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    db.add(patient)
    await db.commit()
    await db.refresh(patient)
    return patient


@router.get("/{patient_id}", response_model=PatientResponse)
async def get_patient(
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
    return patient


@router.put("/{patient_id}", response_model=PatientResponse)
async def update_patient(
    patient_id: str,
    patient_data: PatientUpdate,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Patient).where(Patient.id == patient_id))
    patient = result.scalar_one_or_none()
    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado",
        )

    update_data = patient_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(patient, key, value)

    patient.updated_at = datetime.utcnow()
    await db.commit()
    await db.refresh(patient)
    return patient


@router.delete("/{patient_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_patient(
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

    # Delete patient's photo files from storage
    patient_storage = os.path.join(STORAGE_PATH, patient_id)
    if os.path.exists(patient_storage):
        shutil.rmtree(patient_storage)

    await db.delete(patient)
    await db.commit()
