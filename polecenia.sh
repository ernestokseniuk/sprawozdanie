# a. Polecenie do zbudowania obrazu kontenera
docker build -t weather-app:latest .

# b. Polecenie do uruchomienia kontenera na podstawie zbudowanego obrazu
# Zastąp YOUR_API_KEY swoim kluczem API z OpenWeatherMap
docker run -d -p 5000:5000 -e WEATHER_API_KEY=16793ee11aa9ba8414ebd6820689c1ce --name weather-container weather-app:latest

# c. Polecenie do uzyskania informacji z logów
docker logs weather-container

# d. Polecenia do sprawdzenia liczby warstw i rozmiaru obrazu
# Sprawdzenie liczby warstw
docker history weather-app:latest --no-trunc

# Sprawdzenie rozmiaru obrazu
docker images weather-app:latest

# e. Dodatkowe polecenia do publikacji na GitHub i DockerHub

# Inicjalizacja repozytorium Git i pierwszy commit
git init
git add .
git commit -m "Dodanie aplikacji pogodowej dla PAwChO"

# Dodanie zdalnego repozytorium GitHub (zastąp USERNAME swoją nazwą użytkownika)
git remote add origin https://github.com/ernestokseniuk/sprawozdanie.git
git branch -M main
git push -u origin main

# Tagowanie i wysyłanie obrazu na DockerHub (zastąp USERNAME swoją nazwą użytkownika)
docker tag weather-app:latest ernestokseniuk/sprawozdanie:latest
docker login
docker push ernestokseniuk/sprawozdanie:latest