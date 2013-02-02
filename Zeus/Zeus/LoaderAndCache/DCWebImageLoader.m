//
//  DCWebImageLoader.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 13-1-22.
//  Copyright (c) 2013年 arcsoft. All rights reserved.
//

#import "DCWebImageLoader.h"

NSString * const NOTIFY_WEBIMAGELOADER_DOWNLOAD_DONE = @"NOTIFY_WEBIMAGELOADER_DOWNLOAD_DONE";
NSString * const NOTIFY_WEBIMAGELOADER_DOWNLOAD_ERROR = @"NOTIFY_WEBIMAGELOADER_DOWNLOAD_ERROR";

typedef enum {
    DCDownloadDataState_Empty = 0,
    DCDownloadDataState_Done,
} DCDownloadDataState;

@interface DCWebImageLoader () <NSURLConnectionDelegate> {
    NSURLConnection *_conn;
    NSConditionLock *_lock;
}

@end

@implementation DCWebImageLoader

@synthesize uid = _uid;
@synthesize url = _url;
@synthesize downloadData = _downloadData;

- (id)init {
    @synchronized(self) {
        self = [super init];
        if (self) {
            _lock = [[NSConditionLock alloc] initWithCondition:DCDownloadDataState_Empty];
        }
        return self;
    }
}

- (void)dealloc {
    do {
        @synchronized(self) {
            SAFE_ARC_SAFERELEASE(_conn);
            SAFE_ARC_SAFERELEASE(_lock);
            
            SAFE_ARC_SAFERELEASE(_downloadData);
            SAFE_ARC_SAFERELEASE(_url);
            SAFE_ARC_SAFERELEASE(_uid);
        }
        
        SAFE_ARC_SUPER_DEALLOC();
    } while (NO);
}

- (void)main {
    do {
        @synchronized(self) {
            if (self.revoke) {
                break;
            }
            
            if (!self.uid || !self.url) {
                break;
            }
            
            NSURLRequest *req=[NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            SAFE_ARC_SAFERELEASE(_conn);
            _conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
            [_conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [_conn start];
            if (_conn) {
                SAFE_ARC_SAFERELEASE(_downloadData);
                _downloadData = [NSMutableData data];
                SAFE_ARC_RETAIN(_downloadData);
            } else {
                [NSException raise:@"DCWebImageLoader error" format:@"_conn == nil"];
            }
            
            [_lock lockWhenCondition:DCDownloadDataState_Done];  //block now until we got data or canceld
            SAFE_ARC_SAFERELEASE(_conn);
            [_lock unlockWithCondition:DCDownloadDataState_Empty];
            
            if (_downloadData) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_WEBIMAGELOADER_DOWNLOAD_DONE object:self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_WEBIMAGELOADER_DOWNLOAD_ERROR object:self];
            }
        
        }
    } while (NO);
}

#pragma mark - DCWebImageLoader - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    do {
        @synchronized(self) {
            if (connection != _conn) {
                break;
            }
            
            if (_downloadData) {
                [_downloadData setLength:0];
            }
        }
    } while (NO);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    do {
        @synchronized(self) {
            if (connection != _conn || !data) {
                break;
            }
            
            if (_downloadData) {
                [_downloadData appendData:data];
            }
        }
    } while (NO);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    do {
        @synchronized(self) {
            if (connection != _conn) {
                break;
            }
            
            if ([_lock tryLockWhenCondition:DCDownloadDataState_Empty]) {
                SAFE_ARC_SAFERELEASE(_conn);
                SAFE_ARC_SAFERELEASE(_downloadData);
                [_lock unlockWithCondition:DCDownloadDataState_Done];
            }
        }
    } while (NO);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    do {
        @synchronized(self) {
            if (connection != _conn) {
                break;
            }
            
            if ([_lock tryLockWhenCondition:DCDownloadDataState_Empty]) {
                [_lock unlockWithCondition:DCDownloadDataState_Done];
            }
        }
    } while (NO);
}
@end
