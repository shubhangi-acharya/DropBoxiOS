//
//  ErrorFactory.m
//  MobiquityTest
//
//  Created by Shubhangi Pandya on 13/03/2015.
//  Copyright (c) 2015 Shubhangi. All rights reserved.
//

#import "ErrorFactory.h"

const NSInteger ERR_FILE_NOT_FOUND = 1;
const NSInteger ERR_REQUEST_IN_PROGRESS = 2;
const NSInteger ERR_CONNECTION_ERROR = 3;
const NSInteger ERR_JSON_ERROR = 4;

static NSString * const ERROR_DESCRIPTION[] = {
    @"No error",
    @"Couldn't find file",
    @"Upload already requested for file",
    @"Couldn't connect to server",
    @"JSON Error",
};

@implementation ErrorFactory

+(NSError *) errorWithCode:(NSInteger ) code {
    const NSString *description = ERROR_DESCRIPTION[code];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              description, NSLocalizedDescriptionKey,
                              nil];
    NSError *error = [NSError errorWithDomain:@"com.TestApp.DropBox.ErrorDomain" code:code userInfo:userInfo];
    return error;
}

+(NSError *) errorWithCode:(NSInteger ) errorCode errorMessage:(NSString *) errorMessage fieldErrors:( id ) fieldErrors {
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    if( errorMessage) {
        [userInfo setValue:errorMessage forKey:NSLocalizedDescriptionKey];
    }
    if( fieldErrors ) {
        [userInfo setValue:fieldErrors forKey:NSLocalizedFailureReasonErrorKey];
    }
    NSError *error = [NSError errorWithDomain:@"com.TestApp.DropBox.ErrorDomain" code:errorCode userInfo:userInfo];
    return error;
}

+(NSError *) errorWithCode:(NSInteger) errorCode underlyingError:(NSError * ) error {
    const NSString *description = ERROR_DESCRIPTION[errorCode];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              description, NSLocalizedDescriptionKey,
                              error, NSUnderlyingErrorKey,
                              nil];
    NSError *returnedError = [NSError errorWithDomain:@"com.TestApp.DropBox.ErrorDomain" code:errorCode userInfo:userInfo];
    return returnedError ;
}
@end
