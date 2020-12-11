//
//  DataManage.h
//
//  Created by junjie on 14-3-19.
//  Copyright (c) 2014年 createview junjie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManage : NSObject

+(void) saveDataForObject:(id)value AndKey:(NSString *)key;

+(id) getObjectFromKey:(NSString *)key;


@end
