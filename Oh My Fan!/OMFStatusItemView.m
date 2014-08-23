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

#import "OMFStatusItemView.h"
#import "smcWrapper.h"

// OMFStatusItemView class
@implementation OMFStatusItemView

@synthesize statusItem = _statusItem;
//@synthesize inscriptionLabel = _inscriptionLabel;
@synthesize statusItemIcon = _statusItemIcon;
@synthesize statusItemAlternateIcon = _statusItemAlternateIcon;

@synthesize temperatureUnit = _temperatureUnit;

@synthesize isHighlighting = _isHighlighting;

@synthesize target = _target;
@synthesize action = _action;

@synthesize globalRect = _globalRect;

#pragma mark Initializer(s) & Deallocator(s)
+ ( id ) statusItemViewWithStatusItem: ( NSStatusItem* )_StatusItem
    {
    return [ [ [ [ self class ] alloc ] initWithStatusItem: _StatusItem ] autorelease ];
    }

- ( id ) initWithStatusItem: ( NSStatusItem* )_StatusItem
    {
    CGFloat statusItemLength = [ _StatusItem length ];
    CGFloat statusItemHeight = [ [ NSStatusBar systemStatusBar ] thickness ];

    NSRect bounds = [ self bounds ];
    bounds.size.width = statusItemLength;
    bounds.size.height = statusItemHeight;

    if ( self = [ super initWithFrame: bounds ] )
        {
        self.statusItem = _StatusItem;
        [ self.statusItem setView: self ];

        self.temperatureUnit = ( OMFTemperatureUnit )[ [ USER_DEFAULTS objectForKey: OMFDefaultsKeyTemperatureUnit ] intValue ];
        }

    return self;
    }

- ( void ) dealloc
    {
    [ [ NSStatusBar systemStatusBar ] removeStatusItem: self.statusItem ];

    [ super dealloc ];
    }

- ( void ) viewWillMoveToWindow: ( NSWindow* )_Window
    {
    // TODO: User can choose the frequency for refreshing
    [ NSTimer scheduledTimerWithTimeInterval: ( NSTimeInterval )[ [ USER_DEFAULTS objectForKey: OMFRefreshFrequency ] doubleValue ]
                                      target: self
                                    selector: @selector( redrawInscriptions: )
                                    userInfo: nil
                                     repeats: YES ];

    }

- ( void ) redrawInscriptions: ( NSTimer* )_Timer
    {
    [ self setNeedsDisplay: YES ];
    }

#pragma mark Customize Drawing
- ( void ) drawRect: ( NSRect )_DirtyRect
    {
    [ self.statusItem drawStatusBarBackgroundInRect: _DirtyRect withHighlight: self.isHighlighting ];

    NSRect bounds = [ self bounds ];
    NSImage* imageShouldBeDrawn = self.isHighlighting ? self.statusItemAlternateIcon : self.statusItemIcon;

#if 0 // TODO: To implement the differ appearence
    CGPoint iconOrigin = NSMakePoint( ( NSWidth( bounds ) - imageShouldBeDrawn.size.width ) / 2
                                    , ( NSHeight( bounds ) - imageShouldBeDrawn.size.height ) / 2
                                    );
#endif

    // Draw the icon
    // Because the digits of Fahrenheit is generally greater than Celsius, so...
    CGFloat iconX = ( self.temperatureUnit == OMFCelsius ) ? 8.f : 5.f;

    CGPoint iconOrigin = NSMakePoint( iconX, ( NSHeight( bounds ) - imageShouldBeDrawn.size.height ) / 2 );
    [ imageShouldBeDrawn drawAtPoint: iconOrigin
                            fromRect: NSZeroRect
                           operation: NSCompositeSourceOver
                            fraction: 1.f ];

    // Draw the inscriptions
    NSString* inscription = [ NSString stringWithFormat: @"%d%@ %drpm"
                            , ( self.temperatureUnit == OMFCelsius ) ? ( int )[ smcWrapper CPUTemperatureInCelsius ] : ( int )[ smcWrapper CPUTemperatureInFahrenheit ]
                            , ( self.temperatureUnit == OMFCelsius ) ? @"℃": @"℉"
                            , [ smcWrapper get_fan_rpm: 0 ]
                            ];

    NSColor* inscColor = self.isHighlighting ? [ NSColor whiteColor ] : [ NSColor blackColor ];

    CGFloat inscriptionDelta = ( self.temperatureUnit == OMFCelsius ) ? 11.f : 8.f;
    [ inscription drawAtPoint: NSMakePoint( imageShouldBeDrawn.size.width + inscriptionDelta , ( NSHeight( bounds ) - 13 ) / 2 )
               withAttributes: @{ NSFontAttributeName : [ NSFont fontWithName: @"Lucida Grande" size: 11 ]
                                , NSForegroundColorAttributeName : inscColor }  ];
    }

#pragma mark Event Handling
- ( void ) mouseDown: ( NSEvent* )_Event
    {
    [ NSApp sendAction: self.action to: self.target from: self ];
    }

#pragma Accessors
- ( void ) setStatusItemIcon: ( NSImage* )_StatusItemIcon
    {
    if ( self->_statusItemIcon != _StatusItemIcon )
        {
        [ self->_statusItemIcon release ];
        self->_statusItemIcon = [ _StatusItemIcon retain ];

        [ self setNeedsDisplay: YES ];
        }
    }

- ( NSImage* ) statusItemIcon
    {
    return self->_statusItemIcon;
    }


- ( void ) setStatusItemAlternateIcon: ( NSImage* )_StatusItemAlternateIcon
    {
    if ( self->_statusItemAlternateIcon != _StatusItemAlternateIcon )
        {
        [ self->_statusItemAlternateIcon release ];
        self->_statusItemAlternateIcon = [ _StatusItemAlternateIcon retain ];

        [ self setNeedsDisplay: YES ];
        }
    }

- ( NSImage* ) statusItemAlternateIcon
    {
    return self->_statusItemAlternateIcon;
    }


- ( void ) setHighlighting: ( BOOL )_IsHighlighting
    {
    if ( self->_isHighlighting != _IsHighlighting )
        {
        self->_isHighlighting = _IsHighlighting;

        [ self setNeedsDisplay: YES ];
        }
    }


- ( NSRect ) globalRect
    {
    return [ self.window convertRectToScreen: [ self frame ] ];
    }


- ( void ) setTemperatureUnit: ( OMFTemperatureUnit )_Unit
    {
    if ( self->_temperatureUnit != _Unit )
        {
        self->_temperatureUnit = _Unit;

        [ self setNeedsDisplay: YES ];
        }
    }

- ( OMFTemperatureUnit ) temperatureUnit
    {
    return self->_temperatureUnit;
    }

@end // OMFStatusItemView

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