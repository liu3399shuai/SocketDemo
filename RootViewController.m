//
//  RootViewController.m
//  SocketDemo
//
//  Created by mac on 12-12-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "BookCell.h"

@implementation RootViewController

@synthesize ipText = _ipText;
@synthesize mesText = _mesText;
@synthesize connecBtn = _connecBtn;
@synthesize disconnecBtn = _disconnecBtn;
@synthesize sendBtn = _sendBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.ipText resignFirstResponder];
    [self.mesText resignFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
    sendSocket = [[AsyncSocket alloc] initWithDelegate:self];
    [listenSocket acceptOnPort:0x1234 error:nil];
    
    self.ipText.delegate = self;
    self.mesText.delegate = self;
    
    connectArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    isConnected = NO;
    
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 150) style:UITableViewStylePlain];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    mTableView.bounces = NO;
    [self.view addSubview:mTableView];
    textDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    textArray = [[NSMutableArray alloc] initWithCapacity:0];
}
-(void)connectClick:(id)sender
{
    if (!isConnected) {
        [sendSocket connectToHost:_ipText.text onPort:0x1234 error:nil];
    }
}
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"connect ok %@:%d",host,port);
    isConnected = YES;
}
-(void)sendClick:(id)sender
{
    NSData *data = [_mesText.text dataUsingEncoding:NSUTF8StringEncoding];
    
    if (isConnected) {
        [sendSocket writeData:data withTimeout:-1 tag:100];
    }else{
        NSLog(@"no connect");
    }
}
-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 100) {
        NSLog(@"number %ld send ok",tag);
        [textArray addObject:[NSDictionary dictionaryWithObject:_mesText.text forKey:@"host"]];
        CGFloat hei = mTableView.contentOffset.y + 150;
        mTableView.contentOffset =  CGPointMake(0, hei);
        [mTableView reloadData];
    }
}
-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    [connectArray addObject:newSocket];

    [newSocket readDataWithTimeout:-1 tag:200];
}
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *text = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];

    [textArray addObject:[NSDictionary dictionaryWithObject:text forKey:@"other"]];
    CGFloat hei = mTableView.contentOffset.y + 150;
    mTableView.contentOffset =  CGPointMake(0, hei);
    [mTableView reloadData];
    [sock readDataWithTimeout:-1 tag:200];
}
-(void)disconnectClick:(id)sender
{
    [sendSocket disconnect];
    isConnected = NO;
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"host:%@ disconnect",[sock connectedHost]);
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [textArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify = @"cellName";
    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BookCell" owner:self options:nil] lastObject];
    }
    
    NSString *key = [[[textArray objectAtIndex:indexPath.row]allKeys] lastObject];
    if ([key isEqualToString:@"host"]) {
        cell.lable.text = [[textArray objectAtIndex:indexPath.row] objectForKey:@"host"];
        cell.lable.frame = CGRectMake(0, 0, 160, 50);
        cell.lable.textAlignment = UITextAlignmentLeft;
        cell.backgroundColor = [UIColor lightGrayColor];
    }else{
        cell.lable.text = [[textArray objectAtIndex:indexPath.row] objectForKey:@"other"];
        cell.lable.frame = CGRectMake(160, 0, 160, 50);
        cell.lable.textAlignment = UITextAlignmentRight;
        cell.backgroundColor = [UIColor purpleColor];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[[textArray objectAtIndex:indexPath.row]allKeys] lastObject];
    if ([key isEqualToString:@"host"]) {
        cell.backgroundColor = [UIColor lightGrayColor];
    }else{
        cell.backgroundColor = [UIColor purpleColor];
    }
}
- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [sendSocket setDelegate:nil];
    [sendSocket disconnect];
    [sendSocket release];
    sendSocket = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
