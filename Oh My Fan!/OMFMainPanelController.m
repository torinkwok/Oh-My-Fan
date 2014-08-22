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
#import "smcWrapper.h"

// OMFMainPanelController class
@implementation OMFMainPanelController

@synthesize delegate = _delegate;
@synthesize backgrondView = _backgroundView;
@synthesize dashboardView = _dashboardView;

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
    }

- ( void ) observeValueForKeyPath: ( NSString* )_KeyPath
                         ofObject: ( id )_Object
                           change: ( NSDictionary* )_Change
                          context: ( void* )_Context
    {
    MachineDefaults* machineDefaults = [ [ MachineDefaults alloc ] init ];
    NSInteger minSpeed = [ machineDefaults minSpeedForThisMac ];
    NSInteger maxSpeed = [ machineDefaults maxSpeedForThisMac ];

    NSInteger newTickVal = [ [ _Change objectForKey: @"new" ] integerValue ];
    NSInteger newSpeedVal = ( ( maxSpeed - minSpeed ) / 100 ) * newTickVal + minSpeed;

    [ smcWrapper setKey_external: @"F0Mn" value: [ NSString stringWithFormat: @"%ld", newSpeedVal ] ];

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