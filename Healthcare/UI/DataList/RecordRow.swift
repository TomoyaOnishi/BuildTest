//
//  RecordRow.swift
//  Healthcare
//
//  Created by T T on 2021/06/20.
//

import SwiftUI

struct RecordRow: View {

    let record: BloodPressureRecordModel
    var body: some View {

        HStack {

            Text(record.hhmm)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .lineLimit(1)

            Text(record.bps_bpd)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .lineLimit(1)

            Text(record.heartRate.toInt().description)
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
