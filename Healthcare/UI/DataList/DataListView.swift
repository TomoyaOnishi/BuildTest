//
//  DataListView.swift
//  Healthcare
//
//  Created by T T on 2021/06/18.
//

import SwiftUI

struct DataListView: View {

    @StateObject var vm: DataListViewModel
    @State var day: Date?
    @State var open: Bool = false
    var body: some View {

        ScrollView(.vertical) {
            VStack {
                ForEach(vm.output.dailys) { daily in
                    DailyRow(vm: vm, daily: daily)
                }
            }
        }
        .fullScreenCover(item: vm.$binding.selectedBloodPressure, onDismiss: {
            vm.input.get.send()
        }, content: { item in
            NavigationView {
                DailyInputView( vm: DailyInputViewModel(date: item.start, record: item))
                    .navigationBarTitle(Text("日付"), displayMode: .inline)
            }
        })
        .fullScreenCover(item: vm.$binding.selectedBodyMass, onDismiss: {
            vm.input.get.send()
        }, content: { item in
            NavigationView {
                WeightInputView(vm: WeightInputViewModel(date: item.start, bodyMass: item))
                    .navigationBarTitle(Text("日付"), displayMode: .inline)
            }
        })
        .onAppear {
            self.vm.input.onAppear.send()
        }
    }
}
