from flask import Flask, redirect
app = Flask(__name__)

@app.route("/")
def home():
    return redirect ("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)