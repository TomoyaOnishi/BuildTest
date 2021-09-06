//
//  WalkingSuccessView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/29.
//

import SwiftUI

struct WalkingSuccessView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 63)
            Text("ウォーキング\nお疲れさまでした")
                .font(.system(size: 26))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 56)
            Text("次は整理体操（10分）です。\n\n体操ができる場所へ移動しましょう。\n準備ができたらスタートを\n押してください。")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 40)
            Button(action: {
                
            }){
                NavigationLink(destination: CoolingDownView()) {
                    Text("整理体操をスタート")
                        .foregroundColor(Color.white)
                }
                .isDetailLink(false)
            }
            .frame(width: 298, height: 60)
            .background(Color.blue)
            .cornerRadius(30)
            Spacer()
        }.onAppear(perform: {
            SettingManager.sharedInstance.isTrainingPreparatory = false
        }).navigationBarHidden(true)
    }
}

struct WalkingSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        WalkingSuccessView()
    }
}
