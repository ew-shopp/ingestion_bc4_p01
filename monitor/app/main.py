
from flask_socketio import SocketIO, emit
from flask import Flask, render_template, url_for, copy_current_request_context
from flask import request
import json
import jsonlines
import os.path
import time

__author__ = 'sdalgard'

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
app.config['DEBUG'] = True

#turn the flask app into a socketio app
socketio = SocketIO(app)

class SidEntry():
    def __init__(self, sid):
        self._sid = sid
        self._connect = 0
        self._disconnect = 0
        
    def connect(self):
        self._connect += 1
        
    def disconnect(self):
        self._disconnect +=1
        
    def connections(self):
        return self._connect - self._disconnect
        
    def status(self):
        stat = "Conns:%d Conn:%d Disc:%d Sid:<%s>" % (self.connections(), self._connect, self._disconnect, self._sid)
        return stat
        
class Connections():
    def __init__(self):
        self._sidEntries = {}
        
    def connectSid(self, sid):
        se = self._sidEntries.get(sid)
        
        if se is None:
            se = SidEntry(sid)
            se.connect()
            self._sidEntries[sid] = se
        else:
            se.connect()

        #print "ConnectSid(%s) now %d connections" % (sid, se.connections())
            
    def disconnectSid(self, sid):
        se = self._sidEntries.get(sid)
        if se is None:
            print "DisconnectSid(%s) cannot find entry" % sid
        else:
            se.disconnect()
            #print "DisconnectSid(%s) now %d connections" % (sid, se.connections())
            
    def status(self):
        count = 0
        for key in self._sidEntries:
            se = self._sidEntries[key]
            if se.connections() != 0:
                count += 1
                print "%d - %s" % (count, se.status())            
        
        
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
    def __init__(self, epoch = '0', iso = ''):
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
        
    def getNowDurationEpoch(self):
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

    def getOnelineHtml(self):
        contentHtml = ''
        contentHtml += '%s : %s' % (self._msgType, self._msgName)
        return contentHtml
      
