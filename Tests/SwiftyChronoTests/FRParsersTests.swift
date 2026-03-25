//
//  FRParsersTests.swift
//  SwiftyChrono
//

import XCTest
@testable import SwiftyChrono

/// Unit tests for all FR (French) parsers, ported from the JS test suite.
///
/// Date() init is JS-compatible: month is 0-indexed (0 = January, 7 = August, …).
/// result.start[.month] returns a 1-indexed month value (1 = January, 8 = August, …).
class FRParsersTests: XCTestCase {

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

    // MARK: - FRCasualDateParser (test_fr_casual.js)

    // "maintenant" → the exact reference time (Aug 10 2012 08:09:10)
    func testCasual_maintenant() {
        // new Date(2012, 7, 10, 8, 9, 10, 11) → August 10, 2012 08:09:10
        let r = parse("La deadline est maintenant", Date(2012, 7, 10, 8, 9, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 8, minute: 9, second: 10)
    }

    // "aujourd'hui" → same date, default noon hour
    func testCasual_aujourdhui() {
        let r = parse("La deadline est aujourd'hui", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    // "demain" → next day
    func testCasual_demain() {
        let r = parse("La deadline est demain", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 11)
    }

    // "hier" → previous day
    func testCasual_hier() {
        let r = parse("La deadline était hier", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9)
    }

    // "la veille" → the day before, hour 0
    func testCasual_laVeille() {
        let r = parse("La deadline était la veille", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9, hour: 0)
    }

    // "ce matin" → this morning (hour 8)
    func testCasual_ceMatin() {
        let r = parse("La deadline est ce matin", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 8)
    }

    // "cet après-midi" → this afternoon (hour 14)
    func testCasual_cetApresMidi() {
        let r = parse("La deadline est cet après-midi", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 14)
    }

    // "cet aprem" → this afternoon, colloquial (hour 14)
    func testCasual_cetAprem() {
        let r = parse("La deadline est cet aprem", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 14)
    }

    // "ce soir" → this evening (hour 18)
    func testCasual_ceSoir() {
        let r = parse("La deadline est ce soir", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 18)
    }

    // "cette nuit" → tonight (hour 22)
    func testCasual_cetteNuit() {
        let r = parse("cette nuit", Date(2012, 0, 1, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 22)
    }

    // Combined: "aujourd'hui 17:00"
    func testCasual_aujourdhuiWithTime() {
        let r = parse("La deadline est aujourd'hui 17:00", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 17)
    }

    // Combined: "demain 17:00"
    func testCasual_demainWithTime() {
        let r = parse("La deadline est demain 17:00", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 11, hour: 17)
    }

    // Combined: "demain matin 11h"
    func testCasual_demainMatinWithHour() {
        let r = parse("La deadline est demain matin 11h", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 11, hour: 11)
    }

    // Casual date range: "aujourd'hui à vendredi prochain"
    func testCasual_rangeAujourdhuiToVendrediProchain_earlyInWeek() {
        // ref = Aug 4, 2012 (Saturday) → next Friday = Aug 10
        let r = parse("L'évenènement est d'aujourd'hui à vendredi prochain", Date(2012, 7, 4, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 4, hour: 12)
        assertEnd(r, year: 2012, month: 8, day: 10, hour: 12)
    }

    func testCasual_rangeAujourdhuiToVendrediProchain_lateInWeek() {
        // ref = Aug 10, 2012 (Friday) → next Friday = Aug 17
        let r = parse("L'évenènement est d'aujourd'hui à vendredi prochain", Date(2012, 7, 10, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 12)
        assertEnd(r, year: 2012, month: 8, day: 17, hour: 12)
    }

    // Negative tests: words that look similar but are not dates
    func testCasual_negativeNoMatch_pasaujourdhui() {
        let chrono = Chrono.casual
        let results = chrono.parse("pasaujourd'hui", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 0)
    }

    func testCasual_negativeNoMatch_pashier() {
        let chrono = Chrono.casual
        let results = chrono.parse("pashier", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 0)
    }

    func testCasual_negativeNoMatch_maintenanter() {
        let chrono = Chrono.casual
        let results = chrono.parse("maintenanter", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - FRDeadlineFormatParser (test_fr_deadline.js)

    // "dans 5 jours" → 5 days forward
    func testDeadline_dans5Jours() {
        // ref = Aug 10, 2012 → Aug 15
        let r = parse("On doit faire quelque chose dans 5 jours.", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    // "dans cinq jours" → same as "dans 5 jours" (word number)
    func testDeadline_dansCinqJours() {
        let r = parse("On doit faire quelque chose dans cinq jours.", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    // "dans 5 minutes"
    func testDeadline_dans5Minutes() {
        // ref = Aug 10, 2012 12:14 → 12:19
        let r = parse("dans 5 minutes", Date(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 19)
    }

    // "en 1 heure"
    func testDeadline_en1Heure() {
        // ref = 12:14 → 13:14
        let r = parse("en 1 heure", Date(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 13, minute: 14)
    }

    // "Dans 5 secondes"
    func testDeadline_dans5Secondes() {
        let r = parse("Dans 5 secondes une voiture va bouger", Date(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 14, second: 5)
    }

    // "dans deux semaines"
    func testDeadline_dansDeuxSemaines() {
        // ref = Aug 10, 2012 → Aug 24
        let r = parse("dans deux semaines", Date(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 24)
    }

    // "dans un mois"
    func testDeadline_dansUnMois() {
        // ref = Aug 10, 2012 → Sep 10
        let r = parse("dans un mois", Date(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 9, day: 10)
    }

    // "en une année"
    func testDeadline_enUneAnnee() {
        // ref = Aug 10, 2012 → Aug 10, 2013
        let r = parse("en une année", Date(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 8, day: 10)
    }

    // Strict mode rejects casual relative expressions
    func testDeadline_strictRejectsEnUneAnnee() {
        let chrono = Chrono.strict
        let results = chrono.parse("en une année", Date(2012, 7, 10, 12, 14))
        XCTAssertEqual(results.count, 0)
    }

    func testDeadline_strictRejectsEnQuelquesMois() {
        let chrono = Chrono.strict
        let results = chrono.parse("en quelques mois", Date(2012, 7, 3))
        XCTAssertEqual(results.count, 0)
    }

    func testDeadline_strictRejectsEnQuelquesJours() {
        let chrono = Chrono.strict
        let results = chrono.parse("en quelques jours", Date(2012, 7, 3))
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - FRWeekdayParser (test_fr_weekday.js)

    // "Lundi" with ref on Thursday Aug 9 → previous Monday Aug 6
    func testWeekday_lundi() {
        let r = parse("Lundi", Date(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 6)
        XCTAssertEqual(r?.start[.weekday], 1)
    }

    // "Jeudi" with ref on Thursday Aug 9 → same day Aug 9
    func testWeekday_jeudi() {
        let r = parse("Jeudi", Date(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9)
        XCTAssertEqual(r?.start[.weekday], 4)
    }

    // "Dimanche" with ref on Thursday Aug 9 → next Sunday Aug 12
    func testWeekday_dimanche() {
        let r = parse("Dimanche", Date(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 12)
        XCTAssertEqual(r?.start[.weekday], 0)
    }

    // "vendredi dernier" with ref on Thursday Aug 9 → Friday Aug 3
    func testWeekday_vendrediDernier() {
        let r = parse("la deadline était vendredi dernier...", Date(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 3)
        XCTAssertEqual(r?.start[.weekday], 5)
    }

    // "vendredi prochain" with ref on Saturday Apr 18, 2015 → Friday Apr 24
    func testWeekday_vendrediProchain() {
        let r = parse("Planifions une réuinion vendredi prochain", Date(2015, 3, 18))
        XCTAssertNotNil(r)
        assertStart(r, year: 2015, month: 4, day: 24)
        XCTAssertEqual(r?.start[.weekday], 5)
    }

    // Weekday overlap: "Dimanche 7 décembre 2014" → Sunday Dec 7, 2014
    func testWeekday_overlap_dimanche7Decembre2014() {
        let r = parse("Dimanche 7 décembre 2014", Date(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2014, month: 12, day: 7)
        XCTAssertEqual(r?.start[.weekday], 0)
    }

    // Weekday overlap with slash date: "Dimanche 7/12/2014"
    func testWeekday_overlap_dimanche7Slash122014() {
        let r = parse("Dimanche 7/12/2014", Date(2012, 7, 9))
        XCTAssertNotNil(r)
        assertStart(r, year: 2014, month: 12, day: 7)
        XCTAssertEqual(r?.start[.weekday], 0)
    }

    // MARK: - FRTimeAgoFormatParser (test_fr_time_ago.js)

    // "il y a 5 jours" → 5 days back from Aug 10 = Aug 5
    func testTimeAgo_ilYa5Jours() {
        let r = parse("il y a 5 jours, on a fait quelque chose", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 5)
    }

    // "il y a 10 jours" → crosses month boundary: Aug 10 - 10 = July 31
    func testTimeAgo_ilYa10Jours() {
        let r = parse("il y a 10 jours, on a fait quelque chose", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 7, day: 31)
    }

    // "il y a 15 minutes" → 12:14 - 15min = 11:59
    func testTimeAgo_ilYa15Minutes() {
        let r = parse("il y a 15 minutes", Date(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 11, minute: 59)
    }

    // "il y a 12 heures" → 12:14 - 12h = 00:14
    func testTimeAgo_ilYa12Heures() {
        let r = parse("il y a 12 heures il s'est passé quelque chose", Date(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 0, minute: 14)
    }

    // "il y a 5 mois" → Aug 10 - 5 months = Mar 10
    func testTimeAgo_ilYa5Mois() {
        let r = parse("il y a 5 mois, on a fait quelque chose", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 3, day: 10)
    }

    // "il y a 5 ans" → 2012 - 5 = 2007
    func testTimeAgo_ilYa5Ans() {
        let r = parse("il y a 5 ans, on a fait quelque chose", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2007, month: 8, day: 10)
    }

    // "il y a une semaine" → Aug 3 - 7 days = July 27
    func testTimeAgo_ilYaUneSemaine() {
        let r = parse("il y a une semaine, on a fait quelque chose", Date(2012, 7, 3))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 7, day: 27)
    }

    // MARK: - FRTimeExpressionParser (test_fr_time_exp.js)

    // "8h10" → 08:10 on the reference date
    func testTimeExp_8h10() {
        let r = parse("8h10", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, hour: 8, minute: 10)
    }

    // "8h10m" → same result
    func testTimeExp_8h10m() {
        let r = parse("8h10m", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, hour: 8, minute: 10)
    }

    // "8:10 PM" → 20:10
    func testTimeExp_8_10PM() {
        let r = parse("8:10 PM", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, hour: 20, minute: 10)
    }

    // "8h10 PM" → 20:10
    func testTimeExp_8h10PM() {
        let r = parse("8h10 PM", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, hour: 20, minute: 10)
    }

    // "ce soir 20h" → tonight 20:00 on Jan 1, 2012
    func testTimeExp_ceSoir20h() {
        let r = parse("ce soir 20h", Date(2012, 0, 1, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 20)
    }

    // "Ce soir à 20h" → same result
    func testTimeExp_ceSoirA20h() {
        let r = parse("Ce soir à 20h", Date(2012, 0, 1, 12))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 20)
    }

    // MARK: - FRSlashDateFormatParser (test_fr_slash.js)

    // "lundi 8/2/2016" → Feb 8, 2016 (little-endian: day/month/year)
    func testSlash_lundiSlashDate() {
        let r = parse("lundi 8/2/2016", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 2, day: 8)
    }

    // "le 8/2/2016" → Feb 8, 2016
    func testSlash_leSlashDate() {
        let r = parse("le 8/2/2016", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 2, day: 8)
    }

    // MARK: - FR Dash Date Format (test_fr_dash.js)

    // "Vendredi 12-30-16" → strict mode should find a result
    func testDash_daynameMMDDYY_strict() {
        let chrono = Chrono.strict
        let results = chrono.parse("Vendredi 12-30-16", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
    }

    // "12-30-16" → strict mode should find a result
    func testDash_mmDdYy_strict() {
        let chrono = Chrono.strict
        let results = chrono.parse("12-30-16", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
    }

    // "Vendredi 30-12-16" → strict mode should find a result (dd-mm-yy)
    func testDash_daynameDDMMYY_strict() {
        let chrono = Chrono.strict
        let results = chrono.parse("Vendredi 30-12-16", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
    }

    // "30-12-16" → strict mode should find a result
    func testDash_ddMmYy_strict() {
        let chrono = Chrono.strict
        let results = chrono.parse("30-12-16", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
    }

    // MARK: - FRMonthNameLittleEndianParser (test_fr_little_endian.js)

    // "10 Août 2012" → Aug 10, 2012
    func testLittleEndian_10Aout2012() {
        let r = parse("10 Août 2012", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    // "1er Août 2012" → Aug 1, 2012 (ordinal form)
    func testLittleEndian_1erAout2012() {
        let r = parse("1er Août 2012", Date(2012, 7, 1))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 1)
    }

    // "Dim 15 Sept" → Sun Sep 15, 2013
    func testLittleEndian_dim15Sept() {
        let r = parse("Dim 15 Sept", Date(2013, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 9, day: 15)
    }

    // "DIM 15SEPT" → same, uppercase abbreviation
    func testLittleEndian_DIM15SEPT() {
        let r = parse("DIM 15SEPT", Date(2013, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 9, day: 15)
    }

    // "10 Août" without year → uses ref year 2012
    func testLittleEndian_10AoutNoYear() {
        let r = parse("La date limite est le 10 Août", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    // "Mardi 10 janvier" → nearest Tuesday Jan 10 (forward from Aug 2012 → Jan 2013)
    func testLittleEndian_mardi10Janvier() {
        let r = parse("La date limite est le Mardi 10 janvier", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 1, day: 10)
        XCTAssertEqual(r?.start[.weekday], 2)
    }

    // "31 mars 2016" → Mar 31, 2016
    func testLittleEndian_31Mars2016() {
        let r = parse("31 mars 2016", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 3, day: 31)
    }

    // Date range: "10 - 22 août 2012" → Aug 10–22, 2012
    func testLittleEndian_range10To22Aout2012() {
        let r = parse("10 - 22 août 2012", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 8, day: 22)
    }

    // Date range with "au": "10 au 22 août 2012"
    func testLittleEndian_range10Au22Aout2012() {
        let r = parse("10 au 22 août 2012", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 8, day: 22)
    }

    // Cross-month range: "10 août - 12 septembre"
    func testLittleEndian_rangeAoutToSeptembre() {
        let r = parse("10 août - 12 septembre", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 9, day: 12)
    }

    // Cross-month range with year: "10 août - 12 septembre 2013"
    func testLittleEndian_rangeAoutToSeptembre2013() {
        let r = parse("10 août - 12 septembre 2013", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 8, day: 10)
        assertEnd(r, year: 2013, month: 9, day: 12)
    }

    // Combined expression: "12 juillet à 19:00"
    func testLittleEndian_12JuilletAt19h() {
        let r = parse("12 juillet à 19:00", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 7, day: 12, hour: 19, minute: 0)
    }

    // Combined: "7 Mai 11:00"
    func testLittleEndian_7Mai11h() {
        let r = parse("7 Mai 11:00", Date(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 5, day: 7, hour: 11)
    }

    // Impossible date in strict mode: "32 Août 2014" → no result
    func testLittleEndian_impossibleDate_strictMode() {
        let chrono = Chrono.strict
        let results = chrono.parse("32 Août 2014", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 0)
    }

    // Impossible date: "29 Février 2014" (2014 is not a leap year) → no result in strict
    func testLittleEndian_impossibleLeapDay_strictMode() {
        let chrono = Chrono.strict
        let results = chrono.parse("29 Février 2014", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 0)
    }
}
