//
//  SwiftyChronoTests.swift
//  SwiftyChrono
//
//  Created by Jerrywell on 2017-01-17.
//  Copyright © 2017 Potix.
//

import XCTest
@testable import SwiftyChrono

class SwiftyChronoTests: XCTestCase {

    // MARK: - DE Little Endian

    func testDELittleEndianSingleExpression() {
        let chrono = Chrono()

        var results = chrono.parse("10. August 2012", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].index, 0)
        XCTAssertEqual(results[0].text, "10. August 2012")
        XCTAssertEqual(results[0].start[.year], 2012)
        XCTAssertEqual(results[0].start[.month], 8)
        XCTAssertEqual(results[0].start[.day], 10)

        results = chrono.parse("So, 15. Sep", Date(2013, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].text, "So, 15. Sep")
        XCTAssertEqual(results[0].start[.year], 2013)
        XCTAssertEqual(results[0].start[.month], 9)
        XCTAssertEqual(results[0].start[.day], 15)

        results = chrono.parse("Der Termin ist der 10. August", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].index, 19)
        XCTAssertEqual(results[0].text, "10. August")
        XCTAssertEqual(results[0].start[.year], 2012)
        XCTAssertEqual(results[0].start[.month], 8)
        XCTAssertEqual(results[0].start[.day], 10)

        results = chrono.parse("Der Termin ist Dienstag, 10. Januar", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].index, 15)
        XCTAssertEqual(results[0].text, "Dienstag, 10. Januar")
        XCTAssertEqual(results[0].start[.year], 2013)
        XCTAssertEqual(results[0].start[.month], 1)
        XCTAssertEqual(results[0].start[.day], 10)
        XCTAssertEqual(results[0].start[.weekday], 2)

        results = chrono.parse("31. März 2016", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2016)
        XCTAssertEqual(results[0].start[.month], 3)
        XCTAssertEqual(results[0].start[.day], 31)

        results = chrono.parse("23. februar 2016", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2016)
        XCTAssertEqual(results[0].start[.month], 2)
        XCTAssertEqual(results[0].start[.day], 23)
    }

    func testDELittleEndianAbbreviations() {
        // Regression: "febr" was a crash (force unwrap nil from DE_MONTH_OFFSET)
        let chrono = Chrono()
        let results = chrono.parse("25 febr", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 0, "Parser should not crash on unknown abbreviation 'febr'")
    }

    func testDELittleEndianRangeExpression() {
        let chrono = Chrono()

        var results = chrono.parse("10. - 22. August 2012", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].text, "10. - 22. August 2012")
        XCTAssertEqual(results[0].start[.year], 2012)
        XCTAssertEqual(results[0].start[.month], 8)
        XCTAssertEqual(results[0].start[.day], 10)
        XCTAssertEqual(results[0].end?[.year], 2012)
        XCTAssertEqual(results[0].end?[.month], 8)
        XCTAssertEqual(results[0].end?[.day], 22)

        results = chrono.parse("10. bis 22. August 2012", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.month], 8)
        XCTAssertEqual(results[0].start[.day], 10)
        XCTAssertEqual(results[0].end?[.month], 8)
        XCTAssertEqual(results[0].end?[.day], 22)

        results = chrono.parse("10. August bis 12. September 2013", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2013)
        XCTAssertEqual(results[0].start[.month], 8)
        XCTAssertEqual(results[0].start[.day], 10)
        XCTAssertEqual(results[0].end?[.year], 2013)
        XCTAssertEqual(results[0].end?[.month], 9)
        XCTAssertEqual(results[0].end?[.day], 12)
    }

    func testDELittleEndianCombined() {
        let chrono = Chrono()

        var results = chrono.parse("12. Juli um 19:00 Uhr", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].text, "12. Juli um 19:00 Uhr")
        XCTAssertEqual(results[0].start[.year], 2012)
        XCTAssertEqual(results[0].start[.month], 7)
        XCTAssertEqual(results[0].start[.day], 12)
        XCTAssertEqual(results[0].start[.hour], 19)
        XCTAssertEqual(results[0].start[.minute], 0)

        results = chrono.parse("7. Mai 11:00", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.month], 5)
        XCTAssertEqual(results[0].start[.day], 7)
        XCTAssertEqual(results[0].start[.hour], 11)
    }

    func testDELittleEndianOrdinalWords() {
        let chrono = Chrono()

        var results = chrono.parse("Vierundzwanzigster Mai", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.month], 5)
        XCTAssertEqual(results[0].start[.day], 24)

        results = chrono.parse("Achter bis elfter Mai 2010", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2010)
        XCTAssertEqual(results[0].start[.month], 5)
        XCTAssertEqual(results[0].start[.day], 8)
        XCTAssertEqual(results[0].end?[.day], 11)
    }

    // MARK: - EN Little Endian

    func testENLittleEndian() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        var results = chrono.parse("24th May 2017", Date(2017, 0, 1))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2017)
        XCTAssertEqual(results[0].start[.month], 5)
        XCTAssertEqual(results[0].start[.day], 24)

        results = chrono.parse("10 - 22 August 2012", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.month], 8)
        XCTAssertEqual(results[0].start[.day], 10)
        XCTAssertEqual(results[0].end?[.month], 8)
        XCTAssertEqual(results[0].end?[.day], 22)

        results = chrono.parse("23rd february, 2016", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2016)
        XCTAssertEqual(results[0].start[.month], 2)
        XCTAssertEqual(results[0].start[.day], 23)
    }

    // MARK: - EN Middle Endian

    func testENMiddleEndian() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        var results = chrono.parse("October 7, 2011", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2011)
        XCTAssertEqual(results[0].start[.month], 10)
        XCTAssertEqual(results[0].start[.day], 7)

        results = chrono.parse("Thursday, December 15, 2011", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2011)
        XCTAssertEqual(results[0].start[.month], 12)
        XCTAssertEqual(results[0].start[.day], 15)

        results = chrono.parse("November 1,2001- March 31,2002", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2001)
        XCTAssertEqual(results[0].start[.month], 11)
        XCTAssertEqual(results[0].start[.day], 1)
    }

    // MARK: - EN Time Expression

    func testENTimeExpression() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        var results = chrono.parse("9:00 AM to 5:00 PM", Date(2017, 0, 1))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.hour], 9)
        XCTAssertEqual(results[0].start[.meridiem], 0)
        XCTAssertEqual(results[0].end?[.hour], 17)
        XCTAssertEqual(results[0].end?[.meridiem], 1)

        results = chrono.parse("9:00 AM to 5:00 PM, Tuesday, 20 May 2013", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.hour], 9)
        XCTAssertEqual(results[0].end?[.hour], 17)
        let startDate = results[0].start.date
        let expectedStart = Date(2013, 4, 20, 9, 0)
        XCTAssert(abs(startDate.timeIntervalSince(expectedStart)) < 1)

        results = chrono.parse("Something happen on 2014-04-18 13:00 - 16:00 as", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].text, "2014-04-18 13:00 - 16:00")
    }

    // MARK: - EN Deadline Format

    func testENDeadlineFormat() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        let ref = Date(2012, 7, 10)

        var results = chrono.parse("in 3 days", ref)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.day], ref.added(3, .day).day)

        results = chrono.parse("within 2 weeks", ref)
        XCTAssertEqual(results.count, 1)

        results = chrono.parse("in 1 month", ref)
        XCTAssertEqual(results.count, 1)
    }

    // MARK: - EN Time Ago Format

    func testENTimeAgoFormat() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        let ref = Date(2012, 7, 10, 12, 0, 0)

        var results = chrono.parse("3 days ago", ref)
        XCTAssertEqual(results.count, 1)
        let minus3Days = ref.added(-3, .day)
        XCTAssertEqual(results[0].start[.day], minus3Days.day)
        XCTAssertEqual(results[0].start[.month], minus3Days.month)

        results = chrono.parse("2 hours ago", ref)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.hour], 10)

        results = chrono.parse("5 minutes ago", ref)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.hour], 11)
        XCTAssertEqual(results[0].start[.minute], 55)
    }

    // MARK: - EN Weekday Parser

    func testENWeekday() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        let ref = Date(2012, 7, 9) // Thursday Aug 9 2012

        var results = chrono.parse("last Friday", ref)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.weekday], 5)

        results = chrono.parse("next Monday", ref)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.weekday], 1)
    }

    // MARK: - EN ISO / Slash Formats

    func testENISOFormat() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        var results = chrono.parse("2014-12-14T18:22:14.759Z")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].text, "2014-12-14T18:22:14.759Z")
        XCTAssertEqual(results[0].start[.year], 2014)
        XCTAssertEqual(results[0].start[.month], 12)
        XCTAssertEqual(results[0].start[.day], 14)

        results = chrono.parse("2014-07-07T04:00:00Z")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].text, "2014-07-07T04:00:00Z")

        results = chrono.parse("01/01/2016", Date(2016, 0, 1))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2016)
        XCTAssertEqual(results[0].start[.month], 1)
        XCTAssertEqual(results[0].start[.day], 1)
    }

    // MARK: - EN No False Positives

    func testENNoFalsePositives() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        XCTAssertEqual(chrono.parse(" 3").count, 0)
        XCTAssertEqual(chrono.parse("  11 ").count, 0)
        XCTAssertEqual(chrono.parse(" 0.5 ").count, 0)
        XCTAssertEqual(chrono.parse("12.53%").count, 0)
        XCTAssertEqual(chrono.parse("Version: 1.1.3").count, 0)
        XCTAssertEqual(chrono.parse("Version: 1.1.30").count, 0)
        XCTAssertEqual(chrono.parse("Version: 1.10.30").count, 0)
    }

    // MARK: - EN Multiple Results

    func testENMultipleResults() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        let text = "October 7, 2011, of which details were not revealed out of respect to Jobs's family.[239] Apple announced on the same day that they had no plans for a public service, but were encouraging \"well-wishers\" to send their remembrance messages to an email address created to receive such messages.[240] Sunday, October 16, 2011"
        let results = chrono.parse(text, Date(2012, 7, 10))
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].start[.year], 2011)
        XCTAssertEqual(results[0].start[.month], 10)
        XCTAssertEqual(results[0].start[.day], 7)
        XCTAssertEqual(results[1].start[.year], 2011)
        XCTAssertEqual(results[1].start[.month], 10)
        XCTAssertEqual(results[1].start[.day], 16)
    }

    // MARK: - FR Little Endian

    func testFRLittleEndian() {
        let chrono = Chrono()

        var results = chrono.parse("12 Août 2012", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2012)
        XCTAssertEqual(results[0].start[.month], 8)
        XCTAssertEqual(results[0].start[.day], 12)

        results = chrono.parse("1er Janvier 2017", Date(2017, 0, 1))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2017)
        XCTAssertEqual(results[0].start[.month], 1)
        XCTAssertEqual(results[0].start[.day], 1)
    }

    // MARK: - ES Little Endian

    func testESLittleEndian() {
        let chrono = Chrono()

        var results = chrono.parse("12 de Agosto 2012", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2012)
        XCTAssertEqual(results[0].start[.month], 8)
        XCTAssertEqual(results[0].start[.day], 12)

        results = chrono.parse("15 de Mayo", Date(2017, 0, 1))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.month], 5)
        XCTAssertEqual(results[0].start[.day], 15)
    }

    // MARK: - JP Standard Parser

    func testJPStandard() {
        let chrono = Chrono()

        var results = chrono.parse("2016年8月17日", Date(2016, 7, 1))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2016)
        XCTAssertEqual(results[0].start[.month], 8)
        XCTAssertEqual(results[0].start[.day], 17)

        results = chrono.parse("8月17日", Date(2016, 7, 1))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.month], 8)
        XCTAssertEqual(results[0].start[.day], 17)
    }

    // MARK: - Timezone Offset

    func testTimezoneOffset() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        let results = chrono.parse("2012-10-21 10:00:00 GMT+0200", Date(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2012)
        XCTAssertEqual(results[0].start[.month], 10)
        XCTAssertEqual(results[0].start[.day], 21)
        XCTAssertEqual(results[0].start[.hour], 10)
        XCTAssertEqual(results[0].start[.timeZoneOffset], 120)
    }

    // MARK: - HTTP Date Format (RFC 7231)

    func testHTTPDateFormat() {
        Chrono.preferredLanguage = .english
        defer { Chrono.preferredLanguage = nil }
        let chrono = Chrono()

        let results = chrono.parse("Fri, 13 Jun 2025 08:20:36 GMT", Date(2020, 0, 1))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].start[.year], 2025)
        XCTAssertEqual(results[0].start[.month], 6)
        XCTAssertEqual(results[0].start[.day], 13)
        XCTAssertEqual(results[0].start[.hour], 8)
        XCTAssertEqual(results[0].start[.minute], 20)
        XCTAssertEqual(results[0].start[.second], 36)
    }
}
