//
//  DailyRow.swift
//  Healthcare
//
//  Created by T T on 2021/06/20.
//

import SwiftUI

struct DailyRow: View {

    let vm: DataListViewModel
    let daily: DailyModel
    @State private var isPresented = false
    @State private var presentWeightInput = false

    var body: some View {
        
        VStack( spacing: 0 ) {
            // 上部日付
            HStack {
                Text( daily.title)
                    .font(.system(size: 28, weight: .bold))
                
                Spacer()

            }.padding( .horizontal, 16)

            LazyVStack( spacing: 0 ) {

                HStack {
                    Text("血圧・脈拍")
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))

                HStack {
                    Text("時間")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)

                    Text("最高/最低")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)

                    Text("脈拍")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)

                    Color.white
                        .frame(width: 16, height: 16)
                        .padding()

                }

                Divider()

                LazyVStack( spacing: 0 ) {
                    ForEach(daily.records) { record in


                        RecordRow(record: record)
                            .onTapGesture {
                                vm.binding.selectedBloodPressure = record
                            }

                        Divider()

                    }
                }.frame(maxWidth: .infinity)
                Button {
                    isPresented.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text("追加")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                }

                HStack {
                    Text("体重")
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))



                if let weightRecordModel =  daily.weightRecordModel {

                    BodyMassRecordRow(record: weightRecordModel)
                        .onTapGesture {
                            vm.binding.selectedBodyMass = weightRecordModel
                        }
                    Divider()
                } else {

                    Button {
                        presentWeightInput.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text("追加")
                                .font(.system(size: 24, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                    }

                }

            }
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 4)
            .padding()
            
        }
        .fullScreenCover(isPresented: $isPresented, onDismiss: {
            self.vm.input.get.send()
        }, content: {
            NavigationView {
                DailyInputView( vm: DailyInputViewModel(date: Date(), record: nil))
            }
        })
        .fullScreenCover(isPresented: $presentWeightInput, onDismiss: {
            self.vm.input.get.send()
        }, content: {
            NavigationView {
                WeightInputView( vm: WeightInputViewModel(date: Date(), bodyMass: nil))
            }
        })
    }
}


struct DailyRow_Previews: PreviewProvider {
    static var previews: some View {
        DailyRow(vm: DataListViewModel(), daily: DailyModel(id: "1", title: "8/29(日)", records: [

            BloodPressureRecordModel(bps: 20,
                                     _bps: nil,
                                     bpd: 40,
                                     _bpd: nil,
                                     heartRate: 30,
                                     _heartRate: nil,

                                     start: Date(),
                                     end: Date()),
            BloodPressureRecordModel(bps: 20,
                                     _bps: nil,
                                     bpd: 40,
                                     _bpd: nil,
                                     heartRate: 30,
                                     _heartRate: nil,

                                     start: Date(),
                                     end: Date()),



        ], weightRecordModel: BodyMassRecordModel(bodyMass: 50, _bodyMass: nil, start: Date(), end: Date())))
    }
}

