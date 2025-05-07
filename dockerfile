# syntax=docker/dockerfile:1.4

# Używamy oficjalnego obrazu Pythona jako bazowego
FROM python:3.11-slim

# Informacje o autorze zgodne ze standardem OCI
LABEL org.opencontainers.image.authors="Ernest Okseniuk"
LABEL org.opencontainers.image.title="Weather App for PAwChO"
LABEL org.opencontainers.image.description="Simple weather application for Programming Applications in Cloud Computing course"

# Ustawienie zmiennych środowiskowych
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PORT=5000

# Utworzenie użytkownika bez uprawnień roota
RUN addgroup --system appgroup && \
    adduser --system --group appgroup

# Ustawienie katalogu roboczego
WORKDIR /app

# Kopiowanie plików potrzebnych do instalacji zależności
COPY requirements.txt .

# Instalacja zależności
RUN pip install --no-cache-dir -r requirements.txt

# Kopiowanie plików aplikacji
COPY app.py .
COPY templates/ templates/

# Zmiana właściciela plików aplikacji
RUN chown -R appgroup:appgroup /app

# Przełączenie na użytkownika bez uprawnień roota
USER appgroup

# Expose port defined by environment variable
EXPOSE $PORT

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/ || exit 1

# Uruchomienie aplikacji
CMD ["python", "app.py"]