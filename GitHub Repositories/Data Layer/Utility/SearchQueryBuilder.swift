//
//  SearchQueryBuilder.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation

protocol SearchQueryProtocol {
    func buildQuery(searchText: String, daysBack: Int) -> String
}

struct SearchQueryBuilder: SearchQueryProtocol {
    private let calendar: Calendar
    private let dateProvider: () -> Date

    init(calendar: Calendar = Calendar(identifier: .gregorian), dateProvider: @escaping () -> Date = Date.init) {
        self.calendar = calendar
        self.dateProvider = dateProvider
    }

    func buildQuery(searchText: String, daysBack: Int = 7) -> String {
        let baseDate = calendar.date(byAdding: .day, value: -daysBack, to: dateProvider()) ?? dateProvider()
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: baseDate)

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "created:>\(dateString)"
        }
        return "created:>\(dateString) \(trimmed)"
    }
}
