//
//  RootViewController.h
//  SocketDemo
//
//  Created by mac on 12-12-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

@interface RootViewController : UIViewController <AsyncSocketDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
@private
    AsyncSocket *listenSocket;
    AsyncSocket *sendSocket;
    BOOL isConnected;
    
    NSString *recText;
    
    NSMutableArray *connectArray;
    
    UITableView *mTableView;
    NSMutableDictionary *textDict;
    NSMutableArray *textArray;
}

@property (nonatomic,retain)IBOutlet UITextField *ipText;
@property (nonatomic,retain)IBOutlet UITextField *mesText;
@property (nonatomic,retain)IBOutlet UIButton *connecBtn;
@property (nonatomic,retain)IBOutlet UIButton *sendBtn;
@property (nonatomic,retain)IBOutlet UIButton *disconnecBtn;

-(IBAction)connectClick:(id)sender;

-(IBAction)sendClick:(id)sender;

-(IBAction)disconnectClick:(id)sender;

@end
