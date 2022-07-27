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
    required double lowEdge,
    required double highEdge,
    required int edgeKSize,
    required double maskThresholdValue,
    required double maskThresholdMaxValue,
    required int maskThresholdType,
    required int colorQuantizationDiameter,
    required int smoothlyDiameter,
    required double smoothlySigmaColor,
    required double smoothlySigmaSpace,
    required int smoothlyBorderType,
  }) async {
    File _file;
    Uint8List _fileAssets;

    Uint8List? result;

    switch (pathFrom) {
      case CVPathFrom.GALLERY_CAMERA:
        result = await platform.invokeMethod('cartoonFilter', {
          "pathType": 1,
          "pathString": pathString,
          "imageScaling": imageScaling,
          "blurringKernelSize":blurringKernelSize,
          "lowEdge":lowEdge,
          "highEdge":highEdge,
          "edgeKSize":edgeKSize,
          "maskThresholdValue":maskThresholdValue,
          "maskThresholdMaxValue":maskThresholdMaxValue,
          "maskThresholdType":maskThresholdType,
          "colorQuantizationDiameter":colorQuantizationDiameter,
          "smoothlyDiameter":smoothlyDiameter,
          "smoothlySigmaColor":smoothlySigmaColor,
          "smoothlySigmaSpace": smoothlySigmaSpace,
          "smoothlyBorderType": smoothlyBorderType,
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
          "lowEdge":lowEdge,
          "highEdge":highEdge,
          "edgeKSize":edgeKSize,
          "maskThresholdValue":maskThresholdValue,
          "maskThresholdMaxValue":maskThresholdMaxValue,
          "maskThresholdType":maskThresholdType,
          "colorQuantizationDiameter":colorQuantizationDiameter,
          "smoothlyDiameter":smoothlyDiameter,
          "smoothlySigmaColor":smoothlySigmaColor,
          "smoothlySigmaSpace": smoothlySigmaSpace,
          "smoothlyBorderType": smoothlyBorderType,
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
          "lowEdge":lowEdge,
          "highEdge":highEdge,
          "edgeKSize":edgeKSize,
          "maskThresholdValue":maskThresholdValue,
          "maskThresholdMaxValue":maskThresholdMaxValue,
          "maskThresholdType":maskThresholdType,
          "colorQuantizationDiameter":colorQuantizationDiameter,
          "smoothlyDiameter":smoothlyDiameter,
          "smoothlySigmaColor":smoothlySigmaColor,
          "smoothlySigmaSpace": smoothlySigmaSpace,
          "smoothlyBorderType": smoothlyBorderType,
          "data": _fileAssets,
        });
        break;
    }

    return result;
  }
}
