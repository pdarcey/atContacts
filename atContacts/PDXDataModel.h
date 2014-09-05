//
//  PDXDataModel.h
//  atContacts
//
//  Created by Paul Darcey on 2/09/2014.
//  Copyright (c) 2014 Paul Darcey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDXDataModel : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *twitterName;
@property (strong, nonatomic) NSString *idString;
@property (strong, nonatomic) NSString *hashtag;
@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *wwwAddress;
@property (strong, nonatomic) NSString *twitterDescription;
@property (strong, nonatomic) NSString *photoURL;
@property (strong, nonatomic) NSData *photoData;
@property BOOL alreadyFollow;

@end
