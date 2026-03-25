//
//  ENParsersTests.swift
//  SwiftyChrono
//

import XCTest
@testable import SwiftyChrono

/// Unit tests for all EN parsers.
///
/// Fixed reference date: Wednesday, March 25, 2026 at 14:30:00.
/// Date() init is JS-compatible: month is 0-indexed (0 = January).
class ENParsersTests: XCTestCase {

    private let chrono = Chrono.casual

    /// Wednesday 2026-03-25 14:30:00
    private let ref = Date(2026, 2, 25, 14, 30, 0)

    // MARK: - Helpers

    private func parse(_ text: String, _ refDate: Date? = nil) -> ParsedResult? {
        return chrono.parse(text, refDate ?? ref).first
    }

    private func assertStart(
        _ result: ParsedResult?,
        year: Int? = nil, month: Int? = nil, day: Int? = nil,
        hour: Int? = nil, minute: Int? = nil, second: Int? = nil,
        file: StaticString = #file, line: UInt = #line
    ) {
        guard let result = result else { return XCTFail("no result", file: file, line: line) }
        if let year   = year   { XCTAssertEqual(result.start[.year],   year,   "year",   file: file, line: line) }
        if let month  = month  { XCTAssertEqual(result.start[.month],  month,  "month",  file: file, line: line) }
        if let day    = day    { XCTAssertEqual(result.start[.day],    day,    "day",    file: file, line: line) }
        if let hour   = hour   { XCTAssertEqual(result.start[.hour],   hour,   "hour",   file: file, line: line) }
        if let minute = minute { XCTAssertEqual(result.start[.minute], minute, "minute", file: file, line: line) }
        if let second = second { XCTAssertEqual(result.start[.second], second, "second", file: file, line: line) }
    }

    private func assertEnd(
        _ result: ParsedResult?,
        year: Int? = nil, month: Int? = nil, day: Int? = nil,
        hour: Int? = nil, minute: Int? = nil, second: Int? = nil,
        file: StaticString = #file, line: UInt = #line
    ) {
        guard let result = result else { return XCTFail("no result", file: file, line: line) }
        guard let end = result.end else { return XCTFail("no end component", file: file, line: line) }
        if let year   = year   { XCTAssertEqual(end[.year],   year,   "end year",   file: file, line: line) }
        if let month  = month  { XCTAssertEqual(end[.month],  month,  "end month",  file: file, line: line) }
        if let day    = day    { XCTAssertEqual(end[.day],    day,    "end day",    file: file, line: line) }
        if let hour   = hour   { XCTAssertEqual(end[.hour],   hour,   "end hour",   file: file, line: line) }
        if let minute = minute { XCTAssertEqual(end[.minute], minute, "end minute", file: file, line: line) }
        if let second = second { XCTAssertEqual(end[.second], second, "end second", file: file, line: line) }
    }

    // MARK: - ENISOFormatParser

    func testISO_dateOnly() {
        let r = parse("2026-03-25")
        assertStart(r, year: 2026, month: 3, day: 25)
        XCTAssertEqual(r?.text, "2026-03-25")
    }

    func testISO_dateTime() {
        let r = parse("2026-03-25T09:15:00Z")
        assertStart(r, year: 2026, month: 3, day: 25, hour: 9, minute: 15, second: 0)
        XCTAssertTrue(r!.start.isCertain(component: .hour))
    }

    func testISO_dateTimeWithOffset() {
        let r = parse("2026-01-01T12:00:00+05:30")
        assertStart(r, year: 2026, month: 1, day: 1, hour: 12, minute: 0)
        XCTAssertTrue(r!.start.isCertain(component: .timeZoneOffset))
    }

    func testISO_embeddedInText() {
        let r = parse("meeting on 2026-06-15 at noon")
        assertStart(r, year: 2026, month: 6, day: 15)
    }

    // MARK: - ENMonthNameMiddleEndianParser  (Month Day, Year)

    func testMonthMiddle_withYear() {
        let r = parse("March 25, 2026")
        assertStart(r, year: 2026, month: 3, day: 25)
        XCTAssertTrue(r!.start.isCertain(component: .year))
    }

