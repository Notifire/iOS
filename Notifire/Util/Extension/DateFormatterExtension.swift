//
//  DateFormatterExtension.swift
//  Notifire
//
//  Created by David Bielik on 05/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

enum DateFormatStyle: String {
    case dateOnly = "dd.MM.yyyy"
    case complete = "HH:mm:ss.SS, dd.MM.yyyy"
    case completeNoSec = "HH:mm, dd.MM.yyyy"
    case completeDateFirst = "dd.MM.yyyy HH:mm"
    case completeSpaced = "dd.MM.yyyy\tHH:mm"
}

extension Date {
    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true

        let dateMinus7D = Date().addingTimeInterval(-604800)
        let lastWeekRange = dateMinus7D...Date()

        if calendar.isDateInToday(self) {
            // Today
            dateFormatter.timeStyle = .short    // Short time
            dateFormatter.dateStyle = .none     // No date
        } else if calendar.isDateInYesterday(self) {
            // Yesterday
            dateFormatter.timeStyle = .none     // No time
            dateFormatter.dateStyle = .medium   // "Yesterday
        } else if lastWeekRange.contains(self) {
            let weekday = calendar.component(.weekday, from: self)
            return dateFormatter.weekdaySymbols[weekday-1]
        } else {
            dateFormatter.doesRelativeDateFormatting = false
            dateFormatter.dateFormat = DateFormatStyle.dateOnly.rawValue
        }

        return dateFormatter.string(from: self)
    }

    func string(with style: DateFormatStyle) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = style.rawValue
        return dateFormatter.string(from: self)
    }
}
