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

class Service():
    def __init__(self, name):
        self._name = name
        self._updates = 0
        self._msgs = []

    def post(self, msgDict):
        self._updates += 1
        self._msgs.append(msgDict)
        #print "updates: %d" % (self.updates)
        print "msgDict: %s" % (msgDict)
        
    def getContent(self):
        contentHtml = ""
        contentHtml += "<table>"
        contentHtml += "<tr><th>%s</th></tr>" % self._name
        contentHtml += "<tr><th>Date</th><th>entry</th></tr>"
        
        i1 = 0
        i2 = len(self._msgs)
        if i2 > 4:
            i1 = i2 - 5
            
        for i in range(i1, i2):
            msg = self._msgs[i]
            contentHtml += "<tr><td>%s</td><td>%s</td></tr>" % (msg.get('date'), msg.get('entry'))
            
        contentHtml += "</table>"
        return contentHtml

class StateMonitor():
    def __init__(self):
        self._services = {}
        
    def post(self, msgDict):
        name = msgDict.get('host')
        if not self._services.has_key(name):
            service = Service(name)
            self._services[name] = service
        else:
            service = self._services[name]
            
        service.post(msgDict)
        self.updatePage()
            

    def updatePage(self):        
        sectionHtml = ""
        sectionHtml += "<table><tr>"
        for key in self._services:
            sectionHtml += "<td>"
            sectionHtml += self._services[key].getContent()
            sectionHtml += "</td>"
        sectionHtml += "</tr></table>"
        
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
    socketio.run(app, host='0.0.0.0', port=int("5000"))

