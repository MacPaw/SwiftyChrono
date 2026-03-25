//
//  DEParsersTests.swift
//  SwiftyChrono
//

import XCTest
@testable import SwiftyChrono

/// Unit tests for all DE parsers, converted from the JS test suite.
///
/// Date() init is JS-compatible: month is 0-indexed (0 = January, 7 = August, etc.).
/// So new Date(2012, 7, 10) in JS = Date(2012, 7, 10) in Swift = August 10, 2012.
/// When JS asserts result.start.get('month') == 8 that is the 1-indexed result value,
/// which maps directly to the Swift subscript result.start[.month] == 8.
class DEParsersTests: XCTestCase {

    // MARK: - Helpers

    /// Create a reference Date using JS-compatible 0-indexed months.
    private func ref(_ year: Int, _ month: Int, _ day: Int,
                     _ hour: Int = 12, _ minute: Int = 0, _ second: Int = 0) -> Date {
        return Date(year, month, day, hour, minute, second)
    }

    private func parse(_ text: String, _ refDate: Date, mode: String = "casual") -> ParsedResult? {
        let chrono = mode == "strict" ? Chrono.strict : Chrono.casual
        return chrono.parse(text, refDate).first
    }

    private func assertStart(_ result: ParsedResult?,
                              year: Int? = nil, month: Int? = nil, day: Int? = nil,
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

    private func assertEnd(_ result: ParsedResult?,
                            year: Int? = nil, month: Int? = nil, day: Int? = nil,
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

    // MARK: - test_de_casual: Single Expression

    func test_casual_jetzt() {
        // "jetzt" = now; ref is Aug 10 2012 08:09:10
        let r = parse("Die Frist endet jetzt", ref(2012, 7, 10, 8, 9, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 8, minute: 9, second: 10)
    }

    func test_casual_heute() {
        // "heute" = today
        let r = parse("Die Frist endet heute", ref(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func test_casual_morgen() {
        // "morgen" = tomorrow
        let r = parse("Der Termin ist morgen", ref(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 11)
    }

    func test_casual_morgen_late_night() {
        // "morgen" at 1 AM should still resolve to same day (late night)
        let r = parse("Der Termin ist morgen", ref(2012, 7, 10, 1))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func test_casual_gestern() {
        // "gestern" = yesterday
        let r = parse("Die Frist endete gestern", ref(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9)
    }

    func test_casual_heute_morgen() {
        // "heute Morgen" = this morning → hour 6
        let r = parse("Der Termin war heute Morgen", ref(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 6)
    }

    func test_casual_heute_nachmittag() {
        // "heute Nachmittag" = this afternoon → hour 15
        let r = parse("Der Termin war heute Nachmittag", ref(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 15)
    }

    func test_casual_heute_abend() {
        // "heute Abend" = this evening → hour 18
        let r = parse("Der Termin war heute Abend", ref(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 18)
    }

    // MARK: - test_de_casual: Combined Expression

    func test_casual_heute_with_time() {
        // "heute 17 Uhr" = today at 17:00
        let r = parse("Der Termin war heute 17 Uhr", ref(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 17)
    }

    // MARK: - test_de_casual: Casual Date Range

    func test_casual_range_heute_bis_naechsten_freitag_a() {
        // "heute bis kommenden Freitag" — ref Aug 4 (Saturday), next Friday = Aug 10
        let r = parse("Die Veranstaltung geht heute bis kommenden Freitag", ref(2012, 7, 4, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 4, hour: 12)
        assertEnd(r, year: 2012, month: 8, day: 10, hour: 12)
    }

    func test_casual_range_heute_bis_naechsten_freitag_b() {
        // "heute bis kommenden Freitag" — ref Aug 10 (Friday), next Friday = Aug 17
        let r = parse("Die Veranstaltung ist heute bis kommenden Freitag", ref(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 12)
        assertEnd(r, year: 2012, month: 8, day: 17, hour: 12)
    }

    // MARK: - test_de_casual: Random Text

    func test_casual_random_heute_abend_lowercase() {
        // "Heute abend" → hour 18, Jan 1 2012
        let r = parse("Heute abend", ref(2012, 0, 1, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 18)
    }

    func test_casual_random_heute_abend_with_hour() {
        // "Heute abend 20 Uhr" → hour 20
        let r = parse("Heute abend 20 Uhr", ref(2012, 0, 1, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 20)
    }

    func test_casual_random_heute_abend_um_8() {
        // "Heute Abend um 8" → 8 PM = hour 20
        let r = parse("Heute Abend um 8", ref(2012, 0, 1, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 20)
    }

    func test_casual_random_morgen_vor_16_uhr() {
        // "Morgen vor 16:00 Uhr" → tomorrow Jan 2, hour 16
        let r = parse("Morgen vor 16:00 Uhr", ref(2012, 0, 1, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 2, hour: 16)
    }

    func test_casual_random_diesen_abend() {
        // "diesen Abend" → Oct 1 2016, hour 18
        let r = parse("diesen Abend", ref(2016, 9, 1))
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 10, day: 1, hour: 18)
    }

    func test_casual_random_gestern_nachmittag() {
        // "gestern Nachmittag" → Sep 30 2016, hour 15
        let r = parse("gestern Nachmittag", ref(2016, 9, 1))
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 9, day: 30, hour: 15)
    }

    func test_casual_random_morgen_frueh() {
        // "morgen früh" → Oct 2 2016, hour 6
        let r = parse("morgen früh", ref(2016, 9, 1, 8))
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 10, day: 2, hour: 6)
    }

    // MARK: - test_de_deadline: Single Expression

    func test_deadline_in_5_tagen() {
        // "In 5 Tagen" from Aug 10 2012 → Aug 15 2012
        let r = parse("In 5 Tagen müssen wir fertig sein.", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    func test_deadline_in_fuenf_tagen() {
        // "In fünf Tagen" (word number) → Aug 15 2012
        let r = parse("In fünf Tagen müssen wir fertig sein.", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    func test_deadline_innerhalb_10_tagen() {
        // "innerhalb von 10 Tagen" → Aug 20 2012
        let r = parse("Wir müssen etwas innerhalb von 10 Tagen tun", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 20)
    }

    func test_deadline_in_5_minuten() {
        // "in 5 Minuten" from 12:14 → 12:19
        let r = parse("in 5 Minuten", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 19)
    }

    func test_deadline_innerhalb_1_stunde() {
        // "innerhalb 1 Stunde" from 12:14 → 13:14
        let r = parse("innerhalb 1 Stunde", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 13, minute: 14)
    }

    func test_deadline_in_5_sekunden() {
        // "in 5 Sekunden" from 12:14:00 → 12:14:05
        let r = parse("Diese Auto muss sich in 5 Sekunden bewegen", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 14, second: 5)
    }

    func test_deadline_innerhalb_halben_stunde() {
        // "Innerhalb einer halben Stunde" from 12:14 → 12:44
        let r = parse("Innerhalb einer halben Stunde", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 44)
    }

    func test_deadline_innerhalb_zwei_wochen() {
        // "innerhalb von zwei Wochen" from Aug 10 12:14 → Aug 24
        let r = parse("innerhalb von zwei Wochen", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 24)
    }

    func test_deadline_innerhalb_eines_monats() {
        // "innerhalb eines Monats" from Aug 10 → Sep 10
        let r = parse("innerhalb eines Monats", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 9, day: 10)
    }

    func test_deadline_innerhalb_eines_jahres() {
        // "innerhalb eines Jahres" from Aug 10 2012 → Aug 10 2013
        let r = parse("innerhalb eines Jahres", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 8, day: 10)
    }

    // MARK: - test_de_weekday: Single Expression

    func test_weekday_montag() {
        // "Montag" from Thu Aug 9 2012 → previous Monday Aug 6
        let r = parse("Montag", ref(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 6)
    }

    func test_weekday_donnerstag() {
        // "Donnerstag" from Thu Aug 9 2012 → same day Aug 9
        let r = parse("Donnerstag", ref(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9)
    }

    func test_weekday_sonntag() {
        // "Sonntag" from Thu Aug 9 2012 → Aug 12
        let r = parse("Sonntag", ref(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 12)
    }

    func test_weekday_naechste_woche_freitag() {
        // "am Freitag nächste Woche" from Apr 18 2015 → Apr 24 2015
        let r = parse("Wir haben ein Treffen am Freitag nächste Woche", ref(2015, 3, 18))
        XCTAssertNotNil(r)
        assertStart(r, year: 2015, month: 4, day: 24)
    }

    func test_weekday_naechste_woche_dienstag() {
        // "nächste Woche Dienstag" from Apr 18 2015 → Apr 21 2015
        let r = parse("Ich plane einen freien Tag nächste Woche Dienstag.", ref(2015, 3, 18))
        XCTAssertNotNil(r)
        assertStart(r, year: 2015, month: 4, day: 21)
    }

    // MARK: - test_de_weekday: Weekday Overlap

    func test_weekday_overlap_sonntag_7_dezember_2014() {
        // "Sonntag, den 7. Dezember 2014" → explicit date takes precedence
        let r = parse("Sonntag, den 7. Dezember 2014", ref(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2014, month: 12, day: 7)
    }

    func test_weekday_overlap_sonntag_slash_date() {
        // "Sonntag 12.7.2014" → Jul 12 2014
        let r = parse("Sonntag 12.7.2014", ref(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2014, month: 7, day: 12)
    }

    // MARK: - test_de_weekday: Forward Dates Range

    func test_weekday_forward_date_range() {
        // "diesem Freitag bis Montag" with forwardDate from Aug 4 2016 → Aug 5–8 2016
        let r = Chrono.casual.parse("diesem Freitag bis Montag", ref(2016, 7, 4), [.forwardDate: 1]).first
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 8, day: 5)
        assertEnd(r, year: 2016, month: 8, day: 8)
    }

    // MARK: - test_de_time_ago: Single Expression

    func test_time_ago_vor_5_tagen() {
        // "Vor 5 Tagen" from Aug 10 2012 → Aug 5 2012
        let r = parse("Vor 5 Tagen wir haben etwas getan", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 5)
    }

    func test_time_ago_vor_10_tagen() {
        // "Vor 10 Tagen" from Aug 10 → Jul 31 2012
        let r = parse("Vor 10 Tagen haben wir etwas getan", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 7, day: 31)
    }

    func test_time_ago_vor_15_minuten() {
        // "vor 15 Minuten" from 12:14 → 11:59
        let r = parse("vor 15 Minuten", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 11, minute: 59)
    }

    func test_time_ago_vor_12_stunden() {
        // "vor 12 Stunden" from 12:14 → 0:14
        let r = parse("vor 12 Stunden habe ich etwas getan", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 0, minute: 14)
    }

    func test_time_ago_vor_einer_halben_stunde() {
        // "vor einer halben Stunde" from 12:14 → 11:44
        let r = parse("vor einer halben Stunde", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 11, minute: 44)
    }

    func test_time_ago_vor_12_sekunden() {
        // "vor 12 Sekunden" from 12:14:00 → 12:13:48
        let r = parse("vor 12 Sekunden habe ich etwas getan", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 13, second: 48)
    }

    func test_time_ago_vor_einem_tag() {
        // "Vor einem Tag" from Aug 10 → Aug 9
        let r = parse("Vor einem Tag wir haben etwas getan", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9)
    }

    func test_time_ago_vor_einer_minute() {
        // "vor einer Minute" from 12:14 → 12:13
        let r = parse("vor einer Minute", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 13)
    }

    // MARK: - test_de_time_ago: Casual (months / years / weeks)

    func test_time_ago_vor_5_monaten() {
        // "Vor 5 Monaten" from Aug 10 2012 → Mar 10 2012
        let r = parse("Vor 5 Monaten wir haben etwas getan", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 3, day: 10)
    }

    func test_time_ago_vor_5_jahren() {
        // "Vor 5 Jahren" from Aug 10 2012 → Aug 10 2007
        let r = parse("Vor 5 Jahren wir haben etwas getan", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2007, month: 8, day: 10)
    }

    func test_time_ago_vor_einer_woche() {
        // "Vor einer Woche" from Aug 3 2012 → Jul 27 2012
        let r = parse("Vor einer Woche haben wir etwas getan", ref(2012, 7, 3))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 7, day: 27)
    }

    func test_time_ago_vor_ein_paar_tagen() {
        // "vor ein paar Tagen" (a few days) from Aug 3 2012 → Jul 31 2012
        let r = parse("vor ein paar Tagen haben wir etwas getan", ref(2012, 7, 3))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 7, day: 31)
    }

    // MARK: - test_de_time_exp: Single Expression

    func test_time_exp_range_13_bis_15_uhr() {
        // "13 bis 15 Uhr" → start 13:00, end 15:00
        let r = parse("13 bis 15 Uhr", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, hour: 13, minute: 0)
        assertEnd(r, hour: 15, minute: 0)
    }

    // MARK: - test_de_slash: Single Expression

    func test_slash_weekday_with_iso_date() {
        // "montag 2016-02-08" → Feb 8 2016
        let r = parse("montag 2016-02-08", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 2, day: 8)
    }

    // MARK: - test_de_dash: Strict Mode

    func test_dash_strict_dayname_dd_mm_yyyy() {
        // "Freitag 30.12.2016" in strict mode
        let r = parse("Freitag 30.12.2016", ref(2012, 7, 10), mode: "strict")
        XCTAssertNotNil(r)
    }

    func test_dash_strict_dd_mm_yyyy() {
        // "30.12.2016" in strict mode
        let r = parse("30.12.2016", ref(2012, 7, 10), mode: "strict")
        XCTAssertNotNil(r)
    }

    func test_dash_strict_dayname_comma_dd_mm_yyyy() {
        // "Freitag, 30.12.2016" in strict mode
        let r = parse("Freitag, 30.12.2016", ref(2012, 7, 10), mode: "strict")
        XCTAssertNotNil(r)
    }

    func test_dash_strict_dayname_der_dd_mm_yyyy() {
        // "Freitag, der 30.12.2016" in strict mode
        let r = parse("Freitag, der 30.12.2016", ref(2012, 7, 10), mode: "strict")
        XCTAssertNotNil(r)
    }

    // MARK: - test_de_little_endian: Single Expression

    func test_little_endian_10_august_2012() {
        // "10. August 2012" → Aug 10 2012
        let r = parse("10. August 2012", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func test_little_endian_abbreviated_weekday_month() {
        // "So, 15. Sep" from Aug 10 2013 → Sep 15 2013
        let r = parse("So, 15. Sep", ref(2013, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 9, day: 15)
    }

    func test_little_endian_abbreviated_weekday_month_uppercase() {
        // "SO, 15. SEP" (all caps) → Sep 15 2013
        let r = parse("SO, 15. SEP", ref(2013, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 9, day: 15)
    }

    func test_little_endian_der_10_august() {
        // "der 10. August" without year → Aug 10 (current year from ref)
        let r = parse("Der Termin ist der 10. August", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func test_little_endian_dienstag_10_januar() {
        // "Dienstag, 10. Januar" from Aug 2012 → Jan 10 2013
        let r = parse("Der Termin ist Dienstag, 10. Januar", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 1, day: 10)
    }

    func test_little_endian_abbreviated_di_10_januar() {
        // "Di, 10. Januar" → Jan 10 2013
        let r = parse("Der Termin ist Di, 10. Januar", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 1, day: 10)
    }

    func test_little_endian_31_maerz_2016() {
        // "31. März 2016" → Mar 31 2016
        let r = parse("31. März 2016", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 3, day: 31)
    }

    func test_little_endian_lowercase_month() {
        // "23. februar 2016" (lowercase) → Feb 23 2016
        let r = parse("23. februar 2016", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 2, day: 23)
    }

    // MARK: - test_de_little_endian: Range Expression

    func test_little_endian_range_dash() {
        // "10. - 22. August 2012" → Aug 10–22 2012
        let r = parse("10. - 22. August 2012", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 8, day: 22)
    }

    func test_little_endian_range_bis() {
        // "10. bis 22. August 2012" → Aug 10–22 2012
        let r = parse("10. bis 22. August 2012", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 8, day: 22)
    }

    func test_little_endian_range_cross_month() {
        // "10. August bis 12. September" → Aug 10 – Sep 12 2012
        let r = parse("10. August bis 12. September", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 9, day: 12)
    }

    func test_little_endian_range_cross_month_with_year() {
        // "10. August bis 12. September 2013" → year propagates to start
        let r = parse("10. August bis 12. September 2013", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 8, day: 10)
        assertEnd(r, year: 2013, month: 9, day: 12)
    }

    // MARK: - test_de_little_endian: Combined Expression

    func test_little_endian_combined_12_juli_19_uhr() {
        // "12. Juli um 19:00 Uhr" → Jul 12 2012 19:00
        let r = parse("12. Juli um 19:00 Uhr", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 7, day: 12, hour: 19, minute: 0)
    }

    func test_little_endian_combined_7_mai_11_uhr() {
        // "7. Mai 11:00" → May 7 2012 11:00
        let r = parse("7. Mai 11:00", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 5, day: 7, hour: 11)
    }

    // MARK: - test_de_little_endian: Ordinal Words

    func test_little_endian_ordinal_word_vierundzwanzigster() {
        // "Vierundzwanzigster Mai" → May 24 2012
        let r = parse("Vierundzwanzigster Mai", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 5, day: 24)
    }

    func test_little_endian_ordinal_word_range() {
        // "Achter bis elfter Mai 2010" → May 8–11 2010
        let r = parse("Achter bis elfter Mai 2010", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2010, month: 5, day: 8)
        assertEnd(r, year: 2010, month: 5, day: 11)
    }
}