    func testMonthMiddle_withoutYear() {
        // "April 15" near ref (March 25, 2026) → closest = April 15, 2026
        let r = parse("April 15")
        assertStart(r, month: 4, day: 15)
        XCTAssertFalse(r!.start.isCertain(component: .year))
    }

    func testMonthMiddle_abbreviated() {
        let r = parse("Jan. 1, 2026")
        assertStart(r, year: 2026, month: 1, day: 1)
    }

    func testMonthMiddle_ordinal() {
        let r = parse("February third, 2026")
        assertStart(r, year: 2026, month: 2, day: 3)
    }

    func testMonthMiddle_rangeProducesEnd() {
        let r = parse("March 10 - 12, 2026")
        assertStart(r, year: 2026, month: 3, day: 10)
        assertEnd(r, day: 12)
        XCTAssertNotNil(r?.end)
    }

    // MARK: - ENMonthNameLittleEndianParser  (Day Month Year)

    func testMonthLittle_withYear() {
        let r = parse("25 March 2026")
        assertStart(r, year: 2026, month: 3, day: 25)
    }

    func testMonthLittle_abbreviated() {
        let r = parse("1 Jan 2026")
        assertStart(r, year: 2026, month: 1, day: 1)
    }

    // MARK: - ENMonthNameParser  (Month Year — no day)

    func testMonthName_monthAndYear() {
        let r = parse("in March 2026")
        assertStart(r, year: 2026, month: 3)
    }

    // MARK: - ENSlashDateFormatParser  (MM/DD/YYYY)

    func testSlash_fullDate() {
        let r = parse("3/25/2026")
        assertStart(r, year: 2026, month: 3, day: 25)
    }

    func testSlash_twoDigitYear() {
        let r = parse("3/25/26")
        assertStart(r, year: 2026, month: 3, day: 25)
    }

    func testSlash_withoutYear() {
        let r = parse("3/25")
        assertStart(r, month: 3, day: 25)
    }

    func testSlash_disambiguatesLargeMonth() {
        // 25/3/2026 → day=25, month=3 (large first number unambiguous)
        let r = parse("25/3/2026")
        assertStart(r, year: 2026, month: 3, day: 25)
    }

    // MARK: - ENSlashDateFormatStartWithYearParser  (YYYY/MM/DD)

    func testSlashStartYear_fullDate() {
        let r = parse("2026/03/25")
        assertStart(r, year: 2026, month: 3, day: 25)
    }

    // MARK: - ENTimeExpressionParser

    func testTimeExp_12hourPM() {
        let r = parse("at 3pm")
        assertStart(r, hour: 15)
        XCTAssertTrue(r!.start.isCertain(component: .hour))
    }

    func testTimeExp_12hourAM() {
        let r = parse("at 10 AM")
        assertStart(r, hour: 10, minute: 0)
    }

    func testTimeExp_24hourWithMinutes() {
        let r = parse("at 14:30")
        assertStart(r, hour: 14, minute: 30)
    }

    func testTimeExp_withSeconds() {
        let r = parse("at 09:15:30")
        assertStart(r, hour: 9, minute: 15, second: 30)
    }

    func testTimeExp_range() {
        let r = parse("from 9am to 5pm")
        assertStart(r, hour: 9)
        assertEnd(r, hour: 17)
        XCTAssertNotNil(r?.end)
    }

    // MARK: - ENCasualDateParser

    func testCasual_today() {
        let r = parse("meet today")
        XCTAssertEqual(r?.text, "today")
        assertStart(r, year: 2026, month: 3, day: 25)
    }

    func testCasual_tomorrow() {
        let r = parse("see you tomorrow")
        assertStart(r, year: 2026, month: 3, day: 26)
    }

    func testCasual_tmr() {
        let r = parse("see you tmr")
        assertStart(r, day: 26)
    }

    func testCasual_yesterday() {
        let r = parse("happened yesterday")
        assertStart(r, year: 2026, month: 3, day: 24)
    }