class Entry():
    _entryArr = []  #Static array with all entries

    @staticmethod
    def getEntryByIndex(index):
        ret = None

        if index < 0:
            return None
            
        if index < len(Entry._entryArr):
            ret = Entry._entryArr[index]
            
        return ret
    
    def __init__(self, msgIdDict):
        self._msgIdDict = msgIdDict
        self._msgInst = msgIdDict.get('inst')
        self._msgHost = msgIdDict.get('host')
        self._msgType = msgIdDict.get('type')
        self._hasListener = 0
        self._updates = 0
        self._events = []
        self._subs = {}
        self._start = Times(int(time.time()))
        self._end = Times()
        self._state = ''
        self._parentEntry = None
        self._lastEvent = None
        self._inFiles = Files()
        self._inFilename = ""
        self._outFiles =  Files()
        self._subInFiles = Files()
        self._subOutFiles =  Files()
        
        # Add obj into array for later lookup by index
        self._myIndex = len(Entry._entryArr)
        Entry._entryArr.append(self)

    def setParentEntry(self, parentEntry):
        self._parentEntry = parentEntry

    def reportSubStart(self, start):
        if self._start.getIso() == '':
            self._start = start
        
    def reportParentEnd(self, end):
        if self._end.getIso() == '':
            self._end = end
        
    def requestUpdate(self):
        self._hasListener = 2 # Make some margin in case of lost requests
        self.sendUpdate()
        
    def subscribeUpdate(self):
        self._hasListener = 2 # Make some margin in case of lost requests
        
    def sendUpdate(self):
        if self._hasListener > 0:
            self._hasListener -= 1
            # Generate new html for entry
            sectionHtml = self.getDetailHtml()
            socketio.emit('entry'+str(self._myIndex), {'section': sectionHtml}, namespace='/commio')
        
    def post(self, msgDict):
        self._updates += 1
        #print "updates: %d" % (self._updates)
        #print "(%s)msgDict: %s" % (self._msgInst, msgDict)

        if msgDict.has_key('event'):
            eventDict = msgDict.get('event')
            if not eventDict is None:
                #print type(eventDict)
                #print eventDict
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
                    parent = self._parentEntry
                    if not parent is None:
                        parent.reportSubStart(eventTime)
                        
                if eventName == 'end':
                    self._end = eventTime
                    self._state = eventName
                    for key in self._subs:
                        self._subs[key].reportParentEnd(eventTime)
                    
                if eventName == 'infile':
                    print "infile"
                    self._inFiles.addFiles( Files(1, newEvent.getFilesize()))
                    if self._inFilename == "":
                        self._inFilename = newEvent.getFilename()
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
                    entry = Entry(subIdDict)
                    entry.setParentEntry(self)
                    self._subs[subInst] = entry

                sub = self._subs[subInst]
                sub.post(subDict)
                
                subInFiles = Files()
                subOutFiles = Files()
                for key in self._subs:
                    subInFiles.addFiles(self._subs[key].getInFiles())
                    subOutFiles.addFiles(self._subs[key].getOutFiles())

                self._subInFiles = subInFiles
                self._subOutFiles = subOutFiles
        
        self.sendUpdate()

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
            return self._start.getNowDurationEpoch()
            
        return self._end.getEpoch() - self._start.getEpoch()
        
    def isActive(self):
        ret = True
        if self._state == 'end':
            ret = False
        return ret
        
    def makeCard(self, supportingHtml):
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
        
        contentHtml += supportingHtml

        contentHtml += '  </div>'
        contentHtml += '</div>'        
        return contentHtml
        
    def makeSummaryTable(self):
        contentHtml = ""
        
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
        
        return contentHtml
    
    def makeSessionTable(self):
        contentHtml = ''

        contentHtml += "<table>"

        sortedSubKeys = sorted(list(self._subs.keys()))
        for subKey in sortedSubKeys:
            sub = self._subs[subKey]
            contentHtml += "<tr><td>%s</td></tr>" % (sub.getOnelineHtml())

        contentHtml += "</table>"
        return contentHtml

    def makeEventTable(self):
        contentHtml = ''

        contentHtml += "<table>"

        for event in self._events:
            contentHtml += "<tr><td>%s</td></tr>" % (event.getOnelineHtml())

        contentHtml += "</table>"
        return contentHtml

    def getOnelineHtml(self):
        contentHtml = ''
        contentHtml += '<a href="/entry/%d">' % self._myIndex
        contentHtml += '%s - %s' % (self._state, self.getTitle())
        contentHtml += '</a>' 
        return contentHtml
            
    def getTitle(self):
        hasHost = False
        
        title = self._msgType
        if self._inFilename != "":
            title += " : %s" % self._inFilename
        else:
            if (not self._msgHost is None) and (self._msgHost != ""):
                title += " : %s" % self._msgHost
                
            if self._msgHost != 'top':
                if self._start.getIso() != "":
                    title += " : %s" % self._start.getIso()

        return title
        
    def getDetailHtml(self):
        contentHtml = ''

        summaryTableHtml = self.makeSummaryTable()
        sessionTableHtml = self.makeSessionTable()
        eventTableHtml = self.makeEventTable()


        contentHtml = ""
        contentHtml += '<div class="entry-detail-card mdl-card mdl-shadow--2dp">'
        contentHtml += '  <div class="mdl-card__title">'
        
        contentHtml += '    <h3 class="mdl-card__title-text">%s</h3>' % self.getTitle()
        contentHtml += '  </div>'
        contentHtml += '  <div class="mdl-card__supporting-text">'

        contentHtml += '    <div class="entry-detail-container">'
        contentHtml += '      <div>'
        contentHtml +=          summaryTableHtml
        contentHtml += '      </div>'
        contentHtml += '      <div>'
        contentHtml +=          sessionTableHtml
        contentHtml += '      </div>'
        contentHtml += '      <div>'
        contentHtml +=          eventTableHtml
        contentHtml += '      </div>'
        contentHtml += '    </div>'


        contentHtml += '  </div>'
        contentHtml += '</div>'        

        return contentHtml

    def getSummaryHtml(self):
        contentHtml = ""

        summaryTableHtml = self.makeSummaryTable()

        contentHtml += '<div class="entry-sum-card mdl-card mdl-shadow--2dp">'
        contentHtml += '  <div class="mdl-card__title">'

        title = "%s : %s" % (self._msgType, self._msgInst)
        contentHtml += '    <h3 class="mdl-card__title-text">%s</h3>' % title
        contentHtml += '  </div>'
        contentHtml += '  <div class="mdl-card__menu">'
        contentHtml += '    <a href="/entry/%d">' % self._myIndex
        contentHtml += '      <button class="mdl-button mdl-button--icon mdl-js-button mdl-js-ripple-effect">'
        contentHtml += '        <i class="material-icons">unfold_more</i>'
        contentHtml += '      </button>'
        contentHtml += '    </a>'
        contentHtml += '  </div>'
        contentHtml += '  <div class="mdl-card__supporting-text">'
        
        contentHtml += summaryTableHtml

        contentHtml += '  </div>'
        contentHtml += '</div>'        

        return contentHtml

