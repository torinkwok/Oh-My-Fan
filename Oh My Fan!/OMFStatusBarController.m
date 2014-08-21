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

#import "OMFStatusBarController.h"
#import "OMFStatusItemView.h"

// OMFStatusBarController class
@implementation OMFStatusBarController

@synthesize statusItemView = _statusItemView;

@synthesize hasActiveIcon = _hasActiveIcon;

#pragma mark Initializers & Deallocators
- ( id ) init
    {
    if ( self = [ super init ] )
        {
        NSStatusItem* statusItem = [ [ NSStatusBar systemStatusBar ] statusItemWithLength: NSSquareStatusItemLength ];
        self.statusItemView = [ OMFStatusItemView statusItemViewWithStatusItem: statusItem ];

        [ self.statusItemView setStatusItemIcon: [ NSImage imageNamed: @"statusbar-fan.png" ] ];
        [ self.statusItemView setStatusItemAlternateIcon: [ NSImage imageNamed: @"statusbar-fan-highlighting.png" ] ];
        }

    return self;
    }

#pragma mark Accessors
- ( NSStatusItem* ) statusItem
    {
    return self.statusItemView.statusItem;
    }


- ( void ) setHasActiveIcon: ( BOOL )_HasActiveIcon
    {
    self.statusItemView.isHighlighting = _HasActiveIcon;
    }

- ( BOOL ) hasActiveIcon
    {
    return self.statusItemView.isHighlighting;
    }

@end // OMFStatusBarController

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