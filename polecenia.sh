
docker build -t weather-app:latest .

docker run -d -p 5000:5000 -e WEATHER_API_KEY=16793ee11aa9ba8414ebd6820689c1ce --name weather-container weather-app:latest


docker logs weather-container

docker history weather-app:latest --no-trunc

docker images weather-app:latest




git init
git add .
git commit -m "Dodanie aplikacji pogodowej dla PAwChO"

git remote add origin https://github.com/ernestokseniuk/sprawozdanie.git
git branch -M main
git push -u origin main


docker tag weather-app:latest emistrz28/sprawozdanie:latest
docker login
docker push emistrz28/sprawozdanie:latest

read -p "Naciśnij dowolny klawisz, aby zakończyć skrypt..." -n1 -s
