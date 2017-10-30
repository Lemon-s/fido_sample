//
//  registerController.m
//  testPro
//
//  Created by 张宁 on 16/7/8.
//  Copyright © 2016年 张宁. All rights reserved.
//

#import "registerController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "installViewController.h"
#import "PlistTools.h"
#import "TutorialAppException.h"
#import "gmrz_client_interface.h"
#import "TAUtils.h"
#import "HttpRequest.h"

#define SIZE [UIScreen mainScreen].bounds.size
@interface registerController () {
    UITextField * username;
    UITextField * password;
}


@end

@implementation registerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"登录";
    UIBarButtonItem * Navbutton = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(NavButtonClick)];
    self.navigationItem.rightBarButtonItem = Navbutton;
    
    
    [self greateUI];
    
    
    
    
}





- (void)greateUI {
    NSArray *plahold = @[@"用户名",@"密码"];
    username = [[UITextField alloc]initWithFrame:CGRectMake(0,SIZE.height/4, SIZE.width, 40)];
    password = [[UITextField alloc]initWithFrame:CGRectMake(0,SIZE.height/4+50, SIZE.width, 40)];
    NSArray *user = @[username,password];
    
    
    for (int i =0; i < plahold.count; i++) {
        UITextField *tf = user[i];
        tf.placeholder= [NSString stringWithFormat:@"  %@",plahold[i]];
        tf.keyboardType = UIKeyboardTypeDefault;
        tf.backgroundColor = [UIColor lightGrayColor];
        tf.layer.cornerRadius = 10;
        if(i==1){
            tf.secureTextEntry = YES;
            
        }
        if (i==0) {
            tf.autocorrectionType = UITextAutocorrectionTypeNo;
        }
        [self.view addSubview:tf];
        
        
        
    }
    
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(70, SIZE.height/4+120 , SIZE.width-140, 40)];
    [button setTitle:@"登录" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor orangeColor];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 1001;
    button.layer.cornerRadius = 20;
    [self.view addSubview:button];
    
    
    
    UIButton * Fidobutton = [[UIButton alloc]initWithFrame:CGRectMake(70, SIZE.height/4+100 + 80, SIZE.width - 140, 40)];
    [Fidobutton setTitle:@"Log In with FIDO" forState:UIControlStateNormal];
    [Fidobutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [Fidobutton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    Fidobutton.backgroundColor = [UIColor greenColor];
    Fidobutton.tag = 1000;
    Fidobutton.layer.cornerRadius = 20;
    [Fidobutton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Fidobutton];
    UIImage * image = [UIImage imageNamed:@"fido_alliance"];
    float scale =  image.size.width/image.size.height;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, SIZE.height - SIZE.width/scale - 80, SIZE.width, SIZE.width/scale)];
    imageView.image = image;
    [self.view addSubview:imageView];
    
    
    
    
}



- (void)buttonClick:(UIButton *)button {
    switch (button.tag) {
        case 1000:
        {
            [username resignFirstResponder];
            [password resignFirstResponder];
            
            
            
            [TAUtils showProgressDialog:self.view];
            
            NSString *connect = [[[NSUserDefaults standardUserDefaults] objectForKey:@"connectUrl"] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"API"]];
            
            NSString *url = [connect stringByAppendingString:@"/auth/receive"];
            
            NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
            NSMutableDictionary* value = [[NSMutableDictionary alloc] init];
            [value   setObject:@"default"          forKey:@POLICY_NAME];
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
                        
                        [gmrz_client_interface process:jsonString DoFido:gmrz_authtication Methods:gmrz_default ResultData:^(NSString *FidoOut, FidoStatus status) {
                            
                            if (status == 0) {
                                
                                NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
                                [payload setObject:FidoOut forKey:@"uafResponse"];
                                

                                NSString *urlsend = [url stringByReplacingOccurrencesOfString:@"receive" withString:@"send"];
                                
                                
                                [HttpRequest startRequestFrom:urlsend AndParameter:payload andurlWay:POST andNSdata:nil returnData:^(NSDictionary *resultData, NSError *error) {
                                
                                
                                    if (!error) {
                                        
                                        NSLog(@"%@",resultData);
                                        
                                        NSString *userName = resultData[@"description"][@"authenticatorsSucceeded"][0][@"userName"];
                                        [[NSUserDefaults standardUserDefaults]setValue:userName forKey:@"username"];
                                        NSNumber * statusCode = resultData[@"statusCode"];
                                        
                                        if ([statusCode  isEqual: @1200]) {
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [self changeMainView];
                                                
                                            });
                                            
                                        }else{
                                            
                                            
                                            [TAUtils displayMessage:@"Authentication failed." andShow:@"error"];
                                            
                                        }

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
            
            break;
        case 1001:
        {
            
            NSString * usernames = [username.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            
            if (![usernames isEqualToString:@""] ) {
                
                [[NSUserDefaults standardUserDefaults]setValue:username.text forKey:@"username"];
                
                //[[NSUserDefaults standardUserDefaults]setValue:password.text forKey:@"password"];
                
                
                
                [self changeMainView];
                
            }else{
                [TAUtils displayMessage:@"Please check the user name and password." andShow:@"warning"];
            }
            
            
            
            
            
        }
            
            
            
            break;
            
        default:
            break;
    }
    
    
    
    
}

- (void)changeMainView {
    
    UIApplication * app = [UIApplication sharedApplication];
    AppDelegate * app2 = app.delegate;
    MainViewController * mainbar = [[MainViewController alloc]init];
    mainbar.labelName = username.text;
    app2.window.rootViewController = mainbar;
    
    [[NSUserDefaults standardUserDefaults]setValue:@"on" forKey:@"online"];
}


- (void)NavButtonClick {
    
    installViewController *install = [[installViewController alloc]init];
    [self.navigationController pushViewController:install animated:YES];
    
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
    [username resignFirstResponder];
    [password resignFirstResponder];
}








@end
