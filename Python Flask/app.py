from flask import Flask
import webbrowser
import threading

# Selenium imports
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options
import time

app = Flask(__name__)

@app.route('/')
def hello():
    return "<h1>Hello, World!</h1><p>Welcome to Flask!</p>"

@app.route('/login-screener')
def login_screener():
    try:
        # Chrome driver setup
        chrome_options = Options()
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--start-maximized")

        driver = webdriver.Chrome(service=ChromeService(), options=chrome_options)

        # Go to login page
        driver.get("https://www.screener.in/login/")
        time.sleep(2)

        # Login credentials
        email_input = driver.find_element(By.ID, "id_username")
        password_input = driver.find_element(By.ID, "id_password")

        email_input.send_keys("janetfernando9@gmail.com")
        password_input.send_keys("Joanna1627")
        password_input.send_keys(Keys.RETURN)

        return "<p>Login attempted. Check browser.</p>"
    except Exception as e:
        return f"<p>Error: {str(e)}</p>"

def open_browser():
    webbrowser.open_new("http://127.0.0.1:5000/")

if __name__ == "__main__":
    threading.Timer(1, open_browser).start()
    app.run(debug=False)
