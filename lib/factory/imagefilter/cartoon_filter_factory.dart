/* 
 * Copyright (c) 2021 fgsoruco.
 * See LICENSE for more details.
 */
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/factory/utils.dart';

///Class for process [CartoonFilter]
class CartoonFilterFactory {
  static const platform = const MethodChannel('opencv_4');

  static Future<Uint8List?> cartoonFilter({
    required CVPathFrom pathFrom,
    required String pathString,
    required double imageScaling,
    required int blurringKernelSize,
    required int adaptiveThresholdMaxValue,
    required int adaptiveMethod,
    required int thresholdType,
    required int adaptiveBlockSize,
    required int adaptiveConstantSubtracted,
    required int bilateralDiameter,
    required int bilateralSigmaColor,
    required int bilateralSigmaSpace,
    required int bilateralBorderType,
    required int termCriteriaType,
    required int termCriteriaMaxCount,
    required double termCriteriaEpsilon,
    required int pyrMeanShiftFilteringSp,
    required int pyrMeanShiftFilteringSr,
    required int pyrMeanShiftFilteringMaxLevel,
  }) async {
    File _file;
    Uint8List _fileAssets;

    Uint8List? result;

    int diameterTemp = (bilateralDiameter >= 0)
        ? (bilateralDiameter == 0)
            ? 1
            : bilateralDiameter
        : -1 * bilateralDiameter;
    int borderTypeTemp = Utils.verBorderType(bilateralBorderType);

    switch (pathFrom) {
      case CVPathFrom.GALLERY_CAMERA:
        result = await platform.invokeMethod('cartoonFilter', {
          "pathType": 1,
          "pathString": pathString,
     "imageScaling": imageScaling,
          "blurringKernelSize":blurringKernelSize,
"adaptiveThresholdMaxValue":adaptiveThresholdMaxValue,
"adaptiveMethod":adaptiveMethod,
"thresholdType":thresholdType,
"adaptiveBlockSize":adaptiveBlockSize,
"adaptiveConstantSubtracted":adaptiveConstantSubtracted,
"bilateralDiameter":bilateralDiameter,
"bilateralSigmaColor":bilateralSigmaColor,
"bilateralSigmaSpace":bilateralSigmaSpace,
"bilateralBorderType":bilateralBorderType,
"termCriteriaType": termCriteriaType,
"termCriteriaMaxCount": termCriteriaMaxCount,
"termCriteriaEpsilon": termCriteriaEpsilon,
"pyrMeanShiftFilteringSp": pyrMeanShiftFilteringSp,
"pyrMeanShiftFilteringSr": pyrMeanShiftFilteringSr,
"pyrMeanShiftFilteringMaxLevel": pyrMeanShiftFilteringMaxLevel,
          "data": Uint8List(0),
        });
        break;
      case CVPathFrom.URL:
        _file = await DefaultCacheManager().getSingleFile(pathString);
        result = await platform.invokeMethod('cartoonFilter', {
          "pathType": 2,
          "pathString": '',
     "imageScaling": imageScaling,
          "blurringKernelSize":blurringKernelSize,
"adaptiveThresholdMaxValue":adaptiveThresholdMaxValue,
"adaptiveMethod":adaptiveMethod,
"thresholdType":thresholdType,
"adaptiveBlockSize":adaptiveBlockSize,
"adaptiveConstantSubtracted":adaptiveConstantSubtracted,
"bilateralDiameter":bilateralDiameter,
"bilateralSigmaColor":bilateralSigmaColor,
"bilateralSigmaSpace":bilateralSigmaSpace,
"bilateralBorderType":bilateralBorderType,
"termCriteriaType": termCriteriaType,
"termCriteriaMaxCount": termCriteriaMaxCount,
"termCriteriaEpsilon": termCriteriaEpsilon,
"pyrMeanShiftFilteringSp": pyrMeanShiftFilteringSp,
"pyrMeanShiftFilteringSr": pyrMeanShiftFilteringSr,
"pyrMeanShiftFilteringMaxLevel": pyrMeanShiftFilteringMaxLevel,
          "data": await _file.readAsBytes(),
        });

        break;
      case CVPathFrom.ASSETS:
        _fileAssets = await Utils.imgAssets2Uint8List(pathString);
        result = await platform.invokeMethod('cartoonFilter', {
          "pathType": 3,
          "pathString": '',
     "imageScaling": imageScaling,
          "blurringKernelSize":blurringKernelSize,
"adaptiveThresholdMaxValue":adaptiveThresholdMaxValue,
"adaptiveMethod":adaptiveMethod,
"thresholdType":thresholdType,
"adaptiveBlockSize":adaptiveBlockSize,
"adaptiveConstantSubtracted":adaptiveConstantSubtracted,
"bilateralDiameter":bilateralDiameter,
"bilateralSigmaColor":bilateralSigmaColor,
"bilateralSigmaSpace":bilateralSigmaSpace,
"bilateralBorderType":bilateralBorderType,
"termCriteriaType": termCriteriaType,
"termCriteriaMaxCount": termCriteriaMaxCount,
"termCriteriaEpsilon": termCriteriaEpsilon,
"pyrMeanShiftFilteringSp": pyrMeanShiftFilteringSp,
"pyrMeanShiftFilteringSr": pyrMeanShiftFilteringSr,
"pyrMeanShiftFilteringMaxLevel": pyrMeanShiftFilteringMaxLevel,
          "data": _fileAssets,
        });
        break;
    }

    return result;
  }
}
