//
//  Created by fgsoruco.
//
#import "CartoonFilterFactory.h"

@implementation CartoonFilterFactory

+ (void)processWhitPathType:(int)pathType
                 pathString:(NSString *)pathString
               imageScaling: (double) imageScaling
         blurringKernelSize: (int) blurringKernelSize
                    lowEdge: (double) lowEdge
                   highEdge: (double) highEdge
                  edgeKSize: (int) edgeKSize
         maskThresholdValue: (double) maskThresholdValue
      maskThresholdMaxValue: (double) maskThresholdMaxValue
          maskThresholdType: (int) maskThresholdType
  colorQuantizationDiameter: (int) colorQuantizationDiameter
           smoothlyDiameter: (int) smoothlyDiameter
         smoothlySigmaColor: (double) smoothlySigmaColor
         smoothlySigmaSpace: (double) smoothlySigmaSpace
         smoothlyBorderType: (int) smoothlyBorderType
                       data:(FlutterStandardTypedData *)data
                     result:(FlutterResult)result{
    
    switch (pathType) {
        case 1:
            result(cartoonFilterS(pathString,
                                  imageScaling,
                                  blurringKernelSize,
                                  lowEdge,
                                  highEdge,
                                  edgeKSize,
                                  maskThresholdValue,
                                  maskThresholdMaxValue,
                                  maskThresholdType,
                                  colorQuantizationDiameter,
                                  smoothlyDiameter,
                                  smoothlySigmaColor,
                                  smoothlySigmaSpace,
                                  smoothlyBorderType
                                  ));
            break;
        
        default:
            break;
    }
    
}