    func testCasual_tonight() {
        let r = parse("let's meet tonight")
        assertStart(r, day: 25, hour: 22)
        XCTAssertFalse(r!.start.isCertain(component: .hour))
    }

    func testCasual_lastNight_afterSixAM() {
        // ref hour = 14 (> 6) → last night = yesterday
        let r = parse("last night was fun")
        assertStart(r, month: 3, day: 24)
    }

    func testCasual_lastNight_beforeSixAM() {
        let earlyRef = Date(2026, 2, 25, 2, 0, 0) // 02:00
        let r = chrono.parse("last night", earlyRef).first
        // hour ≤ 6 → same day (not yesterday)
        assertStart(r, day: 25)
    }

    func testCasual_now() {
        let r = parse("right now")
        assertStart(r, year: 2026, month: 3, day: 25)
        XCTAssertFalse(r!.start.isCertain(component: .hour))
    }

    // MARK: - ENCasualTimeParser

    func testCasualTime_morning() {
        let r = parse("this morning")
        assertStart(r, hour: 6)
        XCTAssertFalse(r!.start.isCertain(component: .hour))
    }

    func testCasualTime_afternoon() {
        let r = parse("this afternoon")
        assertStart(r, hour: 15)
    }

    func testCasualTime_evening() {
        let r = parse("this evening")
        assertStart(r, hour: 18)
    }

    func testCasualTime_noon() {
        let r = parse("noon meeting")
        assertStart(r, hour: 12)
    }

    func testCasualTime_customOptions() {
        let r = chrono.parse("morning", ref, [.morning: 7]).first
        assertStart(r, hour: 7)
    }

    // MARK: - ENWeekdayParser

    func testWeekday_nextFriday() {
        // Wed March 25 + 9 days = Fri April 3
        let r = parse("next Friday")
        assertStart(r, month: 4, day: 3)
        XCTAssertEqual(r?.start[.weekday], 5)
        XCTAssertTrue(r!.start.isCertain(component: .day))
    }

    func testWeekday_lastTuesday() {
        // Wed March 25 - 8 days = Tue March 17
        let r = parse("last Tuesday")
        assertStart(r, month: 3, day: 17)
        XCTAssertEqual(r?.start[.weekday], 2)
        XCTAssertTrue(r!.start.isCertain(component: .day))
    }

    func testWeekday_thisWednesday() {
        let r = parse("this Wednesday")
        assertStart(r, year: 2026, month: 3, day: 25)
        XCTAssertEqual(r?.start[.weekday], 3)
    }

    func testWeekday_plain() {
        // bare weekday name → implied (not certain)
        let r = parse("see you Monday")
        XCTAssertEqual(r?.start[.weekday], 1)
        XCTAssertFalse(r!.start.isCertain(component: .day))
    }

    func testWeekday_onMonday() {
        let r = parse("on Monday")
        XCTAssertEqual(r?.start[.weekday], 1)
    }

    // MARK: - ENDeadlineFormatParser

    func testDeadline_inDays() {
        let r = parse("done in 3 days")
        assertStart(r, year: 2026, month: 3, day: 28)
        XCTAssertTrue(r!.start.isCertain(component: .day))
    }

    func testDeadline_withinHours() {
        let r = parse("within 2 hours")
        assertStart(r, hour: 16, minute: 30)
    }

    func testDeadline_inAWeek() {
        // March 25 + 7 = April 1
        let r = parse("in a week")
        assertStart(r, month: 4, day: 1)
    }

    func testDeadline_halfAnHour() {
        // 14:30 + 30 min = 15:00
        let r = parse("in half an hour")
        assertStart(r, hour: 15, minute: 0)
    }

    func testDeadline_inMonths() {
        // March + 2 = May
        let r = parse("in 2 months")
        assertStart(r, year: 2026, month: 5)
    }

    func testDeadline_wordNumber() {
        let r = parse("in three days")
        assertStart(r, day: 28)
    }

    func testDeadline_inYear() {
        let r = parse("in 1 year")
        assertStart(r, year: 2027)
    }

    // MARK: - ENTimeAgoFormatParser

