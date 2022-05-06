//
//  Created by fgsoruco.
//
#import "CartoonFilterFactory.h"

@implementation CartoonFilterFactory

+ (void)processWhitPathType:(int)pathType
                 pathString:(NSString *)pathString
               imageScaling: (double) imageScaling
         blurringKernelSize: (int) blurringKernelSize
  adaptiveThresholdMaxValue: (int) adaptiveThresholdMaxValue
             adaptiveMethod: (int) adaptiveMethod
              thresholdType: (int) thresholdType
          adaptiveBlockSize: (int) adaptiveBlockSize
 adaptiveConstantSubtracted: (int) adaptiveConstantSubtracted
          bilateralDiameter: (int) bilateralDiameter
        bilateralSigmaColor: (int) bilateralSigmaColor
        bilateralSigmaSpace: (int) bilateralSigmaSpace
        bilateralBorderType: (int) bilateralBorderType
           termCriteriaType: (int) termCriteriaType
       termCriteriaMaxCount: (int) termCriteriaMaxCount
        termCriteriaEpsilon: (double) termCriteriaEpsilon
    pyrMeanShiftFilteringSp: (int) pyrMeanShiftFilteringSp
    pyrMeanShiftFilteringSr: (int) pyrMeanShiftFilteringSr
pyrMeanShiftFilteringMaxLevel: (int) pyrMeanShiftFilteringMaxLevel
                       data:(FlutterStandardTypedData *)data
                     result:(FlutterResult)result{
    
    switch (pathType) {
        case 1:
            result(cartoonFilterS(pathString,
                                  imageScaling,
                                  blurringKernelSize,
                                  adaptiveThresholdMaxValue,
                                  adaptiveMethod,
                                  thresholdType,
                                  adaptiveBlockSize,
                                  adaptiveConstantSubtracted,
                                  bilateralDiameter,
                                  bilateralSigmaColor,
                                  bilateralSigmaSpace,
                                  bilateralBorderType,
                                  termCriteriaType,
                                  termCriteriaMaxCount,
                                  termCriteriaEpsilon,
                                  pyrMeanShiftFilteringSp,
                                  pyrMeanShiftFilteringSr,
                                  pyrMeanShiftFilteringMaxLevel
                                  ));
            break;
        
        default:
            break;
    }
    
}

FlutterStandardTypedData * cartoonFilterS(NSString * pathString,
                                          double imageScaling,
                                          int blurringKernelSize,
                                          int adaptiveThresholdMaxValue,
                                          int adaptiveMethod,
                                          int thresholdType,
                                          int adaptiveBlockSize,
                                          int adaptiveConstantSubtracted,
                                          int bilateralDiameter,
                                          int bilateralSigmaColor,
                                          int bilateralSigmaSpace,
                                          int bilateralBorderType,
                                          int termCriteriaType,
                                          int termCriteriaMaxCount,
                                          double termCriteriaEpsilon,
                                          int pyrMeanShiftFilteringSp,
                                          int pyrMeanShiftFilteringSr,
                                          int pyrMeanShiftFilteringMaxLevel){
    

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
        cv::Mat srcBGR;
        cv::Mat srcGray;
        cv::Mat srcGrayBlur;
        cv::Mat srcEdge;
        cv::Mat srcColourPalette;
        cv::Mat srcFinalKmeans;
        cv::Mat srcFinal;
        cv::resize(src, srcResized, cv::Size(), imageScaling, imageScaling);
        cv::cvtColor(srcResized, srcBGR, cv::COLOR_BGRA2BGR);
        // Convert the image to Gray
        cv::cvtColor(srcResized, srcGray, cv::COLOR_BGR2GRAY);
        // Gray blur apply
        cv::medianBlur(srcGray, srcGrayBlur, blurringKernelSize);
        // Convert the image to edge
        cv::adaptiveThreshold(srcGrayBlur, srcEdge, (double) adaptiveThresholdMaxValue, adaptiveMethod, thresholdType, adaptiveBlockSize, (double) adaptiveConstantSubtracted);
        //color_quantization
//        colorQuantization(srcBGR, srcFinalKmeans, 9, 10);
        cv::TermCriteria termCriteria = cv::TermCriteria(termCriteriaType,
                                                         termCriteriaMaxCount,
                                                         termCriteriaEpsilon);
        cv::pyrMeanShiftFiltering(srcBGR,
                                  srcFinalKmeans,
                                  pyrMeanShiftFilteringSp,
                                  pyrMeanShiftFilteringSr,
                                  pyrMeanShiftFilteringMaxLevel,
                                  termCriteria);
        
        cv::Mat convertEdge;
        cv::bilateralFilter(srcEdge, convertEdge, bilateralDiameter, (double) bilateralSigmaColor,(double) bilateralSigmaSpace);
        cv::bitwise_and(srcFinalKmeans, srcFinalKmeans, srcFinal, convertEdge);
        
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
