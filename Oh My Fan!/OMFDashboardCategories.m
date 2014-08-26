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

// NSAffineTransform + OMFRectMapping
@implementation NSAffineTransform ( OMFRectMapping )

- ( NSAffineTransform* ) mapFrom: ( NSRect )_SrcBounds to: ( NSRect )_DstBounds
    {
	NSAffineTransformStruct transformStruct;

	transformStruct.m11 = ( _DstBounds.size.width / _SrcBounds.size.width );
	transformStruct.m12 = 0.0;
	transformStruct.tX = _DstBounds.origin.x - transformStruct.m11 * _SrcBounds.origin.x;
	transformStruct.m21 = 0.0;
	transformStruct.m22 = ( _DstBounds.size.height / _SrcBounds.size.height );
	transformStruct.tY = _DstBounds.origin.y - transformStruct.m22 * _SrcBounds.origin.y;

	[ self setTransformStruct: transformStruct ];

	return self;
    }

/* create a transform that proportionately scales bounds to a rectangle of height
 * centered distance units above a particular point. 
 */
- ( NSAffineTransform* ) scaleBounds: ( NSRect )_Bounds
                            toHeight: ( float )_Height
                    centeredDistance: ( float )_Distance
                          abovePoint: ( NSPoint )_Location
    {
	NSRect dst = _Bounds;
	float scale = ( _Height / dst.size.height );

	dst.size.width *= scale;
	dst.size.height *= scale;
	dst.origin.x = _Location.x - ( dst.size.width / 2.0 );
	dst.origin.y = _Location.y + _Distance;

	return [ self mapFrom: _Bounds to: dst ];
    }

/* create a transform that proportionately scales bounds to a rectangle of height
 * centered distance units above the origin. 
 */
- ( NSAffineTransform* )scaleBounds: ( NSRect )_Bounds
                           toHeight: ( float )_Height
                centeredAboveOrigin: ( float )_Distance
    {
	return [ self scaleBounds: _Bounds
                     toHeight: _Height
             centeredDistance: _Distance
                   abovePoint: NSMakePoint( 0, 0 ) ];
    }

/* initialize the NSAffineTransform so it will flip the contents of bounds vertically.
 */
- ( NSAffineTransform* ) flipVertical: ( NSRect )_Bounds
    {
	NSAffineTransformStruct flipTransform = { 1.f, 0.f, 0.f, -1.f, 0.f, _Bounds.size.height };
	[ self setTransformStruct: flipTransform ];

	return self;
    }

@end // NSAffineTransform + OMFRectMapping


// NSBezierPath + OMFShadowDrawing
@implementation NSBezierPath ( OMFShadowDrawing )

/* fill a bezier path, but draw a shadow under it offset by the
 * given angle (counter clockwise from the x-axis) and distance. 
 */
- ( void ) fillWithShadowAtDegrees: ( float )_Angle withDistance: ( float )_Distance
    {
	float radians = _Angle * ( 3.141592 / 180.0 );
	
	NSShadow* shadow = [ [ NSShadow alloc ] init ];

	[ shadow setShadowOffset: NSMakeSize( cosf( radians ) * _Distance, sinf( radians ) * _Distance ) ];
	[ shadow setShadowBlurRadius: 3.0 ];
	[ shadow setShadowColor: [ [ NSColor blackColor ] colorWithAlphaComponent: 0.3 ] ];

	[ NSGraphicsContext saveGraphicsState ];
        {
        [ shadow set ];
        [ self fill ];
        }
	[ NSGraphicsContext restoreGraphicsState ];

	[ shadow release ];
    }

@end // NSBezierPath + OMFShadowDrawing


// OMFBezierNSLayoutManager class
@implementation OMFBezierNSLayoutManager

@synthesize theBezierPath = _theBezierPath;

- ( void ) dealloc
    {
	self.theBezierPath = nil;

	[ super dealloc ];
    }

- ( NSBezierPath* ) theBezierPath
    {
    return [ [ self->_theBezierPath retain ] autorelease ];
    }

- ( void ) setTheBezierPath: ( NSBezierPath* )_Value
    {
    if ( self->_theBezierPath != _Value )
        {
        [ self->_theBezierPath release ];

        self->_theBezierPath = [ _Value retain ];
        }
    }

/* convert the NSString into a NSBezierPath using a specific font. */
- ( void ) showPackedGlyphs: ( char*  )_Glyphs
                     length: ( unsigned )_GlyphLen
                 glyphRange: ( NSRange )_GlyphRange
                    atPoint: ( NSPoint )_Point
                       font: ( NSFont* )_Font
                      color: ( NSColor* )_Color
         printingAdjustment: ( NSSize )_PrintingAdjustment
    {

    /* if there is a NSBezierPath associated with this
     * layout, then append the glyphs to it. */
	NSBezierPath *bezier = [ self theBezierPath ];
	
	if ( nil != bezier )
        {
        /* add the glyphs to the bezier path */
		[ bezier moveToPoint: _Point ];
		[ bezier appendBezierPathWithPackedGlyphs: _Glyphs ];
        }
    }

@end // OMFBezierNSLayoutManager class



// NSString + OMFBezierConversions
@implementation NSString ( OMFBezierConversions )

- ( NSBezierPath* ) bezierWithFont: ( NSFont* )_Font
    {
	NSBezierPath* bezier = nil; /* default result */
	
    /* put the string's text into a text storage
     * so we can access the glyphs through a layout. */
	NSTextStorage* textStore = [ [ NSTextStorage alloc ] initWithString: self ];
	NSTextContainer* textContainer = [ [ NSTextContainer alloc ] init ];
	OMFBezierNSLayoutManager* myLayout = [ [ OMFBezierNSLayoutManager alloc ] init ];

	[ myLayout addTextContainer: textContainer ];
	[ textStore addLayoutManager: myLayout ];
	[ textStore setFont: _Font ];
	
	/* create a new NSBezierPath and add it to the custom layout */
	[ myLayout setTheBezierPath: [ NSBezierPath bezierPath ] ];
	
    /* to call drawGlyphsForGlyphRange, we need a destination so we'll
     * set up a temporary one.  Size is unimportant and can be small.  */
	NSImage* theImage = [ [ NSImage alloc ] initWithSize: NSMakeSize( 10.0, 10.0 ) ];

    /* lines are drawn in reverse order, so we will draw the text upside down
     * and then flip the resulting NSBezierPath right side up again to achieve
     * our final result with the lines in the right order and the text with
     * proper orientation.  */
	[ theImage setFlipped: YES ];

	[ theImage lockFocus ];
        {
        /* draw all of the glyphs to collecting them into a bezier path
         * using our custom layout class. */
        NSRange glyphRange = [ myLayout glyphRangeForTextContainer: textContainer ];
        [ myLayout drawGlyphsForGlyphRange: glyphRange atPoint: NSMakePoint( 0.0, 0.0 ) ];
        }
	[ theImage unlockFocus ];

	[ theImage release ];

	bezier = [ myLayout theBezierPath ];

	[ textStore release ];
	[ textContainer release ];
	[ myLayout release ];
	
	/* Flip the final NSBezierPath. */
	[ bezier transformUsingAffineTransform: [ [ NSAffineTransform transform ] flipVertical: [ bezier bounds ] ] ];
	
	/* return the new bezier path */
	return bezier;
    }
	
@end // NSString + OMFBezierConversions

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