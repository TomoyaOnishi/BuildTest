//
//  WalkingView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/29.
//

import SwiftUI

struct WalkingView: View {
    
    private let heartRateManager = HeartRateManager()
    
    @State private var heartRate: Int = 0
    @State private var totalSteps: Int = 0
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 63)
            Text("ウォーキング 30分")
                .font(.system(size: 26))
                .fontWeight(.bold)
            Spacer()
                .frame(height: 52)
            CountDownTimerView()
                .frame(width: 260, height: 260, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            Spacer()
            HStack {
                Spacer()
                    .frame(width: 47)
                Image("WalkingStep")
                Spacer()
                    .frame(width: 17)
                Text("歩数")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                Spacer()
                Text("\(totalSteps)")
                    .font(.system(size: 42))
                    .fontWeight(.bold)
                Spacer()
                    .frame(width: 60)
            }
            HStack {
                Spacer()
                    .frame(width: 53)
                Image("WalkingHeart")
                Spacer()
                    .frame(width: 17)
                Text("心拍数")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                Spacer()
                Text("\(heartRate)")
                    .font(.system(size: 42))
                    .fontWeight(.bold)
                Text("BPM")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                Spacer()
                    .frame(width: 34)
            }
            Spacer()
            Button(action: {
                
            }){
                NavigationLink(destination: WalkingSuccessView()) {
                    Text("次へ")
                        .foregroundColor(Color.white)
                }
                .isDetailLink(false)
            }
            .frame(width: 298, height: 60)
            .background(Color.blue)
            .cornerRadius(30)
            Spacer()
        }.onAppear {
            let messageHandler = WatchConnectivityManager.MessageHandler { message in
                // HeartRate
                if let intergerValue = message[.heartRateIntergerValue] as? Int {
                    heartRate = intergerValue
                    WatchConnectivityManager.shared.monitorState = .running
                }
                // Pedometer
                else if let intergerValue = message[.pedometerIntergerValue] as? Int {
                    totalSteps = intergerValue
                }
                else if message[.workoutStart] != nil{
                    WatchConnectivityManager.shared.monitorState = .running
                }
                else if message[.workoutStop] != nil{
                    WatchConnectivityManager.shared.monitorState = .notStarted
                }
                else if let errorData = message[.workoutError] as? Data {
                    if let error = NSKeyedUnarchiver.unarchiveObject(with: errorData) as? Error {
                        WatchConnectivityManager.shared.monitorState = .errorOccur(error)
                    }
                }
            }
            WatchConnectivityManager.shared.addMessageHandler(messageHandler)
            
            heartRateManager.startWatchApp { error in
                if let error = error {
                    WatchConnectivityManager.shared.monitorState = .errorOccur(error)
                }
            }
        }.navigationBarHidden(true)
    }
}

struct WalkingView_Previews: PreviewProvider {
    static var previews: some View {
        WalkingView()
    }
}
