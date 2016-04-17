//
//  ViewController.m
//  Game2048
//
//  Created by luowanglin on 16/1/12.
//  Copyright © 2016年 com.luowanglin. All rights reserved.
//

#import "ViewController.h"

BOOL isbest = NO;//初始化全局，以标记最高分
int timeSecond = -1;//记录时间秒
int timeMinute = 0;//记录时间分
int restTime = 1;//休息时间

@interface ViewController ()
{
    UILabel *score; //显示得分标题
    int score_count;//记录分数
    UILabel *best;//最高纪录标题
    int over;//记录随机次数，以判断游戏是否结束
    UIView *overView;//游戏结束页面（mask）
    UIView *overviewframe;//游戏结束
    UIButton *start;//游戏开始按钮
    UIImage *buttonimage;//按钮背景图片
    BOOL isover;//是否结束，以防止多次调用isover方法
    int bestScorce;//记录每次的最高分，以便游戏结束时显示
    NSMutableArray *mutableArray;//存储初始化生成的所用对象
    UIView *view1;//存放数字对象的容器（手势设置）
    NSTimer *timer;//计时器（时间表）
    UIView *viewRest;//温馨提示页mask
    UIView *view2;//温馨提示页
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isover = YES;
    score_count = 0;
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.97 blue:0.94 alpha:1.0];
    mutableArray = [NSMutableArray array];
    
    //创建容器
    view1 = [[UIView alloc]initWithFrame:CGRectMake(10, 140, 300, 300)];
    view1.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:view1];
    
    //画网格
    for (int j = 0; j < 4; j++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(j*75,0, 1,320)];
        view.backgroundColor = [UIColor colorWithRed:0.98 green:0.97 blue:0.94 alpha:1.0];
        [view1 addSubview:view];
    }
    for (int i = 0; i < 4; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,i*75, 320, 1)];
        view.backgroundColor = [UIColor colorWithRed:0.98 green:0.97 blue:0.94 alpha:1.0];
        [view1 addSubview:view];
    }
    
    //crear label for score and class
    best = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 180, 30)];
    best.text = @"best: 0";
    best.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:25];
    best.textColor = [UIColor grayColor];
    [self.view addSubview:best];
    
    score = [[UILabel alloc]initWithFrame:CGRectMake(20, 80, 180, 30)];
    score.text = @"score: 0";
    score.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:25];
    score.textColor = [UIColor grayColor];
    [self.view addSubview:score];
    
    //创建开始按钮
    [self creatBackgroundImg];
    start = [UIButton buttonWithType:(UIButtonTypeCustom)];
    start.frame = CGRectMake(200, 50, 100, 60);
    [start setTitle:@"start" forState:(UIControlStateNormal)];
    start.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:30];
    [start setBackgroundImage:buttonimage forState:(UIControlStateNormal)];
    [start.layer setCornerRadius:10.0];
    start.layer.masksToBounds = YES;
    [self.view addSubview:start];
    [start addTarget:self action:@selector(StartBtn:) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    view1.userInteractionEnabled = NO;
    //right
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [view1 addGestureRecognizer:swipe];
    //left
    swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [view1 addGestureRecognizer:swipe];
    //up
    swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [view1 addGestureRecognizer:swipe];
    //down
    swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [view1 addGestureRecognizer:swipe];

    if (isbest) {
        best.text = [NSString stringWithFormat:@"best:%d",bestScorce];
    }
    
}

