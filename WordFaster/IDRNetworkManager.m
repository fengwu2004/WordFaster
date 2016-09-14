//
//  IDRNetworkManager.m
//  YFMapKit
//
//  Created by ky on 16/4/21.
//  Copyright © 2016年 yellfun. All rights reserved.
//

#import "IDRNetworkManager.h"

@interface IDRNetworkManager()

@property (nonatomic, retain) NSOperationQueue *queue;

@end

@implementation IDRNetworkManager

static IDRNetworkManager *_instance = nil;

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _instance = [[super allocWithZone:NULL] init];
    });
    
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    
    return [self sharedInstance];
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _queue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (void)asyncServerCall:(NSString *)urlString parameters:(NSData*)parameters {
    
    [self asyncServerCall:urlString parameters:parameters success:nil];
}

- (void)asyncServerCall:(NSString *)urlString parameters:(NSData *)parameters
                success:(void (^)(NSDictionary *responseData))success {
    
    [self asyncServerCall:urlString parameters:parameters success:success failure:nil];
}

- (void)asyncServerCall:(NSString *)urlString parameters:(NSData *)parameters
                success:(void (^)(NSDictionary *responseData))success
                failure:(void (^)(NSDictionary *responseData))failure {
    
    if (!urlString) {
        
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];

    if (parameters) {
        
        [request setHTTPBody:parameters];
        
        [request setHTTPMethod:@"POST"];
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:_queue
       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       
       if (!data) {
           
           if (failure) {
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                   failure(nil);
               });
           }
           
           return;
       }
           
       NSDictionary *responseJSONData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
           
       NSInteger errorCode = [responseJSONData[@"errorCode"] integerValue];
           
       BOOL isSuccess = errorCode == 0;
       
       if (isSuccess) {
           
           if (success) {
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                   success(responseJSONData);
               });
           }
       }
       else {
           
           if (failure) {
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                   failure(responseJSONData);
               });
           }
       }
    }];
}

@end
