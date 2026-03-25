//
//  JPParsersTests.swift
//  SwiftyChrono
//

import XCTest
@testable import SwiftyChrono

/// Unit tests for JP (Japanese) parsers, converted from the JS test suite.
///
/// IMPORTANT: Date() init uses JS-compatible 0-indexed months (0=Jan, 1=Feb, ..., 11=Dec)
/// So new Date(2012, 7, 10) in JS = Date(2012, 7, 10) in Swift = August 10, 2012
class JPParsersTests: XCTestCase {

    // MARK: - Helpers

    private func parse(_ text: String, _ refDate: Date, mode: String = "casual") -> ParsedResult? {
        let chrono = mode == "strict" ? Chrono.strict : Chrono.casual
        return chrono.parse(text, refDate).first
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

    // MARK: - JP Casual: Single Expression

    func testJPCasual_today() {
        // "今日感じたことを忘れずに" — contains 今日 (today)
        let ref = Date(2012, 7, 10, 12) // Aug 10 2012, 12:00
        let r = parse("今日感じたことを忘れずに", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testJPCasual_yesterday() {
        // "昨日の全国観測値ランキング" — contains 昨日 (yesterday)
        let ref = Date(2012, 7, 10, 12) // Aug 10 2012, 12:00
        let r = parse("昨日の全国観測値ランキング", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9)
    }

    // MARK: - JP Standard: Single Expression

    func testJPStandard_fullDate_kanjiYear() {
        // "主な株主（2012年3月31日現在）"
        let ref = Date(2012, 7, 10) // Aug 10 2012
        let r = parse("主な株主（2012年3月31日現在）", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 3, day: 31)
    }

    func testJPStandard_fullDate_fullWidthMonth() {
        // "主な株主（2012年９月3日現在）" — full-width ９
        let ref = Date(2012, 7, 10)
        let r = parse("主な株主（2012年９月3日現在）", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 9, day: 3)
    }

    func testJPStandard_monthDayOnly_fullWidthMonth() {
        // "主な株主（９月3日現在）" — no year
        let ref = Date(2012, 7, 10)
        let r = parse("主な株主（９月3日現在）", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 9, day: 3)
    }

    func testJPStandard_heisei_era() {
        // "主な株主（平成26年12月29日）" — Heisei 26 = 2014
        let ref = Date(2012, 7, 10)
        let r = parse("主な株主（平成26年12月29日）", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2014, month: 12, day: 29)
    }

    func testJPStandard_showa_era_fullWidth() {
        // "主な株主（昭和６４年１月７日）" — Showa 64 = 1989
        let ref = Date(2012, 7, 10)
        let r = parse("主な株主（昭和６４年１月７日）", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 1989, month: 1, day: 7)
    }

    // MARK: - JP Standard: Range Expression

    func testJPStandard_range_asciiDash() {
        // "2013年12月26日-2014年1月7日"
        let ref = Date(2012, 7, 10)
        let r = parse("2013年12月26日-2014年1月7日", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 12, day: 26)
        assertEnd(r, year: 2014, month: 1, day: 7)
    }

    func testJPStandard_range_fullWidthDates_katakanaHyphen() {
        // "２０１３年１２月２６日ー2014年1月7日" — full-width start, ー as separator
        let ref = Date(2012, 7, 10)
        let r = parse("２０１３年１２月２６日ー2014年1月7日", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 12, day: 26)
        assertEnd(r, year: 2014, month: 1, day: 7)
    }
}
