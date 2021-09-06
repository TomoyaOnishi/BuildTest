//
//  TwilioVideoView.swift
//  Healthcare
//
//  Created by T T on 2021/06/13.
//

import SwiftUI
import TwilioVideo

struct TwilioVideoView: UIViewRepresentable {
    var videoView: VideoView

    func makeUIView(context: Context) -> VideoView {
        return videoView
    }

    func updateUIView(_ uiView: VideoView, context: Context) {
    }
}
