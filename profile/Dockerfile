
# Stage 1: Builder
FROM python:3.11-slim AS builder

# Prevent Python from writing pyc files
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /install

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies into /install
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --prefix=/install -r requirements.txt


# Stage 2: Runtime

FROM python:3.11-slim

EXPOSE 5000

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy only installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy application source
COPY . /app

# Create non-root user
RUN adduser --disabled-password --gecos "" --uid 5678 appuser \
    && chown -R appuser /app

USER appuser

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
