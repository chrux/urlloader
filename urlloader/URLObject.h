//
//  URLConnection.h
//  urlloader
//
//  Created by Christian Torres on 6/12/11.
//  Copyright 2011 clov3r.net. All rights reserved.
//

#import <Foundation/Foundation.h>
// Logging
#import "Log.h"

// Delegate
@protocol URLObjectDelegate <NSObject>
@optional
- (void)processDownloadedObject:(NSData *)data;
@end

@interface URLObject : NSObject {
@private
    NSString *agent;
    NSURL *url;
    NSURLConnection *cnx;
    NSMutableData *asyncData;
    id <URLObjectDelegate> delegate;
    BOOL synchronously;
    
}

@property (nonatomic, retain) NSString *agent;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) id <URLObjectDelegate> delegate;

// Set whether to download asynchronously or synchronously
@property (nonatomic) BOOL synchronously;


- (id)initWithString:(NSString *)URLString andAgent:(NSString *)agent;

- (void)setUrlByString:(NSString *)value;

- (id)load;

@end
