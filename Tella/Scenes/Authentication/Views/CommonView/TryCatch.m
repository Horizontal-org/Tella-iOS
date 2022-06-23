//
//  TryCatch.m
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

#import <Foundation/Foundation.h>


@implementation TryCatch : NSObject

+ (BOOL)tryBlock:(void(^)(void))tryBlock
           error:(NSError **)error
{
    @try {
        tryBlock ? tryBlock() : nil;
    }
    @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:@"com.something"
                                         code:42
                                     userInfo:@{NSLocalizedDescriptionKey: exception.name}];
        }
        return NO;
    }
    return YES;
}

@end
