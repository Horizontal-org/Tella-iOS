//
//  TryCatch.m
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TryCatch.h"

@implementation TryCatch

+ (BOOL)tryBlock:(void(^)(void))tryBlock
      catchBlock:(void(^)(NSException*exception))catchBlock {
    @try {
        tryBlock ? tryBlock() : nil;
    }
    @catch (NSException *exception) {
        catchBlock ? catchBlock(exception) : nil;
        return NO;
    }
    return YES;
}
@end
