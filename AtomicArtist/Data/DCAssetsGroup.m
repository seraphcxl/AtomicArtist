//
//  DCAssetsGroup.m
//  AtomicArtist
//
//  Created by Chen XiaoLiang on 12-5-17.
//  Copyright (c) 2012年 seraphCXL. All rights reserved.
//

#import "DCAssetsGroup.h"

@interface DCAssetsGroup () {
    NSMutableArray *_allAssetURLs;
    NSMutableDictionary *_allAssets; // Key:(NSSString *)assetURLStr Value:(ALAsset *)asset
}

@end

@implementation DCAssetsGroup

@synthesize assetsGroup = _assetsGroup;

- (NSUInteger)getIndexForAssetURL:(NSURL *)assetURL {
    if (assetURL) {
        NSUInteger index = 0;
        NSUInteger count = [_allAssetURLs count];
        BOOL find = NO;
        
        do {
            if ([[_allAssetURLs objectAtIndex:index] absoluteString] == assetURL.absoluteString) {
                find = YES;
                break;
            } else {
                ++index;
            }
        } while (index < count);
        
        if (find) {
            return index;
        } else {
            [NSException raise:@"DCAssetsGroup Error" format:@"Reason: assetURL: %@ not find", assetURL.absoluteString];
            return 0;
        }
    } else {
        [NSException raise:@"DCAssetsGroup Error" format:@"Reason: assetURL is nil"];
        return 0;
    }
}

- (NSURL *)getAssetURLAtIndex:(NSUInteger)index {
    if (_allAssetURLs) {
        if (index < [_allAssetURLs count]) {
            return [_allAssetURLs objectAtIndex:index];
        } else {
            [NSException raise:@"DCAssetsGroup Error" format:@"Reason: Index: %d >= allAssetURLs count: %d", index, [_allAssetURLs count]];
            return nil;
        }
    } else {
        [NSException raise:@"DCAssetsGroup Error" format:@"Reason: allAssetURLStrs is nil"];
        return nil;
    }
}

- (NSUInteger)assetCount {
    if (_allAssets) {
        return [_allAssets count];
    } else {
        return 0;
    }
}

- (BOOL)enumerateAssets {
    BOOL successful = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (self.assetsGroup) {
        if (_allAssets) {
            
            if (_allAssets) {
                [_allAssets removeAllObjects];
            }
            
            void (^ALAssetsGroupEnumerationResultsBlock)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        ALAssetRepresentation *representation = [result defaultRepresentation];
                        NSURL *url = [representation url];
                        NSString *assetURLStr = [url absoluteString];
                        [_allAssets setObject:result forKey:assetURLStr];
//                        [allAssetURLs addObject:url];
                        [_allAssetURLs insertObject:url atIndex:index];
                        NSNotification *note = [NSNotification notificationWithName:@"ALAssetAdded" object:self];
                        [[NSNotificationCenter defaultCenter] postNotification:note];
                    } else {
                        NSLog(@"Result not photo");
                    }
                }
            };
            
            [self.assetsGroup enumerateAssetsUsingBlock:ALAssetsGroupEnumerationResultsBlock];
            
            successful = YES;
        } else {
            [NSException raise:@"DCAssetsGroup Error" format:@"Reason: allAssets is nil"];
        }
    } else {
        [NSException raise:@"DCAssetsGroup Error" format:@"Reason: self.assetsGroup is nil"];
    }
    
    [pool drain];
    return successful;
}

- (id)init {
    self = [super init];
    
    _allAssets = [[NSMutableDictionary alloc] init];
    
    _allAssetURLs = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc {
    self.assetsGroup = nil;
    
    [self cleaeCache];
    
    if (_allAssetURLs) {
        [_allAssetURLs release];
        _allAssetURLs = nil;
    }
    
    if (_allAssets) {
        [_allAssets release];
        _allAssets = nil;
    }
    
    [super dealloc];
}

- (void)cleaeCache {
    if (_allAssetURLs) {
        [_allAssetURLs removeAllObjects];
    }
    
    if (_allAssets) {
        [_allAssets removeAllObjects];
    }
}

- (NSArray *)allAssets {
    return [_allAssets allValues];
}

- (ALAsset *)getALAssetForAssetURL:(NSURL *)assetURL {
    ALAsset *result = nil;
    
    if (_allAssets) {
        NSString *assetKey = [assetURL absoluteString];
        result = [_allAssets objectForKey:assetKey];
    }
    
    return result;
}

@end
