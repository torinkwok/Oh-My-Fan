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

#import "OMFDashboardCategories.h"
#import "OMFDashboardView.h"

#define DEBUG_DRAWING_CODE( _Path, _Flag )              \
    if ( _Flag )                                        \
        {                                               \
        [ NSGraphicsContext saveGraphicsState ];        \
        [ [ NSColor redColor ] set ];                   \
        [ _Path setLineWidth: 3 ];                      \
        [ _Path stroke ];                               \
        [ NSGraphicsContext restoreGraphicsState ];     \
        }                                               \

// OMFDashboardView class
@implementation OMFDashboardView

@synthesize speed = _speed;
@synthesize curvature = _curvature;
@synthesize ticks = _ticks;
@synthesize isDraggingIndicator = _isDraggingIndicator;

#pragma mark Initializers & Deallocators
- ( id ) initWithFrame: ( NSRect )_FrameRect
    {
	if ( self = [ super initWithFrame: _FrameRect ] )
        {
        /* set to some startup values */
		self.speed = 30.0f;
		self.curvature = 70.0f;
		self.ticks = 10;
        }

	return self;
    }

- ( void ) dealloc
    {
	self.boundingFrame = nil;

	[ super dealloc ];
    }

#pragma mark Accessors
/* overridden accessor methods for our instance variables. NOTE: in the setter
 * methods we bound the input values to acceptable values for our custom view. 
 */
- ( void ) setSpeed: ( float )_Value
    {
    float nextLevel;
	
    /* bound setting to acceptable value range */
	if ( _Value < 0.0 )             nextLevel = 0.0;
        else if ( _Value > 100.0 )  nextLevel = 100.0;
        else                        nextLevel = _Value;
	
    /* set the new value, on change */
    if ( self->_speed != nextLevel )
        {
        self->_speed = nextLevel;

		[ self setNeedsDisplay: YES ];
        }
    }

- ( void ) setCurvature: ( float )_Value
    {
    float nextCurvature;
	
    /* bound setting to acceptable value range */
	if ( _Value < 0.0 )             nextCurvature = 0.0;
        else if ( _Value > 100.0 )  nextCurvature = 100.0;
        else                        nextCurvature = _Value;
	
    /* set the new value, on change */
	if ( self->_curvature != nextCurvature )
        {
        self->_curvature = nextCurvature;

		[ self setNeedsDisplay: YES ];
        }
    }

- ( void ) setTicks: ( int )_Value
    {
	int nextTicks;
	
    /* bound setting to acceptable value range */
	if ( _Value < 3 )           nextTicks = 3;
        else if ( _Value > 21 ) nextTicks = 21;
        else                    nextTicks = _Value;

    /* set the new value, on change */
    if ( self->_ticks != nextTicks )
        {
        self->_ticks = nextTicks;

		[ self setNeedsDisplay: YES ];
        }
    }

- ( NSBezierPath* ) boundingFrame
    {
    return [ [ self->_boundingFrame retain ] autorelease ];
    }

- ( void )setBoundingFrame:( NSBezierPath* )_Value
    {
    if ( self->_boundingFrame != _Value )
        {
        [ self->_boundingFrame release ];

        self->_boundingFrame = [ _Value copy ];
        }
    }

/* used for saving information about the position of the pointer
 * that we use in our mouse tracking methods for adjusting the speed. */
- ( void ) saveSweepWithCenter: ( NSPoint )_CenterPt
                    startAngle: ( float )_StAngle
                      endAngle: ( float )_EnAngle
    {
    
	self->_iStartAngle = _StAngle;  /* degrees counter clockwise from the x axis */
	self->_iEndAngle = _EnAngle;    /* degrees counter clockwise from the x axis */
	self->_iCenterPt = _CenterPt;   /* pivot point */
    }

