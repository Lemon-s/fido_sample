//
//  ShoppingCart.m
//  testPro
//
//  Created by 张宁 on 16/7/13.
//  Copyright © 2016年 张宁. All rights reserved.
//

#import "ShoppingCart.h"
#import "TutorialAppException.h"
#import "gmrz_client_interface.h"
#import "TAUtils.h"
#import "HttpRequest.h"
@interface ShoppingCart ()

@property (weak, nonatomic) IBOutlet UILabel *priceNumber;


@property (weak, nonatomic) IBOutlet UILabel *priceSum;



@end

@implementation ShoppingCart


- (void)viewDidLoad {
    [super viewDidLoad];
    _priceNumber.text = self.Number;
    NSLog(@"%@",self.Number);
    
    _priceSum.text = [NSString stringWithFormat:@"$%d",[self.Number intValue] * 100];

    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)FIDOPay:(id)sender {
    
    [TAUtils showProgressDialog:self.view];
   
        
    NSString *connect = [[[NSUserDefaults standardUserDefaults] objectForKey:@"connectUrl"] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"API"]];
        
    NSString *url = [connect stringByAppendingString:@"/auth/receive"];
    
    
    //NSString * url = @"https://test31.noknoklabs.cn:8443/uaf/v1/auth/receive";
    NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* value = [[NSMutableDictionary alloc] init];
  
    //    //Construct the transaction text
    NSString * transtext = [NSString stringWithFormat:@"你需要支付 $%d元",[self.Number intValue] *100];
        


    //    // Need top do base64 encoding on transaction text
    NSData *nsdata = [transtext    dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
        //
    [value   setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@USER_NAME];
    [value   setObject:@"default"          forKey:@POLICY_NAME];
    [value setObject:base64Encoded forKey:@TRANSACTION_TEXT];
    [payload setObject:value forKey:@CONTEXT];
    

        [HttpRequest startRequestFrom:url AndParameter:payload andurlWay:POST andNSdata:nil returnData:^(NSDictionary *resultData, NSError *error) {
        
        
            if (!error) {
                
                NSInteger statusCode        = [[resultData objectForKey:@STATUS_CODE] integerValue];
                
                NSError *error;
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultData options:NSJSONWritingPrettyPrinted error:&error];
                
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                
                int equipmentStatus = [gmrz_client_interface checkFingerState];
                
                if (equipmentStatus == Normal) {
                    
                    
                }else if(equipmentStatus == Lock){
                    
                    [TAUtils displayMessage:@"Biometry is locked out." andShow:@"error"];
                    
                    
                }else if(equipmentStatus == NotFingerPrint){
                    
                    [TAUtils displayMessage:@"No fingers are enrolled with Touch ID." andShow:@"error"];
                    goto ENDUI;
                    
                }else if(equipmentStatus == NotSupport){
                    
                    [TAUtils displayMessage:@"equipment not support." andShow:@"error"];
                    goto ENDUI;
                }
                
                
                
                if (statusCode == 1200) {
                    
                    [gmrz_client_interface process:jsonString DoFido:gmrz_checkpolicy Methods:gmrz_keychain ResultData:^(NSString *FidoOut, FidoStatus status) {
                        
                        if (status == 0) {
                            
                            
                            [gmrz_client_interface process:jsonString DoFido:gmrz_authtication Methods:gmrz_default ResultData:^(NSString *FidoOut, FidoStatus status) {
                                
                                if (status == 0) {
                                    
                                    NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
                                    [payload setObject:FidoOut forKey:@"uafResponse"];
                                    
                                    
                                    NSString *urlsend = [url stringByReplacingOccurrencesOfString:@"receive" withString:@"send"];
                                    
                                    
                                    [HttpRequest startRequestFrom:urlsend AndParameter:payload andurlWay:POST andNSdata:nil returnData:^(NSDictionary *resultData, NSError *error) {
                                        
                                        
                                        
                                        if (!error) {
                                            NSNumber *status = resultData[@"statusCode"];
                                            NSString *statusMsg = resultData[@"description"];
                                            if ([status isEqual:@1200]) {
                                                [TAUtils displayMessage:@"running success" andShow:@"testak"];
                                            }else{
                                                [TAUtils displayMessage:statusMsg andShow:@"testak"];
                                            }
                                            
                                        }else{
                                            
                                            [TAUtils displayMessage:@"connect error" andShow:@"error"];
                                        }
                                        
                                        
                                        
                                    }];
                                    
                                    
                                    
                                } else if(status == 1)
                                {
                                    [TAUtils displayMessage:@"running failed" andShow:@"testak"];
                                }
                                else if(status == 2)
                                {
                                    [TAUtils displayMessage:@"usercanal" andShow:@"testak"];
                                }
                                else if(status == 3)
                                {
                                    [TAUtils displayMessage:@" have no avaliable authticator" andShow:@"testak"];
                                }
                                else if(status == 10)
                                {
                                    
                                    [TAUtils displayMessage:@"PROTOCOL ERROR" andShow:@"testak"];
                                }
                                else if(status == 11)
                                {
                                    [TAUtils displayMessage:@"policy can not understand" andShow:@"testak"];
                                }
                                
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [TAUtils dismissProgressDialog];
                                });
                                
                                
                                
                            }];

                            
                            
                            
                        }else if (status == 3){
                            
                            [TAUtils displayMessage:@"没有可用认证器！" andShow:@"testak"];

                            
                        }
                        else if (status == 11){
                            
                            [TAUtils displayMessage:@"no entry finger" andShow:@"testak"];
                            
                        }else{
                            
                            [TAUtils displayMessage:@"policy failed" andShow:@"testak"];
                        }

                    
                    }];

                    
                    
                    
                    
                }
                
                
                
            }else{
                
                NSLog(@"%@",[error localizedDescription]);
                [TAUtils displayMessage:[error localizedDescription] andShow:@"error"];
            }
            
            
            
            
ENDUI:
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [TAUtils dismissProgressDialog];
                
            });
            
            
        }];


    
    
    
                
        
}


- (IBAction)passWordPay:(id)sender {
    equipmentState status = [gmrz_client_interface checkFingerState];
    NSLog(@"%ld",(long)status);
    
    
//    UIAlertController * con = [UIAlertController alertControllerWithTitle:@"testak" message:@"请输入支付密码" preferredStyle:UIAlertControllerStyleAlert];
//    [con addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//        UITextField *tf =  con.textFields.firstObject;
//        [tf resignFirstResponder];
//        NSLog(@"%@",tf.text);
//        if ([tf.text isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"password"]]&&tf.text.length!=0) {
//            [TAUtils displayMessage:@"Pay for success." andShow:@"testak"];
//        }else{
//            [TAUtils displayMessage:@"Pay for failure , Please check the payment password" andShow:@"testak"];
//
//        }
//        //按钮触发的方法
//    }]];
//    [con addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        
//        [TAUtils displayMessage:@"cancel trading." andShow:@"testak"];
//        //按钮触发的方法
//    }]];
//    [con addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        
//        textField.textAlignment = NSTextAlignmentCenter;
//        
//    }];
//    [self presentViewController:con animated:YES completion:nil];
//    
//    
    
    
}





@end
