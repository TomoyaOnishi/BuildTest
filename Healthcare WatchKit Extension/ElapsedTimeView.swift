//
//  ElapsedTimeView.swift
//  ElapsedTimeView
//
//  Created by Shin on 2021/08/29.
//

import SwiftUI

struct ElapsedTimeView: View {
    var elapsedTime: TimeInterval = 0
    @State private var timeFormatter = ElapsedTimeFormatter()

    var body: some View {
        Text(NSNumber(value: elapsedTime), formatter: timeFormatter)
            .font(.system(size: 48))
            .fontWeight(.bold)
    }
}

class ElapsedTimeFormatter: Formatter {
    let componentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    override func string(for value: Any?) -> String? {
        guard let time = value as? TimeInterval else {
            return nil
        }

        guard let formattedString = componentsFormatter.string(from: time) else {
            return nil
        }

        return formattedString
    }
}

struct ElapsedTime_Previews: PreviewProvider {
    static var previews: some View {
        ElapsedTimeView()
    }
}
