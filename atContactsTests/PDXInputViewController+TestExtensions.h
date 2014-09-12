//
//  PDXTwitterCommunicator+TestExtensions.h
//  atContacts
//
//  Created by Paul Darcey on 11/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDXInputViewController (TestExtensions)

// The following are only exposed for testing
- (NSString *)removeHash:(NSString *)hashtag;
- (PDXTwitterCommunicator *)twitter;
- (BOOL)dialogHasBeenPresented;
- (BOOL)userDeniedPermission;
- (BOOL)userHasNoAccount;
- (void)saveHashtag:(NSString *)hashtag;
- (NSString *)retrieveHashtag;


@end
