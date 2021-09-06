//
//  BodyMassRecordRow.swift
//  Healthcare
//
//  Created by T T on 2021/09/02.
//

import SwiftUI


import SwiftUI

struct BodyMassRecordRow: View {

    let record: BodyMassRecordModel
    var body: some View {

        HStack {
            Text(record.bodyMass.description)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .lineLimit(1)

            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .padding()
                .foregroundColor(.blue)

        }.padding(.vertical, 2)
        .background(Color.white)

    }
}
