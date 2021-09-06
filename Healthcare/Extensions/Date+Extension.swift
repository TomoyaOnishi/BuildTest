//
//  Date+Extension.swift
//  Healthcare
//
//  Created by T T on 2021/06/16.
//

import Foundation


import Foundation

extension Date {

    func add(days: Int) -> Date {

        return Calendar.current.date(byAdding: .day, value: days, to: self)!

    }

    func add(minute: Int) -> Date {

        return Calendar.current.date(byAdding: .minute, value: minute, to: self)!

    }

    func stringFromDate(format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ja_JP")

        return formatter.string(from: self)
    }

    static func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }

}


extension Double {
    func toInt() -> Int {
        return Int(self)
    }
}
