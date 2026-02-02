# HIS ID OCR Service - Dockerfile for Render
# Lightweight Tesseract-based OCR

FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-eng \
    libgl1 \
    libglib2.0-0 \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/

# Create upload directories
RUN mkdir -p app/uploads/raw app/uploads/masked

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Render sets PORT environment variable dynamically
# Default to 8000 if not set
ENV PORT=8000

# Expose the port (Render will override this)
EXPOSE $PORT

# Run using shell form so $PORT is expanded
CMD uvicorn app.main:app --host 0.0.0.0 --port $PORT
