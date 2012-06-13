//
//  DCDataModelOperation.m
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DCDataModelOperation.h"

@implementation DCDataModelOperation

- (id)initWithConetet:(NSManagedObjectContext *)context model:(NSManagedObjectModel *)model andArgs:(NSMutableDictionary *)arg {
    self = [super init];
    if (self) {
        [context retain];
        [_context release];
        _context = context;
        
        [model retain];
        [_model release];
        _model = model;
        
        [arg retain];
        [_arg release];
        _arg = arg;
    }
    return self;
}

- (void)dealloc {
    if (_context) {
        [_context release];
        _context = nil;
    }
    
    if (_model) {
        [_model release];
        _model = nil;
    }
    
    [super dealloc];
}

@end