#pragma mark Customize Drawing
/* method for generating the bezier path we use for drawing our pointer */
- ( NSBezierPath* ) speedPointerPath
    {
	NSBezierPath* speedPointer = [ NSBezierPath bezierPath ];
	[ speedPointer moveToPoint: NSMakePoint( 134.39, 218.05 ) ];

	[ speedPointer curveToPoint: NSMakePoint( 137.95, 219.75 )
                  controlPoint1: NSMakePoint( 134.39, 218.05 )
                  controlPoint2: NSMakePoint( 137.95, 219.75 ) ];

	[ speedPointer curveToPoint: NSMakePoint( 141.78, 357.55 )
                  controlPoint1: NSMakePoint( 137.95, 219.75 )
                  controlPoint2: NSMakePoint( 141.78, 357.55 ) ];

	[ speedPointer curveToPoint: NSMakePoint( 151.13, 356.31 )
                  controlPoint1: NSMakePoint( 141.78, 357.55 )
                  controlPoint2: NSMakePoint( 145.39, 359.54 ) ];

	[ speedPointer curveToPoint: NSMakePoint( 158.95, 349.86 )
                  controlPoint1: NSMakePoint( 156.87, 353.08 )
                  controlPoint2: NSMakePoint( 158.95, 349.86 ) ];

	[ speedPointer curveToPoint: NSMakePoint( 134.49, 415.99 )
                  controlPoint1: NSMakePoint( 158.95, 349.86 )
                  controlPoint2: NSMakePoint( 134.49, 415.99 ) ];

	[ speedPointer curveToPoint: NSMakePoint( 110.02, 349.86 )
                  controlPoint1: NSMakePoint( 134.49, 415.99 )
                  controlPoint2: NSMakePoint( 110.02, 349.86 ) ];

	[ speedPointer curveToPoint: NSMakePoint( 117.84, 356.31 )
                  controlPoint1: NSMakePoint( 110.02, 349.86 )
                  controlPoint2: NSMakePoint( 112.1,  353.08 ) ];

	[ speedPointer curveToPoint: NSMakePoint( 127.19, 357.55 )
                  controlPoint1: NSMakePoint( 123.58, 359.54 )
                  controlPoint2: NSMakePoint( 127.19, 357.55 ) ];

	[ speedPointer curveToPoint: NSMakePoint( 131.02, 219.75 )
                  controlPoint1: NSMakePoint( 127.19, 357.55 )
                  controlPoint2: NSMakePoint( 131.02, 219.75 ) ];

	[ speedPointer curveToPoint: NSMakePoint( 134.39, 218.05 )
                  controlPoint1: NSMakePoint( 131.02, 219.75 )
                  controlPoint2: NSMakePoint( 134.39, 218.05 ) ];

	[ speedPointer closePath ];

	[ speedPointer setLineJoinStyle: NSRoundLineJoinStyle ];
	[ speedPointer setLineCapStyle: NSRoundLineCapStyle ];
	[ speedPointer setLineWidth: 0.75 ];

	return speedPointer;
    }

/* method for generating the bezier path we use for drawing the ornaments inside of the dial. */
- ( NSBezierPath *) ornamentPath
    {
	NSBezierPath *ornament = [ NSBezierPath bezierPath ];
	[ornament moveToPoint: NSMakePoint( 251.77, 135.25 ) ];

	[ornament curveToPoint: NSMakePoint( 260.31, 146.12 )
             controlPoint1: NSMakePoint( 252.88, 144.62 )
             controlPoint2: NSMakePoint( 260.31, 146.12 ) ];

	[ornament curveToPoint: NSMakePoint( 266.06, 343.75 )
		     controlPoint1: NSMakePoint( 260.31, 146.12 )
             controlPoint2: NSMakePoint( 266.06, 343.75 ) ];

	[ornament curveToPoint: NSMakePoint( 251.79, 355.06 )
             controlPoint1: NSMakePoint( 266.06, 343.75 )
             controlPoint2: NSMakePoint( 257.38, 346.25 ) ];

	[ornament curveToPoint: NSMakePoint( 237.52, 343.75 )
             controlPoint1: NSMakePoint( 245.5,  345.88 )
             controlPoint2: NSMakePoint( 237.52, 343.75 ) ];

	[ornament curveToPoint: NSMakePoint( 243.27, 146.12 )
             controlPoint1: NSMakePoint( 237.52, 343.75 )
             controlPoint2: NSMakePoint( 243.27, 146.12 ) ];

	[ornament curveToPoint: NSMakePoint( 251.77, 135.25 )
             controlPoint1: NSMakePoint( 243.27, 146.12 )
             controlPoint2: NSMakePoint( 250.25, 144.75 ) ];

	[ ornament closePath ];
	[ ornament setLineJoinStyle: NSRoundLineJoinStyle ];
	[ ornament setLineCapStyle: NSRoundLineCapStyle ];
	[ ornament setLineWidth: 0.25 ];

	return ornament;
    }

