//
//  ZDOCRPipeline.m
//  Pods-ZDOCRKit_Example
//
//  Created by 孙树康 on 2024/6/3.
//



#if __cplusplus && __has_include(<opencv2/imgcodecs/ios.h>)
#import <opencv2/imgproc/types_c.h>
#import <opencv2/core/core.hpp>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/core.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgproc.hpp>

#include "pipeline.h"
#include "timer.h"
#include <arm_neon.h>
#include <iostream>
#include <mutex>
#include <paddle_api.h>
#include <paddle_use_kernels.h>
#include <paddle_use_ops.h>
#include <string>
#import <sys/timeb.h>
#include <vector>

using namespace paddle::lite_api;
using namespace cv;

#endif

#import "ZDOCRPipeline.h"

@interface PiplineResult()

@end

@implementation PiplineResult

@end

@interface ZDOCRPipeline()


@property(nonatomic) bool flag_init;
@property(nonatomic) bool flag_cap_photo;
// change to instance
@property(nonatomic) std::string dict_path;
// change to instance
@property(nonatomic) std::string config_path;

// 对应任务处理的模型文件
@property(nonatomic) std::string det_model_file;
@property(nonatomic) std::string rec_model_file;
@property(nonatomic) std::string cls_model_file;

// what is this?
@property(nonatomic) cv::Mat cvimg;
// 流水线对象, 负责处理OCR的任务
@property(nonatomic) Pipeline *pipeline;


@property (nonatomic, strong, readwrite) NSString *langCode;

@end


@implementation ZDOCRPipeline

- (id)init {
    self = [super init];
    if (self) {
        self.flag_init = false;
        self.flag_cap_photo = false;
        self.dict_path = "";
        self.config_path = "";
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"ZDOCR" withExtension:@"bundle"];
        // config path
        NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
        
        NSString *configURL = [bundle pathForResource:@"config.txt" ofType: nil];
        NSString *dictURL = [bundle pathForResource:@"labels/ppocr_keys_v1.txt" ofType: nil];
        
        NSString *det_model_path = [bundle pathForResource:@"models/ch_det_opt.nb" ofType: nil];
        NSString *rec_model_path = [bundle pathForResource:@"models/ch_rec_opt.nb" ofType: nil];
        NSString *cls_model_path = [bundle pathForResource:@"models/ch_cls_opt.nb" ofType: nil];
        
        self.det_model_file = [det_model_path UTF8String];
        self.rec_model_file = [rec_model_path UTF8String];
        self.cls_model_file = [cls_model_path UTF8String];
        self.config_path = [configURL UTF8String];
        self.dict_path = [dictURL UTF8String];
    }
    return self;
}


- (void)configLanguage:(NSString *)langCode {
    self.langCode = langCode;
}

- (void)resetPipeline {
    self.pipeline = new Pipeline(self.det_model_file, self.cls_model_file, self.rec_model_file,
                                 "LITE_POWER_HIGH", 1, self.config_path, self.dict_path);
}

- (NSArray *)beganOCR:(UIImage *)image {
    cv::Mat originMat;
    UIImageToMat(image, originMat);
    
    [self resetPipeline];
    if (originMat.channels() == 4) {
        cvtColor(originMat, self->_cvimg, COLOR_RGBA2BGR);
    } else {
        cvtColor(originMat, self->_cvimg, COLOR_RGB2BGR);
    }
    
    self.pipeline->ResetDetPredictor(self.det_model_file, "LITE_POWER_HIGH", 1);
    
    std::vector<DetectionResult> results;
    self.pipeline->Process(self->_cvimg, results);
    
    NSMutableArray *rs = [NSMutableArray array];
    for (int i = 0; i < results.size(); i++) {
        DetectionResult result = results[i];
        PiplineResult *r = [[PiplineResult alloc] init];
        CGFloat x_ = CGFloat(result.box.x) / CGFloat(originMat.cols);
        CGFloat y_ = CGFloat(result.box.y) / CGFloat(originMat.rows);
        CGFloat w_ = CGFloat(result.box.width) / CGFloat(originMat.cols);
        CGFloat h_ = CGFloat(result.box.height) / CGFloat(originMat.rows);
        
        r.rect = CGRectMake(x_, y_, w_, h_);
        r.text = [NSString stringWithUTF8String:result.text.c_str()];
        r.score = result.text_score;
        [rs addObject:r];
    }
    // release pipeline
    delete self.pipeline;
    return rs;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}

@end
