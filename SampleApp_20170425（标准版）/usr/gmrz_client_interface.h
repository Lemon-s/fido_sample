//
//  gmrz_client_interface.h
//  TestAkcmd
//
//  Created by Lyndon on 16/7/5.
//  Copyright © 2016年 lenovo. All rights reserved.
//

#import <Foundation/Foundation.h>


//此枚举为选择注册，交易，解注册，检测是否可以进行注册/认证
typedef  NS_ENUM (NSInteger,op){
    gmrz_register = 0,//注册
    gmrz_authtication,//认证
    gmrz_deregister,//解注册
    gmrz_checkpolicy,//检测是否可以进行注册/认证
    
};

//此枚举为选择弹出local UI认证界面（仅适用于认证操作，其他操作请选择gmrz_default）
//认证操作gmrz_default为keyChain
typedef  NS_ENUM (NSInteger,methods) {
    gmrz_default = 0,
    gmrz_keychain,
    gmrz_local,
};


/**
 设备状态
 */
typedef  NS_ENUM (NSInteger,equipmentState) {
    //NOFINGERPRINT
    Normal = 0,
    Lock,//设备锁死
    NotFingerPrint, //没有指纹
    NotSupport,//设备不支持
    PassCodeNotSet//设备没有设置密码
    
};

/**
   Fido SDK返回状态码

 - SUCCESS: 操作执行成功
 - FAILURE: 操作因为某些不规范的原因失败
 - CANCELED: 操作被用户取消
 - NO_MATCH: 没有可用认证器
 - NOT_INSTALLED: MFAC 没有安装
 - NOT_COMPATIBLE: MFAC 不兼容
 - APP_NOT_FOUND: Facet 文件中没有该应用 id
 - TRANSACTION_ERROR: 交易文本没有被执行(暂时不用，属于扩展)
 - WAIT_USER_ACTION: 等待用户执行操作(暂时不用，属于 扩展)
 - INSECURE_TRANSPORT: 暂时未用
 - PROTOCOL_ERROR: 一个违反 UAF 协议的操作
 - TOUIDINVALID: 手机上没有注册指纹
 - CRT_NOT_LEGAL:服务器证书不合法
 */
typedef NS_ENUM(NSInteger,FidoStatus) {

        SUCCESS = 0,
        FAILURE,
        CANCELED,
        NO_MATCH,
        NOT_INSTALLED,
        NOT_COMPATIBLE,
        APP_NOT_FOUND,
        TRANSACTION_ERROR,
        WAIT_USER_ACTION,
        INSECURE_TRANSPORT,
        PROTOCOL_ERROR,
        TOUIDINVALID,
        CRT_NOT_LEGAL
    
};


typedef void(^ResultData)(NSString* FidoOut,FidoStatus status);

typedef NSString* Fido_Version;

/**
 对FeactID校验
 @param GMRZ_FeactID_Validation = YES,开启校验
 @param GMRZ_FeactID_Validation = NO 不进行校验
 */
static const BOOL GMRZ_FeactID_Validation = NO;


@interface gmrz_client_interface:NSObject


/**
 调取指纹注册，认证，解注册，检查是否可以注册/认证Api

 @param FidoIn 传入参数
 @param DoFido 功能参数
 @param Method 认证方式选择
 @param ResultData 返回的Block回调函数
 */
+(void)process:(NSString *)FidoIn DoFido:(op)DoFido Methods:(methods)Method ResultData:(ResultData)ResultData;

/**
 检测设备当前指纹状态

 @return 返回为此时设备状态
 */
+(equipmentState)checkFingerState;

/**
 SDK版本查询

 @return 返回此SDK版本号
 */
+(Fido_Version)getSDKVersion;



@end
