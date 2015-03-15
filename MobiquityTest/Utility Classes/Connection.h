//
//  Connection.h
//  MobiquityTest
//
//  Responsible for making a connection to a remote service and collecting the reponse
//  Initialise with a request and set up a completion block to make it go.
//
//  Created by Shubhangi Pandya on 13/03/2015.
//  Copyright (c) 2015 Shubhangi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Connection : NSObject <NSURLConnectionDataDelegate>

typedef void (^ConnectionCompletionBlock) (NSInteger statusCode, NSDictionary *headers, id obj, NSError * err);

/**
 * Construct a connection with the given request and completion block.
 * The completion block will be called on completion.
 */
-(id)initWithRequest:(NSURLRequest *)req completionBlock:(ConnectionCompletionBlock) completionBlock ;

/**
 * Start the connection
 */
-(void) start;

@end