//手势方法的实现
- (void)swipe:(UISwipeGestureRecognizer *)swip{
//right
    if (swip.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"right");
        for (int y = 0; y < 4; y++) {
            for (int x = 3; x >= 0; x--) {
                
                for (int x1 = x-1 ; x1 >= 0; x1--) {
                    UIButton *btn = [[mutableArray objectAtIndex:y]objectAtIndex:x1];
                    UIButton *btn1 = [[mutableArray objectAtIndex:y]objectAtIndex:x];
                    if (btn1.tag <= 0 && btn.tag > 0) {
                        btn1.tag = btn.tag;
                        btn.tag = 0;
                        [self creatAnimation:btn button:btn1];
                        x++;
                        break;
                    }else if(btn.tag == btn1.tag && btn.tag > 0){
                        btn1.tag *= 2;
                        btn.tag = 0;
                        score_count += btn1.tag;
                        [self creatAnimation:btn button:btn1];
                        [self animationForScore:btn1];
                        break;
                    }else if(btn.tag > 0 && btn1.tag > 0 && btn.tag != btn1.tag){
                        break;
                    }
                }
            }
        }
//left
    }else if(swip.direction == UISwipeGestureRecognizerDirectionLeft){
        NSLog(@"left");
        for (int y = 0; y < 4; y++) {
            for (int x = 0 ; x < 4; x++) {
                
                for (int x1 = x+1; x1 < 4 ; x1++) {
                    UIButton *btn = [[mutableArray objectAtIndex:y]objectAtIndex:x1];
                    UIButton *btn1 = [[mutableArray objectAtIndex:y]objectAtIndex:x];
                    if (btn1.tag <= 0 && btn.tag > 0) {
                        btn1.tag = btn.tag;
                        btn.tag = 0;
                        [self creatAnimation:btn button:btn1];
                        x--;
                        break;
                    }else if (btn1.tag == btn.tag && btn.tag > 0){
                        btn1.tag *= 2;
                        btn.tag = 0;
                        score_count += btn1.tag;
                        [self creatAnimation:btn button:btn1];
                        [self animationForScore:btn1];
                        break;
                    }else if(btn.tag > 0 && btn1.tag > 0 && btn.tag != btn1.tag){
                        break;
                    }

                }
            }
        }
//up
    }else if(swip.direction == UISwipeGestureRecognizerDirectionUp){
        NSLog(@"up");
        for (int y = 0; y < 4; y++) {
            for (int x = 0; x < 4; x++) {
                for (int x1 = x+1; x1 < 4; x1++) {
                    UIButton *btn = [[mutableArray objectAtIndex:x1] objectAtIndex:y];
                    UIButton *btn1 = [[mutableArray objectAtIndex:x] objectAtIndex:y];
                    if (btn.tag > 0 && btn1.tag <= 0) {
                        btn1.tag = btn.tag;
                        btn.tag = 0;
                        [self creatAnimation:btn button:btn1];
                        x--;
                        break;
                    }else if(btn.tag > 0 && btn.tag == btn1.tag){
                        btn1.tag *= 2;
                        btn.tag = 0;
                        score_count += btn1.tag;
                        [self creatAnimation:btn button:btn1];
                        [self animationForScore:btn1];
                        break;
                    }else if(btn.tag > 0 && btn1.tag > 0 && btn.tag != btn1.tag){
                        break;
                    }

                }
            }
        }
//down
    }else if(swip.direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"执行了 down");
        for (int y = 0; y < 4; y++) {
            for (int x = 3; x >= 0 ; x--) {
                for (int x1 = x-1; x1 >= 0; x1--) {
                    UIButton *btn = [[mutableArray objectAtIndex:x1]objectAtIndex:y];
                    UIButton *btn1 = [[mutableArray objectAtIndex:x]objectAtIndex:y];
                    if (btn.tag > 0 && btn1.tag <= 0) {
                        btn1.tag = btn.tag;
                        btn.tag = 0;
                        [self creatAnimation:btn button:btn1];
                        x++;
                        break;
                    }else if (btn.tag > 0 && btn1.tag == btn.tag){
                        btn1.tag *= 2;
                        btn.tag = 0;
                        score_count += btn1.tag;
                        [self creatAnimation:btn button:btn1];
                        [self animationForScore:btn1];
                        break;
                    }else if(btn.tag > 0 && btn1.tag > 0 && btn.tag != btn1.tag){
                        break;
                    }

                }
            }
        }
    }
    
    if (!isbest) {
       [best setText:[NSString stringWithFormat:@"best:%d",score_count]];
    }
    [score setText:[NSString stringWithFormat:@"score:%d",score_count]];
    //延时生成对象 与移动同步
    [self performSelector:@selector(randomDisplayButton) withObject:nil afterDelay:0.5];
}

