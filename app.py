from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "CI/CD Pipeline Working on Jenkins + Docker! If you're seeing this page, it means updates have been automatically Served successfully."

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
