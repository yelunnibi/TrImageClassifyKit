//
//  TRViewController.m
//  TrImageClassifyKit
//
//  Created by dc-zy on 01/08/2025.
//  Copyright (c) 2025 dc-zy. All rights reserved.
//

#import "TRViewController.h"
#import "TrImageClassifyer.h"
//#import "ZDOCRPipeline.h"

@interface TRViewController ()
@property (strong) TrImageClassifyer *classer;
@end

@implementation TRViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	
    self.classer = [[TrImageClassifyer alloc] init];
    
    NSString *imgP = [[NSBundle mainBundle]  pathForResource:@"20250108-164818.jpeg" ofType:nil];
    UIImage *img = [UIImage imageNamed:@"20250108-164818.jpeg"];
    UIImage *img2 = [UIImage imageNamed:@"tabby_cat.jpg"];
    UIImage *img3 = [UIImage imageNamed:@"test.jpg"];
    UIImage *img4 = [UIImage imageNamed:@"IMG_0643.jpg"];
    
    
//    [self.classer runWithImagePath:imgP confidenceTh:0 inputWidth:0 inputHeight:0];
    dispatch_queue_t queue = dispatch_queue_create("com.imageClassify.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSDate *startTime = [NSDate date];
        [self.classer classifyImage:img completion:^(int idx) {
            NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:startTime] * 1000;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"1--结果=%d, 耗时=%.2f毫秒", idx, timeElapsed);
            });
        }];
    });
    
    
    dispatch_async(queue, ^{
        NSDate *startTime = [NSDate date];
        [self.classer classifyImage:img2 completion:^(int idx) {
            NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:startTime] * 1000;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"2--结果=%d, 耗时=%.2f毫秒", idx, timeElapsed);
            });
        }];
    });
    
    dispatch_async(queue, ^{
        NSDate *startTime = [NSDate date];
        [self.classer classifyImage:img3 completion:^(int idx) {
            NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:startTime] * 1000;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"3--结果=%d, 耗时=%.2f毫秒", idx, timeElapsed);
            });
        }];
    });
    
    dispatch_async(queue, ^{
        NSDate *startTime = [NSDate date];
        [self.classer classifyImage:img4 completion:^(int idx) {
            NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:startTime] * 1000;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"4--结果=%d, 耗时=%.2f毫秒", idx, timeElapsed);
            });
        }];
    });
    
    dispatch_async(queue, ^{
        NSDate *startTime = [NSDate date];
        [self.classer classifyImage:img completion:^(int idx) {
            NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:startTime] * 1000;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"5--结果=%d, 耗时=%.2f毫秒", idx, timeElapsed);
            });
        }];
    });
    
    
    dispatch_async(queue, ^{
        NSDate *startTime = [NSDate date];
        [self.classer classifyImage:img2 completion:^(int idx) {
            NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:startTime] * 1000;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"6--结果=%d, 耗时=%.2f毫秒", idx, timeElapsed);
            });
        }];
    });
    
    dispatch_async(queue, ^{
        NSDate *startTime = [NSDate date];
        [self.classer classifyImage:img3 completion:^(int idx) {
            NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:startTime] * 1000;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"7--结果=%d, 耗时=%.2f毫秒", idx, timeElapsed);
            });
        }];
    });
    
    dispatch_async(queue, ^{
        NSDate *startTime = [NSDate date];
        [self.classer classifyImage:img4 completion:^(int idx) {
            NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:startTime] * 1000;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"8--结果=%d, 耗时=%.2f毫秒", idx, timeElapsed);
            });
        }];
    });
    
    dispatch_async(queue, ^{
        
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
