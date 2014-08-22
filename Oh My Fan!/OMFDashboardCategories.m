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


@implementation NSAffineTransform (RectMapping)

- (NSAffineTransform *)mapFrom:(NSRect)src to:(NSRect)dst {
	NSAffineTransformStruct at;
	at.m11 = (dst.size.width/src.size.width);
	at.m12 = 0.0;
	at.tX = dst.origin.x - at.m11*src.origin.x;
	at.m21 = 0.0;
	at.m22 = (dst.size.height/src.size.height);
	at.tY = dst.origin.y - at.m22*src.origin.y;
	[self setTransformStruct: at];
	return self;
}

	/* create a transform that proportionately scales bounds to a rectangle of height
	centered distance units above a particular point.   */
- (NSAffineTransform *)scaleBounds:(NSRect)bounds 
		toHeight:(float)height centeredDistance:(float)distance abovePoint:(NSPoint)location {
	NSRect dst = bounds;
	float scale = (height / dst.size.height);
	dst.size.width *= scale;
	dst.size.height *= scale;
	dst.origin.x = location.x - dst.size.width/2.0;
	dst.origin.y = location.y + distance;
	return [self mapFrom:bounds to:dst];
}

	/* create a transform that proportionately scales bounds to a rectangle of height
	centered distance units above the origin.   */
- (NSAffineTransform *)scaleBounds:(NSRect)bounds toHeight:(float)height
			centeredAboveOrigin:(float)distance {
	return [self scaleBounds: bounds toHeight: height centeredDistance:
			distance abovePoint: NSMakePoint(0,0)];
}

	/* initialize the NSAffineTransform so it will flip the contents of bounds
	vertically. */
- (NSAffineTransform *)flipVertical:(NSRect) bounds {
	NSAffineTransformStruct at;
	at.m11 = 1.0;
	at.m12 = 0.0;
	at.tX = 0;
	at.m21 = 0.0;
	at.m22 = -1.0;
	at.tY = bounds.size.height;
	[self setTransformStruct: at];
	return self;
}

@end



@implementation NSBezierPath (ShadowDrawing)

	/* fill a bezier path, but draw a shadow under it offset by the
	given angle (counter clockwise from the x-axis) and distance. */
- (void)fillWithShadowAtDegrees:(float) angle withDistance:(float)distance {
	float radians = angle*(3.141592/180.0);
	
		/* create a new shadow */
	NSShadow* theShadow = [[NSShadow alloc] init];
	
		/* offset the shadow by the indicated direction and distance */
	[theShadow setShadowOffset:NSMakeSize(cosf(radians)*distance, sinf(radians)*distance)];
	
		/* set other shadow parameters */
	[theShadow setShadowBlurRadius:3.0];
	[theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];

		/* save the graphics context */
	[NSGraphicsContext saveGraphicsState];
	
		/* use the shadow */
	[theShadow set];

		/* fill the NSBezierPath */
	[self fill];
	
		/* restore the graphics context */
	[NSGraphicsContext restoreGraphicsState];
	
		/* done with the shadow */
	[theShadow release];
}

@end



@implementation BezierNSLayoutManager

- (void) dealloc {
	self.theBezierPath = nil;
	[super dealloc];
}

- (NSBezierPath *)theBezierPath {
    return [[theBezierPath retain] autorelease];
}

- (void)setTheBezierPath:(NSBezierPath *)value {
    if (theBezierPath != value) {
        [theBezierPath release];
        theBezierPath = [value retain];
    }
}

	/* convert the NSString into a NSBezierPath using a specific font. */
- (void)showPackedGlyphs:(char *)glyphs length:(unsigned)glyphLen
		glyphRange:(NSRange)glyphRange atPoint:(NSPoint)point font:(NSFont *)font
		color:(NSColor *)color printingAdjustment:(NSSize)printingAdjustment {
	
		/* if there is a NSBezierPath associated with this
		layout, then append the glyphs to it. */
	NSBezierPath *bezier = [self theBezierPath];
	
	if ( nil != bezier ) {
	
			/* add the glyphs to the bezier path */
		[bezier moveToPoint:point];
		[bezier appendBezierPathWithPackedGlyphs: glyphs];
	}
}

@end


@implementation NSString (BezierConversions)

- (NSBezierPath *)bezierWithFont: (NSFont*) theFont {
    
	NSBezierPath *bezier = nil; /* default result */
	
		/* put the string's text into a text storage
		so we can access the glyphs through a layout. */
	NSTextStorage *textStore = [[NSTextStorage alloc] initWithString:self];
	NSTextContainer *textContainer = [[NSTextContainer alloc] init];
	BezierNSLayoutManager *myLayout = [[BezierNSLayoutManager alloc] init];
	[myLayout addTextContainer:textContainer];
	[textStore addLayoutManager:myLayout];
	[textStore setFont: theFont];
	
		/* create a new NSBezierPath and add it to the custom layout */
	[myLayout setTheBezierPath:[NSBezierPath bezierPath]];
	
		/* to call drawGlyphsForGlyphRange, we need a destination so we'll
		set up a temporary one.  Size is unimportant and can be small.  */
	NSImage *theImage = [[NSImage alloc] initWithSize: NSMakeSize(10.0, 10.0)];
		 /* lines are drawn in reverse order, so we will draw the text upside down
		 and then flip the resulting NSBezierPath right side up again to achieve
		 our final result with the lines in the right order and the text with
		 proper orientation.  */
	[theImage setFlipped:YES];
	[theImage lockFocus];
	
		/* draw all of the glyphs to collecting them into a bezier path
		using our custom layout class. */
	NSRange glyphRange = [myLayout glyphRangeForTextContainer:textContainer];
	[myLayout drawGlyphsForGlyphRange:glyphRange atPoint:NSMakePoint(0.0, 0.0)];
	
		/* clean up our temporary drawing environment */
	[theImage unlockFocus];
	[theImage release];
	
		/* retrieve the glyphs from our BezierNSLayoutManager instance */
	bezier = [myLayout theBezierPath];
	
		/* clean up our text storage objects */
	[textStore release];
	[textContainer release];
	[myLayout release];
	
		/* Flip the final NSBezierPath. */
	[bezier transformUsingAffineTransform: 
		[[NSAffineTransform transform] flipVertical:[bezier bounds]]];
	
		/* return the new bezier path */
	return bezier;
}
	
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