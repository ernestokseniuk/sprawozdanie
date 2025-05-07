import os
import logging
import datetime
import requests
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

# Konfiguracja logowania
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Konfiguracja API pogodowego
WEATHER_API_KEY = os.environ.get('WEATHER_API_KEY', 'a1b2c3d4e5f6g7h8i9j0') # Domyślny klucz zastępczy
WEATHER_API_URL = "https://api.openweathermap.org/data/2.5/weather"

# Lista miast i krajów
CITIES = {
    "polska": ["Warszawa", "Kraków", "Gdańsk", "Poznań", "Wrocław"],
    "niemcy": ["Berlin", "Monachium", "Hamburg", "Frankfurt", "Kolonia"],
    "francja": ["Paryż", "Marsylia", "Lyon", "Nicea", "Bordeaux"],
    "włochy": ["Rzym", "Mediolan", "Neapol", "Florencja", "Wenecja"],
    "hiszpania": ["Madryt", "Barcelona", "Walencja", "Sewilla", "Malaga"]
}

@app.route('/')
def index():
    """Strona główna z formularzem wyboru miasta i kraju"""
    return render_template('index.html', cities=CITIES)

@app.route('/api/cities/<country>')
def get_cities(country):
    """Endpoint API zwracający miasta dla wybranego kraju"""
    country = country.lower()
    if country in CITIES:
        return jsonify(CITIES[country])
    return jsonify([])

@app.route('/weather', methods=['GET'])
def get_weather():
    """Pobiera i wyświetla dane pogodowe dla wybranego miasta"""
    city = request.args.get('city', '')
    country = request.args.get('country', '')
    
    if not city or not country:
        return render_template('error.html', message="Proszę wybrać kraj i miasto")
    
    # Pobieranie danych pogodowych
    params = {
        'q': f"{city},{country}",
        'appid': WEATHER_API_KEY,
        'units': 'metric',
        'lang': 'pl'
    }
    
    try:
        response = requests.get(WEATHER_API_URL, params=params)
        response.raise_for_status()
        weather_data = response.json()
        
        # Przygotowanie danych do wyświetlenia
        weather = {
            'city': city,
            'country': country,
            'temperature': weather_data['main']['temp'],
            'feels_like': weather_data['main']['feels_like'],
            'humidity': weather_data['main']['humidity'],
            'pressure': weather_data['main']['pressure'],
            'description': weather_data['weather'][0]['description'],
            'icon': weather_data['weather'][0]['icon'],
            'wind_speed': weather_data['wind']['speed'],
            'clouds': weather_data['clouds']['all']
        }
        
        return render_template('weather.html', weather=weather)
    
    except Exception as e:
        logger.error(f"Błąd podczas pobierania danych pogodowych: {str(e)}")
        return render_template('error.html', message="Nie udało się pobrać danych pogodowych")

if __name__ == '__main__':
    # Pobranie portu z zmiennej środowiskowej lub domyślny 5000
    port = int(os.environ.get('PORT', 5000))
    
    # Logowanie informacji o uruchomieniu
    author = "Jan Kowalski"  # Zmień na swoje imię i nazwisko
    start_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    logger.info(f"=== INFORMACJE O URUCHOMIENIU ===")
    logger.info(f"Data uruchomienia: {start_time}")
    logger.info(f"Autor: {author}")
    logger.info(f"Port nasłuchiwania: {port}")
    logger.info(f"================================")
    
    app.run(host='0.0.0.0', port=port)