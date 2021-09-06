//
//  UnderlineView.swift
//  Healthcare
//
//  Created by Shin on 2021/06/01.
//

import SwiftUI

import SwiftUI

struct UnderlineShape: Shape {

    func path(in rect: CGRect) -> Path {
        let fill = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        var path = Path()
        path.addRoundedRect(in: fill, cornerSize: CGSize(width: 2, height: 2))

        return path
    }
}

struct UnderlineView: View {
    private var color: Color? = nil
    private var height: CGFloat = 1.0

    init(color: Color, height: CGFloat = 1.0) {
        self.color = color
        self.height = height
    }

    var body: some View {
        UnderlineShape().fill(self.color!).frame(minWidth: 0, maxWidth: .infinity, minHeight: height, maxHeight: height)
    }
}

struct UnderlineView_Previews: PreviewProvider {
    static var previews: some View {
        UnderlineView(color: .black)
    }
}
