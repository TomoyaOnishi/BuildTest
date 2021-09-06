//
//  VideoCapture.swift
//  Healthcare
//
//  Created by Shin on 2021/06/06.
//

import AVFoundation
import CoreVideo
import UIKit
import VideoToolbox

class VideoCapture: NSObject {
    enum VideoCaptureError: Error {
        case captureSessionIsMissing
        case invalidInput
        case invalidOutput
        case unknown
    }
    
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    var videoCaptureHandler: ((VideoCapture, CGImage?) -> Void)?
    
    private(set) var cameraPostion = AVCaptureDevice.Position.front

    
    private let sessionQueue = DispatchQueue(
        label: "io.al03.pose-estimation-session-queue")

    public func flipCamera(completion: @escaping (Error?) -> Void) {
        sessionQueue.async {
            do {
                self.cameraPostion = self.cameraPostion == .back ? .front : .back

                self.captureSession.beginConfiguration()

                try self.setCaptureSessionInput()
                try self.setCaptureSessionOutput()

                self.captureSession.commitConfiguration()

                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

    public func setUpAVCapture(completion: @escaping (Error?) -> Void) {
        sessionQueue.async {
            do {
                try self.setUpAVCapture()
//                DispatchQueue.main.async {
                    completion(nil)
//                }
            } catch {
//                DispatchQueue.main.async {
                    completion(error)
//                }
            }
        }
    }

    private func setUpAVCapture() throws {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .vga640x480
        
        try setCaptureSessionInput()

        try setCaptureSessionOutput()

        captureSession.commitConfiguration()
    }

    private func setCaptureSessionInput() throws {

        guard let captureDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: AVMediaType.video,
            position: cameraPostion) else {
                throw VideoCaptureError.invalidInput
        }


        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }

        
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            throw VideoCaptureError.invalidInput
        }

        guard captureSession.canAddInput(videoInput) else {
            throw VideoCaptureError.invalidInput
        }
        captureSession.sessionPreset = .medium

        captureSession.addInput(videoInput)
    }

    private func setCaptureSessionOutput() throws {
        captureSession.outputs.forEach { output in
            captureSession.removeOutput(output)
        }

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)

        guard captureSession.canAddOutput(videoOutput) else {
            throw VideoCaptureError.invalidOutput
        }

        captureSession.addOutput(videoOutput)

        if let connection = videoOutput.connection(with: .video),
           connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = cameraPostion == .front
        }
    }


    public func startCapturing(completion completionHandler: (() -> Void)? = nil) {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }

            if let completionHandler = completionHandler {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }

    public func stopCapturing(completion completionHandler: (() -> Void)? = nil) {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }

            if let completionHandler = completionHandler {
                DispatchQueue.main.async {
                    completionHandler()
                }
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {

    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {

        if let pixelBuffer = sampleBuffer.imageBuffer {
            guard CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) == kCVReturnSuccess
                else {
                    return
            }

            var image: CGImage?

            VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
            
            DispatchQueue.main.sync {
                videoCaptureHandler?(self, image)
            }
        }
    }
}