//创建动画，为移动时的虚拟动画
- (void)creatAnimation:(UIButton*)btn button:(UIButton*)btnC{
    UIButton *copyBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    copyBtn.frame = CGRectMake(btn.frame.origin.x, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
    [copyBtn setTitle:btn.titleLabel.text forState:(UIControlStateNormal)];
    copyBtn.titleLabel.font = btn.titleLabel.font;
    copyBtn.backgroundColor = btn.backgroundColor;
    [view1 addSubview:copyBtn];
    
    [UIView animateWithDuration:0.5 animations:^{
        btn.hidden = YES;
        copyBtn.center = btnC.center;
    } completion:^(BOOL finished) {
        [copyBtn removeFromSuperview];
    }];
    
    copyBtn = nil;//释放掉
}

//更新button的状态
- (void)updateButton{
    for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
            UIButton *btn = [[mutableArray objectAtIndex:y]objectAtIndex:x];
            if (btn.tag == 0) {
                btn.hidden = YES;
                btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:50];
                [btn setTitle:@"" forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:50];
                btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:50];
            }else if (btn.tag == 2) {
                btn.hidden = NO;
                [btn setTitle:@"2" forState:(UIControlStateNormal)];
                btn.backgroundColor = [[UIColor purpleColor]colorWithAlphaComponent:0.5];
//                btn.titleLabel.font = [UIFont systemFontOfSize:50];
                 btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:50];
            }else if(btn.tag == 4){
                btn.hidden = NO;
                btn.backgroundColor = [[UIColor blueColor]colorWithAlphaComponent:0.5];
                [btn setTitle:[NSString stringWithFormat:@"%d",(int)btn.tag] forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:50];
                btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:50];
                
            }else if(btn.tag == 8){
                btn.hidden = NO;
                btn.backgroundColor = [[UIColor orangeColor]colorWithAlphaComponent:0.5];
                [btn setTitle:[NSString stringWithFormat:@"%d",(int)btn.tag] forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:50];
                 btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:50];
            
            }else if(btn.tag == 16){
                btn.hidden = NO;
                btn.backgroundColor = [[UIColor brownColor]colorWithAlphaComponent:0.5];
                [btn setTitle:[NSString stringWithFormat:@"%d",(int)btn.tag] forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:50];
                 btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:50];
            
            }else if(btn.tag == 32){
                btn.hidden = NO;
                btn.backgroundColor = [[UIColor cyanColor]colorWithAlphaComponent:0.5];
                [btn setTitle:[NSString stringWithFormat:@"%d",(int)btn.tag] forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:50];
                 btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:50];
            
            }else if(btn.tag == 64){
                btn.hidden = NO;
                btn.backgroundColor = [[UIColor greenColor]colorWithAlphaComponent:0.5];
                [btn setTitle:[NSString stringWithFormat:@"%d",(int)btn.tag] forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:50];
                 btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:50];
            }else if(btn.tag == 128){
                btn.hidden = NO;
                btn.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.5];
                [btn setTitle:[NSString stringWithFormat:@"%d",(int)btn.tag] forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:40];
                 btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:40];
            
            }else if(btn.tag == 256){
                btn.hidden = NO;
                btn.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
                [btn setTitle:[NSString stringWithFormat:@"%d",(int)btn.tag] forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:40];
                 btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:40];

            }else if(btn.tag == 512){
                btn.hidden = NO;
                btn.backgroundColor = [[UIColor yellowColor]colorWithAlphaComponent:0.5];
                [btn setTitle:[NSString stringWithFormat:@"%d",(int)btn.tag] forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:40];
                 btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:40];

            }else if(btn.tag == 1024){
                btn.hidden = NO;
                btn.backgroundColor = [[UIColor magentaColor]colorWithAlphaComponent:0.5];
                [btn setTitle:[NSString stringWithFormat:@"%d",(int)btn.tag] forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:30];
                 btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:30];

            }else if(btn.tag == 2048){
                btn.hidden = NO;
                btn.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.5];
                [btn setTitle:[NSString stringWithFormat:@"%d",(int)btn.tag] forState:(UIControlStateNormal)];
//                btn.titleLabel.font = [UIFont systemFontOfSize:30];
                 btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:30];

            }
        }
    }
}

