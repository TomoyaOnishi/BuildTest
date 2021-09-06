//
//  TelenursingView.swift
//  Healthcare
//
//  Created by T T on 2021/06/07.
//

import SwiftUI
import TwilioVideo

struct TelenursingView: View {

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {

            VStack {

                VStack(spacing: 8) {

                    Text("次回のテレナーシング")
                        .bold()
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 8) {

                        Text("2021年5月24日（月）")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("18:00〜19:00")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("水野 看護師")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)


                    Button(action: {
                        print("通話を開始")
                    }, label: {
                        Text("通話を開始")
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 298, height: 60)
                            .background(Color.orange)
                            .cornerRadius(30)

                    })
                }
                .padding()

            }
            .background(Color.orange.opacity(0.2))
            .padding()

            Spacer()

        }
    }
}

struct TelenursingView_Previews: PreviewProvider {
    static var previews: some View {
        TelenursingView()
    }
}
