//
//  OnboardingView.swift
//  Healthcare
//
//  Created by T T on 2021/06/22.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    let vm: ContentViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("オンライン心臓リハビリアプリ")
                .bold()

            Image("TabTraning").frame(width: 120, height: 120)

            Text("サービスの簡単な説明サービスの簡単な説明\nサービスの簡単な説明")


            Button(action: {
                vm.input.setFirstOpen.send()
//                presentationMode.wrappedValue.dismiss()

            }){
                    Text("はじめる")
                        .foregroundColor(Color.white)
                        .frame(width: 298, height: 60)
                        .background(Color.blue)
                        .cornerRadius(30)
            }

        }.padding()
    }
}

