//
//  ElectroCardiogramCompleteView.swift
//  Healthcare
//
//  Created by Shin on 2021/06/28.
//

import SwiftUI

struct ElectroCardiogramCompleteView: View {
    
    @EnvironmentObject var setting: SettingEnvironmentObject
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 76)
            Text("心電図を測る")
                .font(.system(size: 26))
                .fontWeight(.bold)
            Spacer()
                .frame(height: 55)
            Text("計測できました。")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height: 54)
            Button(action: {
                setting.isTrainingNavigationActive = false
            }){
                Text("完了")
                    .foregroundColor(Color.white)
            }
            .frame(width: 298, height: 60)
            .background(Color.blue)
            .cornerRadius(30)
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

struct ElectroCardiogramCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        ElectroCardiogramCompleteView()
    }
}
