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
                    lowEdge: Double,
                    highEdge: Double,
                    edgeKSize: Int,
                    maskThresholdValue: Double,
                    maskThresholdMaxValue: Double,
                    maskThresholdType:Int,
                    colorQuantizationDiameter: Int,
                    smoothlyDiameter:Int,
                    smoothlySigmaColor: Double,
                    smoothlySigmaSpace: Double,
                    smoothlyBorderType: Int,
                    data: ByteArray,
                    result: MethodChannel.Result) {
            when (pathType) {
                1 -> result.success(cartoonFilterS(pathString,
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
                ))
            }
        }

        private fun cartoonFilterS(pathString: String,
                                   imageScaling: Double,
                                   blurringKernelSize: Int,
                                   lowEdge: Double,
                                   highEdge: Double,
                                   edgeKSize: Int,
                                   maskThresholdValue: Double,
                                   maskThresholdMaxValue: Double,
                                   maskThresholdType:Int,
                                   colorQuantizationDiameter: Int,
                                   smoothlyDiameter:Int,
                                   smoothlySigmaColor: Double,
                                   smoothlySigmaSpace: Double,
                                   smoothlyBorderType: Int): ByteArray? {
            val inputStream: InputStream = FileInputStream(pathString.replace("file://", ""))
            val data: ByteArray = inputStream.readBytes()
            try {
                var byteArray = ByteArray(0)
                val filename = pathString.replace("file://", "")
                val src = Imgcodecs.imread(filename)
                val srcResized = Mat()
                val srcGray = Mat()
                val srcGrayBlur = Mat()
                val srcEdge = Mat()
                val srcMask = Mat()
                val srcCartoon = Mat()

                val srcFinal = Mat()

                // resize raw image
                Imgproc.resize(src, srcResized, Size(), imageScaling, imageScaling);
                Imgproc.cvtColor(srcResized, srcCartoon, Imgproc.COLOR_BGRA2BGR, 0)
                // convert to gray
                Imgproc.cvtColor(srcResized, srcGray, Imgproc.COLOR_RGB2GRAY)
                // blur image
                Imgproc.medianBlur(srcGray, srcGrayBlur, blurringKernelSize)
                // detect egde
                Imgproc.Canny(srcGrayBlur , srcEdge, lowEdge, highEdge, edgeKSize)
                // create mask
                Imgproc.threshold(srcEdge, srcMask, maskThresholdValue,maskThresholdMaxValue, maskThresholdType)
                Imgproc.cvtColor(srcMask, srcMask, Imgproc.COLOR_GRAY2BGR)
                // cartoon
                val iterator = (1..colorQuantizationDiameter).iterator()

                iterator.forEach {
                    val tempCartoon = Mat()
                    Imgproc.bilateralFilter(srcCartoon, tempCartoon, smoothlyDiameter, smoothlySigmaColor, smoothlySigmaSpace, smoothlyBorderType)
                    Imgproc.cvtColor(tempCartoon, srcCartoon, Imgproc.COLOR_BGRA2BGR, 0)
                }

                Core.bitwise_and(srcCartoon, srcMask, srcFinal)

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