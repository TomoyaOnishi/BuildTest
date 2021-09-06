//
//  BodyTrackingView.swift
//  Healthcare
//
//  Created by Shin on 2021/06/06.
//

import SwiftUI
import Vision

struct BodyTrackingView: View {
    
    private let videoCapture = VideoCapture()
    @State private var currentFrame: CGImage?
    @State private var imageSize = CGSize.zero
    @State private var previewImage = UIImage()
    
    var body: some View {
        GeometryReader { bodyView in
            VStack {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: bodyView.size.width, height: bodyView.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
        }.onAppear(perform: {
            setupAndBeginCapturingVideoFrames()
        }).onDisappear(perform: {
            videoCapture.stopCapturing {
            }
        })
    }
    
    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.videoCaptureHandler = { (videoCapture, capturedImage) in

                guard let image = capturedImage else {
                    fatalError("Captured image is null")
                }

                currentFrame = image

                estimation(image)
            }

            self.videoCapture.startCapturing()
        }
    }
    
    private func estimation(_ cgImage:CGImage) {
        imageSize = CGSize(width: cgImage.width, height: cgImage.height)

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)

        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
        }
    }

    private func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedPointsObservation] else { return }

        if observations.count == 0 {
            guard let currentFrame = self.currentFrame else {
                return
            }
            let image = UIImage(cgImage: currentFrame)
            DispatchQueue.main.async {
                previewImage = image
            }
        } else {
            let points = observations.map { (observation) -> [CGPoint] in
                let ps = processObservation(observation)
                return ps ?? []
            }

            let flatten = points.flatMap{$0}

            guard let image = currentFrame?.drawPoints(points: flatten) else { return }
            DispatchQueue.main.async {
                previewImage = image
            }
        }

    }

    func processObservation(_ observation: VNRecognizedPointsObservation) -> [CGPoint]? {

        // Retrieve all torso points.
        guard let recognizedPoints =
                try? observation.recognizedPoints(forGroupKey: VNRecognizedPointGroupKey.all) else {
            return []
        }


        let imagePoints: [CGPoint] = recognizedPoints.values.compactMap {
            guard $0.confidence > 0 else { return nil }

            return VNImagePointForNormalizedPoint($0.location,
                                                  Int(imageSize.width),
                                                  Int(imageSize.height))
        }

        return imagePoints
    }
}

struct BodyTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        BodyTrackingView()
    }
}
