//
//
//  Created by fgsoruco
//
#ifdef __cplusplus
#undef NO
#import <opencv2/opencv.hpp>
#endif
#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CartoonFilterFactory : NSObject


+ (void) processWhitPathType: (int) pathType
                    pathString: (NSString *) pathString
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
                    data: (FlutterStandardTypedData *) data
                    result: (FlutterResult) result;


@end

NS_ASSUME_NONNULL_END
