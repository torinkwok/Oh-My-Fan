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

#import "NSFileManager+DirectoryLocations.h"

enum { DirectoryLocationErrorNoPathFound, DirectoryLocationErrorFileExistsAtLocation };
	
NSString* const DirectoryLocationDomain = @"DirectoryLocationDomain";

@implementation NSFileManager ( OMFDirectoryLocations )

// findOrCreateDirectory:inDomain:appendPathComponent:error:
//
// Method to tie together the steps of:
//	1) Locate a standard directory by search path and domain mask
//  2) Select the first path in the results
//	3) Append a subdirectory to that path
//	4) Create the directory and intermediate directories if needed
//	5) Handle errors by emitting a proper NSError object
//
// Parameters:
//    searchPathDirectory - the search path passed to NSSearchPathForDirectoriesInDomains
//    domainMask - the domain mask passed to NSSearchPathForDirectoriesInDomains
//    appendComponent - the subdirectory appended
//    errorOut - any error from file operations
//
// returns the path to the directory (if path found and exists), nil otherwise
//
- ( NSString* ) findOrCreateDirectory: ( NSSearchPathDirectory )_SearchPathDirectory
                             inDomain: ( NSSearchPathDomainMask )_DomainMask
                  appendPathComponent: ( NSString* )_AppendComponent
                                error: ( NSError** )_ErrorOut;
    {
	/* Search for the path */
	NSArray* paths = NSSearchPathForDirectoriesInDomains( _SearchPathDirectory, _DomainMask, YES );

    if ( [ paths count ] == 0 )
        {
        if ( _ErrorOut )
            {
            NSDictionary *userInfo =
                [ NSDictionary dictionaryWithObjectsAndKeys:
                      NSLocalizedStringFromTable( @"No path found for directory in domain.", @"Errors", nil ), NSLocalizedDescriptionKey
                    , [ NSNumber numberWithInteger: _SearchPathDirectory ], @"NSSearchPathDirectory"
                    , [ NSNumber numberWithInteger: _DomainMask ], @"NSSearchPathDomainMask"
                    , nil ];

            *_ErrorOut = [ NSError errorWithDomain: DirectoryLocationDomain
                                              code: DirectoryLocationErrorNoPathFound
                                          userInfo: userInfo ];
            }

        return nil;
        }

	/* Normally only need the first path returned */
	NSString* resolvedPath = [ paths objectAtIndex: 0 ];

	/* Append the extra path component */
	if (_AppendComponent)
		resolvedPath = [ resolvedPath stringByAppendingPathComponent: _AppendComponent ];

	/* Create the path if it doesn't exist */
	NSError *error = nil;
	BOOL success = [ self createDirectoryAtPath: resolvedPath
                    withIntermediateDirectories: YES
                                     attributes: nil
                                          error: &error ];
	if ( !success )
        {
		if ( _ErrorOut )
			*_ErrorOut = error;

		return nil;
        }

	/* If we've made it this far, we have a success */
	if ( _ErrorOut )
		*_ErrorOut = nil;

	return resolvedPath;
    }

/* Returns the path to the applicationSupportDirectory (creating it if it doesn't
 * exist).
 */
- ( NSString* ) applicationSupportDirectory
    {
	NSString* executableName =
		[ [ [ NSBundle mainBundle ] infoDictionary ] objectForKey: @"CFBundleExecutable" ];

	NSError *error = nil;
	NSString *result = [ self findOrCreateDirectory: NSApplicationSupportDirectory
                                           inDomain: NSUserDomainMask
                                appendPathComponent: executableName
                                              error: &error];
	if ( !result )
		NSLog( @"Unable to find or create application support directory:\n%@", error);

	return result;
    }

@end // NSFileManager + OMFDirectoryLocations

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