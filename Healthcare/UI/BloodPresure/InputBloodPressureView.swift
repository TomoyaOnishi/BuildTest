//
//  InputBloodPressureView.swift
//  Healthcare
//
//  Created by Shin on 2021/05/26.
//

import SwiftUI
import HealthKit
import Combine

struct InputBloodPressureView: View {

    @ObservedObject var vm: InputBloodPressureViewModel

    var body: some View {
        VStack {
            NavigationLink(destination: InputWeightView(vm: InputWeightViewModel()), isActive: vm.$binding.next) {
                Text("次へ")
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
            }
            .isDetailLink(false)
            Spacer()
                .frame(height: 42)
            Text("血圧を入力")
                .font(.system(size: 26))
                .fontWeight(.bold)
            Group {
                Spacer()
                    .frame(height: 22)
                HStack {
                    Spacer()
                        .frame(width: 88)
                    Text("最高")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                    Spacer()
                        .frame(width: 28)
                    VStack {
                        TextField(" ", text: self.vm.$binding.bloodH)
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
                HStack {
                    Spacer()
                        .frame(width: 88)
                    Text("最低")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(Color.blue)
                    Spacer()
                        .frame(width: 28)
                    VStack {
                        TextField(" ", text: self.vm.$binding.bloodL)
                            .font(Font.system(size: 48, design: .default))
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                        UnderlineView(color: .gray)
                    }
                    Spacer()
                        .frame(width: 88)
                }
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

