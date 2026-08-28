import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv

load_dotenv()

from database import create_tables
from routers.patients import router as patients_router
from routers.photos import router as photos_router
from schemas import HealthResponse

STORAGE_PATH = os.getenv("STORAGE_PATH", "./storage")
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create database tables on startup
    await create_tables()
    # Ensure storage directory exists
    os.makedirs(STORAGE_PATH, exist_ok=True)
    yield


app = FastAPI(
    title="Biomech AI API",
    description="API para la aplicación de análisis biomecánico podológico",
    version="0.1.0",
    lifespan=lifespan,
)

# CORS configuration
origins = ALLOWED_ORIGINS.split(",") if ALLOWED_ORIGINS != "*" else ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount storage as static files
app.mount("/storage", StaticFiles(directory=STORAGE_PATH), name="storage")

# Include routers
app.include_router(patients_router)
app.include_router(photos_router)


@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(status="ok", version="0.1.0")