/* method for generating the bezier path we use for drawing the tik marks around the outside of the dial. */
- ( NSBezierPath* ) tickMarkPath
    {
	NSBezierPath* tickMark = [ NSBezierPath bezierPath ];
	[ tickMark moveToPoint: NSMakePoint( 225.81, 358.28 ) ];

	[ tickMark curveToPoint: NSMakePoint( 222.7,  385.11 )
              controlPoint1: NSMakePoint( 225.81, 358.28 )
              controlPoint2: NSMakePoint( 222.7,  385.11 ) ];

	[ tickMark curveToPoint: NSMakePoint( 235.97, 385.11 )
              controlPoint1: NSMakePoint( 222.7,  385.11 )
              controlPoint2: NSMakePoint( 235.97, 385.11 ) ];

	[ tickMark curveToPoint: NSMakePoint( 232.86, 358.28 )
              controlPoint1: NSMakePoint( 235.97, 385.11 )
              controlPoint2: NSMakePoint( 232.86, 358.28 ) ];

	[tickMark curveToPoint: NSMakePoint( 225.81, 358.28 )
             controlPoint1: NSMakePoint( 232.86, 358.28 )
             controlPoint2: NSMakePoint( 225.81, 358.28 ) ];

	[ tickMark closePath ];
	[ tickMark setLineJoinStyle: NSRoundLineJoinStyle ];
	[ tickMark setLineCapStyle: NSRoundLineCapStyle ];
	[ tickMark setLineWidth: 0.25 ];
    
	return tickMark;
    }

