from flask import Flask, jsonify
import boto3

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({"message": "Hello from ECR-optimized app!"})

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)