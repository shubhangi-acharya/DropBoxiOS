//
//  Connection.m
//  DropBoxSample
//

//  Created by Shubhangi Pandya on 13/03/2015.
//  Copyright (c) 2015 Shubhangi. All rights reserved.
//

#import "Connection.h"


/** Ensure that references are retained to connections until they complete */
static NSMutableArray *sharedConnectionList = nil;


@interface Connection ( ) {
    /*! Body of Response */
    NSMutableData       *_container;
    
    /*! HTTP HEaders */
    NSDictionary        *_headers;
    
    /*! The status code returned from the server */
    NSInteger           _statusCode;
    
    /** Completion block if provided */
    ConnectionCompletionBlock  _completionBlock;
    
    /** UNderlying NSURLConnection */
    NSURLConnection                 *_internalConnection;
}
@end



@implementation Connection


/**
 * Construct a connection with the given request and completion block.
 * The completion block will be called on completion.
 */
-(id)initWithRequest:(NSURLRequest *)req completionBlock:(ConnectionCompletionBlock) completionBlock {
    if ( (self = [super init]) ) {
        // Allocate storage for data
        _container = [[NSMutableData alloc]init];
        
        // Create an NSURLConnection for the request
        _internalConnection = [[NSURLConnection alloc] initWithRequest:req
                                                              delegate:self
                                                      startImmediately:NO];
        
        _completionBlock = [completionBlock copy];
    }
    return self;
}

/**
 * Execute the connection
 */
-(void)start {
    if(!sharedConnectionList) {
        sharedConnectionList = [[NSMutableArray alloc] init];
    }

    // Add connection to shared list to maintain a reference count
    [sharedConnectionList addObject:self];
    
    // Schedule the connection
    [_internalConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    
    // nd launch it
    [_internalConnection start];
}


#pragma mark NSURLConnectionDataDelegate methods

/**
 * Received a response from the server. This could be a redirect or other useless
 * response but we should be prepared to process it anyway
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Store the status code
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    
    _statusCode = httpResponse.statusCode;
    NSLog( @"Info: Response from server : [%ld] %@", (long)_statusCode, [NSHTTPURLResponse localizedStringForStatusCode:_statusCode] );

    // Store the headers
    _headers = httpResponse.allHeaderFields;
    
    // Zero the content (we may be called several times);
    [_container setLength:0];
}


/**
 * We have data. Append to the container
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_container appendData:data];
}

/**
 * Connection has finished.
 * Responses are probably small enough to process on main thread. At least the client should make this decision so just execute the completion block
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(_completionBlock) {
        _completionBlock(_statusCode, _headers, _container, nil);
    }

    // Remove the connection from the list so it can be reclaimed
    [sharedConnectionList removeObject:self];
}

/**
 * Connection failure. We report this as an error to the completion handler
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog( @"Error: connection:didFailWithError:%@", error );

    if(_completionBlock) {
        _completionBlock(0, nil, nil, error);
    }
    
    [sharedConnectionList removeObject:self];
}

/**
 * Override caching behaviour to prevent caching
 */
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSLog( @"- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse" );
    
    return nil;
}


/**
 * Handler redirects by accepting them as standard
 */
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    NSLog( @"- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse" );
    
    NSLog( @"Redirect to : %@ %@ ", request.HTTPMethod, request.URL);
    return request;
}
@end


