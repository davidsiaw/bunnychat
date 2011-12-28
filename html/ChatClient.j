@import <Foundation/CPObject.j>
@import "SCSocket.j"

@implementation ChatClient : CPObject
{
	var webSocket;
	BOOL connected;
	var delegate;
}

- (id)init:(id)aDelegate
{
	self = [super init];
	
	if (self)
	{
		webSocket = [[SCSocket alloc]
			initWithURL:[CPURL URLWithString:@"http://davidsiawpc:8000"]
			delegate: self];
			
		[webSocket listenForMessage:@"nick" action:@selector(nickResponse:)];
		[webSocket listenForMessage:@"msg" action:@selector(recvMessage:)];
		[webSocket listenForMessage:@"users" action:@selector(recvUsers:)];
		[webSocket listenForMessage:@"join" action:@selector(recvJoined:)];
		[webSocket listenForMessage:@"part" action:@selector(recvLeft:)];
		
		connected = false;
		delegate = aDelegate;
	}
	
	return self;
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

- (void)setNick:(CPString)theNick
{
	[webSocket send:"nick" data:{nick: theNick}];
}

- (void)sendMessage:(CPString)msg room:(CPString)aRoom
{
	[webSocket send:"msg" data:{message: msg, roomName: aRoom}];
}

- (void)socketDidDisconnect:(id)sender
{
	console.log("server disconnected");
	connected = false;
	webSocket = nil;
}

- (void)nickResponse:(JSObject)aData
{
	console.log("server says nick is " + aData.status);
	[delegate nickIs:aData.status];
}

- (void)recvMessage:(JSObject)aData
{
	if ([delegate respondsToSelector:@selector(recv:nick:room:)])
	{
		[delegate recv:aData.message nick:aData.nick room:aData.room];
	}
}

- (void)recvUsers:(JSObject)aData
{
	if ([delegate respondsToSelector:@selector(users:room:)])
	{
		[delegate users:aData.userArray room:aData.room];
	}
}

- (void)recvJoined:(JSObject)aData
{
	if ([delegate respondsToSelector:@selector(userJoined:room:)])
	{
		[delegate userJoined:aData.nick room:aData.room];
	}
}

- (void)recvLeft:(JSObject)aData
{
	if ([delegate respondsToSelector:@selector(userLeft:room:)])
	{
		[delegate userLeft:aData.nick room:aData.room];
	}
}

- (void)joinRoom: (CPString)room
{
	[webSocket send:"join" data:{roomName: room}];
}

- (void)partRoom: (CPString)room
{
	[webSocket send:"part" data:{roomName: room}];
}

- (void)getUsers: (CPString)room
{
	[webSocket send:"users" data:{roomName: room}];
}

@end

