
#if __cplusplus && __has_include(<opencv2/imgcodecs/ios.h>)
#import <opencv2/imgproc/types_c.h>
#import <opencv2/core/core.hpp>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/core.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgproc.hpp>
#include <fstream>
#import "paddle_api.h"  // NOLINT

using namespace paddle::lite_api;
using namespace cv;

#endif

#import "TrImageClassifyer.h"


void load_labels(const std::string& path, std::vector<std::string>* labels) {
  std::ifstream ifs(path);
  if (!ifs.is_open()) {
      return;
  }
  std::string line;
  while (getline(ifs, line)) {
    labels->push_back(line);
  }
  ifs.close();
}

std::pair<int, float> print_above_threshold(const float* scores,
                           const int size,
                           const float confidence_th,
                           const std::vector<std::string>& labels) {
    std::vector<std::pair<float, int>> vec;
    vec.resize(size);
    for (int i = 0; i < size; i++) {
        vec[i] = std::make_pair(scores[i], i);
    }
    
    std::partial_sort(vec.begin(),
                      vec.begin() + size,
                      vec.end(),
                      std::greater<std::pair<float, int>>());
    
    // always print the first result
    if (size > 0) {
        float score = vec[0].first;
        int index = vec[0].second;
        printf("index: %d,  name: %s,  score: %f \n",
               index,
               labels[index].c_str(),
               score);
        return std::make_pair(index, score);
    }
    return std::make_pair(-11, 0);
}
// fill tensor with mean and scale and trans layout: nhwc -> nchw, neon speed up
void neon_mean_scale(
    const float* din, float* dout, int size, float* mean, float* scale) {
  float32x4_t vmean0 = vdupq_n_f32(mean[0]);
  float32x4_t vmean1 = vdupq_n_f32(mean[1]);
  float32x4_t vmean2 = vdupq_n_f32(mean[2]);
  float32x4_t vscale0 = vdupq_n_f32(1.f / scale[0]);
  float32x4_t vscale1 = vdupq_n_f32(1.f / scale[1]);
  float32x4_t vscale2 = vdupq_n_f32(1.f / scale[2]);

  float* dout_c0 = dout;
  float* dout_c1 = dout + size;
  float* dout_c2 = dout + size * 2;

  int i = 0;
  for (; i < size - 3; i += 4) {
    float32x4x3_t vin3 = vld3q_f32(din);
    float32x4_t vsub0 = vsubq_f32(vin3.val[0], vmean0);
    float32x4_t vsub1 = vsubq_f32(vin3.val[1], vmean1);
    float32x4_t vsub2 = vsubq_f32(vin3.val[2], vmean2);
    float32x4_t vs0 = vmulq_f32(vsub0, vscale0);
    float32x4_t vs1 = vmulq_f32(vsub1, vscale1);
    float32x4_t vs2 = vmulq_f32(vsub2, vscale2);
    vst1q_f32(dout_c0, vs0);
    vst1q_f32(dout_c1, vs1);
    vst1q_f32(dout_c2, vs2);

    din += 12;
    dout_c0 += 4;
    dout_c1 += 4;
    dout_c2 += 4;
  }
  for (; i < size; i++) {
    *(dout_c0++) = (*(din++) - mean[0]) * scale[0];
    *(dout_c0++) = (*(din++) - mean[1]) * scale[1];
    *(dout_c0++) = (*(din++) - mean[2]) * scale[2];
  }
}

//void neon_mean_scale(
//    const float* din, float* dout, int size, float* mean, float* scale) {
//  for (int i = 0; i < size; i++) {
//    dout[i * 3 + 0] = (din[i * 3 + 0] - mean[0]) * scale[0];
//    dout[i * 3 + 1] = (din[i * 3 + 1] - mean[1]) * scale[1];
//    dout[i * 3 + 2] = (din[i * 3 + 2] - mean[2]) * scale[2];
//  }
//}

