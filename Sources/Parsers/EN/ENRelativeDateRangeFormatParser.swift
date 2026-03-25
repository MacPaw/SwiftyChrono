//
//  ENRelativeDateRangeFormatParser.swift
//  SwiftyChrono
//

import Foundation

private let PATTERN = "(\\W|^)" +
    "(this|last|past|next)\\s+" +
    "(minute|hour|day|week|month|quarter|year)" +
    "(?=\\W|$)"

private let modifierWordGroup = 2
private let periodWordGroup = 3

public class ENRelativeDateRangeFormatParser: Parser {
    override var pattern: String { return PATTERN }

    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.enRelativeDateRangeFormatParser] = true

        let modifierWord = match.string(from: text, atRangeIndex: modifierWordGroup).lowercased()
        let periodWord = match.string(from: text, atRangeIndex: periodWordGroup).lowercased()
        let isLast = modifierWord == "last" || modifierWord == "past"
        let isNext = modifierWord == "next"

        let startDate: Date
        let endDate: Date
        var includeTimeComponents = false

        switch periodWord {
        case "year":
            let targetYear = isLast ? ref.year - 1 : (isNext ? ref.year + 1 : ref.year)
            var comps = DateComponents()
            comps.year = targetYear
            comps.month = 1
            comps.day = 1
            startDate = cal.date(from: comps)!
            comps.month = 12
            comps.day = 31
            endDate = cal.date(from: comps)!

        case "quarter":
            // Quarters are 0-indexed: Q1=0 (Jan-Mar), Q2=1 (Apr-Jun), Q3=2 (Jul-Sep), Q4=3 (Oct-Dec)
            let currentQuarterIndex = (ref.month - 1) / 3
            let targetQuarterIndex: Int
            let targetYear: Int
            if isLast {
                targetQuarterIndex = currentQuarterIndex == 0 ? 3 : currentQuarterIndex - 1
                targetYear = currentQuarterIndex == 0 ? ref.year - 1 : ref.year
            } else if isNext {
                targetQuarterIndex = currentQuarterIndex == 3 ? 0 : currentQuarterIndex + 1
                targetYear = currentQuarterIndex == 3 ? ref.year + 1 : ref.year
            } else {
                targetQuarterIndex = currentQuarterIndex
                targetYear = ref.year
            }
            let startMonth = targetQuarterIndex * 3 + 1
            let endMonth = targetQuarterIndex * 3 + 3
            var comps = DateComponents()
            comps.year = targetYear
            comps.month = startMonth
            comps.day = 1
            startDate = cal.date(from: comps)!
            comps.month = endMonth
            let daysInEndMonth = cal.date(from: comps)!.numberOf(.day, inA: .month) ?? 30
            comps.day = daysInEndMonth
            endDate = cal.date(from: comps)!

        case "month":
            let targetDate = isLast ? ref.added(-1, .month) : (isNext ? ref.added(1, .month) : ref)
            let daysInMonth = targetDate.numberOf(.day, inA: .month) ?? 30
            var comps = DateComponents()
            comps.year = targetDate.year
            comps.month = targetDate.month
            comps.day = 1
            startDate = cal.date(from: comps)!
            comps.day = daysInMonth
            endDate = cal.date(from: comps)!

        case "week":
            // weekday: 0=Sunday, 1=Monday, ..., 6=Saturday
            // daysFromMonday gives how many days back to reach the Monday of this week
            let daysFromMonday = (ref.weekday + 6) % 7
            let weekStart: Date
            if isLast {
                weekStart = ref.added(-(daysFromMonday + 7), .day)
            } else if isNext {
                weekStart = ref.added(7 - daysFromMonday, .day)
            } else {
                weekStart = ref.added(-daysFromMonday, .day)
            }
            startDate = weekStart
            endDate = weekStart.added(6, .day)

        case "day":
            let targetDay = isLast ? ref.added(-1, .day) : (isNext ? ref.added(1, .day) : ref)
            startDate = targetDay
            endDate = targetDay

        case "hour":
            includeTimeComponents = true
            let targetHour = isLast ? ref.added(-1, .hour) : (isNext ? ref.added(1, .hour) : ref)
            var comps = DateComponents()
            comps.year = targetHour.year
            comps.month = targetHour.month
            comps.day = targetHour.day
            comps.hour = targetHour.hour
            comps.minute = 0
            comps.second = 0
            startDate = cal.date(from: comps)!
            comps.minute = 59
            comps.second = 59
            endDate = cal.date(from: comps)!

        case "minute":
            includeTimeComponents = true
            let targetMinute = isLast ? ref.added(-1, .minute) : (isNext ? ref.added(1, .minute) : ref)
            var comps = DateComponents()
            comps.year = targetMinute.year
            comps.month = targetMinute.month
            comps.day = targetMinute.day
            comps.hour = targetMinute.hour
            comps.minute = targetMinute.minute
            comps.second = 0
            startDate = cal.date(from: comps)!
            comps.second = 59
            endDate = cal.date(from: comps)!

        default:
            return nil
        }

        result.start.assign(.year, value: startDate.year)
        result.start.assign(.month, value: startDate.month)
        result.start.assign(.day, value: startDate.day)
        if includeTimeComponents {
            result.start.assign(.hour, value: startDate.hour)
            result.start.assign(.minute, value: startDate.minute)
            result.start.assign(.second, value: startDate.second)
        }

        var endComponents = ParsedComponents(components: nil, ref: ref)
        endComponents.assign(.year, value: endDate.year)
        endComponents.assign(.month, value: endDate.month)
        endComponents.assign(.day, value: endDate.day)
        if includeTimeComponents {
            endComponents.assign(.hour, value: endDate.hour)
            endComponents.assign(.minute, value: endDate.minute)
            endComponents.assign(.second, value: endDate.second)
        }
        result.end = endComponents

        return result
    }
}
