# HIS ID OCR Service - Dockerfile
# Lightweight Tesseract-based OCR for Hugging Face Spaces

# Stage 1: Builder
FROM python:3.10-slim as builder

WORKDIR /app

# Install system dependencies needed for building
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Create virtual environment and install dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# Stage 2: Runtime
FROM python:3.10-slim

WORKDIR /app

# Install runtime system dependencies
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-eng \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code
COPY app/ ./app/

# Create upload directories
RUN mkdir -p app/uploads/raw app/uploads/masked

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Hugging Face Spaces requires port 7860
EXPOSE 7860

# No HEALTHCHECK - let HF Spaces handle health detection natively

# Run the application on port 7860 (required by Hugging Face Spaces)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]
