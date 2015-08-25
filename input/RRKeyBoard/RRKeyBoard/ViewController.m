//
//  ViewController.m
//  RRKeyBoard
//
//  Created by sunyuping on 15/8/18.
//  Copyright (c) 2015年 sunyuping. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UITextView *test = [[UITextView alloc] initWithFrame:CGRectMake(10, 100, 200, 40)];
    [test setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:test];
    
    UITextField *test1 = [[UITextField alloc] initWithFrame:CGRectMake(10, 200, 200, 40)];
    [test1 setBackgroundColor:[UIColor blueColor]];
    test1.secureTextEntry = YES;
    [self.view addSubview:test1];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
