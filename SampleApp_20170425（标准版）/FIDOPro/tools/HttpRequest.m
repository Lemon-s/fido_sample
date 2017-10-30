//
//  HttpRequest.m
//  FaceRecon
//
//  Created by 张宁 on 16/8/24.
//  Copyright © 2016年 lenovo. All rights reserved.
//

#import "HttpRequest.h"
@implementation HttpRequest

static AFHTTPSessionManager *manager;

+(AFHTTPSessionManager *)sharedHttpSessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10.0f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
        // 如果是需要验证自建证书，需要设置为YES
        securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy = securityPolicy;
    });
    
    return manager;
}


+ (void)startRequestFrom :(NSString*)Url AndParameter:(NSDictionary*)parameter andurlWay:(urlWay)urlWay andNSdata:(NSData *)data returnData:(ResultDataString)returnBlock; {
    
    [self sharedHttpSessionManager];
    
    switch (urlWay) {
        case 0:
        {
            
            [manager GET:Url parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                returnBlock(responseObject,nil);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                returnBlock(nil,error);
            }];
            
            
        }
            break;
            
        case 1:
        {
            
            [manager POST:Url parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

                
                returnBlock((NSDictionary *)responseObject,nil);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                returnBlock(nil,error);
            }];

        }
            break;
            
        case 2:
        {
            
            NSData *imageData = [data valueForKeyPath:@"image"];
            [manager POST:Url parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFormData:imageData name:@"imageData"];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                returnBlock(responseObject,nil);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                returnBlock(nil,error);
            }];
            
        }
            break;
            
        default:
            break;
    }
}






@end


@implementation AuthnrRegInfo

@synthesize descr;
@synthesize aaid;
@synthesize userName;
@synthesize regID;




@end

