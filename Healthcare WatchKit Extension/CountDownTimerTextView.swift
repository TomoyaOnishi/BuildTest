//
//  CountDownTimerTextView.swift
//  HealthcareWatchKitApp Extension
//
//  Created by Shin on 2021/06/27.
//

import SwiftUI

private let fireInterval: TimeInterval = 0.032

struct CountDownTimerTextView: View {
    
    private let useMinutesAndSecondsRepresentation = false
    
    @State private var beginingValue: Int = 30 * 60
    @State private var totalTime: TimeInterval = 30 * 60
    @State private var elapsedTime: TimeInterval = 0
    @State private var interval: TimeInterval = 1
    @State private var currentCounterValue: Int = 30 * 60
    @State private var isPlaying = false
    @State private var messageHandler: WatchConnectivityManager.MessageHandler?
    
    let timer = Timer.publish(every: fireInterval, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text(getMinutesAndSeconds(remainingSeconds: currentCounterValue))
                .font(.system(size: 48))
                .fontWeight(.bold)
        }
        .onReceive(timer, perform: { input in
            if isPlaying {
                elapsedTime += fireInterval

                if elapsedTime <= totalTime {
                    let computedCounterValue = beginingValue - Int(elapsedTime / interval)
                    if computedCounterValue != currentCounterValue {
                        currentCounterValue = computedCounterValue
                    }
                }
            }
        }).onAppear {
            messageHandler = WatchConnectivityManager.MessageHandler { message in
                print(message)
                if let value = message[.workoutStart] as? Int {
                    isPlaying = true
                    currentCounterValue = value
                } else if let value = message[.workoutStop] as? Int {
                    isPlaying = false
                    currentCounterValue = value
                }
            }
//            WatchConnectivityManager.shared.addMessageHandler(messageHandler!)
//            WatchConnectivityManager.shared.send([.workoutStart : currentCounterValue])
        }.onDisappear(perform: {
            timer.upstream.connect().cancel()
        })
    }
    
    private func getMinutesAndSeconds(remainingSeconds: Int) -> (String) {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds - minutes * 60
        let secondString = seconds < 10 ? "0" + seconds.description : seconds.description
        return minutes.description + ":" + secondString
    }
    
    private func currentCounterValueToText(value: Int) -> String {
        if currentCounterValue == 0 {
            return "0:00"
        } else {
            if useMinutesAndSecondsRepresentation {
                return getMinutesAndSeconds(remainingSeconds: currentCounterValue)
            } else {
                return "\(currentCounterValue)"
            }
        }
    }
     
}

struct CountDownTimerTextView_Previews: PreviewProvider {
    static var previews: some View {
        CountDownTimerTextView()
    }
}
