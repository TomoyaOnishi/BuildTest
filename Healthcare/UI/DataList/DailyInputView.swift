//
//  DailyInputView.swift
//  Healthcare
//
//  Created by T T on 2021/06/20.
//

import SwiftUI

struct DailyInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm: DailyInputViewModel
    @State var showingAlert: Bool = false
    var body: some View {

        VStack {
            DatePicker("", selection: vm.$binding.selectionDate)
                .environment(\.locale, Locale(identifier: "ja_JP")) // 追加
                .labelsHidden()
                .padding()
            HStack {
                Text("最高")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.red)

                VStack {
                    TextField(" ", text: vm.$binding.bps)
                        .font(Font.system(size: 48, weight: .bold , design: .default))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)

                    UnderlineView(color: .gray)
                }
                Spacer()
                    .frame(maxWidth: .infinity)
            }

            HStack {
                Text("最低")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.blue)

                VStack {
                    TextField(" ", text: vm.$binding.bpd)
                        .font(Font.system(size: 48, weight: .bold, design: .default))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                    UnderlineView(color: .gray)
                }

                Spacer()
                    .frame(maxWidth: .infinity)

            }

            HStack {
                Text("脈拍")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)

                VStack {

                    TextField(" ", text: vm.$binding.heartRate)
                        .font(Font.system(size: 48, weight: .bold, design: .default))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                    UnderlineView(color: .gray)
                }

                Spacer()
                    .frame(maxWidth: .infinity)

            }

            VStack ( spacing: 24) {
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

        }
        .padding(.horizontal, 24 )
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
        .navigationBarTitle(Text("日付"), displayMode: .inline)
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
