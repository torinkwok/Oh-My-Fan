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
#import "OMFDashboardView.h"
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

    [ self setStartAtLogin: ( [ USER_DEFAULTS integerForKey: OMFDefaultsKeyStartAtLogin ] == OMFStartAtLogin ) ? YES : NO ];

    [ self setRights ];
    }

- ( IBAction ) togglePanel: ( id )_Sender
    {
    BOOL isHighlighting = self._statusBarController.statusItemView.isHighlighting ;

    [ self._mainPanelController _fuckPanel: !isHighlighting ];
    }

#pragma mark Conforms <NSApplicationDelegate> protocol
- ( void ) applicationWillFinishLaunching: ( NSNotification* )_Notif
    {
    MachineDefaults* machineDefaults = [ [ MachineDefaults alloc ] init ];

    NSInteger speed = [ machineDefaults calculateSpeedAccordingTickVal: ( NSInteger )[ [ USER_DEFAULTS objectForKey: OMFDefaultTickVal ] doubleValue ] ];

    int numFans = [ machineDefaults numFans ];
    for ( int index = 0; index < numFans; index++ )
        [ smcWrapper setKey_external: [ NSString stringWithFormat: @"F%dMn", index ] value: [ NSString stringWithFormat: @"%ld", speed ] ];

    [ MachineDefaults release ];
    }

- ( void ) applicationWillTerminate: ( NSNotification* )_Notif
    {
    [ USER_DEFAULTS setDouble: self._mainPanelController.dashboardView.speed forKey: OMFDefaultTickVal ];
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
    #if FUCKING_CODE
        NSAlert *alert = [NSAlert alertWithMessageText:@"Authorization failed" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"Authorization failed with code %d",status]];
        [alert setAlertStyle:2];
        NSInteger result = [alert runModal];
        
        if (result == NSAlertDefaultReturn) {
            [[NSApplication sharedApplication] terminate:self];
        }
    #endif
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
    #if FUCKING_CODE
        NSAlert *alert = [NSAlert alertWithMessageText:@"Authorization failed" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"Authorization failed with code %d",status]];
        [alert setAlertStyle:2];
        NSInteger result = [alert runModal];
        
        if (result == NSAlertDefaultReturn) {
            [[NSApplication sharedApplication] terminate:self];
        }
    #endif
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
    #if FUCKING_CODE
        NSAlert *alert = [NSAlert alertWithMessageText:@"Authorization failed" defaultButton:@"Quit" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"Authorization failed with code %d",status]];
        [alert setAlertStyle:2];
        NSInteger result = [alert runModal];
        
        if (result == NSAlertDefaultReturn) {
            [[NSApplication sharedApplication] terminate:self];
        }
    #endif
    }
}

- (void) setStartAtLogin:(BOOL)enabled {
    
	LSSharedFileListRef loginItems = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListSessionLoginItems, /*options*/ NULL);
    
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	
	OSStatus status;
	CFURLRef URLToToggle = (CFURLRef)[NSURL fileURLWithPath:path];
	LSSharedFileListItemRef existingItem = NULL;
	
	UInt32 seed = 0U;
	NSArray *currentLoginItems = [NSMakeCollectable(LSSharedFileListCopySnapshot(loginItems, &seed)) autorelease];
	
	for (id itemObject in currentLoginItems) {
		LSSharedFileListItemRef item = (LSSharedFileListItemRef)itemObject;
		
		UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
		CFURLRef URL = NULL;
		OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
		if (err == noErr) {
			Boolean foundIt = CFEqual(URL, URLToToggle);
			CFRelease(URL);
			
			if (foundIt) {
				existingItem = item;
				break;
			}
		}
	}
	
	if (enabled && (existingItem == NULL)) {
		NSString *displayName = [[NSFileManager defaultManager] displayNameAtPath:path];
		IconRef icon = NULL;
		FSRef ref;
		Boolean gotRef = CFURLGetFSRef(URLToToggle, &ref);
		if (gotRef) {
			status = GetIconRefFromFileInfo(&ref,
											/*fileNameLength*/ 0, /*fileName*/ NULL,
											kFSCatInfoNone, /*catalogInfo*/ NULL,
											kIconServicesNormalUsageFlag,
											&icon,
											/*outLabel*/ NULL);
			if (status != noErr)
				icon = NULL;
		}
		
		LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst, (CFStringRef)displayName, icon, URLToToggle, /*propertiesToSet*/ NULL, /*propertiesToClear*/ NULL);
	} else if (!enabled && (existingItem != NULL))
		LSSharedFileListItemRemove(loginItems, existingItem);
}

#pragma mark IBActions
- ( IBAction ) changedTemperatureUnit: ( id )_Sender
    {
    NSSegmentedControl* tempSegControl = ( NSSegmentedControl* )_Sender;
    OMFTemperatureUnit tempUnit = ( OMFTemperatureUnit )[ tempSegControl.cell tagForSegment: [ tempSegControl selectedSegment ] ];

    [ self._statusBarController.statusItemView setTemperatureUnit: tempUnit ];
    [ USER_DEFAULTS setInteger: tempUnit forKey: OMFDefaultsKeyTemperatureUnit ];
    }

- ( IBAction ) changedStartAtLoginControl: ( id )_Sender
    {
    NSSegmentedControl* startAtLoginSegControl = ( NSSegmentedControl* )_Sender;
    OMFBehaviorWhileStarting startAtLogin = ( OMFBehaviorWhileStarting )[ startAtLoginSegControl.cell tagForSegment: [ startAtLoginSegControl selectedSegment ] ];

    [ self setStartAtLogin: ( startAtLogin == OMFStartAtLogin ) ? YES : NO ];
    [ USER_DEFAULTS setInteger: startAtLogin forKey: OMFDefaultsKeyStartAtLogin ];
    }

- ( IBAction ) changedDashboardAccuracy: ( id )_Sender
    {
    NSSegmentedControl* dashboardSegControl = ( NSSegmentedControl* )_Sender;
    OMFDashboardAccuracy dashboardAccuracy = ( OMFDashboardAccuracy )[ dashboardSegControl.cell tagForSegment: [ dashboardSegControl selectedSegment ] ];

    int tickNum = 0;
    switch ( dashboardAccuracy )
        {
    case OMFDashboardLowAccuracy:       tickNum = 5;    break;
    case OMFDashboardMediumAccuracy:    tickNum = 10;   break;
    case OMFDashboardHighAccuracy:      tickNum = 14;   break;
        }

    [ self._mainPanelController.dashboardView setTicks: tickNum ];
    [ USER_DEFAULTS setInteger: dashboardAccuracy forKey: OMFDefaultsKeyDashboardAccuracy ];
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