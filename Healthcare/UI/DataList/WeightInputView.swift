//
//  WeightInputView.swift
//  Healthcare
//
//  Created by T T on 2021/08/29.
//

import SwiftUI

struct WeightInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm: WeightInputViewModel
    @State var showingAlert: Bool = false

    var body: some View {
        VStack {
            Spacer().frame(height: 240)
            HStack {
                Text("体重")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)

                VStack {

                    TextField(" ", text: vm.$binding.bodyMass)
                        .font(Font.system(size: 42, design: .default))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                    UnderlineView(color: .gray)
                }

                Spacer()
                    .frame(maxWidth: .infinity)

            }

            VStack( spacing: 24) {
                HStack {
                    Button {
                        self.vm.input.done.send()
                    } label: {
                        Text("保存")
                            .bold()
                            .frame( height: 60)
                            .frame(maxWidth: .infinity )

                    }
                    .cornerRadius(30)
                    .buttonStyle(DefaultButtonStyle())
                    .disabled(vm.binding.saveButtonisDisabled)

                }

            }.padding()

            Spacer()

        }.padding(.horizontal, 24 )
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("警告"),
                  message: Text("この記録を削除してよろしいですか？"),
                  primaryButton: .cancel(Text("キャンセル")),    // キャンセル用
                  secondaryButton: .destructive(Text("削除する"),action: {
                    guard let initialRecord = self.vm.output.initialRecord else { return }
                    self.vm.input.delete.send( initialRecord)
                  } ))
        }
        .onReceive(self.vm.output.dismiss) {
            presentationMode.wrappedValue.dismiss()
        }
        .navigationBarTitle(Text("体重を入力"), displayMode: .inline)
        .navigationBarItems(
            leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark")
        }),
            trailing: Button(action: {
                self.showingAlert = true
            }, label: {
                Image(systemName: "trash")
            }).disabled(vm.output.initialRecord == nil)
        )
    }
}

