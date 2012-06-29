//
//  DCViewCache.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCViewCache.h"

@interface DCViewCache () {
    NSMutableDictionary *_tableViewRows;  // key:UIDForIndexPath; value:NSMutableArray *viewsInRow
    NSMutableDictionary *_views;  // key:UIDForView; value:view
}

- (NSString *)uidForView:(UIView *)view;

- (NSString *)uidForTableViewRows:(NSIndexPath *)indexPath;

@end

@implementation DCViewCache

- (void)addView:(UIView *)view withUID:(NSString *)uid inRow:(NSIndexPath *)indexPath {
    do {
        if (!view || !uid || [uid length] == 0 || [indexPath row] < 0) {
            break;
        }
        if (!_tableViewRows || !_views) {
            break;
        }
        
        NSString *uidForRow = [self uidForTableViewRows:indexPath];
        NSMutableArray *viewInRow = nil;
        viewInRow = [_tableViewRows objectForKey:uidForRow];
        if (!viewInRow) {
            viewInRow = [[[NSMutableArray alloc] init] autorelease];
            [_tableViewRows setObject:viewInRow forKey:uidForRow];
        }
        [viewInRow addObject:view];
        
        NSString *viewUID = [self uidForView:view];
        [_views setObject:view forKey:viewUID];
    } while (NO);
}

- (UIView *)getViewWithUID:(NSString *)uid {
    UIView *result = nil;
    do {
        if (_views) {
            result = [_views objectForKey:uid];
        }
    } while (NO);
    return result;
}

- (NSString *)uidForTableViewRows:(NSIndexPath *)indexPath {
    return [[[NSString alloc] initWithFormat:@"%d", [indexPath row]] autorelease];
}

- (NSString *)uidForView:(UIView *)view {
    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        if (!_views) {
            _views = [[NSMutableDictionary alloc] init];
        }
        
        if (!_tableViewRows) {
            _tableViewRows = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)dealloc {
    if (_tableViewRows) {
        [_tableViewRows removeAllObjects];
        [_tableViewRows release];
        _tableViewRows = nil;
    }
    
    if (_views) {
        [_views removeAllObjects];
        [_views release];
        _views = nil;
    }
    
    [super dealloc];
}

@end
