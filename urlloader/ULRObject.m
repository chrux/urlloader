//
//  URLConnection.m
//  urlloader
//
//  Created by Christian Torres on 6/12/11.
//  Copyright 2011 clov3r.net. All rights reserved.
//

#import "URLObject.h"


@implementation URLObject

@synthesize url;
@synthesize agent;
@synthesize delegate;
@synthesize synchronously;

- (id)init
{
    self = [super init];
    if (self) {
        
        // Initialization code here.
        
    }
    
    return self;
}

- (void)dealloc
{
    agent = nil;
    url = nil;
    cnx = nil;
    asyncData = nil;
    delegate = nil;
    [super dealloc];
}

- (id)initWithString:(NSString *)URLString andAgent:(NSString *)agent
{
    
    [self setUrlByString:URLString];
    
    return self;
    
}

// Set URL to parse and removing feed: uri scheme info
// http://en.wikipedia.org/wiki/Feed:_URI_scheme

- (void)setUrlByString:(NSString *)URLString {

	NSURL *value = [NSURL URLWithString:URLString];
    
    // Validar si la URL no es valida
  	//NSLog(@"%@ %@",URLString, [value host]);
	
	// Create new instance of NSURL and check URL scheme
	NSURL *newURL = nil;
    
	if (value) {
        
		if ( [value.scheme isEqualToString:@"feed"] ) {
			
			// Remove feed URL scheme
			newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ([value.resourceSpecifier hasPrefix:@"//"] ? @"http:" : @""), value.resourceSpecifier]];
			
		} else {
			
			// Copy
			newURL = [[value copy] autorelease];
			
		}
        
	}
	
	// Set new url
	if (url) [url release];
	url = [newURL retain];
	
}

- (id)load
{

    // Request
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData 
                                                            timeoutInterval:60];
    
    if ( agent )
        [request setValue:agent forHTTPHeaderField:@"User-Agent"];

    // Async  
   	if ( !synchronously ) {
        cnx = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if ( url ) {
            _Log(@"Loading Data From %@", url);
            asyncData = [[NSMutableData alloc] init];// Create data
        }
    // Sync
    } else {
        NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		if ( data && !error ) {
            asyncData = [[NSMutableData alloc] init];
            [asyncData setLength:0];
            [asyncData appendData:data];
            [request release];
			return asyncData; // Process
		} else {
            NSLog(@"Error %@ %@",[error localizedDescription], url);
		}
    }
    
    [request release];
    return nil;
    
}

#pragma mark NSURLConnection Delegate (Async)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _Log(@"didReceiveResponse");
	[asyncData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    _Log(@"didReceiveData");
	[asyncData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	// Failed
	url = nil;
	asyncData = nil;
	
    // Error
    // inform the user
    _Log(@"didFailWithError - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
    // Succeed
	_Log(@"URLLoader: connectionDidFinishLoading successful... received %d bytes of data", [asyncData length]);
    
    if ( delegate && [delegate respondsToSelector:@selector(processDownloadedObject:)] ) {
        [delegate processDownloadedObject:asyncData];
    }
    
    // Cleanup
    url = nil;
    asyncData = nil;
    
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
   	_Log(@"URLLoader: willCacheResponse");
	return nil; // Don't cache
}

#pragma mark -

@end
