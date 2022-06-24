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

@interface TryCatch : NSObject 

+ (BOOL)tryBlock:(void(^)(void))tryBlock
      catchBlock:(void(^)(NSException*exception))catchBlock;

@end

