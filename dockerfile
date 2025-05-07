# syntax=docker/dockerfile:1.4

# Etap 1: Budowanie zależności
FROM python:3.11-slim AS builder

# Informacje o autorze zgodne ze standardem OCI
LABEL org.opencontainers.image.authors="Jan Kowalski <jan.kowalski@example.com>"
LABEL org.opencontainers.image.title="Weather App for PAwChO"
LABEL org.opencontainers.image.description="Simple weather application for Programming Applications in Cloud Computing course"

# Ustawienie zmiennych środowiskowych
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build

# Kopiowanie tylko plików potrzebnych do instalacji zależności
COPY requirements.txt .

# Instalacja zależności do osobnego katalogu
RUN pip install --no-cache-dir --user -r requirements.txt

# Etap 2: Tworzenie minimalnego obrazu końcowego
FROM python:3.11-slim

# Informacje o autorze zgodne ze standardem OCI
LABEL org.opencontainers.image.authors="Ernest Okseniuk"
LABEL org.opencontainers.image.title="Weather App for PAwChO"
LABEL org.opencontainers.image.description="Simple weather application for Programming Applications in Cloud Computing course"

# Ustawienie zmiennych środowiskowych
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

# Utworzenie użytkownika bez uprawnień roota
RUN addgroup --system appgroup && \
    adduser --system --group appgroup && \
    mkdir -p /app /app/templates && \
    chown -R appgroup:appgroup /app

# Kopiowanie zainstalowanych zależności z etapu builder
COPY --from=builder /root/.local /home/appgroup/.local

# Ustawienie ścieżki do zainstalowanych pakietów Pythona
ENV PATH=/home/appgroup/.local/bin:$PATH

WORKDIR /app

# Kopiowanie plików aplikacji
COPY app.py /app/
COPY templates/ /app/templates/

# Zmiana właściciela plików aplikacji
RUN chown -R appgroup:appgroup /app

# Przełączenie na użytkownika bez uprawnień roota
USER appgroup

# Expose port defined by environment variable
EXPOSE $PORT

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/ || exit 1

# Uruchomienie aplikacji za pomocą gunicorn
CMD gunicorn --bind 0.0.0.0:$PORT app:app