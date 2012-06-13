//
//  DCDataModelOperation.h
//  Perfect365HD
//
//  Created by Chen XiaoLiang on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDataModelOperation : NSOperation {
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
    NSMutableDictionary *_arg;
}

- (id)initWithConetet:(NSManagedObjectContext *)context model:(NSManagedObjectModel *)model andArgs:(NSMutableDictionary *)arg;

@end
