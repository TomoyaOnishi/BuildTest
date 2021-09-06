//
//  CountDownTimerView.swift
//  Healthcare
//
//  Created by Shin on 2021/06/12.
//

import SwiftUI

private let fireInterval: TimeInterval = 0.032

struct CountDownTimerView: View {
    
    private let lineWidth: CGFloat = 2.0
    private let lineColor: UIColor = .black
    private let moveClockWise = true
    private let timerFinishingText: String = "終了"
    private let useMinutesAndSecondsRepresentation = false
    
    @State private var beginingValue: Int = 30 * 60
    @State private var totalTime: TimeInterval = 30 * 60
    @State private var elapsedTime: TimeInterval = 0
    @State private var interval: TimeInterval = 1
    @State private var currentCounterValue: Int = 30 * 60
    @State private var isPlaying = true
    
    let timer = Timer.publish(every: fireInterval, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { bodyView in
            ZStack {
                Path { path in
                    let radius = (bodyView.size.width - lineWidth) / 2
                    path.addArc(
                        center: CGPoint(x: bodyView.size.width / 2, y: bodyView.size.height / 2),
                        radius: radius,
                        startAngle: .radians(0),
                        endAngle: .radians(.pi * 2),
                        clockwise: true)
                }
                .stroke(lineWidth: 10)
                .fill(Color.gray)
                Path { path in
                    let radius = (bodyView.size.width - lineWidth) / 2
                    let currentAngle = Double((.pi * 2 * elapsedTime) / totalTime)
                    path.addArc(
                        center: CGPoint(x: bodyView.size.width / 2, y: bodyView.size.height / 2),
                        radius: radius,
                        startAngle: .radians(currentAngle - .pi / 2),
                        endAngle: .radians(.pi * 2 - .pi / 2),
                        clockwise: true)
                }
                .stroke(lineWidth: 10)
                .fill(Color.blue)
                VStack {
                    Text(getMinutesAndSeconds(remainingSeconds: currentCounterValue))
                        .font(.system(size: 42))
                        .fontWeight(.bold)
                    Button(action: {
                        isPlaying = !isPlaying
                        if isPlaying {
//                            WatchConnectivityManager.shared.send([.workoutStart : currentCounterValue])
                        } else {
//                            WatchConnectivityManager.shared.send([.workoutStop : currentCounterValue])
                        }
                    }){
                        isPlaying ? Image("CountDownPause") : Image("CountDownPlay")
                    }
                    .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
            }
        }.onReceive(timer, perform: { input in
            if isPlaying {
                elapsedTime += fireInterval
                if elapsedTime <= totalTime {
                    let computedCounterValue = beginingValue - Int(elapsedTime / interval)
                    if computedCounterValue != currentCounterValue {
                        currentCounterValue = computedCounterValue
                    }
                }
            }
        }).onAppear(perform: {
//            WatchConnectivityManager.shared.send([.workoutStart : currentCounterValue])
        }).onDisappear(perform: {
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
            return timerFinishingText
        } else {
            if useMinutesAndSecondsRepresentation {
                return getMinutesAndSeconds(remainingSeconds: currentCounterValue)
            } else {
                return "\(currentCounterValue)"
            }
        }
    }
     
}

struct CountDownTimerView_Previews: PreviewProvider {
    static var previews: some View {
        CountDownTimerView()
    }
}
