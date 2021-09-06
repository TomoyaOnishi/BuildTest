//
//  AppleWatchGuideView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/26.
//

import SwiftUI

struct AppleWatchGuideView: View {
    var body: some View {
        VStack {
            VStack {
                Spacer()
                    .frame(height: 76)
                Text("Apple Watch の装着")
                    .font(.system(size: 26))
                    .fontWeight(.bold)
                Spacer()
                    .frame(height: 22)
                Text("心電図の取得、脈拍や運動の状態を\n把握するために、以下を行って下さい。")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Spacer()
                    .frame(height: 40)
            }
            VStack {
                Text("① Apple Watch を装着")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                Spacer()
                    .frame(height: 4)
                Image("AppleWatchGuide1")
                    .frame(width: 258, height: 136, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Spacer()
                    .frame(height: 5)
                Text("② 心リハアプリを起動")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                Spacer()
                    .frame(height: 10)
                Image("AppleWatchGuide2")
                    .frame(width: 129, height: 129, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .offset(x: 10, y: 0)
            }
            Spacer()
                .frame(height: 40)
            Button(action: {
                
            }){
                NavigationLink(destination: InputBloodPressureView(vm: InputBloodPressureViewModel() )) {
                    Text("装着・起動完了したので次へ")
                        .font(.system(size: 18))
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

struct AppleWatchGuideView_Previews: PreviewProvider {
    static var previews: some View {
        AppleWatchGuideView()
    }
}
