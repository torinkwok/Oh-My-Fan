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

@interface OMFDashboardView : BGHUDView
{
	float speed; /* 0.0 to 100.0 percent */
	float curvature; /* 0.0 to 100.0 percent */
	int ticks; /* 3 to 14 ticks */
	
		/* bounding frame for the entire control */
	NSBezierPath *boundingFrame;
	
		/* information about the indicator pointer */
	float iStartAngle, iEndAngle;
	NSPoint iCenterPt;
	
		/* true while we're dragging the indicator around */
	BOOL draggingIndicator;
}

/* properties for our instance variables. */
@property (nonatomic) float speed;
@property (nonatomic) float curvature;
@property (nonatomic) int ticks;
@property (nonatomic) BOOL draggingIndicator;
@property (nonatomic, copy) NSBezierPath *boundingFrame;

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

	/* used for saving information about the position of the pointer
	that we use in our mouse tracking methods for adjusting the speed. */
- (void)saveSweepWithCenter:(NSPoint)centerPt startAngle:(float)stAngle endAngle:(float)enAngle;

@end

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