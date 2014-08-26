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

#import <Cocoa/Cocoa.h>
#import "BGHUDAppKit.h"

// OMFDashboardView class
@interface OMFDashboardView : BGHUDView
    {
@private
	float   _speed;        /* 0.0 to 100.0 percent */
	float   _curvature;    /* 0.0 to 100.0 percent */
	int     _ticks;          /* 3 to 14 ticks */
	
    /* Bounding frame for the entire control */
	NSBezierPath* _boundingFrame;
	
	/* Information about the indicator pointer */
	float _iStartAngle;
    float _iEndAngle;
	NSPoint _iCenterPt;
	
	/* True while we're dragging the indicator around */
	BOOL _isDraggingIndicator;
    }

@property ( nonatomic ) float speed;
@property ( nonatomic ) float curvature;
@property ( nonatomic ) int ticks;
@property ( nonatomic, setter = setDraggingIndicator: ) BOOL isDraggingIndicator;
@property ( nonatomic, copy ) NSBezierPath* boundingFrame;

- ( id ) initWithFrame: ( NSRect )_FrameRect;
- ( void ) dealloc;

/* used for saving information about the position of the pointer
 * that we use in our mouse tracking methods for adjusting the speed. */
- ( void ) saveSweepWithCenter: ( NSPoint )_CenterPt
                    startAngle: ( float )_StAngle
                      endAngle: ( float )_EnAngle;
@end // OMFDashboardView

//////////////////////////////////////////////////////////////////////////////

/*****************************************************************************
 **                                                                         **
 **      _________                                      _______             **
 **     |___   ___|                                   / ______ \            **
 **         | |     _______   _______   _______      | /      |_|           **
 **         | |    ||     || ||     || ||     ||     | |    _ __            **
 **         | |    ||     || ||     || ||     ||     | |   |__  \           **
 **         | |    ||     || ||     || ||     ||     | \_ _ __| |  _        **
 **         |_|    ||_____|| ||     || ||_____||      \________/  |_|       **
 **                                           ||                            **
 **                                    ||_____||                            **
 **                                                                         **
 ****************************************************************************/
///:~