FlutterStandardTypedData * cartoonFilterS(NSString * pathString,
                                          double imageScaling,
                                          int blurringKernelSize,
                                          double lowEdge,
                                          double highEdge,
                                          int edgeKSize,
                                          double maskThresholdValue,
                                          double maskThresholdMaxValue,
                                          int maskThresholdType,
                                          int colorQuantizationDiameter,
                                          int smoothlyDiameter,
                                          double smoothlySigmaColor,
                                          double smoothlySigmaSpace,
                                          int smoothlyBorderType){
    

    CGColorSpaceRef colorSpace;
    const char * suffix;
    int bytesInFile;
    const char * command;
    std::vector<uint8_t> fileData;
    bool puedePasar = false; 
    FlutterStandardTypedData* resultado;
    
    
    command = [pathString cStringUsingEncoding:NSUTF8StringEncoding];
    
    FILE* file = fopen(command, "rb");
    fseek(file, 0, SEEK_END);
    bytesInFile = (int) ftell(file);
    fseek(file, 0, SEEK_SET);
    std::vector<uint8_t> file_data(bytesInFile);
    fread(file_data.data(), 1, bytesInFile, file);
    fclose(file);
    
    fileData = file_data;
    
    NSData *imgOriginal = [NSData dataWithBytes: file_data.data()
                                   length: bytesInFile];
    
    
    suffix = strrchr(command, '.');
    if (!suffix || suffix == command) {
        suffix = "";
    }
    
    if (strcasecmp(suffix, ".png") == 0 || strcasecmp(suffix, ".jpg") == 0 || strcasecmp(suffix, ".jpeg") == 0) {
        puedePasar = true;
    }
    
    
    if (puedePasar) {
        
        
        CFDataRef file_data_ref = CFDataCreateWithBytesNoCopy(NULL, fileData.data(),
                                                              bytesInFile,
                                                              kCFAllocatorNull);
        
        CGDataProviderRef image_provider = CGDataProviderCreateWithCFData(file_data_ref);
        
        CGImageRef image = nullptr;
        if (strcasecmp(suffix, ".png") == 0) {
            image = CGImageCreateWithPNGDataProvider(image_provider, NULL, true,
                                                     kCGRenderingIntentDefault);
        } else if ((strcasecmp(suffix, ".jpg") == 0) ||
                   (strcasecmp(suffix, ".jpeg") == 0)) {
            image = CGImageCreateWithJPEGDataProvider(image_provider, NULL, true,
                                                      kCGRenderingIntentDefault);
        }
        
        colorSpace = CGImageGetColorSpace(image);
        CGFloat cols = CGImageGetWidth(image);
        CGFloat rows = CGImageGetHeight(image);
        
        cv::Mat src(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
        
        CGContextRef contextRef = CGBitmapContextCreate(src.data,                 // Pointer to  data
                                                         cols,                       // Width of bitmap
                                                         rows,                       // Height of bitmap
                                                         8,                          // Bits per component
                                                         src.step[0],              // Bytes per row
                                                         colorSpace,                 // Colorspace
                                                         kCGImageAlphaNoneSkipLast |
                                                         kCGBitmapByteOrderDefault); // Bitmap info flags
        CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image);
        CGContextRelease(contextRef);
        CFRelease(image);
        CFRelease(image_provider);
        CFRelease(file_data_ref);
        
        
        cv::Mat dst;
        cv::Mat srcResized;
        cv::Mat srcGray;
        cv::Mat srcGrayBlur;
        cv::Mat srcEdge;
        cv::Mat srcMask;
        cv::Mat srcCartoon;
        cv::Mat srcFinal;
        cv::resize(src, srcResized, cv::Size(), imageScaling, imageScaling);
        cv::cvtColor(srcResized, srcCartoon, cv::COLOR_BGRA2BGR, 0);
        // Convert the image to Gray
        cv::cvtColor(srcResized, srcGray, cv::COLOR_BGR2GRAY);
        // Gray blur apply
        cv::medianBlur(srcGray, srcGrayBlur, blurringKernelSize);
        // Convert the image to edge
        cv::Canny(srcGrayBlur, srcEdge, lowEdge, highEdge, edgeKSize);
        // create mask
        cv::threshold(srcEdge, srcMask, maskThresholdValue, maskThresholdMaxValue, maskThresholdType);
        cv::cvtColor(srcMask, srcMask, cv::COLOR_GRAY2BGR);
        //color_quantization cartoon
        
        for (int count = 1; count <= colorQuantizationDiameter; ++count){
            cv::Mat tempCartoon;
            cv::bilateralFilter(srcCartoon, tempCartoon, smoothlyDiameter, smoothlySigmaColor, smoothlySigmaSpace, smoothlyBorderType);
            cv::cvtColor(tempCartoon, srcCartoon, cv::COLOR_BGRA2BGR, 0);
        }

        cv::bitwise_and(srcCartoon, srcMask, srcFinal);
        
        NSData *data = [NSData dataWithBytes:srcFinal.data length:srcFinal.elemSize()*srcFinal.total()];
        
        if (srcFinal.elemSize() == 1) {
              colorSpace = CGColorSpaceCreateDeviceGray();
          } else {
              colorSpace = CGColorSpaceCreateDeviceRGB();
          }
          CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
          // Creating CGImage from cv::Mat
          CGImageRef imageRef = CGImageCreate(srcFinal.cols,                                 //width
                                              srcFinal.rows,                                 //height
                                             8,                                          //bits per component
                                             8 * srcFinal.elemSize(),                       //bits per pixel
                                              srcFinal.step[0],                            //bytesPerRow
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
        
        NSData* imgConvert;
        
        if (strcasecmp(suffix, ".png") == 0) {
            imgConvert = UIImagePNGRepresentation(finalImage);
        } else if ((strcasecmp(suffix, ".jpg") == 0) ||
                   (strcasecmp(suffix, ".jpeg") == 0)) {
            imgConvert = UIImageJPEGRepresentation(finalImage, 1);
        }
        
        
        resultado = [FlutterStandardTypedData typedDataWithBytes: imgConvert];
        
    } else {
        resultado = [FlutterStandardTypedData typedDataWithBytes: imgOriginal];
    }
    return resultado;
}

int colorQuantization( cv::Mat &inputImg, cv::Mat &outputImg, int kValue, int attempts) {
    if (inputImg.empty())
           return -1;
       if (attempts <= 0)
           return -1;
    
    int width = inputImg.cols;
    int height = inputImg.rows;
    int srcChannel = inputImg.channels();
    int sampleCount = width * height;
    
    cv::Mat samplesImg = inputImg.reshape(1, sampleCount);//every pixel is a sample
    cv::Mat data;
    samplesImg.convertTo(data, CV_32F);
    cv::Mat labels;
    cv::Mat centers;
    //K-Means
    cv::TermCriteria termCriteria = cv::TermCriteria(cv::TermCriteria::EPS + cv::TermCriteria::COUNT, 5, 0.1);
    
    cv::kmeans(data, kValue, labels, termCriteria, attempts, cv::KMEANS_PP_CENTERS, centers);
    //create a color map
      std::vector<cv::Scalar> colorMaps;
      uchar b, g, r;;
      //clusterCount is equal to centers.rows
      for (int i = 0; i < centers.rows; i++)
      {
          b = (uchar)centers.at<float>(i, 0);
          g = (uchar)centers.at<float>(i, 1);
          r = (uchar)centers.at<float>(i, 2);
          colorMaps.push_back(cv::Scalar(b, g, r));
      }
    // Show  result
    int index = 0;
    outputImg = cv::Mat::zeros(inputImg.size(), inputImg.type());
    uchar *ptr=NULL;
    int *label = NULL;
    for (int row = 0; row < height; row++) {
        ptr = outputImg.ptr<uchar>(row);
        for (int col = 0; col < width; col++) {
            index = row * width + col;
            label = labels.ptr<int>(index);
            *(ptr + col * 3) = colorMaps[*label][0];
            *(ptr + col * 3 + 1) = colorMaps[*label][1];
            *(ptr + col * 3 + 2) = colorMaps[*label][2];
        }
    }
    return 0;
}

@end
