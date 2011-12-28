@import <AppKit/CPPanel.j>
@import <AppKit/CPWindowController.j>

@import "ChatClient.j"
@import "ChatRoom.j"

@implementation LoginWindow : CPWindowController
{
	var theWindow;
	var usernameField;
	var loginButton;
	
	var loginName;
	var theSocket;
}

- (CPWindow)window
{
	return theWindow;
}

- (id)init
{
	theWindow = [[CPPanel alloc]
		initWithContentRect: CGRectMake(30,30,225,125)
		styleMask: CPHUDBackgroundWindowMask];
		
	var content = [theWindow contentView];
	
	usernameField = [CPTextField 
		textFieldWithStringValue:@""
		placeholder:@"Your nickname"
		width: 205];
	[usernameField setFrameOrigin:CGPointMake(10, 20)];
	[usernameField setTarget:self];
	[usernameField setAction:@selector(close:)];
	
	loginButton = [[CPButton alloc] initWithFrame:CGRectMake(14,80,197,24)];
	[loginButton setTitle:@"Log In"];
	[loginButton setTarget:self];
	[loginButton setAction:@selector(close:)];
	
	[content addSubview:usernameField];
	[content addSubview:loginButton];
		
	self = [super initWithWindow:theWindow];
	
	if (self)
	{
		[theWindow setTitle:@"Log In"];
		[theWindow setFloatingPanel:YES];
		
		theSocket = [[ChatClient alloc] init:self];
	}
	
	return self;
}

- (CPString)name
{
	return loginName;
}

- (SCSocket)socket
{
	return theSocket;
}

- (void)close: (id)sender
{
	[theSocket setNick:[usernameField stringValue]];	
	[loginButton setEnabled:NO];
}

- (void)nickIs: (CPString)status
{
	[[CPApplication sharedApplication] stopModal];
	if (status != 'ok')
	{
		alert("Nick is " + status);
	}
	else
	{
		// Exit the login mode
		[self close];
		
		var chatroom = [[ChatRoom alloc] initMainRoomWithSocket:theSocket];
		[chatroom showWindow:self];
	}
	
	[loginButton setTarget:self];
	[loginButton setAction:@selector(close:)];
	[loginButton setEnabled:YES];
}

@end

