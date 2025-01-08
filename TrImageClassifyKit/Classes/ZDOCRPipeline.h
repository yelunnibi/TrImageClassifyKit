//
//  ZDOCRPipeline.h
//  Pods-ZDOCRKit_Example
//
//  Created by 孙树康 on 2024/6/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 识别结果
@interface PiplineResult: NSObject
// 识别框 坐标，归一化
@property (nonatomic, assign) CGRect rect;
// 识别文本
@property (nonatomic, copy) NSString *text;
// 识别分数
@property (nonatomic, assign) CGFloat score;

@end

@interface ZDOCRPipeline : NSObject
// 配置语言
@property (nonatomic, copy, readonly) NSString *langCode;

// 模型配置
- (void)configLanguage: (NSString *)langCode;

- (NSArray <PiplineResult *>*)beganOCR: (UIImage *)image;

@end

NS_ASSUME_NONNULL_END
