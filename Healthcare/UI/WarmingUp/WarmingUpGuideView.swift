//
//  WarmingUpGuideView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/29.
//

import SwiftUI

struct WarmingUpGuideView: View {
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
                .frame(height: 76)
            Text("準備体操をはじめる")
                .font(.system(size: 26))
                .fontWeight(.bold)
            Spacer()
                .frame(height: 55)
            Text("次は準備体操（15分）です。\n\n体操ができる場所へ移動しましょう。準備ができたらスタートを押してください。")
                
                .font(.system(size: 18))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 55)
            Image("PreparatoryGymnasticsGuide")
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 80, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            Spacer()
                .frame(height: 70)
            Button(action: {
                
            }){
                NavigationLink(destination: WarmingUpView()) {
                    Text("準備体操をスタート")
                        .fontWeight(.bold)
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

struct WarmingUpGuideView_Previews: PreviewProvider {
    static var previews: some View {
        WarmingUpGuideView()
    }
}