/* custom view's main drawing method */
- ( void ) drawRect: ( NSRect )_DirtyRect
    {
	float const inset = 8.0; /* inset from edges - padding around drawing */
	float const shadowAngle = -35.0;
	
    /* the bounds of this view */
    NSRect boundary = self.bounds;
	
	float sweepAngle = 270.0 * ( self->_curvature / 100.0 ) + 45.0;
	float sAngle = 90 - sweepAngle / 2;
	float eAngle = 90 + sweepAngle / 2;
	
    /* central axis will be aligned with the bottom axis. */
	
	/* calculate center, and radius. */
	NSPoint center;
	float spread = .0f;
    float radius = .0f;
    float dip = .0f;

	/* center horizontally in the view */
	center.x = boundary.origin.x + ( boundary.size.width / 2.0 );

	/* if the sweep is less than or equal to 180 degrees, then we could use
     * the distance from the center to where we'll hit the right
	 * hand side as the radius. */
	spread = ( sweepAngle <= 180 ) ?
			sqrtf( pow( center.x, 2 ) + pow( tanf( sAngle * pi / 180 ) * center.x, 2 ) ) * 2 : boundary.size.width;

    /* if the sweep is greater than 180 degrees, then the right and
     * left sides will dip down below the center. */
	dip = ( sweepAngle > 180 ) ? fabsf( sinf( sAngle * pi / 180 ) ) : 0.0;

    /* calculate the radius based on the height */
	radius = ( boundary.size.height / ( dip + 1.0 ) ) - inset;
	/* then calculate the center based on the radius */
	center.y = boundary.origin.y + radius * dip + ( inset / 2.0 );
		
	/* those calculations could have put us over the right and
	 * left edges, so limit the radius by the maximum spread. */
	if ( radius > spread / 2.0 - inset )
        radius = spread / 2.0 - inset;

	/* calculate some heights proportionate to the radius. */
	float tickSize = radius * ( 5.0 / 100.0 );          /* 5% tick mark height */
	float labelSize = radius * ( 9.0 / 100.0 );         /* 9% label text height */
	float indicatorSize = radius * ( 55.0 / 100.0 );    /* 55% indicator needle length */
	float centerSize = radius * ( 15.0 / 100.0 );       /* 15% center cover size */
	float ornamentSize = radius * ( 40.0 / 100.0 );     /* 40% ornament size */
	float paddingSize = radius * ( 2.0 / 100.0 );       /* 2% padding for spacing between items */

    /* adjust the radius and center position in case we're drawing a pie
     * shaped wedge so that the bottom of the dashboard is aligned with
     * the bottom of the view's rectangle. */
	if ( sweepAngle < 180.0 )
        {
		float wedgeOffset = sinf( sAngle * pi / 180 ) * centerSize;

		center.y -= wedgeOffset;
		radius += wedgeOffset;

		/* make sure we aren't going past the right or left edge */
		if ( radius > spread / 2.0 - inset )
            radius = spread / 2.0 - inset;
        }
	
    /* bottom of the text labels, center the ornaments and needle below this */
	float bottomOfText = radius - tickSize - labelSize - ( paddingSize * 3 );
	
	/* top and bottom position for the ornaments */
	float ornamentTop = ( bottomOfText + centerSize + ornamentSize ) / 2.0;
	float ornamentBottom = ornamentTop - ornamentSize;

	/* top and bottom position for the indicator arm */
	float armTop = ( bottomOfText + centerSize + indicatorSize ) / 2.0;
	float armBottom = armTop - indicatorSize;


	/* make a bezier path for the background */
	NSBezierPath *frame = [ [ [ NSBezierPath alloc ] init ] autorelease ];

	[ frame appendBezierPathWithArcWithCenter: center radius: centerSize startAngle: eAngle endAngle: sAngle clockwise: YES ];
	[ frame appendBezierPathWithArcWithCenter: center radius: radius startAngle: sAngle endAngle: eAngle ];
	[ frame closePath ];
	[ frame setLineWidth: 0.5 ];
	[ frame setLineJoinStyle: NSRoundLineJoinStyle ];

	/* save a copy of the bounding frame */
	[self setBoundingFrame: frame];

	/* construct a tick mark path centered at the origin */
	NSBezierPath* tickmark = self.tickMarkPath;
	[ tickmark transformUsingAffineTransform:
		[ [ NSAffineTransform transform ]
				scaleBounds: [ tickmark bounds ] toHeight: tickSize centeredAboveOrigin: ( radius - paddingSize - tickSize ) ] ];

	/* construct a small background decoration centered at the origin */
	NSBezierPath* ornament = [ self ornamentPath ];
	[ ornament transformUsingAffineTransform:
		[ [ NSAffineTransform transform ]
				scaleBounds: [ ornament bounds ] toHeight: ornamentSize centeredAboveOrigin: ornamentBottom ] ];

	/* construct a the indicator pointer centered at the origin */
	NSBezierPath* speedPointer = [ self speedPointerPath ];
	[ speedPointer transformUsingAffineTransform:
		[ [ NSAffineTransform transform ]
				scaleBounds: [ speedPointer bounds ] toHeight: indicatorSize centeredAboveOrigin: armBottom ] ];

	/* blending colors for the ornaments and tick marks */
	NSColor* startColor = [ NSColor greenColor ];
	NSColor* midColor = [ NSColor yellowColor ];
	NSColor* endColor = [ NSColor redColor ];
#if 0   // TODO: Alternate colors
    NSColor* startColor = [ NSColor colorWithCalibratedRed: .9804f green: .9804f blue: 1.f alpha: 1.f ];
    NSColor* midColor = [ NSColor colorWithCalibratedRed: .8235f green: .5608f blue: .5137f alpha: 1.f ];
    NSColor* endColor = [ NSColor colorWithCalibratedRed: .1569f green: .2039f blue: .6314f alpha: 1.f ];
#endif

    /* calculate the font to use for the label */
	NSFont* labelFont = [ [ NSFont labelFontOfSize: labelSize ] printerFont ];

	/* transforms used during drawing */
	NSAffineTransform* transform;
	NSAffineTransform* identity = [ NSAffineTransform transform ];
	
    /* calculate the pointer arm's total sweep */
	float pointerWidth = speedPointer.bounds.size.width;
    /* border on each end of sweep to accomodate width of pointer */
	float tickoutside = ( ( pointerWidth * .67f ) / ( radius / 2.f ) ) * 180 / pi;
    /* total arm sweep will be background sweep minus border on each side */
	float armSweep = sweepAngle - tickoutside*2;
	
    /* calculate the number of tick mark labels */
	float ornamentWidth = ornament.bounds.size.width;
    /* border on each end of sweep to accomodate width of pointer */
	float ornamentDegrees = ( ornamentWidth / ornamentBottom ) * 180 / pi;
    /* calculate the maximum number of ornaments that will fit */
	int maxTicks = truncf( armSweep / ornamentDegrees );
    /* limit the number of ticks we'll draw by the maximum */
	int limitedTicks = ( ( self.ticks > maxTicks ) ? maxTicks : self.ticks );
    /* calculate the number of degrees between tickmarks */
	float tickdegrees = ( armSweep ) / ( ( float )limitedTicks - 1.0 );

    /* loop drawing tick mark labels and ornaments */
    for ( int index = 0; index < limitedTicks; index++ )
        {
        /* set up the transform matrix so we're drawing at the appropriate angle. 
         * Here, we reset the xform matrix, center it on the axis of our dial, 
         * and then rotate it to the nth position. */
		transform = [ [ NSAffineTransform alloc ] initWithTransform: identity ];    /* reset the xform matrix */
		[ transform translateXBy: center.x yBy: center.y ];                         /* set the center to the center of our dial */

        CGFloat degree = ( ( limitedTicks - index - 1 ) * tickdegrees + tickoutside + sAngle - 90 );
		[ transform rotateByDegrees: degree ];
		[ transform concat ];

		/* calculate the label string to display */
		float displayedValue = roundf( ( float )( 100.f / ( limitedTicks - 1 ) ) * index );

		NSString* theLabel = nil;
        if ( index == 0 )
            theLabel = NSLocalizedString( @"L", nil );
        else if ( index == limitedTicks - 1 )
            theLabel = NSLocalizedString( @"H", nil );
        else
            theLabel = [ NSString stringWithFormat: @"%.0f", displayedValue ];

		/* draw the tick mark label string using a NSBezierPath */
		NSBezierPath* nthLabelPath = [ theLabel bezierWithFont: labelFont ];
		[ nthLabelPath transformUsingAffineTransform:
            [ [ NSAffineTransform transform ] scaleBounds: [ nthLabelPath bounds ]
                                                 toHeight: [ nthLabelPath bounds ].size.height
                                      centeredAboveOrigin: bottomOfText - [ labelFont descender ] ] ];

		[ nthLabelPath setLineWidth: .5f ];
        [ [ [ NSColor whiteColor ] colorWithAlphaComponent: .5f ] set ];
		[ nthLabelPath fill ];
		[ nthLabelPath stroke ];

        /* draw the ornament.
         * Ramp from green to yellow and then from yellow to red. */
		float cfraction = ( ( float )index / ( float )( limitedTicks - 1 ) );
		if ( cfraction <= .5f )
			[ [ [ startColor blendedColorWithFraction: cfraction * 2 ofColor: midColor ] colorWithAlphaComponent: .5f ] set ];
		else
            [ [ [ midColor blendedColorWithFraction: ( cfraction - 0.5 ) * 2 ofColor: endColor ] colorWithAlphaComponent: .5f ] set ];

		[ ornament fill ];
		[ tickmark fill ];
		[ tickmark stroke ];
		[ ornament stroke ];

		[ transform invert ];
		[ transform concat ];
        
        [ transform release ];
        }
					
    /* translate and rotate the indicator arrow to its final position */
	NSAffineTransform* positionSpeedometer = [ NSAffineTransform transform ];
	[ positionSpeedometer translateXBy: center.x yBy: center.y ]; /* set the center to the center of our dial */
	[ positionSpeedometer rotateByDegrees: ( armSweep + tickoutside - ( armSweep / 100 ) * self->_speed + sAngle ) - 90 ];
	[ speedPointer transformUsingAffineTransform: positionSpeedometer ];
	
    /* draw the pointer */
	[ [ NSColor colorWithCalibratedRed: 1.f green: .24f blue: .084f alpha: .65f ] set ];
	[ speedPointer fillWithShadowAtDegrees: shadowAngle withDistance: inset / 2 ];
	[ speedPointer stroke ];
	
    /* record arm information for the drag routine */
	[ self saveSweepWithCenter: center
                    startAngle: ( sAngle + tickoutside )
                      endAngle: ( sAngle + tickoutside + armSweep ) ];
    }

