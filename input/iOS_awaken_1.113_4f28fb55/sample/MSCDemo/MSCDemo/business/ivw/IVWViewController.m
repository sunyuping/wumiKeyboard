//
//  IVWViewController.m
//
//  Created by xlhou on 14-6-26.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//

/*
 *
    demo为唤醒的使用示例
    本次demo假定唤醒词是“讯飞语音”和“讯飞语点”，第一个唤醒词是“讯飞语音”，第二个唤醒词是“讯飞语点”
    总体运行顺序是：
 1. 设置唤醒参数；
 2. 创建唤醒对象；
 3. 启动唤醒；
 4. 通过回调获取唤醒状态
 
 在使用时需要注意唤醒的本地资源路径，一定要与具体的文件保持一致
 *
 *
 */

#import <QuartzCore/QuartzCore.h>
#import "ISRDataHelper.h"
#import "PopupView.h"
#import "Definition.h"
#import "IVWViewController.h"



@interface IVWViewController ()

@end

@implementation IVWViewController


/*
 * @开始启动语音唤醒
 */

- (IBAction) onBtnStart:(id)sender
{
    _resultView.text = @"";
    
    //设置唤醒门限值
    //0:表示第一个唤醒词，-20表示对应的门限值
    //1：表示第二个唤醒词，-20表示对应的门限值
    //唤醒词的数目跟序号是一一对应的
    [self.iflyVoiceWakeuper setParameter:@"0:-20;1:-20;" forKey:[IFlySpeechConstant IVW_THRESHOLD]];
    
    //设置唤醒服务类型，wakeup表示是唤醒服务，除此外以后还可能有其他拓展服务
    [self.iflyVoiceWakeuper setParameter:@"wakeup" forKey:[IFlySpeechConstant IVW_SST]];
    
    
    //设置唤醒服务周期，1：表示唤醒成功后继续录音，并保持唤醒状态；0：表示唤醒成功后停止录音
    [self.iflyVoiceWakeuper setParameter:@"1" forKey:[IFlySpeechConstant KEEP_ALIVE]];
    
    BOOL ret = [self.iflyVoiceWakeuper startListening];
    if(ret)
    {
        self.startBtn.enabled = NO;
        self.stopBtn.enabled=YES;
    }
}


/*
 * @ 暂停录音 并不释放资源
 *  在后台运行如想暂停录音，调用 IFlyVoiceWakeuper cancel
 *
 *
 */
- (IBAction) onBtnStop:(id) sender
{
    [self.iflyVoiceWakeuper stopListening];
    
//    self.stopBtn.enabled=NO;
//    self.startBtn.enabled = YES;
//    [_resultView resignFirstResponder];
    
    NSLog(@"唤醒结束");
}

/**
 隐藏键盘
 ****/
- (void)onKeyBoardDown:(id) sender
{
    [_resultView resignFirstResponder];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIBarButtonItem *spaceBtnItem = [[ UIBarButtonItem alloc]     //键盘
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                     target:nil action:nil];
    
    UIBarButtonItem *hideBtnItem = [[UIBarButtonItem alloc]
                                    initWithTitle:@"隐藏" style:UIBarButtonItemStylePlain
                                    target:self action:@selector(onKeyBoardDown:)];
    
    [hideBtnItem setTintColor:[UIColor whiteColor]];
    UIToolbar *toolbar = [[ UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray *array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    
    _resultView.inputAccessoryView = toolbar;
    _resultView.layer.borderWidth = 0.5f;
    _resultView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [_resultView.layer setCornerRadius:7.0f];
    
    CGFloat posY = _resultView.frame.origin.y+_resultView.frame.size.height/6;
    _popUpView = [[PopupView alloc] initWithFrame:CGRectMake(100, posY, 0, 0) withParentView:self.view];
    
    
    //demo中的唤醒词，假定是“讯飞语音”和“讯飞语点”
     self.words = [[NSDictionary alloc]initWithObjectsAndKeys:@"讯飞语音",@"0",@"讯飞语点",@"1",nil];

    //获取唤醒词路径,目录需要根据具体的文件位置设定
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *wordPath = [[NSString alloc] initWithFormat:@"%@/ivwres/wakeupresource.jet",resPath];
    
    //转换路径为符合sdk规范的唤醒路径
    NSString *ivwResourcePath = [IFlyResourceUtil generateResourcePath:wordPath];
    
    [[IFlySpeechUtility getUtility] setParameter:[NSString stringWithFormat: @"engine_start=ivw,ivw_res_path=%@",ivwResourcePath] forKey:[IFlyResourceUtil ENGINE_START]];
    
    self.iflyVoiceWakeuper = [IFlyVoiceWakeuper sharedInstance];
    self.iflyVoiceWakeuper.delegate = self;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.iflyVoiceWakeuper stopListening];
    
    [super viewWillDisappear:animated];
}

- (void) dealloc
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 录音开始
 */
-(void) onBeginOfSpeech
{
    NSLog(@"%s",__func__);
}

/**
 录音结束
 */
-(void) onEndOfSpeech
{
    NSLog(@"%s",__func__);
    self.stopBtn.enabled=NO;
    self.startBtn.enabled = YES;
    [_resultView resignFirstResponder];
}

/**
 会话错误
 
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 
 */
-(void) onError:(IFlySpeechError *)error
{
    if (error.errorCode!=0) {
        
        [_popUpView setText:[NSString stringWithFormat:@"识别结束,错误码:%d",error.errorCode]];
        [self.view addSubview:_popUpView];
        
        NSLog(@"%s,errorCode:%d",__func__,error.errorCode);
    }
//    _stopBtn.enabled = NO;
    

}


/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void) onVolumeChanged: (int)volume
{
//    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
//    [_popUpView setText: vol];
//    [self.view addSubview:_popUpView];
    
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    [_popUpView showText: vol];
    
}


/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的resultID记录唤醒词位置和动作
* @see
 */
-(void) onResult:(NSMutableDictionary *)resultArray
{

    NSString *sst = [resultArray objectForKey:@"sst"];
    NSNumber *wakeId = [resultArray objectForKey:@"id"];
    NSString *score = [resultArray objectForKey:@"score"];
    NSString *bos = [resultArray objectForKey:@"bos"];
    NSString *eos = [resultArray objectForKey:@"eos"];
    NSString * wakeIDStr = [NSString stringWithFormat:@"%@",wakeId];
    
    NSLog(@"【唤醒词】=%@",[self.words objectForKey:wakeIDStr]);
    NSLog(@"【操作类型】sst=%@",sst);
    NSLog(@"【唤醒词id】id=%@",wakeId);
    NSLog(@"【得分】score=%@",score);
    NSLog(@"【尾端点】eos=%@",eos);
    NSLog(@"【前端点】bos=%@",bos);
    
    NSLog(@"");
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"\n"];
    
    [result appendFormat:@"【唤醒词】=%@\n",[self.words objectForKey:wakeIDStr]];
    [result appendFormat:@"【操作类型】sst=%@\n",sst];
    [result appendFormat:@"【唤醒词id】id=%@\n",wakeId];
    [result appendFormat:@"【得分】score=%@\n",score];
    [result appendFormat:@"【尾端点】eos=%@\n",eos];
    [result appendFormat:@"【前端点】bos=%@\n",bos];
    //[result appendString:@"********************分割*********************\n"];
    

    _result = result;
    self.result = result;
    _resultView.text = [NSString stringWithFormat:@"%@%@", _resultView.text,result];
    self.result=nil;
    [_resultView scrollRangeToVisible:NSMakeRange([_resultView.text length], 0)];

}






@end
