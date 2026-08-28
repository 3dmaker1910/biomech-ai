from pydantic import BaseModel, ConfigDict, Field
from typing import Optional
from datetime import datetime


class PatientCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    age: int = Field(..., ge=0, le=150)
    sex: str = Field(..., pattern="^(masculino|femenino|otro)$")
    weight_kg: float = Field(..., gt=0, le=500)
    height_cm: float = Field(..., gt=0, le=300)
    reason: str = Field(..., min_length=1, max_length=100)
    notes: Optional[str] = Field(None, max_length=200)


class PatientUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    age: Optional[int] = Field(None, ge=0, le=150)
    sex: Optional[str] = Field(None, pattern="^(masculino|femenino|otro)$")
    weight_kg: Optional[float] = Field(None, gt=0, le=500)
    height_cm: Optional[float] = Field(None, gt=0, le=300)
    reason: Optional[str] = Field(None, min_length=1, max_length=100)
    notes: Optional[str] = Field(None, max_length=200)


class PatientResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    age: int
    sex: str
    weight_kg: float
    height_cm: float
    reason: str
    notes: Optional[str]
    created_at: datetime
    updated_at: datetime


class PhotoResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    patient_id: str
    photo_type: str
    file_path: str
    file_size: int
    width: int
    height: int
    created_at: datetime


class HealthResponse(BaseModel):
    status: str
    version: str
