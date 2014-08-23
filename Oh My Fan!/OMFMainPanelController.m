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

#import "OMFMainPanelController.h"
#import "OMFStatusItemView.h"
#import "OMFPanelBackgroundView.h"
#import "OMFDashboardView.h"
#import "OMFAboutPanelController.h"
#import "smcWrapper.h"

// OMFMainPanelController class
@implementation OMFMainPanelController

@synthesize delegate = _delegate;

@synthesize backgrondView = _backgroundView;
    @synthesize dashboardView = _dashboardView;
        @synthesize settingPullDownButton;
            @synthesize aboutPanelController;

#pragma mark Initializers & Deallocators
+ ( id ) mainPanelControllerWithDelegate: ( id <OMFMainPanelControllerDelegate> )_Delegate
    {
    return [ [ [ [ self class ] alloc ] initWithDelegate: _Delegate ] autorelease ];
    }

- ( id ) initWithDelegate: ( id <OMFMainPanelControllerDelegate> )_Delegate
    {
    if ( self = [ super initWithWindowNibName: @"OMFMainPanel" ] )
        {
        self.delegate = _Delegate;
        }

    return self;
    }

#pragma mark Conforms <NSAwakeFromNib> protocol
- ( void ) awakeFromNib
    {
    [ self.window setOpaque: NO ];
    [ self.window setBackgroundColor: [ NSColor clearColor ] ];
    [ self.window setLevel: NSPopUpMenuWindowLevel ];

    [ self.backgrondView setArrowX: NSWidth( [ self.window frame ] ) / 2 ];

    [ self.dashboardView addObserver: self
                          forKeyPath: @"self.speed"
                             options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                             context: nil ];

    [ self.dashboardView setSpeed: [ [ USER_DEFAULTS objectForKey: OMFDefaultTickVal ] doubleValue ] ];
    }

- ( void ) observeValueForKeyPath: ( NSString* )_KeyPath
                         ofObject: ( id )_Object
                           change: ( NSDictionary* )_Change
                          context: ( void* )_Context
    {
    MachineDefaults* machineDefaults = [ [ MachineDefaults alloc ] init ];

    NSInteger newTickVal = [ [ _Change objectForKey: @"new" ] integerValue ];
    NSInteger speed = [ machineDefaults calculateSpeedAccordingTickVal: newTickVal ];

    int numFans = [ machineDefaults numFans ];
    for ( int index = 0; index < numFans; index++ )
        [ smcWrapper setKey_external: [ NSString stringWithFormat: @"F%dMn", index ] value: [ NSString stringWithFormat: @"%ld", speed ] ];

    [ MachineDefaults release ];
    }

#pragma mark Panel Handling
- ( void ) openPanel
    {
    NSRect frameOfStatusItemView = [ [ self.delegate statusItemViewForPanelController: self ] globalRect ];

    NSRect frame = [ self.window frame ];
    NSPoint origin = NSMakePoint( NSMidX( frameOfStatusItemView ) - NSWidth( frame ) / 2
                                , NSMinY( frameOfStatusItemView ) - NSHeight( frame )
                                );
    frame.origin = origin;
    [ self.window setFrame: frame display: YES ];

    [ self.window makeKeyAndOrderFront: self ];
    [ NSApp activateIgnoringOtherApps: YES ];
    }

- ( void ) closePanel
    {
    [ self.window orderOut: self ];
    }

#pragma mark Conforms <NSWindowDelegate> protocol
- ( void ) windowDidResize: ( NSNotification* )_Notif
    {
    [ self.backgrondView setArrowX: NSWidth( [ self.window frame ] ) / 2 ];
    }

- ( void ) windowDidResignKey: ( NSNotification* )_Notif
    {
    [ self _fuckPanel: NO ];
    }

- ( void ) _fuckPanel: ( BOOL )_IsHighlighting
    {
    OMFStatusItemView* statusItemView = [ self.delegate statusItemViewForPanelController: self ];

    if ( _IsHighlighting )
        {
        [ statusItemView setHighlighting: YES ];
        [ self openPanel ];
        }
    else
        {
        [ statusItemView setHighlighting: NO ];
        [ self closePanel ];
        }
    }

#pragma mark IBActions
- ( IBAction ) about: ( id )_Sender
    {
    if ( !self.aboutPanelController )
        self.aboutPanelController = [ OMFAboutPanelController aboutPanelController ];

    [ self.aboutPanelController showWindow: self ];
    }

@end // OMFMainPanelController

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