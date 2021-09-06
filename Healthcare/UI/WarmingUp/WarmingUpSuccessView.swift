//
//  WarmingUpSuccessView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/29.
//

import SwiftUI

struct WarmingUpSuccessView: View {
    var body: some View {
        VStack() {
            Spacer()
                .frame(height: 76)
            Text("準備体操\nお疲れさまでした")
                .font(.system(size: 26))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 56)
            Text("次はウォーキング（30分）です。\n\n準備ができたらスタートを押してください。")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 56)
            Button(action: {
                
            }){
                NavigationLink(destination: WalkingView()) {
                    Text("ウォーキングをスタート")
                        .foregroundColor(Color.white)
                }
                .isDetailLink(false)
            }
            .frame(width: 298, height: 60)
            .background(Color.blue)
            .cornerRadius(30)
            Spacer()
        }.navigationBarHidden(true)
    }
}

struct WarmingUpSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        WarmingUpSuccessView()
    }
}
