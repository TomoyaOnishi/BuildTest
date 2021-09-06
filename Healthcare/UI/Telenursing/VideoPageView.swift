//
//  VideoPageView.swift
//  Healthcare
//
//  Created by T T on 2021/06/09.
//

import SwiftUI
import TwilioVideo

struct VideoPageView: View {

    @ObservedObject var vm: VideoPageViewModel

    var body: some View {

        VStack {
            Button("connect") {
                self.vm.input.connect.send()
            }
            Button("disconnect") {
                self.vm.input.disconnect.send()
            }
            Button("mic") {
                self.vm.input.mic.send()
            }

            Image(uiImage: self.vm.output.previewImage)
                .resizable()
                .scaledToFit()

            TwilioVideoView(videoView: vm.output.previewView)

            if vm.output.remoteView != nil {
                TwilioVideoView(videoView: vm.output.remoteView!)
            }
        }.onAppear {
            self.vm.input.onAppear.send()
        }.onDisappear {
            self.vm.input.onDisappear.send()
        }
    }
}

struct VideoPageView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPageView(vm: VideoPageViewModel())
    }
}
