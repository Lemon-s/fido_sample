//
//  HttpRequest.h
//  FaceRecon
//
//  Created by 张宁 on 16/8/24.
//  Copyright © 2016年 lenovo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define STATUS_CODE "statusCode"
#define POLICY_NAME "policyName"
#define CONTEXT     "context"
#define USER_NAME   "userName"
#define UAF_REQUEST "uafRequest"
#define TRANSACTION_TEXT       "transactionText"

@interface AuthnrRegInfo : NSObject

@property NSString* descr;
@property NSString* aaid;
@property NSString* userName;
@property NSObject* regID;

@end

@interface HttpRequest : NSObject

typedef void(^ResultDataString)(NSDictionary * resultData,NSError * error);

typedef NS_ENUM(NSInteger,urlWay) {
    GET = 0,
    POST,
    UpLoad,
};



/**
 请求方法

 @param Url 链接地址
 @param parameter 参数
 @param urlWay 方式
 @param data 数据
 @param returnBlock 回调方法
 */
+ (void)startRequestFrom :(NSString*)Url AndParameter:(NSDictionary*)parameter andurlWay:(urlWay)urlWay andNSdata:(NSData *)data returnData:(ResultDataString)returnBlock;



@end
