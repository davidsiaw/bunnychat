var express = require('express');
var io = require('socket.io');

var app = express.createServer();


app.get(/^\/serverinfo.js/, function (req,res) {
    console.log('requested server information');
    res.send('var ipaddress = "http://bunnychat.davidsiaw.c9.io";');
});

app.get(/^\/.*/, function (req,res) {
	console.log('requested:' + req.url);
	res.sendfile('html' + req.url);
});

var chatserver = io.listen(app);

var mainRoomHistory = [];
var mainUserList = [];
var userToSocket = {};

chatserver.sockets.on('connection', function (socket) {
	socket.emit('hello', { version: '1.0' });
	
	console.log('ws connection recieved');
	
	socket.on('nick', function (data) {
		console.log('nick ' + data.nick);
		if (userToSocket[data.nick])
		{
			socket.emit('nick', { status: 'used' });
			return;
		}
		
		if (data.nick.length < 4)
		{
			socket.emit('nick', { status: 'too short' });
			return;
		}
	
		socket.emit('nick', { status: 'ok' });
		userToSocket[data.nick] = socket;
		socket.nick = data.nick;
		socket.rooms = [];
		socket.broadcast.emit('join', {nick: socket.nick, room: ''});
		mainUserList.push(socket.nick);
		
		for (var itemNumber in mainRoomHistory)
		{
			var item = mainRoomHistory[itemNumber];
			socket.emit('msg', { message: item.msg, nick: item.nick, room: ""});
		}
	});
	
	socket.on('msg', function (data) {
		console.log('msg from ' + socket.nick + ': ' + data.message);
		socket.broadcast.emit('msg', { message: data.message, nick: socket.nick, room: data.roomName});
		socket.emit('msg', { message: data.message, nick: socket.nick, room: data.roomName});
		
		if (data.roomName === "")	// empty is main room
		{
			mainRoomHistory.push({nick: socket.nick, msg: data.message});
			if (mainRoomHistory.length > 40)
			{
				mainRoomHistory.splice(0,1);
			}
			console.log(mainRoomHistory);
		}
	});
	
	socket.on('join', function (data) {
		console.log('join ' + data.roomName);
		if (userToSocket[socket.nick])
		{
			
		}
		else
		{
			socket.emit('error', { info: 'nick not set' });
			socket.disconnect();
		}
	});
	
	socket.on('users', function(data) {
		// empty room name is main room TODO ROOMS
		console.log('requested user list for ' + data.roomName);
		
		console.log(mainUserList);
		socket.emit('users', {userArray: mainUserList, room: data.roomName});
	});
	
	socket.on('disconnect', function () {
		console.log('disconnect ' + socket.nick);
		socket.broadcast.emit('part', {nick: socket.nick});
		userToSocket[socket.nick] = undefined;
		mainUserList = mainUserList.filter(function(item) { return item != socket.nick; });
	});
});

console.log('server running on port: ' + process.env.PORT);
app.listen(process.env.PORT);

