//
//  CustomVideoSource.swift
//  Healthcare
//
//  Created by T T on 2021/06/11.
//

import Foundation
import TwilioVideo
import Accelerate

class CustomVideoSource: NSObject, VideoSource {
    var sink: VideoSink?

    var isScreencast: Bool {
        return false
    }

    // Private variables
    var view: UIImage?
    var displayTimer: CADisplayLink?
    var willEnterForegroundObserver: NSObjectProtocol?
    var didEnterBackgroundObserver: NSObjectProtocol?

    // Constants
    static let kCaptureFrameRate = 50
    static let kCaptureScaleFactor: CGFloat = 1.0

    init(aView: UIImage = UIImage(named: "CoolingDownIcon")!) {
        sink = nil
        view = aView
    }

    func startCapture() {
        print("Start capturing.")

        startTimer()
        registerNotificationObservers()
    }

    func stopCapture() {
        print("Stop capturing.")

        unregisterNotificationObservers()
        invalidateTimer()
    }

    private func startTimer() {
        invalidateTimer()

        // Use a CADisplayLink timer so that our drawing is synchronized to the display vsync.

        displayTimer = CADisplayLink(target: self, selector: #selector(CustomVideoSource.captureView))
        displayTimer?.preferredFramesPerSecond = CustomVideoSource.kCaptureFrameRate
        displayTimer?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        displayTimer?.isPaused = UIApplication.shared.applicationState == UIApplication.State.background
    }

    private func invalidateTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }

    private func registerNotificationObservers() {
        let notificationCenter = NotificationCenter.default;

        willEnterForegroundObserver = notificationCenter.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                                     object: nil,
                                                                     queue: OperationQueue.main,
                                                                     using: { (Notification) in
                                                                        self.displayTimer?.isPaused = false;
                                                                     })

        didEnterBackgroundObserver = notificationCenter.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                                    object: nil,
                                                                    queue: OperationQueue.main,
                                                                    using: { (Notification) in
                                                                        self.displayTimer?.isPaused = true;
                                                                    })
    }

    private func unregisterNotificationObservers() {
        let notificationCenter = NotificationCenter.default

        if let willEnterForegroundObserver = willEnterForegroundObserver {
            notificationCenter.removeObserver(willEnterForegroundObserver)
        }
        if let didEnterBackgroundObserver = didEnterBackgroundObserver {
            notificationCenter.removeObserver(didEnterBackgroundObserver)
        }

        willEnterForegroundObserver = nil
        didEnterBackgroundObserver = nil
    }

    @objc func captureView( timer: CADisplayLink ) {

        let iValue = Int.random(in: 0 ... 9)

//        let img = UIImage(named: "\(iValue).png")
        let img: UIImage? = v.resized(toWidth: 400)


        if let deliverableImage = img {
            self.deliverCapturedImage(image: deliverableImage,
                                      orientation: VideoOrientation.right,
                                      timestamp: timer.timestamp)
        }
    }

    private func deliverCapturedImage(image: UIImage,
                                      orientation: VideoOrientation,
                                      timestamp: CFTimeInterval) {


        /*
         * Make a (deep) copy of the UIImage's underlying data. We do this by getting the CGImage, and its CGDataProvider.
         * In some cases, the bitmap's pixel format is not compatible with CVPixelBuffer and we need to repack the pixels.
         */
        guard let cgImage = image.cgImage else {
            return
        }

        let alphaInfo = cgImage.alphaInfo
        let tes = cgImage.bitmapInfo.rawValue & CGBitmapInfo.byteOrderMask.rawValue
        let byteOrderInfo = CGBitmapInfo(rawValue: tes)
        let dataProvider = cgImage.dataProvider
        let data = dataProvider?.data
        let baseAddress = CFDataGetBytePtr(data!)!
        /*
         * The underlying data is marked as immutable, but we are the sole owner and can do as we please.
         * Also, the CVPixelBuffer constructor will only accept a mutable pointer.
         */
        let mutableBaseAddress = UnsafeMutablePointer<UInt8>(mutating: baseAddress)
        var pixelFormat = PixelFormat.format32BGRA

        var imageBuffer = vImage_Buffer(data: mutableBaseAddress,
                                        height: vImagePixelCount(cgImage.height),
                                        width: vImagePixelCount(cgImage.width),
                                        rowBytes: cgImage.bytesPerRow)

        switch byteOrderInfo {
        case .byteOrder32Little:
            /*
             * Pixel format encountered on iOS simulators. Note: We have observed that pre-multiplied images
             * do not contain any transparent alpha, but still appear to be too dim. This appears to be a simulator only bug.
             * Without proper alpha information it is impossible to un-premultiply the data.
             */
            assert(alphaInfo == .premultipliedFirst || alphaInfo == .noneSkipFirst)
        case .byteOrder32Big:
            // Never encountered with snapshots on iOS, but maybe on macOS?
            assert(alphaInfo == .premultipliedFirst || alphaInfo == .noneSkipFirst)
            pixelFormat = PixelFormat.format32ARGB
        case .byteOrder16Little:
            assert(false)
        case .byteOrder16Big:
            assert(false)
        default:
//            pixelFormat = PixelFormat.format32ARGB

//            break
            /*
             * The pixels are formatted in the default order for CoreGraphics, which on iOS is kCVPixelFormatType_32RGBA.
             * This pixel format is defined by Core Video, but creating a buffer returns kCVReturnInvalidPixelFormat on an iOS device.
             * We will instead repack the memory from RGBA to BGRA, which is supported by Core Video (and Twilio Video).
             * Note: While UIImages captured on a device claim to have pre-multiplied alpha, the alpha channel is always opaque (0xFF).
             */
            assert(alphaInfo == .premultipliedLast || alphaInfo == .noneSkipLast)

            // Swap the red and blue channels.
            var permuteMap = [UInt8(2), UInt8(1), UInt8(0), UInt8(3)]
            vImagePermuteChannels_ARGB8888(&imageBuffer,
                                           &imageBuffer,
                                           &permuteMap,
                                           vImage_Flags(kvImageDoNotTile))
        }

        /*
         * We own the copied CFData which will back the CVPixelBuffer, thus the data's lifetime is bound to the buffer.
         * We will use a CVPixelBufferReleaseBytesCallback in order to release the CFData when the buffer dies.
         */
        let unmanagedData = Unmanaged<CFData>.passRetained(data!)
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreateWithBytes(nil,
                                                  cgImage.width,
                                                  cgImage.height,
                                                  pixelFormat.rawValue,
                                                  mutableBaseAddress,
                                                  cgImage.bytesPerRow,
                                                  { releaseContext, baseAddress in
                                                    let contextData = Unmanaged<CFData>.fromOpaque(releaseContext!)
                                                    contextData.release()
                                                  },
                                                  unmanagedData.toOpaque(),
                                                  nil,
                                                  &pixelBuffer)

        if let buffer = pixelBuffer {
            // Deliver a frame to the consumer.
            let frame = VideoFrame(timeInterval: timestamp,
                                   buffer: buffer,
                                   orientation: orientation)

            // The consumer retains the CVPixelBuffer and will own it as the buffer flows through the video pipeline.
            self.sink?.onVideoFrame(frame!)
        } else {
            print("Video source failed with status code: \(status).")
        }
    }

    func requestOutputFormat(_ outputFormat: VideoFormat) {
        if let sink = sink {
            sink.onVideoFormatRequest(outputFormat)
        }
    }
}

