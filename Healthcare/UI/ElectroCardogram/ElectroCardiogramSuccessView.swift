//
//  ElectroCardiogramSuccessView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/29.
//

import SwiftUI

struct ElectroCardiogramSuccessView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 76)
            Text("心電図を測る")
                .font(.system(size: 26))
                .fontWeight(.bold)
            Spacer()
                .frame(height: 55)
            Text("計測できました。\nApple Watch のアプリを\nReha アプリに切り替えてください。")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
            Button(action: {
                
            }){
                NavigationLink(destination: InputBloodPressureView(vm: InputBloodPressureViewModel())) {
                    Text("次へ")
                        .foregroundColor(Color.white)
                }
                .isDetailLink(false)
            }
            .frame(width: 298, height: 60)
            .background(Color.blue)
            .cornerRadius(30)
            Spacer().frame(height: 54)
        }
    }
}

struct ElectroCardiogramSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        ElectroCardiogramSuccessView()
    }
}
