//
//  InputWeightView.swift
//  Healthcare
//
//  Created by T T on 2021/06/17.
//

import SwiftUI

struct InputWeightView: View {

    @ObservedObject var vm: InputWeightViewModel

    var body: some View {
        VStack {

            NavigationLink(destination: ElectroCardiogramGuideView(), isActive: vm.$binding.next) {
                Text("次へ")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
            }
            .isDetailLink(false)
            Spacer()
                .frame(height: 42)
            Text("体重を入力")
                .font(.system(size: 26))
                .fontWeight(.bold)
            Group {
                Spacer()
                    .frame(height: 22)
                HStack {
                    Spacer()
                        .frame(width: 88)
                    Text("体重")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                    Spacer()
                        .frame(width: 28)
                    VStack {
                        TextField(" ", text: self.vm.$binding.weight)
                            .font(Font.system(size: 48, design: .default))
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                        UnderlineView(color: .gray)
                    }
                    Spacer()
                        .frame(width: 88)
                }
                Spacer()
                    .frame(height: 10)

            }
            Spacer()
                .frame(height: 34)

            Button(action: {
                self.vm.input.next.send()
            }){
                Text("次へ")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .frame(width: 298, height: 60)
                    .background(Color.blue)
                    .cornerRadius(30)

            }

            Spacer()
        }
        .onAppear {
            self.vm.input.onAppear.send()
        }
        .navigationBarHidden(true)
    }
}
