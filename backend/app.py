from flask import Flask

app = Flask(__name__)


@app.get("/")
def index():
    return {"message": "Flask is up and running!"}
