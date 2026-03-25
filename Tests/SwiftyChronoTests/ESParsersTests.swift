//
//  ESParsersTests.swift
//  SwiftyChrono
//

import XCTest
@testable import SwiftyChrono

/// Unit tests for all ES (Spanish) parsers.
///
/// Date() init is JS-compatible: month is 0-indexed (0 = January, 7 = August, etc.).
/// result.start[.month] returns 1-indexed values (1 = January, 8 = August, etc.),
/// matching what JS tests check via result.start.get('month').
class ESParsersTests: XCTestCase {

    // MARK: - Helpers

    private func ref(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0, _ second: Int = 0) -> Date {
        return Date(year, month, day, hour, minute, second)
    }

    private func parse(_ text: String, _ refDate: Date, mode: String = "casual") -> ParsedResult? {
        let chrono = mode == "strict" ? Chrono.strict : Chrono.casual
        return chrono.parse(text, refDate).first
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

    // MARK: - ESCasualDateParser (test_es_casual.js)

    func testCasual_ahora() {
        // "ahora" = now
        // ref: new Date(2012, 7, 10, 8, 9, 10) → August 10, 2012 08:09:10
        let r = parse("La fecha límite es ahora", ref(2012, 7, 10, 8, 9, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 8, minute: 9, second: 10)
    }

    func testCasual_hoy() {
        // "hoy" = today
        let r = parse("La fecha límite es hoy", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testCasual_manana() {
        // "Mañana" = tomorrow
        let r = parse("La fecha límite es Mañana", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 11)
    }

    func testCasual_ayer() {
        // "ayer" = yesterday
        let r = parse("La fecha límite fue ayer", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9)
    }

    func testCasual_anoche() {
        // "anoche" = last night
        let r = parse("La fehca límite fue anoche ", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 9, hour: 0)
    }

    func testCasual_estaMañana() {
        // "esta mañana" = this morning → hour 6
        let r = parse("La fecha límite fue esta mañana ", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 6)
    }

    func testCasual_estaTarde() {
        // "esta tarde" = this evening → hour 18
        let r = parse("La fecha límite fue esta tarde ", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 18)
    }

    func testCasual_combinedHoyWithTime() {
        // "hoy 5PM" = today at 5 PM
        let r = parse("La fecha límite es hoy 5PM", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 17)
    }

    func testCasual_estaNoche() {
        // "esta noche" = tonight → hour 22
        let r = parse("esta noche", ref(2012, 0, 1))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 22)
        XCTAssertEqual(r?.start[.meridiem], 1)
    }

    func testCasual_estaNocheWithTime() {
        // "esta noche 8pm" → hour 20
        let r = parse("esta noche 8pm", ref(2012, 0, 1))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 1, day: 1, hour: 20)
        XCTAssertEqual(r?.start[.meridiem], 1)
    }

    func testCasual_weekdayJueves() {
        // "jueves" = Thursday → weekday 4
        let r = Chrono.casual.parse("jueves", Date()).first
        XCTAssertNotNil(r)
        XCTAssertEqual(r?.start[.weekday], 4)
    }

    func testCasual_weekdayViernes() {
        // "viernes" = Friday → weekday 5
        let r = Chrono.casual.parse("viernes", Date()).first
        XCTAssertNotNil(r)
        XCTAssertEqual(r?.start[.weekday], 5)
    }

    func testCasual_negativeNoHoy() {
        // "nohoy" should not parse
        let results = Chrono.casual.parse("nohoy", Date())
        XCTAssertEqual(results.count, 0)
    }

    func testCasual_negativeHymañana() {
        // "hymañana" should not parse
        let results = Chrono.casual.parse("hymañana", Date())
        XCTAssertEqual(results.count, 0)
    }

    func testCasual_negativeXayer() {
        // "xayer" should not parse
        let results = Chrono.casual.parse("xayer", Date())
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - ESDeadlineFormatParser (test_es_deadline.js)

    func testDeadline_en5Dias() {
        // "en 5 días" = in 5 days; ref Aug 10 → Aug 15
        let r = parse("tenemos que hacer algo en 5 días.", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 15)
    }

    func testDeadline_dentroDe10Dias() {
        // "dentro de 10 dias" = within 10 days; ref Aug 10 → Aug 20
        let r = parse("tenemos que hacer algo dentro de 10 dias", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 20)
    }

    func testDeadline_en5Minutos() {
        // "en 5 minutos"; ref 12:14 → 12:19
        let r = parse("en 5 minutos", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 19)
    }

    func testDeadline_enUnaHora() {
        // "en una hora"; ref 12:14 → 13:14
        let r = parse("en una hora", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 13, minute: 14)
    }

    func testDeadline_enMediaHora() {
        // "en media hora"; ref 12:14 → 12:44
        let r = parse("en media hora", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 12, minute: 44)
    }

    // MARK: - ESTimeAgoFormatParser (test_es_time_ago.js)

    func testTimeAgo_hace5Dias() {
        // "hace 5 días" = 5 days ago; ref Aug 10 → Aug 5
        let r = parse("hace 5 días, hicimos algo", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 5)
    }

    func testTimeAgo_hace10Dias() {
        // "hace 10 dias"; ref Aug 10 → Jul 31 (month 7 in 1-indexed)
        let r = parse("hace 10 dias, hicimos algo", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 7, day: 31)
    }

    func testTimeAgo_hace15Minutos() {
        // "hace 15 minutos"; ref 12:14 → 11:59
        let r = parse("hace 15 minutos", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 11, minute: 59)
    }

    func testTimeAgo_hace12Horas() {
        // "hace 12 horas"; ref 12:14 → 0:14
        let r = parse("   hace 12 horas", ref(2012, 7, 10, 12, 14))
        XCTAssertNotNil(r)
        assertStart(r, hour: 0, minute: 14)
    }

    func testTimeAgo_hace5Meses() {
        // "hace 5 meses"; ref Aug 10, 2012 → Mar 10, 2012 (month 3)
        let r = parse("hace 5 meses, hicimos algo", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 3, day: 10)
    }

    func testTimeAgo_hace5Anos() {
        // "hace 5 años"; ref Aug 10, 2012 → Aug 10, 2007
        let r = parse("hace 5 años, hicimos algo", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2007, month: 8, day: 10)
    }

    func testTimeAgo_haceUnaSemana() {
        // "hace una semana"; ref Aug 3, 2012 → Jul 27, 2012 (month 7)
        let r = parse("hace una semana, hicimos algo", ref(2012, 7, 3))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 7, day: 27)
    }

    // MARK: - ESTimeExpressionParser (test_es_time_exp.js)

    func testTimeExp_aLas613AM() {
        // "a las 6.13 AM"
        let r = parse("Quedemos a las 6.13 AM", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, hour: 6, minute: 13)
    }

    func testTimeExp_rangeHyphen() {
        // "8:10 - 12.32" → start 8:10, end 12:32
        let r = parse("8:10 - 12.32", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, hour: 8, minute: 10)
        assertEnd(r, hour: 12, minute: 32)
    }

    func testTimeExp_rangeDe630pmA11pm() {
        // "de 6:30pm a 11:00pm" → start 18:30, end 23:00
        let r = parse(" de 6:30pm a 11:00pm ", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, hour: 18, minute: 30)
        XCTAssertEqual(r?.start[.meridiem], 1)
        assertEnd(r, hour: 23, minute: 0)
        XCTAssertEqual(r?.end?[.meridiem], 1)
    }

    func testTimeExp_dateAndTime() {
        // "10 de Agosto de 2012 10:12:59 pm" → Aug 10, 2012 22:12:59
        let r = parse("Algo pasó el 10 de Agosto de 2012 10:12:59 pm", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 22, minute: 12, second: 59)
    }

    func testTimeExp_meridiemImply() {
        // "hoy de 1pm a 3" → start 13:00, end 3:00 next day (implied)
        let r = parse("hoy de 1pm a 3", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10, hour: 13, minute: 0)
        XCTAssertEqual(r?.start[.meridiem], 1)
        XCTAssertTrue(r!.start.isCertain(component: .meridiem))
        assertEnd(r, hour: 3, minute: 0)
        XCTAssertFalse(r!.end!.isCertain(component: .meridiem))
    }

    func testTimeExp_aMediodia() {
        // "a mediodia" → noon hour 12
        let r = Chrono.casual.parse("a mediodia", Date()).first
        XCTAssertNotNil(r)
        XCTAssertEqual(r?.start[.hour], 12)
    }

    // MARK: - ESSlashDateFormatParser (test_es_slash.js)

    func testSlash_dayMonthYear() {
        // "lunes 8/2/2016" → day 8, month 2 (Feb), year 2016
        let r = parse("lunes 8/2/2016", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2016, month: 2, day: 8)
    }

    // MARK: - ESDashDateFormatParser (test_es_dash.js)

    func testDash_daynameAndDate() {
        // "Viernes 30-12-16" → strict parse should succeed
        let results = Chrono.strict.parse("Viernes 30-12-16", ref(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
    }

    func testDash_dateOnly() {
        // "30-12-16" → strict parse should succeed
        let results = Chrono.strict.parse("30-12-16", ref(2012, 7, 10))
        XCTAssertEqual(results.count, 1)
    }

    // MARK: - ESLittleEndianParser (test_es_little_endian.js)

    func testLittleEndian_10Agosto2012() {
        // "10 Agosto 2012" → Aug 10, 2012
        let r = parse("10 Agosto 2012", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testLittleEndian_Dom15Sep() {
        // "Dom 15Sep" → Sep 15, 2013
        let r = parse("Dom 15Sep", ref(2013, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 9, day: 15)
    }

    func testLittleEndian_DOM15SEP() {
        // "DOM 15SEP" → Sep 15, 2013 (uppercase)
        let r = parse("DOM 15SEP", ref(2013, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 9, day: 15)
    }

    func testLittleEndian_10AgostoNoYear() {
        // "10 Agosto" → Aug 10, 2012 (no year, inferred from ref)
        let r = parse("La fecha final es el 10 Agosto", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
    }

    func testLittleEndian_Martes10Enero() {
        // "Martes, 10 Enero" ref Aug 2012 → Jan 10, 2013 (future); weekday 2 = Tuesday
        let r = parse("La fecha final es el Martes, 10 Enero", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 1, day: 10)
        XCTAssertEqual(r?.start[.weekday], 2)
    }

    func testLittleEndian_Mar10Enero() {
        // "Mar, 10 Enero" abbreviated weekday; same result as Martes
        let r = parse("La fecha final es el Mar, 10 Enero", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 1, day: 10)
        XCTAssertEqual(r?.start[.weekday], 2)
    }

    func testLittleEndian_range10To22Agosto() {
        // "10 - 22 Agosto 2012" → Aug 10 to Aug 22, 2012
        let r = parse("10 - 22 Agosto 2012", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 8, day: 22)
    }

    func testLittleEndian_range10Al22Agosto() {
        // "10 al 22 Agosto 2012" → Aug 10 to Aug 22, 2012
        let r = parse("10 al 22 Agosto 2012", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 8, day: 22)
    }

    func testLittleEndian_range10AgostoTo12Septiembre() {
        // "10 Agosto - 12 Septiembre" → Aug 10 to Sep 12, 2012
        let r = parse("10 Agosto - 12 Septiembre", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 8, day: 10)
        assertEnd(r, year: 2012, month: 9, day: 12)
    }

    func testLittleEndian_range10AgostoTo12Septiembre2013() {
        // "10 Agosto - 12 Septiembre 2013" → Aug 10 to Sep 12, 2013
        let r = parse("10 Agosto - 12 Septiembre 2013", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2013, month: 8, day: 10)
        assertEnd(r, year: 2013, month: 9, day: 12)
    }

    func testLittleEndian_12DeJulioALas19() {
        // "12 de Julio a las 19:00" → Jul 12, 2012 at 19:00
        let r = parse("12 de Julio a las 19:00", ref(2012, 7, 10))
        XCTAssertNotNil(r)
        assertStart(r, year: 2012, month: 7, day: 12, hour: 19, minute: 0)
    }

    func testLittleEndian_impossibleDateStrictMode() {
        // "32 Agosto 2014" → strict mode should reject it
        XCTAssertNil(parse("32 Agosto 2014", ref(2012, 7, 10), mode: "strict"))
    }

    func testLittleEndian_29FebreroBisiesto_strictMode() {
        // "29 Febrero 2014" → 2014 is not a leap year; strict mode should reject
        XCTAssertNil(parse("29 Febrero 2014", ref(2012, 7, 10), mode: "strict"))
    }

    func testLittleEndian_32AgostoNoYear_strictMode() {
        // "32 Agosto" → invalid day; strict mode should reject
        XCTAssertNil(parse("32 Agosto", ref(2012, 7, 10), mode: "strict"))
    }
}
