//
//  DefaultButtonStyle.swift
//  Healthcare
//
//  Created by T T on 2021/09/02.
//

import SwiftUI

struct DefaultButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        DefaultButton(configuration:configuration)
    }
    struct DefaultButton: View {
        @Environment(\.isEnabled) var isEnabled
        let configuration: DefaultButtonStyle.Configuration
        var body: some View {
            configuration.label
                .foregroundColor(Color.white)
                .background(isEnabled ? Color.blue : Color(.systemGray3))
                .opacity(configuration.isPressed ? 0.2 : 1.0)
        }
    }
}
