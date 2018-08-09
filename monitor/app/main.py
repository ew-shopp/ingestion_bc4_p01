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
import jsonlines
import os.path
#from time import sleep
#from threading import Thread, Event
import time

__author__ = 'slynn'

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
app.config['DEBUG'] = True

#turn the flask app into a socketio app
socketio = SocketIO(app)

class Files():
    def __init__(self, num = 0, size = 0):
        self._num = num
        self._size = size

    def copy(self):
        return Files(self._num, self._size)
                
    def addFiles(self, files):
        self._num += files.getNum()
        self._size += files.getSize()
        
    def getNum(self):
        return self._num
        
    def getSize(self):
        return self._size

class Times():
    def __init__(self, epoch = '0', iso = '0'):
        self._epoch = epoch
        self._iso = iso

    def getIso(self):
        return self._iso
        
    def getEpoch(self):
        ret = 0
        try:
            ret = int(self._epoch)
        except ValueError:
            ret = 0
            
        return ret
        
    def getNowDuration(self):
        nowEpoch = int(time.time())
        return nowEpoch - self.getEpoch()

class Event():
    def __init__(self, msgDict):
        self._msgType = msgDict.get('type')
        self._msgTime = Times(msgDict.get('time_epoch'), msgDict.get('time_iso'))
        self._msgLog  = msgDict.get('log')
        self._msgName = msgDict.get('name')
        self._msgFilename = msgDict.get('filename')
        self._msgFilesize = msgDict.get('filesize')
        self._endTime = Times()
        
    def getName(self):
        return self._msgName
        
    def getTime(self):
        return self._msgTime
        
    def getFilename(self):
        return self._msgFilename
        
    def getFilesize(self):
        ret = 0
        try:
            ret = int(self._msgFilesize)
        except ValueError:
            ret = 0
            
        return ret

    
    def setEndTime(self, timeObj):
        self._endTime = timeObj
      