    func testTimeAgo_daysAgo() {
        // March 25 - 3 = March 22
        let r = parse("3 days ago")
        assertStart(r, year: 2026, month: 3, day: 22)
        XCTAssertTrue(r!.start.isCertain(component: .day))
    }

    func testTimeAgo_hoursAgo() {
        // 14:30 - 2h = 12:30
        let r = parse("2 hours ago")
        assertStart(r, hour: 12, minute: 30)
    }

    func testTimeAgo_minutesAgo() {
        let r = parse("10 minutes ago")
        assertStart(r, hour: 14, minute: 20)
    }

    func testTimeAgo_aWeekAgo() {
        // March 25 - 7 = March 18
        let r = parse("a week ago")
        assertStart(r, month: 3, day: 18)
        // week uses imply
        XCTAssertFalse(r!.start.isCertain(component: .day))
    }

    func testTimeAgo_halfAnHourAgo() {
        // 14:30 - 30 min = 14:00
        let r = parse("half an hour ago")
        assertStart(r, hour: 14, minute: 0)
    }

    func testTimeAgo_yearsAgo() {
        let r = parse("2 years ago")
        assertStart(r, year: 2024)
    }

    func testTimeAgo_monthsAgo() {
        // March - 3 = December 2025
        let r = parse("3 months ago")
        assertStart(r, year: 2025, month: 12)
    }

    func testTimeAgo_anHourAgo() {
        let r = parse("an hour ago")
        assertStart(r, hour: 13)
    }

    // MARK: - ENRelativeDateFormatParser  (modifier + explicit number + period)

    func testRelFormat_next3Days() {
        let r = parse("next 3 days")
        assertStart(r, year: 2026, month: 3, day: 28)
        XCTAssertTrue(r!.start.isCertain(component: .day))
    }

    func testRelFormat_last2Weeks() {
        // March 25 - 14 = March 11; week uses imply
        let r = parse("last 2 weeks")
        assertStart(r, year: 2026, month: 3, day: 11)
        XCTAssertFalse(r!.start.isCertain(component: .day))
    }

    func testRelFormat_past4Months() {
        // March 2026 - 4 = November 2025; month assigns year+month, implies day
        let r = parse("past 4 months")
        assertStart(r, year: 2025, month: 11)
        XCTAssertTrue(r!.start.isCertain(component: .year))
        XCTAssertTrue(r!.start.isCertain(component: .month))
        XCTAssertFalse(r!.start.isCertain(component: .day))
    }

    func testRelFormat_next2Years() {
        let r = parse("next 2 years")
        assertStart(r, year: 2028)
        XCTAssertTrue(r!.start.isCertain(component: .year))
        XCTAssertFalse(r!.start.isCertain(component: .month))
    }

    func testRelFormat_wordNumber() {
        let r = parse("next three days")
        assertStart(r, day: 28)
    }

    func testRelFormat_noMatchWithoutNumber() {
        // "last week" must NOT be consumed by ENRelativeDateFormatParser
        let results = chrono.parse("last week", ref)
        XCTAssertEqual(results.count, 1)
        // ENRelativeDateRangeFormatParser handles it → has end
        XCTAssertNotNil(results.first?.end)
    }

    // MARK: - ENRelativeDateRangeFormatParser

    // MARK: Years

    func testRange_lastYear() {
        let r = parse("report for last year")
        assertStart(r, year: 2025, month: 1, day: 1)
        assertEnd(r, year: 2025, month: 12, day: 31)
    }

    func testRange_thisYear() {
        let r = parse("this year budget")
        assertStart(r, year: 2026, month: 1, day: 1)
        assertEnd(r, year: 2026, month: 12, day: 31)
    }

    func testRange_nextYear() {
        let r = parse("plan for next year")
        assertStart(r, year: 2027, month: 1, day: 1)
        assertEnd(r, year: 2027, month: 12, day: 31)
    }

    func testRange_pastYear_equalsLastYear() {
        let last = parse("last year")
        let past = parse("past year")
        XCTAssertEqual(last?.start[.year], past?.start[.year])
        XCTAssertEqual(last?.end?[.year],  past?.end?[.year])
    }