#pragma mark Events Handling
- ( BOOL ) acceptsFirstMouse:( NSEvent* )theEvent
    {
    return YES;
    }

/* Convert a mouse click inside of the speedometer view into an angle, 
 * and then convert that angle into the new value that should be displayed. */
- ( void ) setLevelForMouse: ( NSPoint )_LocalPoint
    {
    /* calculate the new position */
	float clickedAngle = atanf( ( _LocalPoint.y - self->_iCenterPt.y ) / ( _LocalPoint.x - self->_iCenterPt.x ) ) * ( 180 / pi );
	
	/* convert arc tangent result */
	if ( _LocalPoint.x < self->_iCenterPt.x )
        clickedAngle += 180;
	
	/* clamp angle between the start and end angles */
	if ( clickedAngle > self->_iEndAngle )
		clickedAngle = self->_iEndAngle;
	else if ( clickedAngle < self->_iStartAngle )
		clickedAngle = self->_iStartAngle;
		
	/* set the new speed, but only if it has changed */
	float newLevel = ( self->_iEndAngle - clickedAngle ) / ( self->_iEndAngle - self->_iStartAngle ) * 100.0;
	if ( self.speed != newLevel )
		self.speed = newLevel;
    }

/* ceturn false so we can track the mouse in our view. */
- ( BOOL ) mouseDownCanMoveWindow
    {
    return NO;
    }

