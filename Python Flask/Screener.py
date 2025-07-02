from flask import Flask, jsonify
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

app = Flask(__name__)

@app.route('/scrape')
def scrape_website():
    url = "https://www.screener.in/screens/29890289/swing_stocks/"

    # Set up Chrome driver with headless mode
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    # Launch browser
    driver = webdriver.Chrome(options=options)
    driver.get(url)

    # Get page title
    page_title = driver.title

    # (Optional) Collect more data — like stock names
    stock_elements = driver.find_elements(By.CSS_SELECTOR, "td.text.left.golden.small > a")
    stock_names = [el.text for el in stock_elements]

    driver.quit()

    return jsonify({
        "title": page_title,
        "stocks": stock_names
    })

if __name__ == "__main__":
    app.run(debug=True)
