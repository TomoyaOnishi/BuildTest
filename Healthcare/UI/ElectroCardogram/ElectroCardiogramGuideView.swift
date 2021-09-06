//
//  ElectroCardiogramGuideView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/26.
//

import SwiftUI

struct ElectroCardiogramGuideView: View {
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 76)
            Text("心電図を測る")
                .font(.system(size: 26))
                .fontWeight(.bold)
            Spacer()
                .frame(height: 55)
            Text("AppleWatchで心電図を\n測ってください。")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 22)
            Image("ElectroCardiogramIcon")
            Spacer()
                .frame(height: 22)
            Button(action: {
                print("Tapped Next.")
            }){
                if SettingManager.sharedInstance.isTrainingPreparatory {
                    NavigationLink(destination: WarmingUpGuideView()) {
                        Text("次へ")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    .isDetailLink(false)
                } else {
                    NavigationLink(destination: ElectroCardiogramCompleteView()) {
                        Text("次へ")
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    .isDetailLink(false)
                }
            }
            .padding()
            .frame(width: 298, height: 60)
            .background(Color.blue)
            .cornerRadius(30)
            Spacer()
        }.navigationBarHidden(true)
    }
}

struct ElectroCardiogramGuideView_Previews: PreviewProvider {
    static var previews: some View {
        ElectroCardiogramGuideView()
    }
}