/* test for mouse clicks inside of the speedometer area of the view */
- ( NSView* ) hitTest: ( NSPoint )_Point
    {
	NSPoint localPoint = [ self convertPoint: _Point fromView: [ self superview ] ];

	if ( [ self.boundingFrame containsPoint: localPoint ] )
		return self;

	return [ super hitTest: _Point ];
    }

/* re-calculate the speed value based on the mouse position for clicks
 * in the speedometer area of the view. */
- ( void ) mouseDown: ( NSEvent * )_IncomingEvent
    {
	NSPoint localPoint = [ self convertPoint: [ _IncomingEvent locationInWindow ] fromView: nil ];

	if ( [ self.boundingFrame containsPoint: localPoint ] )
        {
		[ self setLevelForMouse: localPoint ];
		[ self setDraggingIndicator: YES ];
        }
    }

/* re-calculate the speed value based on the mouse position while the mouse
 * is being dragged inside of the speedometer area of the view. */
- ( void ) mouseDragged: ( NSEvent* )_IncomingEvent
    {
	NSPoint localPoint = [ self convertPoint: [ _IncomingEvent locationInWindow ] fromView: nil ];

	if ( [ self.boundingFrame containsPoint: localPoint ] )
		[ self setLevelForMouse: localPoint ];
    }

/* clear the dragging flag once the mouse is released. */
- ( void ) mouseUp: ( NSEvent* )_IncomingEvent
    {
	[ self setDraggingIndicator: NO ];

    [ USER_DEFAULTS setDouble: self.speed forKey: OMFDefaultsKeyDefaultTickVal ];
    [ USER_DEFAULTS synchronize ];
    }

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