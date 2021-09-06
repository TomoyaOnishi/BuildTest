//
//  PedometerView.swift
//  HealthcareWatchKitApp Extension
//
//  Created by Shin on 2021/06/15.
//

import SwiftUI

struct PedometerView: View {

    @StateObject var pedometer = Pedometer()
    
    var body: some View {
        HStack {
            Spacer()
            Image("Step")
                .frame(width: 18, height: 24)
            Spacer()
                .frame(width: 6)
            Text("\(pedometer.count)")
                .font(.system(size: 24))
            Spacer()
        }.onAppear {
            pedometer.start()
        }.onDisappear(perform: {
            pedometer.stop()
        })
    }
}

struct PedometerView_Previews: PreviewProvider {
    static var previews: some View {
        PedometerView()
    }
}
