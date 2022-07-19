package ar.fgsoruco.opencv4.factory.imagefilter

import android.util.Log
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import org.opencv.photo.Photo
import java.io.FileInputStream
import java.io.InputStream
import io.flutter.plugin.common.MethodChannel
import org.opencv.core.*

class CartoonFilterFactory {
    companion object {
        fun process(pathType: Int,
                    pathString: String,
                    imageScaling: Double,
                    blurringKernelSize: Int,
                    adaptiveThresholdMaxValue: Int,
                    adaptiveMethod: Int,
                    thresholdType: Int,
                    adaptiveBlockSize: Int,
                    adaptiveConstantSubtracted: Int,
                    bilateralDiameter:Int,
                    bilateralSigmaColor: Int,
                    bilateralSigmaSpace:Int,
                    bilateralBorderType: Int,
                    termCriteriaType: Int,
                    termCriteriaMaxCount: Int,
                    termCriteriaEpsilon: Double,
                    pyrMeanShiftFilteringSp: Int,
                    pyrMeanShiftFilteringSr: Int,
                    pyrMeanShiftFilteringMaxLevel: Int,
                    data: ByteArray,
                    result: MethodChannel.Result) {
            when (pathType) {
                1 -> result.success(cartoonFilterS(pathString,
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
                ))
            }
        }

        private fun cartoonFilterS(pathString: String,
                                   imageScaling: Double,
                                   blurringKernelSize: Int,
                                   adaptiveThresholdMaxValue: Int,
                                   adaptiveMethod: Int,
                                   thresholdType: Int,
                                   adaptiveBlockSize: Int,
                                   adaptiveConstantSubtracted: Int,
                                   bilateralDiameter:Int,
                                   bilateralSigmaColor: Int,
                                   bilateralSigmaSpace:Int,
                                   bilateralBorderType: Int,
                                   termCriteriaType: Int,
                                   termCriteriaMaxCount: Int,
                                   termCriteriaEpsilon: Double,
                                   pyrMeanShiftFilteringSp: Int,
                                   pyrMeanShiftFilteringSr: Int,
                                   pyrMeanShiftFilteringMaxLevel: Int): ByteArray? {
            val inputStream: InputStream = FileInputStream(pathString.replace("file://", ""))
            val data: ByteArray = inputStream.readBytes()
            try {
                var byteArray = ByteArray(0)
                val filename = pathString.replace("file://", "")
                val src = Imgcodecs.imread(filename)
                val srcResized = Mat()
                val srcBGR = Mat()
                val srcGray = Mat()
                val srcGrayBlur = Mat()
                val srcEdge = Mat()
                val convertEdge = Mat()
                val srcColourPalette = Mat()
                val srcFinalKmeans = Mat()
                val brighter = Mat()
                val srcFinal = Mat()
                Imgproc.resize(src, srcResized, Size(), imageScaling, imageScaling);
                Imgproc.cvtColor(srcResized, srcBGR, Imgproc.COLOR_BGRA2BGR)
                // cartoonize
                // Convert the image to Gray
                Imgproc.cvtColor(srcResized, srcGray, Imgproc.COLOR_BGR2GRAY)

                // Gray blur apply
                Imgproc.medianBlur(srcGray, srcGrayBlur, blurringKernelSize)

                // Convert the image to edge
                Imgproc.adaptiveThreshold(srcGrayBlur,
                        srcEdge,
                        adaptiveThresholdMaxValue.toDouble(),
                        adaptiveMethod,
                        thresholdType,
                        adaptiveBlockSize,
                        adaptiveConstantSubtracted.toDouble())

                //color_quantization
                val termCriteria = TermCriteria(termCriteriaType, termCriteriaMaxCount, termCriteriaEpsilon)
                Imgproc.pyrMeanShiftFiltering(srcBGR, srcFinalKmeans, pyrMeanShiftFilteringSp.toDouble(), pyrMeanShiftFilteringSr.toDouble(), pyrMeanShiftFilteringMaxLevel, termCriteria)

                Imgproc.bilateralFilter(srcEdge, convertEdge, bilateralDiameter, bilateralSigmaColor.toDouble(), bilateralSigmaSpace.toDouble(), bilateralBorderType)

                Core.bitwise_and(srcFinalKmeans, srcFinalKmeans, srcFinal, convertEdge)



                val matOfByte = MatOfByte()
                Imgcodecs.imencode(".jpg", srcFinal, matOfByte)
                byteArray = matOfByte.toArray()

                return byteArray
            } catch (e: java.lang.Exception) {
                println("OpenCV Error: $e")
                return data
            }

        }

    }
}