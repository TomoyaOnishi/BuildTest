//
//  VideoPageViewModel.swift
//  Healthcare
//
//  Created by T T on 2021/06/09.
//

import Foundation
import Combine
import TwilioVideo
import Vision
var v :UIImage = UIImage()
final class VideoPageViewModel: NSObject, ViewModelObject {

    // videoCapture
    private let videoCapture = VideoCapture()
    private var currentFrame: CGImage?
    private var imageSize = CGSize.zero

    let input: Input
    let output: Output
    @BindableObject private(set) var binding: Binding

    final class Input: InputObject {
        let onAppear = PassthroughSubject<Void, Never>()
        let onDisappear = PassthroughSubject<Void, Never>()

        let connect = PassthroughSubject<Void, Never>()
        let disconnect = PassthroughSubject<Void, Never>()
        let mic = PassthroughSubject<Void, Never>()

    }
    final class Output: OutputObject {
        @Published fileprivate(set) var room: Room?
        @Published fileprivate(set) var camera: CameraSource?
        @Published fileprivate(set) var localVideoTrack: LocalVideoTrack?
        @Published fileprivate(set) var localAudioTrack: LocalAudioTrack?
        @Published fileprivate(set) var remoteParticipant: RemoteParticipant?
        @Published fileprivate(set) var previewView: VideoView = VideoView(frame: .zero)
        @Published fileprivate(set) var remoteView: VideoView?
        @Published fileprivate(set) var viewSource: VideoSource?

        @Published fileprivate(set) var previewImage: UIImage = UIImage()

    }

    final class Binding: BindingObject {}

    private var cancellables = Set<AnyCancellable>()

    let videoRepository: IVideoRepository

    init(videoRepository: IVideoRepository = VideoRepositoryImpl()) {

        self.videoRepository = videoRepository
        self.input = Input()
        self.output = Output()
        self.binding = Binding()
        super.init()
        self.bindInputs()
        self.bindOutputs()
        self.request()
    }

    private func bindInputs() {
        self.input.onAppear.sink { [weak self] in
            guard let self = self else { return }
            self.setupAndBeginCapturingVideoFrames()

        }.store(in: &cancellables)

        self.input.onDisappear.sink { [weak self] in
            guard let self = self else { return }
            self.setupAndBeginCapturingVideoFrames()

        }.store(in: &cancellables)

        self.input.connect.sink { [weak self] in
            guard let self = self else { return }

            self.getToken(roomId: "TEST_ROOM_NAME", userId: "TEST_UID_\(UUID())") { token in
                if let token = token {
                    self.connect( accessToken: token)
                } else {
                    print("トークン取得失敗")
                }
            }
        }.store(in: &cancellables)

        self.input.disconnect.sink { [weak self] in
            guard let self = self else { return }
            self.disConnect()
        }.store(in: &cancellables)
    }
    private func bindOutputs() {
    }
    private func request() {
    }

    enum DataSource {
        case camera
        case custom
        case visionpose
    }

    deinit {
        videoCapture.stopCapturing {}

        self.output.camera?.stopCapture()
        self.output.camera = nil

    }
}

extension VideoPageViewModel {

    private func logMessage(messageText: String) {
        print(messageText)
    }

    private func getToken(roomId: String, userId: String, completion: @escaping (String?) -> Void) {
        self.videoRepository.getToken(roomId: roomId).sink { comp in

            switch comp {
            case .finished:
                break
            case .failure(_):
                completion(nil)
            }
        } receiveValue: { token in
            print(token)
            completion(token)
        }.store(in: &self.cancellables)

    }

    private func connect( accessToken: String) {

        //        let accessToken = getToken(roomName: roomName, userId: userId)

        self.prepareLocalMedia()

        let connectOptions = ConnectOptions(token: accessToken) { (builder) in

            // Use the local media that we prepared earlier.
            builder.audioTracks = self.output.localAudioTrack != nil ? [self.output.localAudioTrack!] : [LocalAudioTrack]()
            builder.videoTracks = self.output.localVideoTrack != nil ? [self.output.localVideoTrack!] : [LocalVideoTrack]()

            // Use the preferred audio codec
            if let preferredAudioCodec = TwilioVideoSettings.shared.audioCodec {
                builder.preferredAudioCodecs = [preferredAudioCodec]
            }

            // Use the preferred video codec
            if let preferredVideoCodec = TwilioVideoSettings.shared.videoCodec {
                builder.preferredVideoCodecs = [preferredVideoCodec]
            }

            // Use the preferred encoding parameters
            if let encodingParameters = TwilioVideoSettings.shared.getEncodingParameters() {
                builder.encodingParameters = encodingParameters
            }

            // Use the preferred signaling region
            if let signalingRegion = TwilioVideoSettings.shared.signalingRegion {
                builder.region = signalingRegion
            }

            // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
            // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.

            // Token作成でルーム情報を付与しているため不要
            //            builder.roomName = roomName
        }

        // Connect to the Room using the options we provided.
        self.output.room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)