//随机显示数字对象
- (void)randomDisplayButton{
    int random = arc4random() % 4;
    int random1 = arc4random() % 4;
    UIButton *btn = [[mutableArray objectAtIndex:random] objectAtIndex:random1];
    if (btn.tag != 0) {
        over ++;
        if (over > 60) {
            [self isOver];
        }else{
            [self randomDisplayButton];
        }
    }else{
        int random = arc4random() %100;
        if (random > 20) {
            btn.tag = 2;
        }else{
            btn.tag = 4;
        }
        btn.hidden = NO;
        [self updateButton];
        over = 0;
    }
}

//响应开始按钮的实现
- (void)StartBtn:(UIButton*)sender{
    view1.userInteractionEnabled = YES;

    for (int i =0; i < 4; i++) {
        NSMutableArray *arraTemp = [NSMutableArray array];
        for (int j = 0; j < 4 ; j++) {
            UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
            btn.frame = CGRectMake(1+74*j+j, 1+74*i+i, 74, 74);
            btn.backgroundColor = [[UIColor purpleColor]colorWithAlphaComponent:0.8];
            [btn setTitle:@"2" forState:(UIControlStateNormal)];
            btn.titleLabel.font = [UIFont systemFontOfSize:50];
            [view1 addSubview:btn];
            btn.tag = 0;
            btn.hidden = YES;
            [arraTemp addObject:btn];
            
        }
        [mutableArray addObject:arraTemp];
    }
    [self randomDisplayButton];
    [self randomDisplayButton];
    sender.enabled = NO;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recoderTimer) userInfo:nil repeats:YES];
    [timer fire];
    

}

//创建得分动画
- (void)animationForScore:(UIButton *)btn{
    UILabel *scor = [[UILabel alloc]initWithFrame:CGRectMake(90, 80, 100, 50)];
    scor.text = [NSString stringWithFormat:@"+%d",(int)btn.tag];
    scor.textColor = [UIColor grayColor];
    scor.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:30];
    
    [self.view addSubview:scor];
    [UIView animateWithDuration:1.0 animations:^{
        [scor setTransform:(CGAffineTransformMakeScale(0.1, 0.1))];
        [scor setFrame:CGRectMake(160, -200, scor.frame.size.width, scor.frame.size.height)];
    }];
    
    scor = nil;
}

//判断游戏是否结束
- (void)isOver{
    [timer invalidate];
    if (isover) {
        view1.userInteractionEnabled = NO;
        overView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
        overView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0];
        
        overviewframe = [[UIView alloc]initWithFrame:CGRectMake(10, 140, 300, 200)];
        overviewframe.backgroundColor = [UIColor grayColor];
        overviewframe.layer.cornerRadius = 5.0;
        
        //label for game over!
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 280, 100)];
        if (bestScorce < score_count) {
            bestScorce = score_count;
            isbest = YES;
        }
        lable.text = [NSString stringWithFormat:@"best score:%d",bestScorce];
        lable.textColor = [UIColor whiteColor];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:30];
        [overviewframe addSubview:lable];
        
        //back button
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [self creatBackgroundImg];
        btn.frame = CGRectMake(100, 110, 100, 60);
        [btn setBackgroundImage:buttonimage forState:(UIControlStateNormal)];
        btn.layer.cornerRadius = 10.0;
        btn.layer.masksToBounds = YES;
        [btn setTitle:@"back" forState:(UIControlStateNormal)];
        btn.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:30];
        [btn addTarget:self action:@selector(backAction) forControlEvents:(UIControlEventTouchUpInside)];
        [overviewframe addSubview:btn];
        
        [overviewframe setTransform:(CGAffineTransformMakeScale(0.01, 0.01))];
        
        
        [overView addSubview:overviewframe];
        [self.view addSubview:overView];
        
        [UIView animateWithDuration:1.0 animations:^{
            [overviewframe setTransform:(CGAffineTransformMakeScale(1, 1))];
            overView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.5];
        }];
        isover = NO;
    }
    
}

//返回按钮的实现
- (void)backAction{
    [timer fire];
  NSArray *array = [self.view subviews];
    [UIView animateWithDuration:1.0 animations:^{
        [overviewframe setTransform:(CGAffineTransformMakeScale(0.01, 0.01))];
        overView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        for (UIView * obj in array) {
            [obj removeFromSuperview];
        }
        [self viewDidLoad];
    }];

}