void pre_process(const cv::Mat& img,
                 int width,
                 int height,
                 Tensor dstTensor,
                 float* means,
                 float* scales) {
  cv::Mat rgb_img;
  cv::cvtColor(img, rgb_img, cv::COLOR_BGR2RGB);
  cv::resize(rgb_img, rgb_img, cv::Size(width, height), 0.f, 0.f);
  cv::Mat imgf;
  rgb_img.convertTo(imgf, CV_32FC3, 1 / 255.f);
  const float* dimg = reinterpret_cast<const float*>(imgf.data);
  float* data = dstTensor.mutable_data<float>();
  neon_mean_scale(dimg, data, width * height, means, scales);
}

//void RunModel(std::string model_file,
//              std::string img_path,
//              const std::vector<std::string>& labels,
//              const float confidence_th,
//              int width,
//              int height) {
////  // 1. Set MobileConfig
//  MobileConfig config;
//  config.set_model_from_file(model_file);
//
//  // 2. Create PaddlePredictor by MobileConfig
//  std::shared_ptr<PaddlePredictor> predictor =
//      CreatePaddlePredictor<MobileConfig>(config);
//
//  // 3. Prepare input data from image
//  std::unique_ptr<Tensor> input_tensor(std::move(predictor->GetInput(0)));
//  input_tensor->Resize({1, 3, height, width});
//  auto* data = input_tensor->mutable_data<float>();
//  // read img and pre-process
//  cv::Mat img = imread(img_path, cv::IMREAD_COLOR);
//  //   pre_process(img, width, height, data);
//  float means[3] = {0.485f, 0.456f, 0.406f};
//  float scales[3] = {0.229f, 0.224f, 0.225f};
//  pre_process(img, width, height, *input_tensor, means, scales);
//
//  // 4. Run predictor
//  predictor->Run();
//
//  // 5. Get output and post process
//  std::unique_ptr<const Tensor> output_tensor(
//      std::move(predictor->GetOutput(0)));
//  auto* outptr = output_tensor->data<float>();
//  auto shape_out = output_tensor->shape();
//  int64_t cnt = 1;
//  for (auto& i : shape_out) {
//    cnt *= i;
//  }
//  print_above_threshold(outptr, cnt, confidence_th, labels);
//}


@interface TrImageClassifyer() {
    std::shared_ptr<PaddlePredictor> predictor;
    std::vector<std::string> labels;
}

@property(nonatomic) bool flag_init;
@property(nonatomic) std::string model_file;
@property(nonatomic) std::string label_file;
@property(nonatomic) Mat cvimg;
// 串行队列
//@property(nonatomic) dispatch_queue_t serialQueue;

@end

@implementation TrImageClassifyer

- (instancetype)init {
    if (self = [super init]) {
        self.flag_init = false;
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"TrImageClassifyKit" withExtension:@"bundle"];
        // config path
        NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
        NSString *modelPath = [bundle pathForResource:@"models/pdlite_model.nb" ofType: nil];
        NSString *labelPath = [bundle pathForResource:@"labels/labels.txt" ofType: nil];
        
        self.model_file = [modelPath UTF8String];
        self.label_file = [labelPath UTF8String];
        
        /// 初始化队列
        //        self.serialQueue = dispatch_queue_create("com.tr.imageclassifyer", DISPATCH_QUEUE_SERIAL);
        
        // 加载标签文件
        std::ifstream ifs(self.label_file);
        std::string line;
        while (getline(ifs, line)) {
            labels.push_back(line);
        }
        ifs.close();
        //
        // 初始化预测器
        MobileConfig config;
        config.set_model_from_file(self.model_file);
        predictor = CreatePaddlePredictor<MobileConfig>(config);
        
        self.flag_init = true;
    }
    return self;
}

/// 返回标签文件，数组返回
- (NSArray<NSString *> *)getLabels {
    NSMutableArray *labelArray = [NSMutableArray array];
    for (const std::string& label : labels) {
        NSString *nsLabel = [NSString stringWithUTF8String:label.c_str()];
        [labelArray addObject:nsLabel];
    }
    return [labelArray copy];
}

- (void)dealloc {
    predictor.reset();
    predictor = nil;
}