        //        logMessage(messageText: "Attempting to connect to room \(roomName))")

        //        startPreview(dataSource: <#VideoPageViewModel.DataSource#>)
    }


    private func prepareLocalMedia() {


        // ローカルトラックとしてマイクの音声を取得する
        if (self.output.localAudioTrack == nil) {
            self.output.localAudioTrack = LocalAudioTrack(options: nil, enabled: true, name: "Microphone")

            if (self.output.localAudioTrack == nil) {
                logMessage(messageText: "Failed to create audio track")
            }
        }

        // ローカルのビデオトラック データソースは
        if (self.output.localVideoTrack == nil) {
            self.startPreview(dataSource: .camera)
        }
    }

    private func startPreview(dataSource: DataSource) {

        if PlatformUtils.isSimulator {
            return
        }

        switch dataSource {

        case .camera:
            let frontCamera = CameraSource.captureDevice(position: .front)
            let backCamera = CameraSource.captureDevice(position: .back)

            if (frontCamera != nil || backCamera != nil) {

                let options = CameraSourceOptions { (builder) in

                    // Track UIWindowScene events for the key window's scene.
                    // The example app disables multi-window support in the .plist (see UIApplicationSceneManifestKey).
                    builder.orientationTracker = UserInterfaceTracker(scene: UIApplication.shared.keyWindow!.windowScene!)

                }
                // Preview our local camera track in the local video preview view.
                self.output.camera = CameraSource(options: options, delegate: self)
                //            LocalVideoTrack(source: VideoSource(, enabled: <#T##Bool#>, name: <#T##String?#>)




                self.output.localVideoTrack = LocalVideoTrack(source: self.output.camera!, enabled: true, name: "Camera")

                // Add renderer to video track for local preview
                self.output.localVideoTrack!.addRenderer(self.output.previewView)
                logMessage(messageText: "Video track created")



                self.output.camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
                    if let error = error {
                        self.logMessage(messageText: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                    } else {
                        self.output.previewView.shouldMirror = (captureDevice.position == .front)
                    }
                }

            } else {
                self.logMessage(messageText:"No front or back capture device found!")
            }
        case .custom:
            setupLocalMedia()

            self.output.localVideoTrack!.addRenderer(self.output.previewView)

        case .visionpose:

            break
        }

    }

    private func setupLocalMedia() {

        // ソースを作る
        let source = CustomVideoSource()

        //            // ビデオトラックを作る
        guard let videoTrack = LocalVideoTrack(source: source, enabled: true, name: "Screen") else {
            return
        }
        //
        self.output.localVideoTrack = videoTrack

        // ソースを保持
        self.output.viewSource = source

        // ソースからキャプチャ開始
        source.startCapture()

    }

    private func setupRemoteVideoView() {
        // Creating `VideoView` programmatically
        self.output.remoteView = VideoView(frame: CGRect.zero, delegate: self)

    }

    private func renderRemoteParticipant(participant : RemoteParticipant) -> Bool {
        // This example renders the first subscribed RemoteVideoTrack from the RemoteParticipant.
        let videoPublications = participant.remoteVideoTracks
        for publication in videoPublications {
            if let subscribedVideoTrack = publication.remoteTrack,
               publication.isTrackSubscribed {
                setupRemoteVideoView()
                subscribedVideoTrack.addRenderer(self.output.remoteView!)
                self.output.remoteParticipant = participant
                return true
            }
        }
        return false
    }

    private func renderRemoteParticipants(participants : Array<RemoteParticipant>) {
        for participant in participants {
            // Find the first renderable track.
            if participant.remoteVideoTracks.count > 0,
               renderRemoteParticipant(participant: participant) {
                break
            }
        }
    }

    private func cleanupRemoteParticipant() {
        if self.output.remoteParticipant != nil {
            self.output.remoteView = nil
            self.output.remoteParticipant = nil
        }
    }

    private func disConnect() {
        self.output.room?.disconnect()
        if let source = self.output.viewSource as? CustomVideoSource {
            source.stopCapture()
        }
        self.output.localVideoTrack = nil
    }
}

