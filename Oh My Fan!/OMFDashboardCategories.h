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

// NSAffineTransform + OMFRectMapping
@interface NSAffineTransform ( OMFRectMapping )

/* initialize the NSAffineTransform so it maps points in
 * srcBounds proportionally to points in dstBounds */
- ( NSAffineTransform* ) mapFrom: ( NSRect )_SrcBounds to: ( NSRect )_DstBounds;

/* scale the rectangle 'bounds' proportionally to the given height centered
 * above the origin with the bottom of the rectangle a distance of height above
 * the a particular point.  Handy for revolving items around a particular point. */
- ( NSAffineTransform* ) scaleBounds: ( NSRect )_Bounds
                            toHeight: ( float )_Height
                    centeredDistance: ( float )_Distance
                          abovePoint: ( NSPoint )_Location;

/* same as the above, except it centers the item above the origin.  */
- ( NSAffineTransform* ) scaleBounds: ( NSRect )_Bounds
                            toHeight: ( float )_Height
                 centeredAboveOrigin: ( float )_Distance;

/* initialize the NSAffineTransform so it will flip the contents of bounds
 * vertically. */
- ( NSAffineTransform* ) flipVertical: ( NSRect )_Bounds;

@end

// NSBezierPath + OMFShadowDrawing
@interface NSBezierPath ( OMFShadowDrawing )

/* fill a bezier path, but draw a shadow under it offset by the
 * given angle (counter clockwise from the x-axis) and distance. */
- ( void ) fillWithShadowAtDegrees: ( float )_Angle withDistance: ( float )_Distance;

@end // NSAffineTransform + OMFRectMapping


@interface BezierNSLayoutManager: NSLayoutManager {
	NSBezierPath *theBezierPath;
}
- (void)dealloc;

@property (nonatomic, copy) NSBezierPath *theBezierPath;

	/* convert the NSString into a NSBezierPath using a specific font. */
- (void)showPackedGlyphs:(char *)glyphs length:(unsigned)glyphLen
		glyphRange:(NSRange)glyphRange atPoint:(NSPoint)point font:(NSFont *)font
		color:(NSColor *)color printingAdjustment:(NSSize)printingAdjustment;
@end


@interface NSString (BezierConversions)

	/* convert the NSString into a NSBezierPath using a specific font. */
- (NSBezierPath *)bezierWithFont:(NSFont *)theFont;

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