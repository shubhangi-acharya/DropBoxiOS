//
//  ErrorFactory.h
//  MobiquityTest
//
//  Created by Shubhangi Pandya on 13/03/2015.
//  Copyright (c) 2015 Shubhangi. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN const NSInteger ERR_FILE_NOT_FOUND;
FOUNDATION_EXTERN const NSInteger ERR_REQUEST_IN_PROGRESS;
FOUNDATION_EXTERN const NSInteger ERR_CONNECTION_ERROR;
FOUNDATION_EXTERN const NSInteger ERR_JSON_ERROR;

@interface ErrorFactory : NSObject

+(NSError *) errorWithCode:(NSInteger ) code;
+(NSError *) errorWithCode:(NSInteger ) code errorMessage:(NSString *) errorMessage fieldErrors:( id ) fieldErrors;
+(NSError *) errorWithCode:(NSInteger) errorCode underlyingError:(NSError * ) error;

@end
