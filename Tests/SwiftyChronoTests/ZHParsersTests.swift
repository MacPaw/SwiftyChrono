//
//  ZHParsersTests.swift
//  SwiftyChrono
//

import XCTest
@testable import SwiftyChrono

/// Unit tests for ZH-Hans (Simplified Chinese) and ZH-Hant (Traditional Chinese) parsers,
/// converted from the JS test suite.
///
/// IMPORTANT: Date() init uses JS-compatible 0-indexed months (0=Jan, 1=Feb, ..., 11=Dec)
/// So new Date(2012, 7, 10) in JS = Date(2012, 7, 10) in Swift = August 10, 2012
class ZHParsersTests: XCTestCase {

    // MARK: - Helpers

    private func parse(_ text: String, _ refDate: Date, mode: String = "casual") -> ParsedResult? {
        let chrono = mode == "strict" ? Chrono.strict : Chrono.casual
        return chrono.parse(text, refDate).first
    }

    private func parseWithOptions(_ text: String, _ refDate: Date, options: [OptionType: Int]) -> ParsedResult? {
        return Chrono.casual.parse(text, refDate, options).first
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

    // MARK: - ZH-Hans

    // MARK: ZH-Hans Casual: Single Expression

    func testZHHansCasual_erJia_now() {
        // "鸡而家全部都是鸡" — 而家 = now (Cantonese)
        let ref = Date(2012, 7, 10, 8, 9, 10) // Aug 10 2012, 08:09:10
        let r = parse("鸡而家全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 8, minute: 9, second: 10)
    }

    func testZHHansCasual_jinRi_today() {
        // "鸡今日全部都是鸡" — 今日 = today
        let ref = Date(2012, 7, 10, 12)
        let r = parse("鸡今日全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testZHHansCasual_qinRi_yesterday() {
        // "鸡琴日全部都是鸡" — 琴日 = yesterday (Cantonese)
        let ref = Date(2012, 7, 10, 12)
        let r = parse("鸡琴日全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9)
    }

    func testZHHansCasual_zuoTianWanShang_yesterdayEvening() {
        // "鸡昨天晚上全部都是鸡" — 昨天晚上 = yesterday evening
        let ref = Date(2012, 7, 10, 12)
        let r = parse("鸡昨天晚上全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9, hour: 22)
    }

    func testZHHansCasual_jinRiZaoZao_todayMorning() {
        // "鸡今日朝早全部都是鸡" — 今日朝早 = this morning
        let ref = Date(2012, 7, 10, 12)
        let r = parse("鸡今日朝早全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 6)
    }

    func testZHHansCasual_jinWan_tonight() {
        // "鸡今晚全部都是鸡" — 今晚 = tonight
        let ref = Date(2012, 7, 10, 12)
        let r = parse("鸡今晚全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 22)
    }

    // MARK: ZH-Hans Casual: Date Range

    func testZHHansCasual_todayToNextFriday_saturdayRef() {
        // "鸡今日 - 下礼拜五全部都是鸡" — ref = Sat Aug 4, next Friday = Aug 10
        let ref = Date(2012, 7, 4, 12)
        let r = parse("鸡今日 - 下礼拜五全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 4, hour: 12)
        assertEnd(r, year: 2012, month: 8, day: 10, hour: 12)
    }

    func testZHHansCasual_todayToNextFriday_thursdayRef() {
        // "鸡今日 - 下礼拜五全部都是鸡" — ref = Thu Aug 10, next Friday = Aug 17
        let ref = Date(2012, 7, 10, 12)
        let r = parse("鸡今日 - 下礼拜五全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 12)
        assertEnd(r, year: 2012, month: 8, day: 17, hour: 12)
    }

    // MARK: ZH-Hans Casual: Random Text

    func testZHHansCasual_jinRiYeWan_tonightEvening() {
        // "今日夜晚" — today evening
        let ref = Date(2012, 0, 1, 12) // Jan 1 2012
        let r = parse("今日夜晚", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 22)
        XCTAssertEqual(r?.start[.meridiem], 1)
    }

    func testZHHansCasual_jinWan8dian_tonight8pm() {
        // "今晚8点正" — tonight 8:00 PM
        let ref = Date(2012, 0, 1, 12)
        let r = parse("今晚8点正", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 20)
        XCTAssertEqual(r?.start[.meridiem], 1)
    }

    func testZHHansCasual_wanShang8dian_evening8pm() {
        // "晚上8点" — evening 8:00 PM
        let ref = Date(2012, 0, 1, 12)
        let r = parse("晚上8点", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 20)
        XCTAssertEqual(r?.start[.meridiem], 1)
    }

    func testZHHansCasual_xingQiSi_weekday() {
        // "星期四" — Thursday (weekday only)
        let r = Chrono.casual.parse("星期四", Date()).first
        XCTAssertNotNil(r)
        XCTAssertEqual(r?.start[.weekday], 4)
    }

    // MARK: ZH-Hans Date: Single Expression

    func testZHHansDate_arabicFullDate() {
        // "鸡2016年9月3号全部都是鸡"
        let ref = Date(2012, 7, 10)
        let r = parse("鸡2016年9月3号全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 3)
    }

    func testZHHansDate_chineseNumeralFullDate() {
        // "鸡二零一六年，九月三号全部都是鸡"
        let ref = Date(2012, 7, 10)
        let r = parse("鸡二零一六年，九月三号全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 3)
    }

    func testZHHansDate_monthDayOnly() {
        // "鸡九月三号全部都是鸡" — no year, infers from ref
        let ref = Date(2014, 7, 10)
        let r = parse("鸡九月三号全部都是鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2014, month: 9, day: 3)
    }

    // MARK: ZH-Hans Deadline: Single Expression

    func testZHHansDeadline_fiveDaysWithin_chineseNumeral() {
        // "五天内我们要做完功课" — within 5 days; ref Aug 10 → Aug 15
        let ref = Date(2012, 7, 10)
        let r = parse("五天内我们要做完功课", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    func testZHHansDeadline_fiveDaysWithin_arabicNumeral() {
        // "5天之内我们要做完功课" — within 5 days; ref Aug 10 → Aug 15
        let ref = Date(2012, 7, 10)
        let r = parse("5天之内我们要做完功课", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    func testZHHansDeadline_tenDaysWithin() {
        // "十天内我们要做完功课" — within 10 days; ref Aug 10 → Aug 20
        let ref = Date(2012, 7, 10)
        let r = parse("十天内我们要做完功课", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 20)
    }

    func testZHHansDeadline_fiveMinutesLater() {
        // "五分钟后" — 5 minutes later; ref 12:14 → 12:19
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("五分钟后", ref)
        XCTAssertNotNil(r)
        assertStart(r, minute: 19)
    }

    func testZHHansDeadline_oneHourWithin() {
        // "一个钟之内" — within 1 hour; ref 12:14 → 13:14
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("一个钟之内", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 13, minute: 14)
    }

    func testZHHansDeadline_fiveMinutesLater_arabicNumeral() {
        // "5分钟之后我就松手" — 5 minutes later; ref 12:14 → 12:19
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("5分钟之后我就松手", ref)
        XCTAssertNotNil(r)
        assertStart(r, minute: 19)
    }

    func testZHHansDeadline_fiveSecondsLater() {
        // "系5秒之后你就会松手" — 5 seconds later; ref 12:14:00 → 12:14:05
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("系5秒之后你就会松手", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 14, second: 5)
    }

    func testZHHansDeadline_halfHourWithin() {
        // "半小时之内" — within half hour; ref 12:14 → 12:44
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("半小时之内", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 44)
    }

    func testZHHansDeadline_twoWeeksWithin() {
        // "两个礼拜内回复我" — within 2 weeks; ref Aug 10 → Aug 24
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("两个礼拜内回复我", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 24)
    }

    func testZHHansDeadline_oneMonthWithin_arabicNumeral() {
        // "1个月之内回复我" — within 1 month; Aug 10 → Sep 10
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("1个月之内回复我", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 9, day: 10)
    }

    func testZHHansDeadline_severalMonthsWithin() {
        // "几个月之内回复我" — within a few months (3); Aug 10 → Nov 10
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("几个月之内回复我", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 11, day: 10)
    }

    func testZHHansDeadline_oneYearWithin_chineseNumeral() {
        // "一年内回复我" — within 1 year; 2012 → 2013
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("一年内回复我", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 8, day: 10)
    }

    func testZHHansDeadline_oneYearWithin_arabicNumeral() {
        // "1年之内回复我" — within 1 year; 2012 → 2013
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("1年之内回复我", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 8, day: 10)
    }

    // MARK: ZH-Hans Time Expression: Single Expression

    func testZHHansTimeExp_morningTime() {
        // "鸡上午6点13分全部都系鸡" — 上午 = AM; 6:13
        let ref = Date(2012, 7, 10)
        let r = parse("鸡上午6点13分全部都系鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 6, minute: 13)
    }

    // MARK: ZH-Hans Time Expression: Range Expression

    func testZHHansTimeExp_morningToAfternoonRange() {
        // "鸡由今朝八点十分至下午11点32分全部都系鸡" — from 8:10 AM to 11:32 PM
        let ref = Date(2012, 7, 10)
        let r = parse("鸡由今朝八点十分至下午11点32分全部都系鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 8, minute: 10)
        assertEnd(r, hour: 23, minute: 32)
    }

    func testZHHansTimeExp_pmRange() {
        // "6点30pm-11点pm" — 18:30 to 23:00
        let ref = Date(2012, 7, 10)
        let r = parse("6点30pm-11点pm", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 18, minute: 30)
        assertEnd(r, hour: 23, minute: 0)
        XCTAssertEqual(r?.start[.meridiem], 1)
        XCTAssertEqual(r?.end?[.meridiem], 1)
    }

    // MARK: ZH-Hans Time Expression: Date + Time

    func testZHHansTimeExp_dateAndTime_chineseNumerals() {
        // "鸡二零一八年十一月廿六日下午三时半五十九秒全部都系鸡"
        // 2018-11-26 15:30:59
        let ref = Date(2012, 7, 10)
        let r = parse("鸡二零一八年十一月廿六日下午三时半五十九秒全部都系鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2018, month: 11, day: 26, hour: 15, minute: 30, second: 59)
    }

    // MARK: ZH-Hans Time Expression: Meridiem Imply

    func testZHHansTimeExp_meridiemImply_pmToAm() {
        // "1点pm到3点" — 13:00 PM to 3:00 AM (next day)
        let ref = Date(2012, 7, 10)
        let r = parse("1点pm到3点", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 13, minute: 0, second: 0)
        XCTAssertEqual(r?.start[.meridiem], 1)
        XCTAssertTrue(r!.start.isCertain(component: .meridiem))
        assertEnd(r, year: 2012, month: 8, day: 11, hour: 3, minute: 0, second: 0)
        XCTAssertFalse(r!.end!.isCertain(component: .meridiem))
    }

    // MARK: ZH-Hans Time Expression: Random Date + Time

    func testZHHansTimeExp_random_dateWithTimeRange() {
        // "2014年, 3月5日凌晨 6 点至 7 点" — should parse as a single result
        let r = Chrono.casual.parse("2014年, 3月5日凌晨 6 点至 7 点", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHansTimeExp_random_nextSaturdayTime() {
        // "下星期六凌晨1点30分廿九秒"
        let r = Chrono.casual.parse("下星期六凌晨1点30分廿九秒", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHansTimeExp_random_yesterdayMorning() {
        // "昨天早上六点正"
        let r = Chrono.casual.parse("昨天早上六点正", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHansTimeExp_random_juneWithTime() {
        // "六月四日3:00am"
        let r = Chrono.casual.parse("六月四日3:00am", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHansTimeExp_random_lastFridayAfternoon() {
        // "上个礼拜五16时"
        let r = Chrono.casual.parse("上个礼拜五16时", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHansTimeExp_random_marchDateWithTime() {
        // "3月17日 20点15"
        let r = Chrono.casual.parse("3月17日 20点15", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHansTimeExp_random_hourOnly() {
        // "10点"
        let r = Chrono.casual.parse("10点", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHansTimeExp_random_noon() {
        // "中午12点"
        let r = Chrono.casual.parse("中午12点", Date()).first
        XCTAssertNotNil(r)
        XCTAssertEqual(r?.start[.hour], 12)
    }

    // MARK: ZH-Hans Weekday: Single Expression

    func testZHHansWeekday_thursday() {
        // "星期四" — Thursday; ref Fri Sep 2 2016 → previous Thu Sep 1
        let ref = Date(2016, 8, 2) // Sep 2 2016
        let r = parse("星期四", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 1)
        XCTAssertEqual(r?.start[.weekday], 4)
    }

    func testZHHansWeekday_thursday_forwardDateOnly() {
        // "礼拜四 (forward dates only)" — with forwardDate option; next Thu Sep 8
        let ref = Date(2016, 8, 2)
        let r = parseWithOptions("礼拜四 (forward dates only)", ref, options: [.forwardDate: 1])
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 8)
        XCTAssertEqual(r?.start[.weekday], 4)
    }

    func testZHHansWeekday_sunday() {
        // "礼拜日" — Sunday; ref Fri Sep 2 → next Sun Sep 4
        let ref = Date(2016, 8, 2)
        let r = parse("礼拜日", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 4)
        XCTAssertEqual(r?.start[.weekday], 0)
    }

    func testZHHansWeekday_lastWednesday() {
        // "鸡上个礼拜三全部都系鸡" — last Wednesday; ref Fri Sep 2 → Aug 24
        let ref = Date(2016, 8, 2)
        let r = parse("鸡上个礼拜三全部都系鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 8, day: 24)
        XCTAssertEqual(r?.start[.weekday], 3)
    }

    func testZHHansWeekday_nextSunday() {
        // "鸡下星期天全部都系鸡" — next Sunday; ref Fri Sep 2 → Sep 4
        let ref = Date(2016, 8, 2)
        let r = parse("鸡下星期天全部都系鸡", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 4)
        XCTAssertEqual(r?.start[.weekday], 0)
    }

    // MARK: ZH-Hans Weekday: Forward Dates Only Option

    func testZHHansWeekday_saturdayToMonday_forwardDate() {
        // "星期六-星期一" — Saturday to Monday; ref Fri Sep 2 with forwardDate
        // → Sat Sep 3 to Mon Sep 5
        let ref = Date(2016, 8, 2)
        let r = parseWithOptions("星期六-星期一", ref, options: [.forwardDate: 1])
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 3)
        assertEnd(r, year: 2016, month: 9, day: 5)
        XCTAssertEqual(r?.start[.weekday], 6)
        XCTAssertEqual(r?.end?[.weekday], 1)
    }

    // MARK: - ZH-Hant

    // MARK: ZH-Hant Casual: Single Expression

    func testZHHantCasual_erJia_now() {
        // "雞而家全部都係雞" — 而家 = now (Cantonese Traditional)
        let ref = Date(2012, 7, 10, 8, 9, 10)
        let r = parse("雞而家全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 8, minute: 9, second: 10)
    }

    func testZHHantCasual_jinRi_today() {
        // "雞今日全部都係雞" — 今日 = today
        let ref = Date(2012, 7, 10, 12)
        let r = parse("雞今日全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testZHHantCasual_tingRi_tomorrow() {
        // "雞聽日全部都係雞" — 聽日 = tomorrow (Cantonese Traditional)
        let ref = Date(2012, 7, 10, 12)
        let r = parse("雞聽日全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 11)
    }

    func testZHHantCasual_qinRi_yesterday() {
        // "雞琴日全部都係雞" — 琴日 = yesterday (Cantonese Traditional)
        let ref = Date(2012, 7, 10, 12)
        let r = parse("雞琴日全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9)
    }

    func testZHHantCasual_zuoTianWanShang_yesterdayEvening() {
        // "雞昨天晚上全部都係雞" — yesterday evening
        let ref = Date(2012, 7, 10, 12)
        let r = parse("雞昨天晚上全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9, hour: 22)
    }

    func testZHHantCasual_jinRiZaoZao_todayMorning() {
        // "雞今日朝早全部都係雞" — this morning
        let ref = Date(2012, 7, 10, 12)
        let r = parse("雞今日朝早全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 6)
    }

    func testZHHantCasual_anZhou_afternoon() {
        // "雞晏晝全部都係雞" — 晏晝 = afternoon (Cantonese Traditional)
        let ref = Date(2012, 7, 10, 12)
        let r = parse("雞晏晝全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 15)
    }

    func testZHHantCasual_jinWan_tonight() {
        // "雞今晚全部都係雞" — tonight
        let ref = Date(2012, 7, 10, 12)
        let r = parse("雞今晚全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 22)
    }

    // MARK: ZH-Hant Casual: Combined Expression

    func testZHHantCasual_combined_todayAfternoon5() {
        // "雞今日晏晝5點全部都係雞" — today afternoon 5:00 PM = 17:00
        let ref = Date(2012, 7, 10, 12)
        let r = parse("雞今日晏晝5點全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 17)
    }

    // MARK: ZH-Hant Casual: Date Range

    func testZHHantCasual_todayToNextFriday_saturdayRef() {
        // "雞今日 - 下禮拜五全部都係雞" — ref = Sat Aug 4, next Friday = Aug 10
        let ref = Date(2012, 7, 4, 12)
        let r = parse("雞今日 - 下禮拜五全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 4, hour: 12)
        assertEnd(r, year: 2012, month: 8, day: 10, hour: 12)
    }

    func testZHHantCasual_todayToNextFriday_thursdayRef() {
        // "雞今日 - 下禮拜五全部都係雞" — ref = Thu Aug 10, next Friday = Aug 17
        let ref = Date(2012, 7, 10, 12)
        let r = parse("雞今日 - 下禮拜五全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 12)
        assertEnd(r, year: 2012, month: 8, day: 17, hour: 12)
    }

    // MARK: ZH-Hant Casual: Random Text

    func testZHHantCasual_jinRiYeWan_tonightEvening() {
        // "今日夜晚"
        let ref = Date(2012, 0, 1, 12)
        let r = parse("今日夜晚", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 22)
        XCTAssertEqual(r?.start[.meridiem], 1)
    }

    func testZHHantCasual_jinWan8dian_tonight8pm() {
        // "今晚8點正" — tonight 8:00 PM (Traditional character 點)
        let ref = Date(2012, 0, 1, 12)
        let r = parse("今晚8點正", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 20)
        XCTAssertEqual(r?.start[.meridiem], 1)
    }

    func testZHHantCasual_wanShang8dian_evening8pm() {
        // "晚上8點" — evening 8 PM (Traditional character)
        let ref = Date(2012, 0, 1, 12)
        let r = parse("晚上8點", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 20)
        XCTAssertEqual(r?.start[.meridiem], 1)
    }

    func testZHHantCasual_xingQiSi_weekday() {
        // "星期四" — Thursday (weekday only)
        let r = Chrono.casual.parse("星期四", Date()).first
        XCTAssertNotNil(r)
        XCTAssertEqual(r?.start[.weekday], 4)
    }

    // MARK: ZH-Hant Date: Single Expression

    func testZHHantDate_arabicFullDate() {
        // "雞2016年9月3號全部都係雞"
        let ref = Date(2012, 7, 10)
        let r = parse("雞2016年9月3號全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 3)
    }

    func testZHHantDate_chineseNumeralFullDate() {
        // "雞二零一六年，九月三號全部都係雞"
        let ref = Date(2012, 7, 10)
        let r = parse("雞二零一六年，九月三號全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 3)
    }

    func testZHHantDate_monthDayOnly() {
        // "雞九月三號全部都係雞" — no year, infers from ref
        let ref = Date(2014, 7, 10)
        let r = parse("雞九月三號全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2014, month: 9, day: 3)
    }

    // MARK: ZH-Hant Date: Range Expression

    func testZHHantDate_range_asciiDash() {
        // "2016年9月3號-2017年10月24號"
        let ref = Date(2012, 7, 10)
        let r = parse("2016年9月3號-2017年10月24號", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 3)
        assertEnd(r, year: 2017, month: 10, day: 24)
    }

    func testZHHantDate_range_chineseNumeralStart_katakanaHyphen() {
        // "二零一六年九月三號ー2017年10月24號"
        let ref = Date(2012, 7, 10)
        let r = parse("二零一六年九月三號ー2017年10月24號", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 3)
        assertEnd(r, year: 2017, month: 10, day: 24)
    }

    // MARK: ZH-Hant Deadline: Single Expression

    func testZHHantDeadline_fiveDaysWithin_chineseNumeral() {
        // "五日內我地有d野做" — within 5 days; ref Aug 10 → Aug 15
        let ref = Date(2012, 7, 10)
        let r = parse("五日內我地有d野做", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    func testZHHantDeadline_fiveDaysWithin_arabicNumeral() {
        // "5日之內我地有d野做" — within 5 days
        let ref = Date(2012, 7, 10)
        let r = parse("5日之內我地有d野做", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    func testZHHantDeadline_tenDaysWithin() {
        // "十日內我地有d野做" — within 10 days; ref Aug 10 → Aug 20
        let ref = Date(2012, 7, 10)
        let r = parse("十日內我地有d野做", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 20)
    }

    func testZHHantDeadline_fiveMinutesLater() {
        // "五分鐘後" — 5 minutes later; ref 12:14 → 12:19
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("五分鐘後", ref)
        XCTAssertNotNil(r)
        assertStart(r, minute: 19)
    }

    func testZHHantDeadline_oneHourWithin() {
        // "一個鐘之內" — within 1 hour; ref 12:14 → 13:14
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("一個鐘之內", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 13, minute: 14)
    }

    func testZHHantDeadline_fiveMinutesLater_arabicNumeral() {
        // "5分鐘之後我就收皮" — 5 minutes later; ref 12:14 → 12:19
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("5分鐘之後我就收皮", ref)
        XCTAssertNotNil(r)
        assertStart(r, minute: 19)
    }

    func testZHHantDeadline_fiveSecondsLater() {
        // "係5秒之後你就會收皮" — 5 seconds later; ref 12:14:00 → 12:14:05
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("係5秒之後你就會收皮", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 14, second: 5)
    }

    func testZHHantDeadline_halfHourWithin() {
        // "半小時之內" — within half hour; ref 12:14 → 12:44
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("半小時之內", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 44)
    }

    func testZHHantDeadline_twoWeeksWithin() {
        // "兩個禮拜內答覆我" — within 2 weeks; ref Aug 10 → Aug 24
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("兩個禮拜內答覆我", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 24)
    }

    func testZHHantDeadline_oneMonthWithin_arabicNumeral() {
        // "1個月之內答覆我" — within 1 month; Aug 10 → Sep 10
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("1個月之內答覆我", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 9, day: 10)
    }

    func testZHHantDeadline_severalMonthsWithin() {
        // "幾個月之內答覆我" — within a few months (3); Aug 10 → Nov 10
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("幾個月之內答覆我", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 11, day: 10)
    }

    func testZHHantDeadline_oneYearWithin_chineseNumeral() {
        // "一年內答覆我" — within 1 year; 2012 → 2013
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("一年內答覆我", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 8, day: 10)
    }

    func testZHHantDeadline_oneYearWithin_arabicNumeral() {
        // "1年之內答覆我" — within 1 year; 2012 → 2013
        let ref = Date(2012, 7, 10, 12, 14)
        let r = parse("1年之內答覆我", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 8, day: 10)
    }

    // MARK: ZH-Hant Time Expression: Single Expression

    func testZHHantTimeExp_morningTime() {
        // "雞上午6點13分全部都係雞" — 上午 = AM; 6:13 (Traditional 點)
        let ref = Date(2012, 7, 10)
        let r = parse("雞上午6點13分全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 6, minute: 13)
    }

    // MARK: ZH-Hant Time Expression: Range Expression

    func testZHHantTimeExp_morningToAfternoonRange() {
        // "雞由今朝八點十分至下午11點32分全部都係雞" — from 8:10 AM to 11:32 PM
        let ref = Date(2012, 7, 10)
        let r = parse("雞由今朝八點十分至下午11點32分全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 8, minute: 10)
        assertEnd(r, hour: 23, minute: 32)
    }

    func testZHHantTimeExp_pmRange() {
        // "6點30pm-11點pm" — 18:30 to 23:00 (Traditional 點)
        let ref = Date(2012, 7, 10)
        let r = parse("6點30pm-11點pm", ref)
        XCTAssertNotNil(r)
        assertStart(r, hour: 18, minute: 30)
        assertEnd(r, hour: 23, minute: 0)
        XCTAssertEqual(r?.start[.meridiem], 1)
        XCTAssertEqual(r?.end?[.meridiem], 1)
    }

    // MARK: ZH-Hant Time Expression: Date + Time

    func testZHHantTimeExp_dateAndTime_chineseNumerals() {
        // "雞二零一八年十一月廿六日下午三時半五十九秒全部都係雞"
        // 2018-11-26 15:30:59
        let ref = Date(2012, 7, 10)
        let r = parse("雞二零一八年十一月廿六日下午三時半五十九秒全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2018, month: 11, day: 26, hour: 15, minute: 30, second: 59)
    }

    // MARK: ZH-Hant Time Expression: Meridiem Imply

    func testZHHantTimeExp_meridiemImply_pmToAm() {
        // "1點pm到3點" — 13:00 PM to 3:00 AM (next day) (Traditional 點)
        let ref = Date(2012, 7, 10)
        let r = parse("1點pm到3點", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 13, minute: 0, second: 0)
        XCTAssertEqual(r?.start[.meridiem], 1)
        XCTAssertTrue(r!.start.isCertain(component: .meridiem))
        assertEnd(r, year: 2012, month: 8, day: 11, hour: 3, minute: 0, second: 0)
        XCTAssertFalse(r!.end!.isCertain(component: .meridiem))
    }

    // MARK: ZH-Hant Time Expression: Random Date + Time

    func testZHHantTimeExp_random_dateWithTimeRange() {
        // "2014年, 3月5日晏晝 6 點至 7 點" — Traditional characters
        let r = Chrono.casual.parse("2014年, 3月5日晏晝 6 點至 7 點", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHantTimeExp_random_nextSaturdayTime() {
        // "下星期六凌晨1點30分廿九秒" — Traditional character 點
        let r = Chrono.casual.parse("下星期六凌晨1點30分廿九秒", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHantTimeExp_random_yesterdayMorning() {
        // "尋日朝早六點正" — yesterday morning (Traditional Cantonese 尋日)
        let r = Chrono.casual.parse("尋日朝早六點正", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHantTimeExp_random_juneWithTime() {
        // "六月四日3:00am"
        let r = Chrono.casual.parse("六月四日3:00am", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHantTimeExp_random_lastFridayAfternoon() {
        // "上個禮拜五16時" — Traditional 個/禮拜
        let r = Chrono.casual.parse("上個禮拜五16時", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHantTimeExp_random_marchDateWithTime() {
        // "3月17日 20點15" — Traditional 點
        let r = Chrono.casual.parse("3月17日 20點15", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHantTimeExp_random_hourOnly() {
        // "10點" — Traditional 點
        let r = Chrono.casual.parse("10點", Date()).first
        XCTAssertNotNil(r)
    }

    func testZHHantTimeExp_random_noon() {
        // "中午12點" — Traditional 點
        let r = Chrono.casual.parse("中午12點", Date()).first
        XCTAssertNotNil(r)
        XCTAssertEqual(r?.start[.hour], 12)
    }

    // MARK: ZH-Hant Weekday: Single Expression

    func testZHHantWeekday_thursday() {
        // "星期四" — Thursday; ref Fri Sep 2 2016 → previous Thu Sep 1
        let ref = Date(2016, 8, 2)
        let r = parse("星期四", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 1)
        XCTAssertEqual(r?.start[.weekday], 4)
    }

    func testZHHantWeekday_thursday_forwardDateOnly() {
        // "禮拜四 (forward dates only)" — Traditional 禮拜; with forwardDate → next Thu Sep 8
        let ref = Date(2016, 8, 2)
        let r = parseWithOptions("禮拜四 (forward dates only)", ref, options: [.forwardDate: 1])
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 8)
        XCTAssertEqual(r?.start[.weekday], 4)
    }

    func testZHHantWeekday_sunday() {
        // "禮拜日" — Traditional 禮拜; Sunday; ref Fri Sep 2 → Sun Sep 4
        let ref = Date(2016, 8, 2)
        let r = parse("禮拜日", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 4)
        XCTAssertEqual(r?.start[.weekday], 0)
    }

    func testZHHantWeekday_lastWednesday() {
        // "雞上個禮拜三全部都係雞" — last Wednesday; ref Fri Sep 2 → Aug 24
        let ref = Date(2016, 8, 2)
        let r = parse("雞上個禮拜三全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 8, day: 24)
        XCTAssertEqual(r?.start[.weekday], 3)
    }

    func testZHHantWeekday_nextSunday() {
        // "雞下星期天全部都係雞" — next Sunday; ref Fri Sep 2 → Sep 4
        let ref = Date(2016, 8, 2)
        let r = parse("雞下星期天全部都係雞", ref)
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 4)
        XCTAssertEqual(r?.start[.weekday], 0)
    }

    // MARK: ZH-Hant Weekday: Forward Dates Only Option

    func testZHHantWeekday_saturdayToMonday_forwardDate() {
        // "星期六-星期一" — Saturday to Monday; ref Fri Sep 2 with forwardDate
        // → Sat Sep 3 to Mon Sep 5
        let ref = Date(2016, 8, 2)
        let r = parseWithOptions("星期六-星期一", ref, options: [.forwardDate: 1])
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 3)
        assertEnd(r, year: 2016, month: 9, day: 5)
        XCTAssertEqual(r?.start[.weekday], 6)
        XCTAssertEqual(r?.end?[.weekday], 1)
    }
}
