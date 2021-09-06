//
//  TraningTopView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/16.
//

import Foundation
import SwiftUI

struct TraningTopView: View {
    
    @EnvironmentObject var setting: SettingEnvironmentObject
    
    var body: some View {
        VStack() {
            Spacer()
                .frame(height: 22)
            ZStack {
                HStack {
                    Image("TraningTopLine")
                        .resizable()
                        .frame(width: 2, height: 240)
                        .padding(.leading, 14)
                    Spacer()
                }
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                            .frame(width: 6.5)
                        Image("TraningTopEllipseSmall")
                        Text("  トレーニング前：血圧・心電図測定")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 34)
                    HStack {
                        ZStack {
                            Image("TraningTopEllipseLarge")
                            Text("1")
                                .foregroundColor(Color.white)
                                .fontWeight(.bold)
                        }
                        Text("準備体操 15分")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 24)
                    HStack {
                        ZStack {
                            Image("TraningTopEllipseLarge")
                            Text("2")
                                .foregroundColor(Color.white)
                                .fontWeight(.bold)
                        }
                        Text("ウォーキング 30分")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 24)
                    HStack {
                        ZStack {
                            Image("TraningTopEllipseLarge")
                            Text("3")
                                .foregroundColor(Color.white)
                                .fontWeight(.bold)
                        }
                        Text("整理運動 10分")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 34)
                    HStack {
                        Spacer()
                            .frame(width: 6.5)
                        Image("TraningTopEllipseSmall")
                        Text("  トレーニング後：血圧・心電図測定")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 8)
            .padding(.bottom, 42)
            Button(action: {
                print("")
            }){
                switch WatchConnectivityManager.shared.monitorState {
                case .notStarted, .errorOccur:
                    NavigationLink(destination: AppleWatchGuideView(), isActive: $setting.isTrainingNavigationActive) {
                        Text("はじめる")
                            .foregroundColor(Color.white)
                            .fontWeight(.bold)
                    }
                case .launching, .running:
                    NavigationLink(destination: InputBloodPressureView(vm: InputBloodPressureViewModel()), isActive: $setting.isTrainingNavigationActive) {
                        Text("はじめる")
                            .foregroundColor(Color.white)
                            .fontWeight(.bold)
                    }
                }}
                .frame(width: 298, height: 60)
                    .background(Color.blue)
                    .cornerRadius(30)
                Spacer()
            }.onAppear {
                SettingManager.sharedInstance.isTrainingPreparatory = true
                
                let messageHandler = WatchConnectivityManager.MessageHandler { message in
                    print(message)

                    if (message[.heartRateIntergerValue] as? Int) != nil {
                        WatchConnectivityManager.shared.monitorState = .running
                    }
                    else if message[.workoutStop] != nil{
                        WatchConnectivityManager.shared.monitorState = .notStarted
                    }
                    else if message[.workoutStart] != nil{
                        WatchConnectivityManager.shared.monitorState = .running
                    }
                    else if let errorData = message[.workoutError] as? Data {
                        if let error = NSKeyedUnarchiver.unarchiveObject(with: errorData) as? Error {
                            WatchConnectivityManager.shared.monitorState = .errorOccur(error)
                        }
                    }
                }
                WatchConnectivityManager.shared.addMessageHandler(messageHandler)
            }
        }
    }

    struct GuideView_Previews: PreviewProvider {
        static var previews: some View {
            TraningTopView()
        }
    }

