//
//  validateViewController.m
//  testPro
//
//  Created by 张宁 on 16/7/13.
//  Copyright © 2016年 张宁. All rights reserved.
//

#import "validateViewController.h"
#import "TutorialAppException.h"
#import "gmrz_client_interface.h"
#import "TAUtils.h"
#import "HttpRequest.h"

@interface validateViewController ()
@property (weak, nonatomic) IBOutlet UILabel *username;
@end

@implementation validateViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
    // Do any additional setup after loading the view from its nib.
    
    _username.text = [NSString stringWithFormat:@"%@,%@",@"Welcome",self.user];
    
}


- (IBAction)usersetting:(id)sender {
    
    
    [TAUtils showProgressDialog:self.view];
    
        
        
        NSString *connect = [[[NSUserDefaults standardUserDefaults] objectForKey:@"connectUrl"] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"API"]];
        
//        NSLog(@"%@",connect);
        NSString *url = [connect stringByAppendingString:@"/reg/receive"];
        
        
        
        
        NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* value = [[NSMutableDictionary alloc] init];
        
        [value   setObject:self.user forKey:@USER_NAME];
        [value   setObject:@"default"          forKey:@POLICY_NAME];
        [payload setObject:value               forKey:@CONTEXT];
    
    
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
                
                [gmrz_client_interface process:jsonString DoFido:gmrz_register Methods:gmrz_default ResultData:^(NSString *FidoOut, FidoStatus status) {
                    
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
                
                
                
            }
            
            
            
        }else{
            
            [TAUtils displayMessage:@"connect error" andShow:@"error"];
        }
        
        
        
        
    ENDUI:
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [TAUtils dismissProgressDialog];
            
        });
        
        
    }];


    
    
    
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
