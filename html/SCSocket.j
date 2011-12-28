@import <Foundation/CPObject.j>
@import "Socket.IO/socket.io.js"

@implementation SCSocket : CPObject
{
    JSObject socket;
    id delegate;
}

- (id)initWithURL:(CPURL)aURL delegate:aDelegate
{
    self = [super init];
    if (self)
    {
        socket = io.connect([aURL host], {port:[aURL port], transports:[
        	'websocket', 
        	'htmlfile', 
        	'xhr-multipart', 
        	'xhr-polling', 
        	'jsonp-polling']});
        	
        delegate = aDelegate;
       
        if ([delegate respondsToSelector:@selector(socketDidDisconnect:)])
        {
            socket.on('disconnect', function() 
            {
            	[delegate socketDidDisconnect:self];
            	[[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
            });
            socket.socket.onDisconnect(function() 
            {
            	[delegate socketDidDisconnect:self];
            	[[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
            });
        }
            
    }
    return self;
}

- (void)close
{
    if (socket) 
    {
        socket._events = {};
        socket.disconnect();
    }
}

- (void)listenForMessage:(CPString)message action:(SEL)selector
{
	if ([delegate respondsToSelector:selector])
	{
		socket.on(message,
			function(data) 
			{
				console.log("recieved message: " + message);
				[delegate performSelector:selector withObject:data]; 
				[[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
			}
		);
	}
}

- (void)send:(CPString)aEvent data:(JSObject)aData
{
    socket.emit(aEvent, aData);
}

@end