class Entry():
    _entryArr = []

    @staticmethod
    def getEntryByIndex(index):
        ret = None
        if index < len(Entry._entryArr):
            ret = Entry._entryArr(index)
            
        return ret
    
    def __init__(self, msgIdDict):
        self._msgIdDict = msgIdDict
        self._msgInst = msgIdDict.get('inst')
        self._msgHost = msgIdDict.get('host')
        self._msgType = msgIdDict.get('type')
        self._updates = 0
        self._events = []
        self._subs = {}
        self._start = Times()
        self._end = Times()
        self._state = 'init'
        self._lastEvent = None
        self._inFiles = Files()
        self._outFiles =  Files()
        self._subInFiles = Files()
        self._subOutFiles =  Files()
        
        # Add obj into array for later lookup by index
        self._myIndex = len(Entry._entryArr)
        Entry._entryArr.append(self)

    def post(self, msgDict):
        self._updates += 1
        #print "updates: %d" % (self._updates)
        print "(%s)msgDict: %s" % (self._msgInst, msgDict)

        if msgDict.has_key('event'):
            eventDict = msgDict.get('event')
            if not eventDict is None:
                print type(eventDict)
                print eventDict
                newEvent = Event(eventDict)
                self._events.append(newEvent)
                eventName = newEvent.getName()
                eventTime = newEvent.getTime()
                print "(%s)newEvent: %s %s" % (self._msgInst, eventName, eventTime.getIso())
                if self._lastEvent != None:
                    self._lastEvent.setEndTime(eventTime)
                    
                if eventName == 'start':
                    self._start = eventTime
                    self._state = eventName
                if eventName == 'end':
                    self._end = eventTime
                    self._state = eventName
                if eventName == 'infile':
                    print "infile"
                    self._inFiles.addFiles( Files(1, newEvent.getFilesize()))
                    print self._inFiles
                if eventName == 'outfile':
                    self._outFiles.addFiles( Files(1, newEvent.getFilesize()))

                self._lastEvent = newEvent
            
        if msgDict.has_key('sub'):
            subDict = msgDict.get('sub')
            if not subDict is None:
                subIdDict = subDict.get('id')
                subInst = subIdDict.get('inst')
                subHost = subIdDict.get('host')
                subType = subIdDict.get('type')
                
                if not self._subs.has_key(subInst):
                    self._subs[subInst] = Entry(subIdDict)

                sub = self._subs[subInst]
                sub.post(subDict)
                
                subInFiles = Files()
                subOutFiles = Files()
                for key in self._subs:
                    subInFiles.addFiles(self._subs[key].getInFiles())
                    subOutFiles.addFiles(self._subs[key].getOutFiles())

                self._subInFiles = subInFiles
                self._subOutFiles = subOutFiles
        
        # Generate new html for entry
        sectionHtml = self.getDetailHtml()
        socketio.emit(str(self._myIndex), {'section': sectionHtml}, namespace='/commio')

    def getInFiles(self):
        ret = self._inFiles.copy()
        ret.addFiles(self._subInFiles)
        return ret
        
    def getOutFiles(self):
        ret = self._outFiles.copy()
        ret.addFiles(self._subOutFiles)
        return ret

    def getDurationSec(self):
        if self._start.getEpoch() == 0:
            return 0
        if self._end.getEpoch() == 0:
            return self._start.getNowDuration()
            
        return self._end.getEpoch() - self._start.getEpoch()
        
    def isActive(self):
        ret = True
        if self._state == 'end':
            ret = False
        return ret
        
    def getDetailHtml(self):
        contentHtml = ""
        try:
            contentHtml += "This is instance %s with index %s updates %d" % (self._msgInst, self._myIndex, self._updates) 
            #contentHtml += "Bla"
        except:
            contentHtml = ""
        
        return contentHtml

    def getSummaryHtml(self):
        contentHtml = ""
        
        contentHtml += '<div class="entry-sum-card mdl-card mdl-shadow--2dp">'
        contentHtml += '  <div class="mdl-card__title">'
        contentHtml += '    <h3 class="mdl-card__title-text">%s</h3>' % self._msgHost
        contentHtml += '  </div>'
        contentHtml += '  <div class="mdl-card__menu">'
        contentHtml += '    <a href="/entry/%d">' % self._myIndex
        contentHtml += '      <button class="mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect">'
        contentHtml += '        <i class="material-icons">unfold_more</i>'
        contentHtml += '      </button>'
        contentHtml += '    </a>'
        contentHtml += '  </div>'
        contentHtml += '  <div class="mdl-card__supporting-text">'
        
        contentHtml += "<table>"
        contentHtml += "<tr><td>%s</td><td>%s</td></tr>" % ('State', self._state)
        contentHtml += "<tr><td>%s</td><td>%s</td></tr>" % ('Start', self._start.getIso())
        contentHtml += "<tr><td>%s</td><td>%s</td></tr>" % ('End', self._end.getIso())
        durationSec = self.getDurationSec()
        contentHtml += "<tr><td>%s</td><td>%s</td></tr>" % ('Duration (s)', durationSec)
        contentHtml += "<tr><td>%s</td><td>%d</td></tr>" % ('Events', len(self._events))
        
        active = 0
        for key in self._subs:
            if self._subs[key].isActive():
                active += 1
        contentHtml += "<tr><td>%s</td><td>%d / %d</td></tr>" % ('Subs', active, len(self._subs))
        
        inFiles = self.getInFiles()
        sizeKb = inFiles.getSize()/1024.0
        kbPrMin = 0
        if durationSec > 0:
            kbPrMin = sizeKb / (durationSec/60.0)
        contentHtml += "<tr><td>%s</td><td>%d / %.3f </td></tr>" % ('In files n / kB', inFiles.getNum(), sizeKb)
        contentHtml += "<tr><td>%s</td><td> %.3f</td></tr>" % ('- kB per min', kbPrMin)         

        outFiles = self.getOutFiles()
        sizeKb = outFiles.getSize()/1024.0
        kbPrMin = 0
        if durationSec > 0:
            kbPrMin = sizeKb / (durationSec/60.0)
        contentHtml += "<tr><td>%s</td><td>%d / %.3f</td></tr>" % ('Out files', outFiles.getNum(), sizeKb)
        contentHtml += "<tr><td>%s</td><td> %.3f</td></tr>" % ('- kB per min', kbPrMin)         
            
        contentHtml += "</table>"

        contentHtml += '  </div>'
        contentHtml += '</div>'        
        return contentHtml

