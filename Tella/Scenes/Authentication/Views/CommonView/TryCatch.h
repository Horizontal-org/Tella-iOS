//
//  TryCatch.h
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

#ifndef TryCatch_h
#define TryCatch_h


#endif /* TryCatch_h */
#import <Foundation/Foundation.h>

@interface TryCatch

+ (BOOL)tryBlock:(void(^)(void))tryBlock
           error:(NSError **)error;

@end

