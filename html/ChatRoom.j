@import <AppKit/CPPanel.j>
@import <AppKit/CPWindowController.j>
@import <AppKit/CPWebView.j>
@import <AppKit/CPCollectionView.j>

@import "ChatClient.j"

@implementation ChatRoom : CPWindowController
{
	var chatclient;
	
	var inputArea;
	var chatArea;
	var userlistArea;
	
	var htmlAbove;
	var htmlBelow;
	var chatContent;
	var userList;
}

- (id)initMainRoomWithSocket:(ChatClient)aChatClient;
{
	theWindow = [[CPPanel alloc]
	initWithContentRect: CGRectMake(30,60,400,300)
	styleMask: CPHUDBackgroundWindowMask | CPResizableWindowMask];
		
	var content = [theWindow contentView];
	
	
	chatArea = [[CPWebView alloc]
		initWithFrame:CGRectMake(10,0,250,260)];
	
	[chatArea setScrollMode:CPWebViewScrollNative];
	[chatArea setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
	
	htmlAbove = "<html><body style=\"margin: 0px; font-family:'helvetica', sans-serif;\"><table height=\"100%\" ><tr><td id=\"cht\" style=\"vertical-align:bottom; font-size:10pt\">";
	htmlBelow = "</td></tr></table></body></html>";
	[chatArea loadHTMLString:(htmlAbove + htmlBelow)];
	
	inputArea = [CPTextField 
		textFieldWithStringValue:@""
		placeholder:@"Type here"
		width:260];
		
	[inputArea setFrameOrigin:CGPointMake(5,263)];
	[inputArea setAutoresizingMask:CPViewWidthSizable | CPViewMinYMargin];
	[inputArea setAction:@selector(send:)];
	
	
	userlistArea = [[CPWebView alloc]
		initWithFrame:CGRectMake(267,0,120,286)];
		
	htmlAbove = "<html><body style=\"margin: 0px; font-family:'helvetica', sans-serif;\"><table height=\"100%\" ><tr><td id=\"cht\" style=\"vertical-align:top; font-size:10pt\">";
	htmlBelow = "</td></tr></table></body></html>";
	[userlistArea setAutoresizingMask:CPViewMinXMargin | CPViewHeightSizable];
	[userlistArea loadHTMLString:(htmlAbove + htmlBelow)];
	[userlistArea setScrollMode:CPWebViewScrollNative];
	
	[content addSubview:chatArea];
	[content addSubview:inputArea];
	[content addSubview:userlistArea];
	
	self = [super initWithWindow:theWindow];
	
	if (self)
	{
		userList = [];
		[theWindow setTitle:@"Main Room"];
		[theWindow setFloatingPanel:YES];
		chatclient = aChatClient;
		[chatclient setDelegate:self];
		chatContent = "";
		[self refreshChat];
	}
	
	return self;
}

- (action)showWindow:(id)aSender
{
	[super showWindow:aSender];
	[chatclient getUsers:""];
	chatContent = "Now chatting in Main Room";
}

- (void)send: (id)sender
{
	if ([[inputArea stringValue] length] != 0) {
		[chatclient sendMessage:[inputArea stringValue] room:@""];
		[inputArea setStringValue:@""];
	}
}

- (void)recv:(CPString)message nick:(CPString)aNick room:(CPString)aRoom
{

	chatContent += "<br>" + "&lt;" + aNick + "&gt; " + sanitize(message);
		
	[self refreshChat];
}

- (void)users:(id)userArray room:(CPString)aRoom
{
	userList = userArray;
	[self refreshChat];
}

- (void)userJoined:(CPString)aNick room:(CPString)aRoom
{
	chatContent += "<br><b>" + aNick + "</b> has joined"; 
	[chatclient getUsers:""];
}

- (void)userLeft:(CPString)aNick room:(CPString)aRoom
{
	chatContent += "<br><b>" + aNick + "</b> has left";
	[chatclient getUsers:""];
}

- (void)refreshChat
{
	console.log(chatContent);
	[chatArea objectByEvaluatingJavaScriptFromString:
	@"document.getElementById('cht').innerHTML='" + chatContent + @"';\
	window.scrollBy(0,989999);\
	"];
	
	var userstring = "";
	console.log(userList);
	for (i=0;i<userList.length;i++)
	{
		userstring += userList[i] + "<br>"
	}
	
	[userlistArea objectByEvaluatingJavaScriptFromString:
	@"document.getElementById('cht').innerHTML=\'" + userstring + @"\';"];
}

@end

