///:
/*****************************************************************************
 **                                                                         **
 **                               .======.                                  **
 **                               | INRI |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                      .========'      '========.                         **
 **                      |   _      xxxx      _   |                         **
 **                      |  /_;-.__ / _\  _.-;_\  |                         **
 **                      |     `-._`'`_/'`.-'     |                         **
 **                      '========.`\   /`========'                         **
 **                               | |  / |                                  **
 **                               |/-.(  |                                  **
 **                               |\_._\ |                                  **
 **                               | \ \`;|                                  **
 **                               |  > |/|                                  **
 **                               | / // |                                  **
 **                               | |//  |                                  **
 **                               | \(\  |                                  **
 **                               |  ``  |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                   \\    _  _\\| \//  |//_   _ \// _                     **
 **                  ^ `^`^ ^`` `^ ^` ``^^`  `^^` `^ `^                     **
 **                                                                         **
 **                       Copyright (c) 2014 Tong G.                        **
 **                          ALL RIGHTS RESERVED.                           **
 **                                                                         **
 ****************************************************************************/

#import "OMFAppDelegate.h"
#import "OMFStatusItemView.h"
#import "smcWrapper.h"

// OMFAppDelegate class
@implementation OMFAppDelegate

@synthesize _statusBarController;
@synthesize _mainPanelController;

#pragma mark Conforms <NSAwakeFromNib> protocol
- ( void ) awakeFromNib
    {
    self._statusBarController = [ OMFStatusBarController statusBarController ];
    self._mainPanelController = [ OMFMainPanelController mainPanelControllerWithDelegate: self ];

    [ self setRights ];
    }

- ( IBAction ) togglePanel: ( id )_Sender
    {
    BOOL isHighlighting = self._statusBarController.statusItemView.isHighlighting ;

    [ self._mainPanelController _fuckPanel: !isHighlighting ];
    }

#pragma mark Conforms <OMFMainPanelControllerDelegate> protocol
- ( OMFStatusItemView* ) statusItemViewForPanelController: ( OMFMainPanelController* )_StatusItemView
    {
    return self._statusBarController.statusItemView;
    }
    
- (void)setRights{
	NSString *smcpath = [[NSBundle mainBundle]   pathForResource:@"smc" ofType:@""];
	NSFileManager *fmanage=[NSFileManager defaultManager];
    NSDictionary *fdic = [fmanage attributesOfItemAtPath:smcpath error:nil];
	if ([[fdic valueForKey:@"NSFileOwnerAccountName"] isEqualToString:@"root"] && [[fdic valueForKey:@"NSFileGroupOwnerAccountName"] isEqualToString:@"admin"] && ([[fdic valueForKey:@"NSFilePosixPermissions"] intValue]==3437)) {
		// If the SMC binary has already been modified to run as root, then do nothing.
        return;
	 }
    //TODO: Is the usage of commPipe safe?
	FILE *commPipe;
	AuthorizationRef authorizationRef;
	AuthorizationItem gencitem = { "system.privilege.admin", 0, NULL, 0 };
	AuthorizationRights gencright = { 1, &gencitem };
	int flags = kAuthorizationFlagExtendRights | kAuthorizationFlagInteractionAllowed;
	OSStatus status = AuthorizationCreate(&gencright,  kAuthorizationEmptyEnvironment, flags, &authorizationRef);
    if (status != errAuthorizationSuccess) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Authorization failed" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"Authorization failed with code %d",status]];
        [alert setAlertStyle:2];
        NSInteger result = [alert runModal];
        
        if (result == NSAlertDefaultReturn) {
            [[NSApplication sharedApplication] terminate:self];
        }
    }
	NSString *tool=@"/usr/sbin/chown";
    NSArray *argsArray = [NSArray arrayWithObjects: @"root:admin",smcpath,nil];
	int i;
	char *args[255];
	for(i = 0;i < [argsArray count];i++){
		args[i] = (char *)[[argsArray objectAtIndex:i]cString];
	}
	args[i] = NULL;
	status=AuthorizationExecuteWithPrivileges(authorizationRef,[tool UTF8String],0,args,&commPipe);
    if (status != errAuthorizationSuccess) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Authorization failed" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"Authorization failed with code %d",status]];
        [alert setAlertStyle:2];
        NSInteger result = [alert runModal];
        
        if (result == NSAlertDefaultReturn) {
            [[NSApplication sharedApplication] terminate:self];
        }
    }
	//second call for suid-bit
	tool=@"/bin/chmod";
	argsArray = [NSArray arrayWithObjects: @"6555",smcpath,nil];
	for(i = 0;i < [argsArray count];i++){
		args[i] = (char *)[[argsArray objectAtIndex:i]cString];
	}
	args[i] = NULL;
	status=AuthorizationExecuteWithPrivileges(authorizationRef,[tool UTF8String],0,args,&commPipe);
    if (status != errAuthorizationSuccess) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Authorization failed" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"Authorization failed with code %d",status]];
        [alert setAlertStyle:2];
        NSInteger result = [alert runModal];
        
        if (result == NSAlertDefaultReturn) {
            [[NSApplication sharedApplication] terminate:self];
        }
    }
}

@end // OMFAppDelegate

/////////////////////////////////////////////////////////////////////////////

/****************************************************************************
 **                                                                        **
 **      _________                                      _______            **
 **     |___   ___|                                   / ______ \           **
 **         | |     _______   _______   _______      | /      |_|          **
 **         | |    ||     || ||     || ||     ||     | |    _ __           **
 **         | |    ||     || ||     || ||     ||     | |   |__  \          **
 **         | |    ||     || ||     || ||     ||     | \_ _ __| |  _       **
 **         |_|    ||_____|| ||     || ||_____||      \________/  |_|      **
 **                                           ||                           **
 **                                    ||_____||                           **
 **                                                                        **
 ***************************************************************************/
///:~