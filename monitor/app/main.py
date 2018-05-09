from flask import Flask, url_for
from flask import request
import json

app = Flask(__name__)

@app.route('/')
def api_root():
    return 'Welcome to the Monitor server\n'
    
@app.route('/log', methods = ['POST'])
def api_log():
    if request.headers['Content-Type'] == 'application/json':
        print json.dumps(request.json)
        return "ok"
    else:
        return "415 Unsupported Media Type ;)"

    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int("5000"))
        