    // MARK: Quarters

    func testRange_lastQuarter_fromQ1_rollsBackToQ4PrevYear() {
        // ref is in Q1 2026 → last quarter = Q4 2025 (Oct–Dec)
        let r = parse("last quarter")
        assertStart(r, year: 2025, month: 10, day: 1)
        assertEnd(r, year: 2025, month: 12, day: 31)
    }

    func testRange_thisQuarter_Q1() {
        let r = parse("this quarter")
        assertStart(r, year: 2026, month: 1, day: 1)
        assertEnd(r, year: 2026, month: 3, day: 31)
    }

    func testRange_nextQuarter_fromQ1() {
        // Q2 = Apr–Jun
        let r = parse("next quarter")
        assertStart(r, year: 2026, month: 4, day: 1)
        assertEnd(r, year: 2026, month: 6, day: 30)
    }

    func testRange_lastQuarter_fromQ4_rollsBackWithinSameYear() {
        // ref in Q4 2025 (December) → last quarter = Q3 2025 (Jul–Sep)
        let q4Ref = Date(2025, 11, 15)
        let r = chrono.parse("last quarter", q4Ref).first
        assertStart(r, year: 2025, month: 7, day: 1)
        assertEnd(r, year: 2025, month: 9, day: 30)
    }

    func testRange_nextQuarter_fromQ4_rollsToNextYear() {
        // ref in Q4 2025 → next quarter = Q1 2026
        let q4Ref = Date(2025, 11, 15)
        let r = chrono.parse("next quarter", q4Ref).first
        assertStart(r, year: 2026, month: 1, day: 1)
        assertEnd(r, year: 2026, month: 3, day: 31)
    }

    func testRange_thisQuarter_fromQ2() {
        // ref in Q2 (May) → Q2 = Apr–Jun
        let q2Ref = Date(2026, 4, 15)
        let r = chrono.parse("this quarter", q2Ref).first
        assertStart(r, year: 2026, month: 4, day: 1)
        assertEnd(r, year: 2026, month: 6, day: 30)
    }

    func testRange_thisQuarter_fromQ3() {
        // ref in Q3 (August) → Q3 = Jul–Sep
        let q3Ref = Date(2026, 7, 10)
        let r = chrono.parse("this quarter", q3Ref).first
        assertStart(r, year: 2026, month: 7, day: 1)
        assertEnd(r, year: 2026, month: 9, day: 30)
    }

    func testRange_nextQuarter_fromQ2_isQ3() {
        let q2Ref = Date(2026, 4, 15)
        let r = chrono.parse("next quarter", q2Ref).first
        assertStart(r, year: 2026, month: 7, day: 1)
        assertEnd(r, year: 2026, month: 9, day: 30)
    }

    func testRange_lastQuarter_fromQ3_isQ2() {
        let q3Ref = Date(2026, 7, 10)
        let r = chrono.parse("last quarter", q3Ref).first
        assertStart(r, year: 2026, month: 4, day: 1)
        assertEnd(r, year: 2026, month: 6, day: 30)
    }

    func testRange_pastQuarter_equalsLastQuarter() {
        let last = parse("last quarter")
        let past = parse("past quarter")
        XCTAssertEqual(last?.start[.month], past?.start[.month])
        XCTAssertEqual(last?.end?[.month],  past?.end?[.month])
    }

    // MARK: Months

    func testRange_lastMonth_february28Days() {
        // ref = March 2026 → last month = Feb 2026 (28 days, not a leap year)
        let r = parse("last month")
        assertStart(r, year: 2026, month: 2, day: 1)
        assertEnd(r, year: 2026, month: 2, day: 28)
    }

    func testRange_thisMonth() {
        let r = parse("this month")
        assertStart(r, year: 2026, month: 3, day: 1)
        assertEnd(r, month: 3, day: 31)
    }

    func testRange_nextMonth() {
        // April = 30 days
        let r = parse("next month")
        assertStart(r, month: 4, day: 1)
        assertEnd(r, month: 4, day: 30)
    }

