/*
 * AppController.j
 * NewApplication
 *
 * Created by You on November 16, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>

@import "LoginWindow.j"
@import "ChatClient.j"

@implementation AppController : CPObject
{
	var menu;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() 				
    	styleMask:CPBorderlessBridgeWindowMask];
    	
   	var contentView = [theWindow contentView];
        
	var login = [[LoginWindow alloc] init];
	
	[[CPApplication sharedApplication] runModalForWindow:[login window]];
	
    [theWindow orderFront:self];
	
	[CPMenu setMenuBarVisible:NO];
	
	menu = [[CPApplication sharedApplication] mainMenu];
	
	[menu removeItemAtIndex:0];
	[menu removeItemAtIndex:0];
	[menu removeItemAtIndex:0];
	
	[menu setTitle:@"Chatz0rz"];
	
	/*
	var joinRoomMenuItem = [menu addItemWithTitle:@"Join Room"
		action:@selector(joinRoom:)
		keyEquivalent:@"a"];
		*/
}

@end

