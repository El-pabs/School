from flask import Flask
import socket

app = Flask(__name__)

@app.route("/") # Endpoint racine de l'application
def hello():
    return f"Nous sommes actuellement dans le socket : {socket.gethostname()}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)