//
//  Dropbox.h
//  DropBoxSample
//
//  Created by Shubhangi Pandya on 13/03/15.
//  Copyright (c) 2015 Shubhangi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


// OAuth Stuff
extern NSString * const oauthTokenKey;
extern NSString * const oauthTokenKeySecret;
extern NSString * const requestToken;
extern NSString * const requestTokenSecret;
extern NSString * const accessToken;
extern NSString * const accessTokenSecret;
extern NSString * const dropboxUIDKey;
extern NSString * const dropboxTokenReceivedNotification;

// App settings
extern NSString * const appFolder;

typedef void (^DropboxRequestTokenCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);

@interface Dropbox : NSObject <CLLocationManagerDelegate>

// oauth
+ (void)requestTokenWithCompletionHandler:(DropboxRequestTokenCompletionHandler)completionBlock;
+ (void)exchangeTokenForUserAccessTokenURLWithCompletionHandler:(DropboxRequestTokenCompletionHandler)completionBlock;
+ (NSString*)apiAuthorizationHeader;

// helpers
+ (NSDictionary*)dictionaryFromOAuthResponseString:(NSString*)response;

+ (NSURL*)appRootURL;
+ (NSURL*)uploadURLForPath:(NSString*)path;
+ (NSURL*)createPhotoUploadURL;
@end
