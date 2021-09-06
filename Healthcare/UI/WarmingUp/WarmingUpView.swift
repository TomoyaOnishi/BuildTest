//
//  WarmingUpView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/29.
//

import SwiftUI
import AVKit

struct WarmingUpView: View {
    
    private let heartRateManager = HeartRateManager()
    private let avPlayer = AVPlayer(url:  Bundle.main.url(forResource: "PreparatoryGymnastics", withExtension: "mp4")!)
    
    @State private var messageHandler: WatchConnectivityManager.MessageHandler?
    @State private var monitorState: WatchConnectivityManager.MonitorState = .notStarted
    @State private var heartRate: Int = 0
    
    var body: some View {
        GeometryReader { bodyView in
            VStack {
                Spacer()
                    .frame(height: 38)
                Text("準備体操 15分")
                    .font(.system(size: 26))
                    .fontWeight(.bold)
                Spacer()
                    .frame(height: 17)
                PlayerView(player: avPlayer)
                Spacer()
                    .frame(height: 88)
                HStack {
                    Spacer()
                    BodyTrackingView()
                        .frame(width: 104, height: 140, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Text("\(heartRate)")
                        .font(.system(size: 60))
                        .fontWeight(.bold)
                    VStack {
                        Image("WarmingUpHeart")
                        Text("BPM")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                Spacer()
                Button(action: {
                    
                }){
                    NavigationLink(destination: WarmingUpSuccessView()) {
                        Text("次へ")
                            .foregroundColor(Color.white)
                    }
                    .isDetailLink(false)
                }
                .frame(width: 298, height: 60)
                .background(Color.blue)
                .cornerRadius(30)
                Spacer()
            }
        }
        .onAppear {
            avPlayer.play()
            
            let messageHandler = WatchConnectivityManager.MessageHandler { message in
                print(message)
                
                if let intergerValue = message[.heartRateIntergerValue] as? Int {
                    heartRate = intergerValue
                    monitorState = .running
                }
                else if message[.workoutStop] != nil{
                    monitorState = .notStarted
                }
                else if message[.workoutStart] != nil{
                    monitorState = .running
                }
                else if let errorData = message[.workoutError] as? Data {
                    if let error = NSKeyedUnarchiver.unarchiveObject(with: errorData) as? Error {
                        monitorState = .errorOccur(error)
                    }
                }
            }
            WatchConnectivityManager.shared.addMessageHandler(messageHandler)
        }.onDisappear {
            avPlayer.pause()
        }.navigationBarHidden(true)
    }
}

struct WarmingUpView_Previews: PreviewProvider {
    static var previews: some View {
        WarmingUpView()
    }
}