//创建button 背景图片
- (void)creatBackgroundImg{
    //创建rect 框架 -- 背景图片
    CGRect rect = CGRectMake(0, 0, 100, 100);
    //开始图形化
    UIGraphicsBeginImageContext(rect.size);
    //获得图形化上下文
    CGContextRef contex = UIGraphicsGetCurrentContext();
    //填充颜色为上下文
    CGContextSetFillColorWithColor(contex, [UIColor colorWithRed:0.26 green:0.52 blue:0.96 alpha:1.0].CGColor);
    //加入框架约束
    CGContextFillRect(contex, rect);
    //创建图片对象 从图形化上下文
    buttonimage = UIGraphicsGetImageFromCurrentImageContext();
    //结束图形化
    UIGraphicsEndImageContext();
    
}

//计时器的实现
- (void)recoderTimer{
    timeSecond ++;
    NSMutableString *str = [NSMutableString string];
    if (timeSecond > 9 && timeSecond < 60) {
        if (timeMinute < 10){
            [str appendFormat:@"0%d:%d",timeMinute,timeSecond];
        }else{
            [str appendFormat:@"%d:%d",timeMinute,timeSecond];
        }
    }else if (timeSecond < 10){
        if (timeMinute < 10) {
            [str appendFormat:@"0%d:0%d",timeMinute,timeSecond];
        }else{
            [str appendFormat:@"%d:0%d",timeMinute,timeSecond];
        }
    }else if(timeSecond == 60){
        timeMinute++;
        timeSecond = 0;
        if (timeMinute < 10) {
            [str appendFormat:@"0%d:00",timeMinute];
        }else{
            [str appendFormat:@"%d:00",timeMinute];
        }
    }else{
        NSLog(@"zhixingleyiwai");
    }
    [start setTitle:str forState:(UIControlStateDisabled)];
    if (timeMinute == restTime) {
        [self tipForYou];
    }
}

//保护视力小提示
- (void)tipForYou{
    [timer invalidate];
    restTime += 5;
    viewRest = [[UIView alloc]initWithFrame:CGRectMake(0,0, 320, 480)];
    viewRest.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0];
    
    view2 = [[UIView alloc]initWithFrame:CGRectMake(30, 140, 260, 200)];
    view2.backgroundColor = [UIColor grayColor];
    view2.layer.cornerRadius = 5.0;
   
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, 40, 240, 80)];
    label.text = @"you need look some green plant!";
    label.textAlignment = NSTextAlignmentNatural;
    label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
    label.textColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = CGRectMake(85, 110, 90, 40);
    [btn setTitle:@"continue" forState:(UIControlStateNormal)];
    [btn setBackgroundImage:buttonimage forState:(UIControlStateNormal)];
    btn.layer.cornerRadius = 5.0;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(continueAction) forControlEvents:(UIControlEventTouchUpInside)];
    
    [view2 setTransform:(CGAffineTransformMakeScale(0.01, 0.01))];
    
    [view2 addSubview:label];
    [view2 addSubview:btn];
    [viewRest addSubview:view2];
    
    [self.view addSubview:viewRest];
    
    [UIView animateWithDuration:1.0 animations:^{
        [view2 setTransform:(CGAffineTransformMakeScale(1, 1))];
        viewRest.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.5];
    }];
    
}

//继续游戏按钮的实现
- (void)continueAction{
    NSArray *arr = [viewRest subviews];
    [UIView animateWithDuration:1.0 animations:^{
        [view2 setTransform:(CGAffineTransformMakeScale(0.01, 0.01))];
        viewRest.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        for (id obj in arr) {
            [obj removeFromSuperview];
        }
        [viewRest removeFromSuperview];
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recoderTimer) userInfo:nil repeats:YES];
    [timer fire];
}

//文件操作
- (void)oprationFile{
  //获取沙盒document路径
   NSArray *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [path objectAtIndex:0];
    //创建文件夹
    NSString *testDirectory = [documentDir stringByAppendingPathComponent:@"test"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testPath = [testDirectory stringByAppendingPathComponent:@"test.txt"];
    BOOL res=[fileManager createFileAtPath:testPath contents:nil attributes:nil];
    if (res) {
        NSLog(@"文件创建成功: %@" ,testPath);
    }else
        NSLog(@"文件创建失败");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

















