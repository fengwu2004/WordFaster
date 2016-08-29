//
//  IDRNetworkManager.h
//  YFMapKit
//
//  Created by ky on 16/4/21.
//  Copyright © 2016年 yellfun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDRNetworkManager : NSObject

+ (instancetype)sharedInstance;

- (void)asyncServerCall:(NSString *)urlString parameters:(NSData *)parameters
                success:(void (^)(NSDictionary *))success;

- (void)asyncServerCall:(NSString *)urlString parameters:(NSData *)parameters;

- (void)asyncServerCall:(NSString *)urlString timeout:(NSInteger)timeoutInterval parameters:(NSData *)parameters
                success:(void (^)(NSDictionary *responseData))success
                failure:(void (^)(NSDictionary *responseData))failure;
@end
