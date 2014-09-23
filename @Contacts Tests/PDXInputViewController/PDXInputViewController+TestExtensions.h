//
//  PDXTwitterCommunicator+TestExtensions.h
//  atContacts
//
//  Created by Paul Darcey on 11/09/2014.
//  © 2014 Paul Darcey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDXInputViewController (TestExtensions)

/**
 *  Exposes methods within PDXInputViewController which would otherwise not be available for individual testing
 *
 *  The following are only exposed for testing
 *
 *  @since 1.0
 */

- (NSString *)removeHash:(NSString *)hashtag;
- (PDXTwitterCommunicator *)twitter;
- (BOOL)dialogHasBeenPresented;
- (BOOL)userDeniedPermission;
- (BOOL)userHasNoAccount;
- (void)saveHashtag:(NSString *)hashtag;
- (NSString *)retrieveHashtag;

@end