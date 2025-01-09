#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrImageClassifyer : NSObject


/// 返回标签数组
- (NSArray<NSString *> *)getLabels;


/// 分类图片,返回的是标签数组的下标index
/// - Parameter image: 图片
- (int)classifyImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
