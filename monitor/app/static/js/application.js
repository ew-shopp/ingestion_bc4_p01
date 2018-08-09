
$(document).ready(function(){
    //connect to the socket server.
    var socket = io.connect('http://' + document.domain + ':' + location.port + '/commio');
    //var socket = io.connect(document.URL + '/connect');
    var numbers_received = [];
    var path = location.pathname;
    
    if (path == "/" ) {
        path = 'top';
    }
    else {
        sections = path.split("/");
        path = sections[sections.length-1];
    }

    console.log("Using path " + path);
    
    //receive details from server
    socket.on(path, function(msg) {
        console.log("Received " + path + " " + msg.section);
        $('#dynsection').html(msg.section);
    });

});