class StateMonitor():
    def __init__(self, logFilename):
        self._types = {}
        self._logFilename = logFilename
        self._hasListener = 0
        
    def requestUpdate(self):
        self._hasListener = 2 # Make some margin in case of lost requests
        self.sendUpdate()
        
    def subscribeUpdate(self):
        self._hasListener = 2 # Make some margin in case of lost requests
        
    def sendUpdate(self):
        if self._hasListener > 0:
            self._hasListener -= 1
            # Generate new html for summary page
            sectionHtml = self.getSummaryHtml()
            socketio.emit('top', {'section': sectionHtml}, namespace='/commio')
        
    def post(self, msgDict, startup = False):
        if not startup:
            self.writeToLog(msgDict)

        msgIdDict = msgDict.get('id')
        
        msgInst = msgIdDict.get('inst')
        msgType = msgIdDict.get('type')

        if not self._types.has_key(msgType):
            self._types[msgType] = Entry(msgIdDict)
        entry = self._types[msgType]

        entry.post(msgDict)

        if not startup:
            self.sendUpdate()

            
    def getSummaryHtml(self):        
        sectionHtml = ""

        sectionHtml += '<div class="inst-sum-container">'
        
        msgTypes = sorted(list(self._types.keys()))
        for msgType in msgTypes:
            sectionHtml += '<div>'
            entry = self._types[msgType]
            sectionHtml += entry.getSummaryHtml()
            sectionHtml += '</div>'
        sectionHtml += '</div>'

        return sectionHtml
               
    def readFromLog(self):
        if os.path.isfile(self._logFilename):
            print "Starting to read from file: " + self._logFilename
            with jsonlines.open(self._logFilename) as reader:
                for jsonStr in reader:
                    #print "Read json " + jsonStr
                    self.post(json.loads(jsonStr), True)
                    
            print "Reached end in file: " + self._logFilename
            self.sendUpdate()
        else:
            print "Cannot find file: " + self._logFilename


    def writeToLog(self, dictToWrite):
        jsonStr = json.dumps(dictToWrite)
        #print "Write json " + jsonStr
        with jsonlines.open(self._logFilename, mode='a') as writer:
            writer.write(jsonStr)
        
stateMonitor = StateMonitor('log.jsonl')
stateMonitor.readFromLog()

currentConnections = Connections()

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
    print('Client connected <%s>' % (request.sid))

@socketio.on('disconnect', namespace='/commio')
def commio_disconnect():
    print('Client disconnected <%s>' % (request.sid))

@socketio.on('request_update', namespace='/commio')
def commio_requests_update(jsonStr):
    print "Received request_update: " + str(jsonStr)
    rxDict = json.loads(jsonStr)
    rxType = rxDict.get('type')
    rxIndex = rxDict.get('index')
    obj = None
    if rxType == 'top':
        obj = stateMonitor
    elif rxType == 'entry':
        obj = Entry.getEntryByIndex(rxIndex)
        
    if not obj is None:
        obj.requestUpdate()
    else:
        socketio.emit(rxType+str(rxIndex), {'section': 'ERROR - no content'}, namespace='/commio')
        
@socketio.on('subscribe_update', namespace='/commio')
def commio_subscribe_update(jsonStr):
    print "Received subscribe_update: " + str(jsonStr)
    rxDict = json.loads(jsonStr)
    rxType = rxDict.get('type')
    rxIndex = rxDict.get('index')
    obj = None
    if rxType == 'top':
        obj = stateMonitor
    elif rxType == 'entry':
        obj = Entry.getEntryByIndex(rxIndex)
        
    if not obj is None:
        obj.subscribeUpdate()

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=int("5000"))

