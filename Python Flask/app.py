from flask import Flask
import webbrowser
import threading

app = Flask(__name__)

@app.route('/')
def hello():
    return "<h1>Hello, World!</h1><p>Welcome to Flask!</p>"

def open_browser():
    webbrowser.open_new("http://127.0.0.1:5000/")

if __name__ == "__main__":
    threading.Timer(1, open_browser).start()
    app.run(debug=False)
