//
//  CoolingDownSuccessView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/29.
//

import SwiftUI

struct CoolingDownSuccessView: View {
    
    @EnvironmentObject var setting: SettingEnvironmentObject
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 63)
            Text("整理運動\nお疲れさまでした")
                .font(.system(size: 26))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 56)
            Text("最後に血圧と心電図を測って終了です。")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 56)
            Button(action: {
                
            }){
                NavigationLink(destination: InputBloodPressureView(vm: InputBloodPressureViewModel() )  ) {
                    Text("次へ")
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

struct CoolingDownSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        CoolingDownSuccessView()
    }
}
