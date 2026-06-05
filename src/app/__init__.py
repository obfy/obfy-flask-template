from flask import Flask, jsonify, request

from app.services import pricing_quote

app = Flask(__name__)


@app.get("/quote")
def quote():
    units = int(request.args.get("units", 1))
    return jsonify(pricing_quote(units))