class StateMonitor():
    def __init__(self, logFilename):
        self._entries = {}
        self._logFilename = logFilename
        
    def readFromLog(self):
        if os.path.isfile(self._logFilename):
            print "Starting to read from file: " + self._logFilename
            with jsonlines.open(self._logFilename) as reader:
                for jsonStr in reader:
                    #print "Read json " + jsonStr
                    self.post(json.loads(jsonStr), True)
                    
            print "Reached end in file: " + self._logFilename
            self.updatePage()
        else:
            print "Cannot find file: " + self._logFilename


    def writeToLog(self, dictToWrite):
        jsonStr = json.dumps(dictToWrite)
        #print "Write json " + jsonStr
        with jsonlines.open(self._logFilename, mode='a') as writer:
            writer.write(jsonStr)
        
    def post(self, msgDict, startup = False):
        if not startup:
            self.writeToLog(msgDict)
        
        msgIdDict = msgDict.get('id')
        
        msgInst = msgIdDict.get('inst')
        msgType = msgIdDict.get('type')
        if not self._entries.has_key(msgType):
            self._entries[msgType] = {}
        typeDict = self._entries[msgType]
            
        if not typeDict.has_key(msgInst):
            typeDict[msgInst] = Entry(msgIdDict)
        entry = typeDict[msgInst]
            
        entry.post(msgDict)

        if not startup:
            self.updatePage()
            

    def updatePage(self):        
        sectionHtml = ""
        
        sectionHtml += '<div class="type-sum-container">'
        
        msgTypes = sorted(list(self._entries.keys()))
        for msgType in msgTypes:
            typeDict = self._entries[msgType]
            sectionHtml += '<div>'
            
            sectionHtml += '<div class="inst-sum-container">'
            sectionHtml += '<div class="rotate-text">'
            sectionHtml += msgType
            sectionHtml += '</div>'
            
            msgInsts = sorted(list(typeDict.keys()))
            for msgInst in msgInsts:
                sectionHtml += '<div>'
                entry = typeDict[msgInst]
                sectionHtml += entry.getSummaryHtml()
                sectionHtml += '</div>'
            sectionHtml += '</div>'
                
            sectionHtml += '</div>'

        sectionHtml += '</div>'
        
        socketio.emit('top', {'section': sectionHtml}, namespace='/commio')
       
stateMonitor = StateMonitor('log.jsonl')
stateMonitor.readFromLog()

@app.route('/')
def index():
    #only by sending this page first will the client be connected to the socketio instance
    return render_template('index.html')

@app.route('/entry/<index>')
def entryIndex(index):
    return render_template('index.html')

@app.route('/log', methods = ['POST'])
def api_log():
    if request.headers['Content-Type'] == 'application/json':
        print json.dumps(request.json)

        stateMonitor.post(request.json)
        return "ok"
    else:
        return "415 Unsupported Media Type ;)"

@socketio.on('connect', namespace='/commio')
def commio_connect():
    # need visibility of the global thread object
    #global thread
    print('Client connected')
    stateMonitor.updatePage()

@socketio.on('disconnect', namespace='/commio')
def commio_disconnect():
    print('Client disconnected')


if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=int("5000"))

