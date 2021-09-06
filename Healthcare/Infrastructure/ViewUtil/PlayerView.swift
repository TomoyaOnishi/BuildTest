//
//  PlayerView.swift
//  Healthcare
//
//  Created by Shin on 2021/06/27.
//

import SwiftUI
import AVKit

struct PlayerView: UIViewRepresentable {
    let player: AVPlayer

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return UIPlayerView(player: player)
    }

}

class UIPlayerView: UIView {
    private let playerLayer = AVPlayerLayer()

    init(player: AVPlayer) {
        super.init(frame: .zero)
        
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer.frame = bounds
    }
}
