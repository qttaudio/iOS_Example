//
//  NSBundle+Helper.m
//  AudioDemo
//
//  Created by apple on 2020/11/15.
//  Copyright © 2020 audio. All rights reserved.
//

#import "NSBundle+Helper.h"
#import <objc/runtime.h>

@implementation NSBundle (Helper)

+(void) startChange
{
    [NSBundle methodSwizzleWithOrigTarget:[NSBundle class] OrigSel:@selector(bundleIdentifier) newSel:@selector(demoBundleIdentifier)];
}
+(void) reSetChange
{
    [NSBundle methodSwizzleWithOrigTarget:[NSBundle class] OrigSel:@selector(bundleIdentifier) newSel:@selector(demoBundleIdentifier)];
}
-(NSString *) demoBundleIdentifier
{
    return @"qtt.io.agora.chatroom";
}

+(void) methodSwizzleWithOrigTarget:(Class)origTarget OrigSel:(SEL)origSel newSel:(SEL)newSel
{
    Class origClass = origTarget;
    if ([origTarget isKindOfClass:[origTarget class]]) {
        origClass = object_getClass(origTarget);
    }
    Method origMethod = class_getInstanceMethod(origClass, origSel);
    Method newMethod = class_getInstanceMethod(origClass, newSel);
    if (!origMethod) {
        class_addMethod(origClass, origSel, imp_implementationWithBlock(^(id self, SEL _cmd){}), "v16@0:8");
        origMethod = class_getInstanceMethod(origClass, origSel);
    }
    
    IMP origIMP = method_getImplementation(origMethod);
    IMP newIMP = method_getImplementation(newMethod);
    
    if(class_addMethod(origClass, origSel, origIMP, method_getTypeEncoding(origMethod))){
        class_replaceMethod(origClass, origSel, newIMP, method_getTypeEncoding(newMethod));
    }else{
        method_setImplementation(origMethod, newIMP);
        method_setImplementation(newMethod, origIMP);
    }
}
@end
