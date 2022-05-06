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
                    data: (FlutterStandardTypedData *) data
                    result: (FlutterResult) result;


@end

NS_ASSUME_NONNULL_END