    func testRange_lastMonth_fromJanuary_rollsToDecember() {
        let janRef = Date(2026, 0, 15)
        let r = chrono.parse("last month", janRef).first
        assertStart(r, year: 2025, month: 12, day: 1)
        assertEnd(r, year: 2025, month: 12, day: 31)
    }

    func testRange_lastMonth_leapYearFebruary() {
        // ref = March 15 2024 (leap year) → last month = Feb 2024 = 29 days
        let marchRef = Date(2024, 2, 15)
        let r = chrono.parse("last month", marchRef).first
        assertStart(r, year: 2024, month: 2, day: 1)
        assertEnd(r, year: 2024, month: 2, day: 29)
    }

    func testRange_nextMonth_fromJanuary_isFebruary28Days() {
        // 2026 is not a leap year → Feb has 28 days
        let janRef = Date(2026, 0, 31)
        let r = chrono.parse("next month", janRef).first
        assertStart(r, year: 2026, month: 2, day: 1)
        assertEnd(r, year: 2026, month: 2, day: 28)
    }

    func testRange_thisMonth_31Days() {
        // August has 31 days
        let augRef = Date(2026, 7, 15)
        let r = chrono.parse("this month", augRef).first
        assertStart(r, year: 2026, month: 8, day: 1)
        assertEnd(r, year: 2026, month: 8, day: 31)
    }

    func testRange_pastMonth_equalsLastMonth() {
        let last = parse("last month")
        let past = parse("past month")
        XCTAssertEqual(last?.start[.month], past?.start[.month])
        XCTAssertEqual(last?.end?[.day],    past?.end?[.day])
    }

    // MARK: Weeks

    func testRange_lastWeek() {
        // ref = Wed March 25; daysFromMonday = 2
        // last week Mon = March 16, Sun = March 22
        let r = parse("last week")
        assertStart(r, year: 2026, month: 3, day: 16)
        assertEnd(r, year: 2026, month: 3, day: 22)
    }

    func testRange_thisWeek() {
        // Mon March 23 → Sun March 29
        let r = parse("this week")
        assertStart(r, month: 3, day: 23)
        assertEnd(r, month: 3, day: 29)
    }

    func testRange_nextWeek() {
        // Mon March 30 → Sun April 5
        let r = parse("next week")
        assertStart(r, month: 3, day: 30)
        assertEnd(r, month: 4, day: 5)
    }

    func testRange_pastWeek_equalsLastWeek() {
        let last = parse("last week")
        let past = parse("past week")
        XCTAssertEqual(last?.start[.day], past?.start[.day])
        XCTAssertEqual(last?.end?[.day],  past?.end?[.day])
    }

    func testRange_thisWeek_fromMonday() {
        // ref = Monday March 23 → daysFromMonday = 0 → no shift
        let monRef = Date(2026, 2, 23, 10, 0, 0)
        let r = chrono.parse("this week", monRef).first
        assertStart(r, day: 23)
        assertEnd(r, day: 29)
    }

    func testRange_thisWeek_fromSunday() {
        // ref = Sunday March 29 → weekday=0, daysFromMonday=(0+6)%7=6
        // thisWeekMon = March 29-6 = March 23
        let sunRef = Date(2026, 2, 29, 10, 0, 0)
        let r = chrono.parse("this week", sunRef).first
        assertStart(r, day: 23)
        assertEnd(r, day: 29)
    }

    func testRange_nextWeek_fromMonday() {
        // ref = Monday March 23 → daysFromMonday=0 → nextWeekMon = March 23+7 = March 30
        let monRef = Date(2026, 2, 23, 10, 0, 0)
        let r = chrono.parse("next week", monRef).first
        assertStart(r, day: 30)
        assertEnd(r, month: 4, day: 5)
    }

    // MARK: Days

    func testRange_lastDay() {
        let r = parse("last day")
        assertStart(r, year: 2026, month: 3, day: 24)
        assertEnd(r, day: 24)
    }

    func testRange_thisDay() {
        let r = parse("this day")
        assertStart(r, year: 2026, month: 3, day: 25)
        assertEnd(r, day: 25)
    }

