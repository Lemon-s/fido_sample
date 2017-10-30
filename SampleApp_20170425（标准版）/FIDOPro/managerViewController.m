//
//  managerViewController.m
//  testPro
//
//  Created by 张宁 on 16/7/13.
//  Copyright © 2016年 张宁. All rights reserved.
//

#import "managerViewController.h"
#import "TutorialAppException.h"
#import "gmrz_client_interface.h"
#import "TAUtils.h"
#import "HttpRequest.h"

@interface managerViewController ()
@property (nonatomic, strong)NSString *str;

@end

@implementation managerViewController{
    NSMutableArray* mAuthList;
}
@synthesize mbGetList;
@synthesize mRegistrationsTable;
@synthesize mAuthList;


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (mbGetList== false) {
        
        [mAuthList removeAllObjects];
        
        [self reloadData];
        
    }
    
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    mAuthList = [[NSMutableArray alloc]init];
    
    
    
}
- (void)reloadData {
    
    
    [mAuthList removeAllObjects];
    
    [mRegistrationsTable reloadData];
    
    mRegistrationsTable.delegate   = self;
    mRegistrationsTable.dataSource = self;
    
    
        NSString *connect = [[[NSUserDefaults standardUserDefaults] objectForKey:@"connectUrl"] stringByAppendingString:[[NSUserDefaults standardUserDefaults]objectForKey:@"API"]];
        
        NSString *url = [connect stringByAppendingString:@"/reg/list"];
        
        _urlCont = url;
        //NSString* url =@"https://test.noknoklabs.cn:8443/uaf/v1/reg/list";
        
        NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* value = [[NSMutableDictionary alloc] init];
        
        [value   setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@USER_NAME];
        [value   setObject:@"default"          forKey:@POLICY_NAME];
        [payload setObject:value               forKey:@CONTEXT];
        
        
        
        
        
               // [gHttpConnection setUserID:userName];
        // send and read response from server
        
        // Send request to the server and get response

        [HttpRequest startRequestFrom:url AndParameter:payload andurlWay:POST andNSdata:nil returnData:^(NSDictionary *resultData, NSError *error) {
        
            if (!error) {
                
                NSMutableDictionary* uafRequestDescription = [[NSMutableDictionary alloc] init];
                NSMutableDictionary* authenticators = [[NSMutableDictionary alloc] init];
                
                if(nil != resultData && nil == error){
                    uafRequestDescription = [resultData objectForKey:@"description"];
                    NSInteger statusCode        = [[resultData objectForKey:@STATUS_CODE] integerValue];

                    
                    if (1200 == statusCode)
                    {
                        authenticators = [uafRequestDescription objectForKey:@"authenticators"];
                        
                        // Populate an array with AuthnrRegInfo objects.
                        for (NSDictionary* auth in authenticators)
                        {
                            AuthnrRegInfo* info = [[AuthnrRegInfo alloc] init];
                            info.userName = [auth objectForKey:@USER_NAME];
                            info.descr = [auth objectForKey:@"description"];
                            info.aaid = [auth objectForKey:@"aaid"];
                            
                            NSString* keyID = [auth objectForKey:@"keyID"];
                            
                            NSMutableDictionary* regID = [[NSMutableDictionary alloc] init];
                            [regID setValue:info.aaid forKey:@"aaid"];
                            [regID setValue:keyID forKey:@"keyID"];
                            
                            // regID value must be passed back to performDeregistration as argument.
                            info.regID = regID;
                            
                            NSLog(@"AuthnrRegInfo: aaid=%@ descr=%@ userName=%@ regID=%@", info.aaid, info.descr, info.userName, info.regID);
                            
                            [mAuthList addObject:info];
                            
                            
                            if (!mAuthList)
                            {
                                
                                return;
                            }
                            
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.mRegistrationsTable reloadData];
                                mbGetList = false;
                            });
                            
                            
                            
                            
                        }
                        
                    }
                    
                }            
                
            }else{
                
                
            }
           
        
        
        }];
        
        
        // Parse and create responseAuthList from server response
        
        
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)deregister:(id)sender
{
    
    
    if (mAuthList.count <= 0) {
        
        [TAUtils displayMessage:@"No entry information" andShow:@"testak"];
        return;
        
    }
    
    
    NSUInteger elementIndex = 0;
    NSIndexPath *selectedIndexPath = [mRegistrationsTable indexPathForSelectedRow];
    if (selectedIndexPath)
    {
        elementIndex = selectedIndexPath.row;
    }else {
        
        [TAUtils displayMessage:@"No Selected." andShow:@"warning"];
        return;
    }
    
    if (mAuthList.count != 0) {
        
                AuthnrRegInfo* info = [mAuthList objectAtIndex:elementIndex];
                NSString *url = [_urlCont stringByReplacingOccurrencesOfString:@"list" withString:@"delete"];
                
                //NSString* url = @"https://test.noknoklabs.cn:8443/uaf/v1/reg/delete";
                NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
                NSDictionary* value   = (NSDictionary*)info.regID;
                
                [payload setObject:value forKey:@CONTEXT];
                

                [HttpRequest startRequestFrom:url AndParameter:payload andurlWay:POST andNSdata:nil returnData:^(NSDictionary *resultData, NSError *error) {
                    
                    if (!error) {
                    
                            NSInteger statusCode        = [[resultData objectForKey:@STATUS_CODE] integerValue];
                            
                            if( 1200 == statusCode )
                            {

                                NSError *error;
                                
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultData options:NSJSONWritingPrettyPrinted error:&error];
                                
                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                
                                [gmrz_client_interface process:jsonString DoFido:gmrz_deregister Methods:gmrz_default ResultData:^(NSString *FidoOut, FidoStatus status) {
                                    
                                    if (status == 0) {
                                        
                                        [TAUtils displayMessage:@"running success" andShow:@"testak"];
                                        
                                    }
                                    else if(status == 1)
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
                                    
                                    
                                }];
                                
                                
                                
                                
                                [mAuthList removeObjectAtIndex:elementIndex];
                                
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                    // Update list
                                    [self.mRegistrationsTable reloadData];
                                    
                                }];
                                

                                mbGetList = false;            }
                    }else{
                        
                        [TAUtils displayMessage:@"connect error" andShow:@"error"];
                    }

                        
                    
                    
                }];
        
        
        
        
    }
    
    
}



# pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mAuthList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (mAuthList.count > 0)
    {
        AuthnrRegInfo* info = [mAuthList objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", info.aaid, info.descr];
    }
    
    return cell;
    
    
    
}





@end
