"""
Demo Flask application to test the operation of Flask with socket.io

Aim is to create a webpage that is constantly updated with random numbers from a background python process.

30th May 2014

===================

Updated 13th April 2018

+ Upgraded code to Python 3
+ Used Python3 SocketIO implementation
+ Updated CDN Javascript and CSS sources

"""




# Start with a basic flask app webpage.
from flask_socketio import SocketIO, emit
from flask import Flask, render_template, url_for, copy_current_request_context
from flask import request
import json
from random import random
from time import sleep
from threading import Thread, Event

__author__ = 'slynn'

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
app.config['DEBUG'] = True

#turn the flask app into a socketio app
socketio = SocketIO(app)

class StateMonitor():
    def __init__(self):
        self.updates = 0
        self.msgs = []
        
    def post(self, msgDict):
        self.updates += 1
        print "updates: %d" % (self.updates)
        print "msgDict: %s" % (msgDict)
        self.msgs.append(msgDict)
        sectionHtml = ""
        sectionHtml += "<table>"
        sectionHtml += "<tr><th>Date</th><th>Host</th><th>entry</th></tr>"
        for msg in self.msgs:
            sectionHtml += "<tr><td>%s</td><td>%s</td><td>%s</td></tr>" % (msg.get('date'), msg.get('host'), msg.get('entry'))
        sectionHtml += "</table>"
        print sectionHtml
        socketio.emit('dynsection', {'dynsection': sectionHtml}, namespace='/test')
       
stateMonitor = StateMonitor()

@app.route('/')
def index():
    #only by sending this page first will the client be connected to the socketio instance
    return render_template('index.html')

@app.route('/log', methods = ['POST'])
def api_log():
    if request.headers['Content-Type'] == 'application/json':
        print json.dumps(request.json)
        stateMonitor.post(request.json)
        return "ok"
    else:
        return "415 Unsupported Media Type ;)"

@socketio.on('connect', namespace='/test')
def test_connect():
    # need visibility of the global thread object
    #global thread
    print('Client connected')

    ##Start the random number generator thread only if the thread has not been started before.
    #if not thread.isAlive():
    #    print("Starting Thread")
    #    thread = RandomThread()
    #    thread.start()

@socketio.on('disconnect', namespace='/test')
def test_disconnect():
    print('Client disconnected')


if __name__ == '__main__':
    socketio.run(app)