    func testRange_nextDay() {
        let r = parse("next day")
        assertStart(r, day: 26)
        assertEnd(r, day: 26)
    }

    func testRange_pastDay_equalsLastDay() {
        let last = parse("last day")
        let past = parse("past day")
        XCTAssertEqual(last?.start[.day], past?.start[.day])
    }

    // MARK: Hours

    func testRange_lastHour() {
        // ref = 14:30 → targetHour.hour = 13 → 13:00:00–13:59:59
        let r = parse("last hour")
        assertStart(r, year: 2026, month: 3, day: 25, hour: 13, minute: 0, second: 0)
        assertEnd(r, hour: 13, minute: 59, second: 59)
    }

    func testRange_thisHour() {
        // ref = 14:30 → 14:00:00–14:59:59
        let r = parse("this hour")
        assertStart(r, hour: 14, minute: 0, second: 0)
        assertEnd(r, hour: 14, minute: 59, second: 59)
    }

    func testRange_nextHour() {
        // ref = 14:30 → 15:00:00–15:59:59
        let r = parse("next hour")
        assertStart(r, hour: 15, minute: 0, second: 0)
        assertEnd(r, hour: 15, minute: 59, second: 59)
    }

    func testRange_lastHour_rollsBackToPreviousDay() {
        // ref = 00:30 → lastHour = hour 23 of March 24
        let midnightRef = Date(2026, 2, 25, 0, 30, 0)
        let r = chrono.parse("last hour", midnightRef).first
        assertStart(r, day: 24, hour: 23, minute: 0)
        assertEnd(r, day: 24, hour: 23, minute: 59)
    }

    // MARK: Minutes

    func testRange_lastMinute() {
        // ref = 14:30 → 14:29:00–14:29:59
        let r = parse("last minute")
        assertStart(r, hour: 14, minute: 29, second: 0)
        assertEnd(r, minute: 29, second: 59)
    }

    func testRange_thisMinute() {
        let r = parse("this minute")
        assertStart(r, hour: 14, minute: 30, second: 0)
        assertEnd(r, minute: 30, second: 59)
    }

    func testRange_nextMinute() {
        let r = parse("next minute")
        assertStart(r, minute: 31, second: 0)
        assertEnd(r, minute: 31, second: 59)
    }

    func testRange_lastMinute_rollsBackToPreviousHour() {
        // ref = 14:00 → last minute = 13:59:00–13:59:59
        let topOfHourRef = Date(2026, 2, 25, 14, 0, 0)
        let r = chrono.parse("last minute", topOfHourRef).first
        assertStart(r, hour: 13, minute: 59, second: 0)
        assertEnd(r, hour: 13, minute: 59, second: 59)
    }

    // MARK: Result structure invariants

    func testRange_alwaysHasEnd() {
        let expressions = [
            "last year", "this quarter", "next month",
            "last week", "this day", "next hour", "last minute",
        ]
        for text in expressions {
            let r = chrono.parse(text, ref).first
            XCTAssertNotNil(r?.end, "\(text) should have an end component")
        }
    }

    func testRange_startDateNotAfterEndDate() {
        let expressions = [
            "last year", "this year", "next year",
            "last quarter", "this quarter", "next quarter",
            "last month", "this month", "next month",
            "last week", "this week", "next week",
            "last hour", "this hour", "next hour",
            "last minute", "this minute", "next minute",
        ]
        for text in expressions {
            let r = chrono.parse(text, ref).first!
            guard let end = r.end else { XCTFail("\(text): no end"); continue }
            XCTAssertLessThanOrEqual(
                r.start.date, end.date,
                "\(text): start must be ≤ end"
            )
        }
    }

    func testRange_tagIsSet() {
        let r = parse("last week")
        XCTAssertEqual(r?.tags[.enRelativeDateRangeFormatParser], true)
    }

    func testRange_startComponentsCertain() {
        let r = parse("last year")
        XCTAssertTrue(r!.start.isCertain(component: .year))
        XCTAssertTrue(r!.start.isCertain(component: .month))
        XCTAssertTrue(r!.start.isCertain(component: .day))
    }
}
