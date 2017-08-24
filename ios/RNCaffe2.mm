
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RNCaffe2.h"

#include "caffe2/core/flags.h"
#include "caffe2/core/init.h"
#include "caffe2/core/predictor.h"
#include "caffe2/utils/proto_utils.h"


@implementation RNCaffe2

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (void)LoadPBFile: (NSString *)filePath net:(caffe2::NetDef *)net {
  NSURL *netURL = [NSURL fileURLWithPath:filePath];
  NSData *data = [NSData dataWithContentsOfURL:netURL];
  const void *buffer = [data bytes];
  int len = (int)[data length];
  CAFFE_ENFORCE(net->ParseFromArray(buffer, len));
}

- (caffe2::Predictor *)getPredictor: (NSString *)init_net_path predict_net_path:(NSString *)predict_net_path {
  caffe2::NetDef init_net, predict_net;
  [self LoadPBFile:init_net_path net:&init_net];
  [self LoadPBFile:predict_net_path net:&predict_net];
  auto predictor = new caffe2::Predictor(init_net, predict_net);
  init_net.set_name("InitNet");
  predict_net.set_name("PredictNet");
  return predictor;
}

- (NSString*)predictWithImage: (UIImage *)image predictor:(caffe2::Predictor *)predictor classes:(NSArray*)classes{
  cv::Mat src_img, bgr_img;

  UIImageToMat(image, src_img);
  // needs to convert to BGR because the image loaded from UIImage is in RGBA
  cv::cvtColor(src_img, bgr_img, CV_RGBA2BGR);

  size_t height = CGImageGetHeight(image.CGImage);
  size_t width = CGImageGetWidth(image.CGImage);

  caffe2::TensorCPU input;

  // Reasonable dimensions to feed the predictor.
  const int predHeight = 256;
  const int predWidth = 256;
  const int crops = 1;
  const int channels = 3;
  const int size = predHeight * predWidth;
  const float hscale = ((float)height) / predHeight;
  const float wscale = ((float)width) / predWidth;
  const float scale = std::min(hscale, wscale);
  std::vector<float> inputPlanar(crops * channels * predHeight * predWidth);

  // Scale down the input to a reasonable predictor size.
  for (auto i = 0; i < predHeight; ++i) {
    const int _i = (int) (scale * i);
    //printf("+\n");
    for (auto j = 0; j < predWidth; ++j) {
      const int _j = (int) (scale * j);
      inputPlanar[i * predWidth + j + 0 * size] = (float) bgr_img.data[(_i * width + _j) * 3 + 0];
      inputPlanar[i * predWidth + j + 1 * size] = (float) bgr_img.data[(_i * width + _j) * 3 + 1];
      inputPlanar[i * predWidth + j + 2 * size] = (float) bgr_img.data[(_i * width + _j) * 3 + 2];
    }
  }

  input.Resize(std::vector<int>({crops, channels, predHeight, predWidth}));
  input.ShareExternalPointer(inputPlanar.data());

  caffe2::Predictor::TensorVector input_vec{&input};
  caffe2::Predictor::TensorVector output_vec;
  predictor->run(input_vec, &output_vec);

  float max_value = 0;
  int best_match_index = -1;
  for (auto output : output_vec) {
    for (auto i = 0; i < output->size(); ++i) {
      float val = output->template data<float>()[i];
      if(val > 0.001) {
        //printf("%i: %s : %f\n", i, imagenet_classes[i], val);
        if(val>max_value) {
          max_value = val;
          best_match_index = i;
        }
      }
    }
  }

  return classes[best_match_index];
}


RCT_EXPORT_METHOD(classifyImage:(NSString *)imageName
                  initModel:(NSString *)initModel
                  predictModel:(NSString *)predictModel
                  classes:(NSArray *)classes
                  callback:(RCTResponseSenderBlock)callback)
{
  NSString *init_net_path = [NSBundle.mainBundle pathForResource:initModel ofType:@"pb"];
  NSString *predict_net_path = [NSBundle.mainBundle pathForResource:predictModel ofType:@"pb"];

  caffe2::Predictor *predictor = [self getPredictor:init_net_path predict_net_path:predict_net_path];

  UIImage *image = [UIImage imageNamed:imageName];
  NSString *label = [self predictWithImage:image predictor:predictor classes:classes];

  // This is to allow us to use memory leak checks.
  google::protobuf::ShutdownProtobufLibrary();

  callback(@[[NSNull null], label]);
}


RCT_EXPORT_METHOD(predict:(NSArray *)inpupData
                  initModel:(NSString *)initModel
                  predictModel:(NSString *)predictModel
                  callback:(RCTResponseSenderBlock)callback)
{
  NSString *init_net_path = [NSBundle.mainBundle pathForResource:initModel ofType:@"pb"];
  NSString *predict_net_path = [NSBundle.mainBundle pathForResource:predictModel ofType:@"pb"];

  caffe2::Predictor *predictor = [self getPredictor:init_net_path predict_net_path:predict_net_path];

  UIImage *image = [UIImage imageNamed:imageName];
  NSArray *outputData = [self predictWithImage:image predictor:predictor classes:classes];

  // This is to allow us to use memory leak checks.
  google::protobuf::ShutdownProtobufLibrary();

  callback(@[[NSNull null], outputData]);
}


@end