/// 开始图片分类
- (ClassificationResult)classifyImage:(UIImage *)image {
    ClassificationResult result = {-1, -1.0f}; // 默认值
    if (!self.flag_init) {
        NSLog(@"[Debug] Pipeline not initialized");// 返回错误
        return result;
    }
    
    // 使用dispatch_sync在串行队列中同步执行
//    __block int result = -1;
    //    dispatch_async(self.serialQueue, ^{
    try {
        int height =  224;
        int width = 224;
        float confidence_th = 0.8;
        
        // 转换UIImage到Mat
        Mat originMat;
        UIImageToMat(image, originMat);
        if (originMat.empty()) {
            NSLog(@"[Debug] Failed to convert UIImage to Mat");
            return result;
        }
        //            NSLog(@"[Debug] Original image size: %dx%d, channels: %d", originMat.cols, originMat.rows, originMat.channels());
        
        // 3. Prepare input data from image
        std::unique_ptr<Tensor> input_tensor(std::move(predictor->GetInput(0)));
        input_tensor->Resize({1, 3, width, height});
        auto* data = input_tensor->mutable_data<float>();
        
        float means[3] = {0.485f, 0.456f, 0.406f};
        float scales[3] = {0.229f, 0.224f, 0.225f};
        pre_process(originMat, width, height, *input_tensor, means, scales);
        
        // 4. Run predictor
        predictor->Run();
        
        // 5. Get output and post process
        std::unique_ptr<const Tensor> output_tensor(
                                                    std::move(predictor->GetOutput(0)));
        auto* outptr = output_tensor->data<float>();
        auto shape_out = output_tensor->shape();
        int64_t cnt = 1;
        for (auto& i : shape_out) {
            cnt *= i;
        }
        auto resultPair = print_above_threshold(outptr, cnt, confidence_th, labels);
        result.index = resultPair.first;
        result.score = resultPair.second;
        return result;
    } catch (const cv::Exception& e) {
        NSLog(@"[Debug] OpenCV exception: %s", e.what());
          return result;;
    } catch (const std::exception& e) {
        NSLog(@"[Debug] Exception during inference: %s", e.what());
        return result;;
    } catch (...) {
        NSLog(@"[Debug] Unknown exception during inference");
        return result;;
    }
}
    
    //
    //- (void)runWithImagePath:(NSString *)imagePath
    //          confidenceTh:(float)confidenceTh
    //              inputWidth:(int)inputWidth
    //             inputHeight:(int)inputHeight {
    //    if (!imagePath) {
    //        NSLog(@"[ERROR] model_file, image_path and label_file are necessary");
    //        return;
    //    }
    //    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"TrImageClassifyKit" withExtension:@"bundle"];
    //    // config path
    //    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    //    NSString *modelPath = [bundle pathForResource:@"models/pd_new_model.nb" ofType: nil];
    //    NSString *labelPath = [bundle pathForResource:@"labels/labels.txt" ofType: nil];
    //
    //    std::vector<std::string> labels;
    //    load_labels([labelPath UTF8String], &labels);
    //
    //    if (confidenceTh <= 0) {
    //        confidenceTh = 0.8;
    //    }
    //
    //    int height = inputHeight > 0 ? inputHeight : 224;
    //    int width = inputWidth > 0 ? inputWidth : 224;
    //
    //    RunModel([modelPath UTF8String], [imagePath UTF8String], labels, confidenceTh, 224, 224);
    //}
@end



//
//int main(int argc, char** argv) {
//  if (argc < 4) {
////    std::cerr << "[ERROR] usage: " << argv[0]
////              << " model_file image_path label_file\n";
//    exit(1);
//  }
//  printf("parameter:  model_file, image_path and label_file are necessary \n");
//  printf("parameter:  confidence_th, input_width,  input_height, are optional \n");
//  std::string model_file = argv[1];
//  std::string img_path = argv[2];
//  std::string label_file = argv[3];
//  std::vector<std::string> labels;
//  load_labels(label_file, &labels);
// float confidence_th = 0.8;
//  int height = 448;
//  int width = 448;
//  if (argc > 4) {
//      confidence_th = atoi(argv[4]);
//  }
//  if (argc > 6) {
//    width = atoi(argv[5]);
//    height = atoi(argv[6]);
//  }
//
//  RunModel(model_file, img_path, labels, confidence_th, width, height);
//  return 0;
//}

