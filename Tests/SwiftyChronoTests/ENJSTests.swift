// ENJSTests.swift
// Additional EN parser tests ported from the JS test suite.
// Reference dates use the JS-compatible Date() init (0-indexed months).

import XCTest
@testable import SwiftyChrono

class ENJSTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Chrono.preferredLanguage = .english
    }

    override func tearDown() {
        Chrono.preferredLanguage = nil
        super.tearDown()
    }

    private func parse(_ text: String, _ refDate: Date, mode: String = "casual") -> ParsedResult? {
        let chrono = mode == "strict" ? Chrono.strict : Chrono.casual
        return chrono.parse(text, refDate).first
    }

    private func parseAll(_ text: String, _ refDate: Date, mode: String = "casual") -> [ParsedResult] {
        let chrono = mode == "strict" ? Chrono.strict : Chrono.casual
        return chrono.parse(text, refDate)
    }

    private func assertStart(_ result: ParsedResult?, year: Int? = nil, month: Int? = nil, day: Int? = nil,
                              hour: Int? = nil, minute: Int? = nil, second: Int? = nil,
                              file: StaticString = #file, line: UInt = #line) {
        guard let result = result else { return XCTFail("no result", file: file, line: line) }
        if let year   = year   { XCTAssertEqual(result.start[.year],   year,   "year",   file: file, line: line) }
        if let month  = month  { XCTAssertEqual(result.start[.month],  month,  "month",  file: file, line: line) }
        if let day    = day    { XCTAssertEqual(result.start[.day],    day,    "day",    file: file, line: line) }
        if let hour   = hour   { XCTAssertEqual(result.start[.hour],   hour,   "hour",   file: file, line: line) }
        if let minute = minute { XCTAssertEqual(result.start[.minute], minute, "minute", file: file, line: line) }
        if let second = second { XCTAssertEqual(result.start[.second], second, "second", file: file, line: line) }
    }

    private func assertEnd(_ result: ParsedResult?, year: Int? = nil, month: Int? = nil, day: Int? = nil,
                            hour: Int? = nil, minute: Int? = nil, second: Int? = nil,
                            file: StaticString = #file, line: UInt = #line) {
        guard let result = result else { return XCTFail("no result", file: file, line: line) }
        guard let end = result.end else { return XCTFail("no end component", file: file, line: line) }
        if let year   = year   { XCTAssertEqual(end[.year],   year,   "end year",   file: file, line: line) }
        if let month  = month  { XCTAssertEqual(end[.month],  month,  "end month",  file: file, line: line) }
        if let day    = day    { XCTAssertEqual(end[.day],    day,    "end day",    file: file, line: line) }
        if let hour   = hour   { XCTAssertEqual(end[.hour],   hour,   "end hour",   file: file, line: line) }
        if let minute = minute { XCTAssertEqual(end[.minute], minute, "end minute", file: file, line: line) }
        if let second = second { XCTAssertEqual(end[.second], second, "end second", file: file, line: line) }
    }

    // MARK: - Casual (from test_en_casual.js)

    func testCasual_now() {
        // new Date(2012, 7, 10, 8, 9, 10, 11) = August 10, 2012 08:09:10
        let ref = Date(2012, 7, 10, 8, 9, 10)
        let r = parse("The Deadline is now", ref)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 8, minute: 9, second: 10)
    }

    func testCasual_today() {
        let ref = Date(2012, 7, 10, 12)
        let r = parse("The Deadline is today", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testCasual_tomorrow() {
        let ref = Date(2012, 7, 10, 12)
        let r = parse("The Deadline is Tomorrow", ref)
        assertStart(r, year: 2012, month: 8, day: 11)
    }

    func testCasual_yesterday() {
        let ref = Date(2012, 7, 10, 12)
        let r = parse("The Deadline was yesterday", ref)
        assertStart(r, year: 2012, month: 8, day: 9)
    }

    func testCasual_lastNight() {
        let ref = Date(2012, 7, 10, 12)
        let r = parse("The Deadline was last night", ref)
        assertStart(r, year: 2012, month: 8, day: 9, hour: 0)
    }

    func testCasual_thisMorning() {
        let ref = Date(2012, 7, 10, 12)
        let r = parse("The Deadline was this morning", ref)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 6)
    }

    func testCasual_thisAfternoon() {
        let ref = Date(2012, 7, 10, 12)
        let r = parse("The Deadline was this afternoon", ref)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 15)
    }

    func testCasual_thisEvening() {
        let ref = Date(2012, 7, 10, 12)
        let r = parse("The Deadline was this evening", ref)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 18)
    }

    func testCasual_todayAtFivePM() {
        let ref = Date(2012, 7, 10, 12)
        let r = parse("The Deadline is today 5PM", ref)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 17)
    }

    func testCasual_tonight() {
        let ref = Date(2012, 0, 1, 12)
        let r = parse("tonight", ref)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 22)
    }

    func testCasual_tonightAt8pm() {
        let ref = Date(2012, 0, 1, 12)
        let r = parse("tonight 8pm", ref)
        assertStart(r, hour: 20)
    }

    func testCasual_tomorrowBefore4pm() {
        let ref = Date(2012, 0, 1, 12)
        let r = parse("tomorrow before 4pm", ref)
        assertStart(r, year: 2012, month: 1, day: 2, hour: 16)
    }

    func testCasual_negativeCases() {
        let ref = Date(2012, 7, 10)
        XCTAssertEqual(parseAll("notoday", ref).count, 0)
        XCTAssertEqual(parseAll("xyesterday", ref).count, 0)
        XCTAssertEqual(parseAll("nowhere", ref).count, 0)
    }

    // MARK: - Deadline (from test_en_deadline.js)

    func testDeadline_in5Days() {
        let ref = Date(2012, 7, 10)
        let r = parse("we have to do something in 5 days.", ref)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    func testDeadline_inFiveDays_wordNumber() {
        let ref = Date(2012, 7, 10)
        let r = parse("we have to do something in five days.", ref)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    func testDeadline_within10Day() {
        let ref = Date(2012, 7, 10)
        let r = parse("we have to do something within 10 day", ref)
        assertStart(r, year: 2012, month: 8, day: 20)
    }

    func testDeadline_in5Minutes() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("in 5 minutes", ref)
        assertStart(r, hour: 12, minute: 19)
    }

    func testDeadline_within1Hour() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("within 1 hour", ref)
        assertStart(r, hour: 13, minute: 14)
    }

    func testDeadline_in5Seconds() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("In 5 seconds A car need to move", ref)
        assertStart(r, hour: 12, minute: 14, second: 5)
    }

    func testDeadline_withinHalfAnHour() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("within half an hour", ref)
        assertStart(r, hour: 12, minute: 44)
    }

    func testDeadline_withinTwoWeeks() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("within two weeks", ref)
        assertStart(r, year: 2012, month: 8, day: 24)
    }

    func testDeadline_withinOneYear() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("within one year", ref)
        assertStart(r, year: 2013, month: 8, day: 10)
    }

    func testDeadline_strictModeDoesNotMatchCasual() {
        let ref = Date(2012, 7, 10, 12, 14)
        XCTAssertNil(parse("within one year", ref, mode: "strict"))
        XCTAssertNil(parse("within a few months", ref, mode: "strict"))
        XCTAssertNil(parse("within a few days", ref, mode: "strict"))
    }

    // MARK: - Time Ago (from test_en_time_ago.js)

    func testTimeAgo_5DaysAgo() {
        let ref = Date(2012, 7, 10)
        let r = parse("5 days ago, we did something", ref)
        assertStart(r, year: 2012, month: 8, day: 5)
    }

    func testTimeAgo_10DaysAgo_crossesMonthBoundary() {
        let ref = Date(2012, 7, 10)
        let r = parse("10 days ago, we did something", ref)
        assertStart(r, year: 2012, month: 7, day: 31)
    }

    func testTimeAgo_15MinuteAgo() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("15 minute ago", ref)
        assertStart(r, hour: 11, minute: 59)
    }

    func testTimeAgo_15MinuteEarlier() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("15 minute earlier", ref)
        assertStart(r, hour: 11, minute: 59)
    }

    func testTimeAgo_12HoursAgo() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("   12 hours ago", ref)
        assertStart(r, hour: 0, minute: 14)
    }

    func testTimeAgo_halfAnHourAgo() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("   half an hour ago", ref)
        assertStart(r, hour: 11, minute: 44)
    }

    func testTimeAgo_12SecondsAgo() {
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("12 seconds ago I did something", ref)
        assertStart(r, hour: 12, minute: 13, second: 48)
    }

    func testTimeAgo_5MonthsAgo() {
        let ref = Date(2012, 7, 10) // August 10
        let r = parse("5 months ago, we did something", ref)
        assertStart(r, year: 2012, month: 3, day: 10)
    }

    func testTimeAgo_5YearsAgo() {
        let ref = Date(2012, 7, 10) // August 10, 2012
        let r = parse("5 years ago, we did something", ref)
        assertStart(r, year: 2007, month: 8, day: 10)
    }

    func testTimeAgo_aWeekAgo() {
        let ref = Date(2012, 7, 3) // August 3
        let r = parse("a week ago, we did something", ref)
        assertStart(r, year: 2012, month: 7, day: 27)
    }

    func testTimeAgo_aFewDaysAgo() {
        let ref = Date(2012, 7, 3)
        let r = parse("a few days ago, we did something", ref)
        assertStart(r, year: 2012, month: 7, day: 31)
    }

    func testTimeAgo_strictDoesNotMatchCasual() {
        let ref = Date(2012, 7, 3)
        XCTAssertNil(parse("a week ago, we did something", ref, mode: "strict"))
    }

    // MARK: - Weekday (from test_en_weekday.js)

    func testWeekday_monday_looksBehind() {
        // ref = Aug 9 2012 (Thursday). Monday before is Aug 6.
        let ref = Date(2012, 7, 9)
        let r = parse("Monday", ref)
        assertStart(r, year: 2012, month: 8, day: 6)
        XCTAssertEqual(r?.start[.weekday], 1)
        XCTAssertFalse(r!.start.isCertain(component: .day))
    }

    func testWeekday_monday_forwardDate() {
        let ref = Date(2012, 7, 9)
        let r = Chrono.casual.parse("Monday", ref, [.forwardDate: 1]).first
        assertStart(r, year: 2012, month: 8, day: 13)
    }

    func testWeekday_thursday_sameDay() {
        let ref = Date(2012, 7, 9) // Thursday Aug 9
        let r = parse("Thursday", ref)
        assertStart(r, year: 2012, month: 8, day: 9)
        XCTAssertEqual(r?.start[.weekday], 4)
    }

    func testWeekday_sunday_lookAhead() {
        let ref = Date(2012, 7, 9) // Thursday Aug 9. Sunday = Aug 12
        let r = parse("Sunday", ref)
        assertStart(r, year: 2012, month: 8, day: 12)
        XCTAssertEqual(r?.start[.weekday], 0)
    }

    func testWeekday_lastFriday() {
        let ref = Date(2012, 7, 9) // Thursday Aug 9
        let r = parse("The Deadline is last Friday...", ref)
        assertStart(r, year: 2012, month: 8, day: 3)
        XCTAssertEqual(r?.start[.weekday], 5)
    }

    func testWeekday_pastFriday() {
        let ref = Date(2012, 7, 9)
        let r = parse("The Deadline is past Friday...", ref)
        assertStart(r, year: 2012, month: 8, day: 3)
    }

    func testWeekday_fridayNextWeek() {
        let ref = Date(2015, 3, 18) // Saturday April 18, 2015
        let r = parse("Let's have a meeting on Friday next week", ref)
        assertStart(r, year: 2015, month: 4, day: 24)
        XCTAssertEqual(r?.start[.weekday], 5)
    }

    func testWeekday_tuesdayNextWeek() {
        let ref = Date(2015, 3, 18)
        let r = parse("I plan on taking the day off on Tuesday, next week", ref)
        assertStart(r, year: 2015, month: 4, day: 21)
        XCTAssertEqual(r?.start[.weekday], 2)
    }

    func testWeekday_withMorning() {
        let ref = Date(2015, 3, 18)
        let r = parse("Lets meet on Tuesday morning", ref)
        assertStart(r, year: 2015, month: 4, day: 21, hour: 6)
    }

    func testWeekday_fullDateWithWeekday() {
        // Explicit date with weekday prefix — weekday is certain
        let ref = Date(2012, 7, 9)
        let r = parse("Sunday, December 7, 2014", ref)
        assertStart(r, year: 2014, month: 12, day: 7)
        XCTAssertEqual(r?.start[.weekday], 0)
        XCTAssertTrue(r!.start.isCertain(component: .day))
    }

    // MARK: - Middle Endian (from test_en_middle_endian.js)

    func testMiddle_julyWithYear() {
        let ref = Date(2012, 7, 10)
        let r = parse("She is getting married soon (July 2017).", ref)
        assertStart(r, year: 2017, month: 7, day: 1)
    }

    func testMiddle_monthOnly() {
        let ref = Date(2012, 7, 10)
        let r = parse("She is leaving in August.", ref)
        assertStart(r, year: 2012, month: 8, day: 1)
    }

    func testMiddle_monthAndYear() {
        let ref = Date(2012, 7, 10)
        let r = parse("I am arriving sometime in August, 2012, probably.", ref)
        assertStart(r, year: 2012, month: 8, day: 1)
    }

    func testMiddle_fullDate() {
        let ref = Date(2012, 7, 10)
        let r = parse("August 10, 2012", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testMiddle_dayRange() {
        let ref = Date(2012, 7, 10)
        let r = parse("August 10 - 22, 2012", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 8, day: 22)
    }

    func testMiddle_monthRange() {
        let ref = Date(2012, 7, 10)
        let r = parse("August 10 - November 12", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 11, day: 12)
    }

    func testMiddle_ordinalDay() {
        let ref = Date(2012, 7, 10)
        let r = parse("May eighth, 2010", ref)
        assertStart(r, year: 2010, month: 5, day: 8)
    }

    func testMiddle_impossibleDateStrictMode() {
        let ref = Date(2012, 7, 10)
        XCTAssertNil(parse("August 32, 2014", ref, mode: "strict"))
        XCTAssertNil(parse("Febuary 29, 2014", ref, mode: "strict"))
    }

    // MARK: - Little Endian (from test_en_little_endian.js)

    func testLittle_dayMonthYear() {
        let ref = Date(2012, 7, 10)
        let r = parse("10 August 2012", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testLittle_withWeekdayPrefix() {
        let ref = Date(2013, 7, 10)
        let r = parse("Sun 15Sep", ref)
        assertStart(r, year: 2013, month: 9, day: 15)
    }

    func testLittle_withWeekdayPrefixUppercase() {
        let ref = Date(2013, 7, 10)
        let r = parse("SUN 15SEP", ref)
        assertStart(r, year: 2013, month: 9, day: 15)
    }

    func testLittle_ordinal() {
        let ref = Date(2012, 7, 10)
        let r = parse("31st March, 2016", ref)
        assertStart(r, year: 2016, month: 3, day: 31)
    }

    func testLittle_ordinalLowercase() {
        let ref = Date(2012, 7, 10)
        let r = parse("23rd february, 2016", ref)
        assertStart(r, year: 2016, month: 2, day: 23)
    }

    func testLittle_rangeWithSameMonth() {
        let ref = Date(2012, 7, 10)
        let r = parse("10 - 22 August 2012", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 8, day: 22)
    }

    func testLittle_rangeAcrossMonths() {
        let ref = Date(2012, 7, 10)
        let r = parse("10 August - 12 September", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 9, day: 12)
    }

    func testLittle_impossibleDateStrictMode() {
        let ref = Date(2012, 7, 10)
        XCTAssertNil(parse("32 August 2014", ref, mode: "strict"))
        XCTAssertNil(parse("29 February 2014", ref, mode: "strict"))
    }

    // MARK: - Slash Date (from test_en_slash.js)

    func testSlash_monthSlashYear() {
        let ref = Date(2012, 7, 10)
        let r = parse("The event is going ahead (04/2016)", ref)
        assertStart(r, year: 2016, month: 4, day: 1)
    }

    func testSlash_fullUSFormat() {
        let ref = Date(2012, 7, 10)
        let r = parse("8/10/2012", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testSlash_withoutYear() {
        let ref = Date(2012, 7, 10)
        let r = parse("8/10", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testSlash_yearFirst() {
        let ref = Date(2012, 7, 10)
        let r = parse("2012/8/10", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testSlash_dateRange() {
        let ref = Date(2012, 7, 10)
        let r = parse("8/10/2012 - 8/15/2012", ref)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 8, day: 15)
    }

    func testSlash_impossibleDateStrictMode() {
        let ref = Date(2012, 7, 10)
        XCTAssertNil(parse("8/32/2014", ref, mode: "strict"))
        XCTAssertNil(parse("2/29/2014", ref, mode: "strict"))
    }

    // MARK: - Dash Date (from test_en_dash.js)

    func testDash_euroPhoneNotParsed() {
        let ref = Date(2012, 7, 10)
        XCTAssertNil(parse("80-32-89-89", ref, mode: "strict"))
    }

    func testDash_mmDdYyWithWeekday() {
        let ref = Date(2012, 7, 10)
        XCTAssertNotNil(parse("Friday 12-30-16", ref, mode: "strict"))
    }

    func testDash_mmDdYy() {
        let ref = Date(2012, 7, 10)
        XCTAssertNotNil(parse("12-30-16", ref, mode: "strict"))
    }

    // MARK: - Relative format (from test_en_relative.js)
    // Note: "next week" / "last week" etc. go through ENRelativeDateRangeFormatParser now
    // which returns a range. Tests here check the start component only.

    func testRelative_next2Weeks() {
        // ENRelativeDateFormatParser: next 2 weeks from Oct 1, 2016
        let ref = Date(2016, 9, 1) // October 1
        let r = parse("next 2 weeks", ref)
        assertStart(r, year: 2016, month: 10, day: 15)
    }

    func testRelative_last2Weeks() {
        let ref = Date(2016, 9, 1)
        let r = parse("last 2 weeks", ref)
        assertStart(r, year: 2016, month: 9, day: 17)
    }

    func testRelative_next2Days() {
        let ref = Date(2016, 9, 1)
        let r = parse("next 2 days", ref)
        assertStart(r, year: 2016, month: 10, day: 3)
    }

    func testRelative_last2Days() {
        let ref = Date(2016, 9, 1)
        let r = parse("last 2 days", ref)
        assertStart(r, year: 2016, month: 9, day: 29)
    }

    func testRelative_next2Months() {
        let ref = Date(2016, 9, 1)
        let r = parse("next 2 months", ref)
        assertStart(r, year: 2016, month: 12, day: 1)
    }

    func testRelative_last2Months() {
        let ref = Date(2016, 9, 1)
        let r = parse("last 2 months", ref)
        assertStart(r, year: 2016, month: 8, day: 1)
    }

    func testRelative_nextFewWeeks() {
        let ref = Date(2016, 9, 1)
        let r = parse("next few weeks", ref)
        assertStart(r, year: 2016, month: 10, day: 22)
    }
}
