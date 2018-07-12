
$(document).ready(function(){
    //connect to the socket server.
    var socket = io.connect('http://' + document.domain + ':' + location.port + '/test');
    var numbers_received = [];

    //receive details from server
    socket.on('dynsection', function(msg) {
        console.log("Received dynsection" + msg.dynsection);
        $('#dynsection').html(msg.dynsection);
    });

});
