
$(document).ready(function(){
    //connect to the socket server.
    var socket = io.connect('http://' + document.domain + ':' + location.port + '/commio');
    //var socket = io.connect(document.URL + '/connect');
    var numbers_received = [];
    var path = location.pathname;
    
    
    //debugger;
    
    type = '';
    index = -1;
    
    if (path == "/" ) {
        type = 'top';
        name = 'top';
    }
    else {
        sections = path.split("/");
        type = sections[sections.length-2]
        index = parseInt(sections[sections.length-1]);
        name = type+sections[sections.length-1];
    }

    var requestData = new Object();
    requestData.type = type;
    requestData.index = index;
    requestJson = JSON.stringify(requestData);
    
    console.log("Using request " + requestJson);


    socket.on('connect', function(){
        console.log("Callback connect");
        //ask for latest data from server and place a subscription
        socket.emit('request_update', requestJson);
    });
    
    //receive details from server
    socket.on(name, function(msg) {
        //console.log("Received " + name + " " + msg.section);
        console.log("Received " + name );
        $('#dynsection').html(msg.section);
        
        //refresh subscription
        socket.emit('subscribe_update', requestJson);
    });

});