extension VideoPageViewModel: CameraSourceDelegate {

}

extension VideoPageViewModel: RoomDelegate {
    func roomDidConnect(room: Room) {
        logMessage(messageText: "Connected to room \(room.name) as \(room.localParticipant?.identity ?? "")")

        // This example only renders 1 RemoteVideoTrack at a time. Listen for all events to decide which track to render.

        print(room.remoteParticipants)
        for remoteParticipant in room.remoteParticipants {
            remoteParticipant.delegate = self
        }
    }

    func roomDidDisconnect(room: Room, error: Error?) {
        logMessage(messageText: "Disconnected from room \(room.name), error = \(String(describing: error))")

        //        self.cleanupRemoteParticipant()
        //        self.room = nil
        //
        //        self.showRoomUI(inRoom: false)
    }

    func roomDidFailToConnect(room: Room, error: Error) {
        logMessage(messageText: "Failed to connect to room with error = \(String(describing: error))")
        //        self.room = nil
        //
        //        self.showRoomUI(inRoom: false)
    }

    func roomIsReconnecting(room: Room, error: Error) {
        logMessage(messageText: "Reconnecting to room \(room.name), error = \(String(describing: error))")
    }

    func roomDidReconnect(room: Room) {
        logMessage(messageText: "Reconnected to room \(room.name)")
    }

    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        // Listen for events from all Participants to decide which RemoteVideoTrack to render.
        participant.delegate = self

        logMessage(messageText: "Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")

        // Nothing to do in this example. Subscription events are used to add/remove renderers.
    }
}

extension VideoPageViewModel: RemoteParticipantDelegate {

    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has offered to share the video Track.

        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) video track")
    }

    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has stopped sharing the video Track.

        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) video track")
    }

    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has offered to share the audio Track.

        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) audio track")
    }

    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has stopped sharing the audio Track.

        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) audio track")
    }

    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // The LocalParticipant is subscribed to the RemoteParticipant's video Track. Frames will begin to arrive now.

        logMessage(messageText: "Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")

        if (self.output.remoteParticipant == nil) {
            _ = renderRemoteParticipant(participant: participant)
        }
    }

    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.

        logMessage(messageText: "Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")

        if self.output.remoteParticipant == participant {
            cleanupRemoteParticipant()

            // Find another Participant video to render, if possible.
            if var remainingParticipants = output.room?.remoteParticipants,
               let index = remainingParticipants.firstIndex(of: participant) {
                remainingParticipants.remove(at: index)
                renderRemoteParticipants(participants: remainingParticipants)
            }
        }
    }

    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.

        logMessage(messageText: "Subscribed to \(publication.trackName) audio track for Participant \(participant.identity)")
    }

    func didUnsubscribeFromAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.

        logMessage(messageText: "Unsubscribed from \(publication.trackName) audio track for Participant \(participant.identity)")
    }

    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) video track")
    }

    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) video track")
    }

    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) audio track")
    }

    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) audio track")
    }

    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }

    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
}

extension VideoPageViewModel: VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        print(#function)
    }
}

/**
 * videoCapture
 */
extension VideoPageViewModel {
    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { [weak self ] error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.videoCaptureHandler = { (videoCapture, capturedImage) in

                guard let image = capturedImage else {
                    fatalError("Captured image is null")
                }

                self.currentFrame = image
                self.estimation(image)
            }

            self.videoCapture.startCapturing()
        }
    }

    // 画像
    private func estimation(_ cgImage:CGImage) {
        imageSize = CGSize(width: cgImage.width, height: cgImage.height)

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)

        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
        }
    }


    private func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedPointsObservation] else { return }

        // Process each observation to find the recognized body pose points.
        if observations.count == 0 {
            guard let currentFrame = self.currentFrame else {
                return
            }
            let image = UIImage(cgImage: currentFrame)
            DispatchQueue.main.async {
                self.output.previewImage = image
                v = image
            }
        } else {
            let points = observations.map { (observation) -> [CGPoint] in
                let ps = processObservation(observation)
                return ps ?? []
            }

            let flatten = points.flatMap{$0}

            guard let image = currentFrame?.drawPoints(points: flatten) else { return }
            DispatchQueue.main.async {
                self.output.previewImage = image
                v = image
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

struct PlatformUtils {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()
}
