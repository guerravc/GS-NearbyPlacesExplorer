//
//  OSMOpeningHoursParserTests.swift
//  GS-NearbyPlacesExplorerTests
//
//  Created by Carlos Lopez on 13/08/26.
//

import XCTest
@testable import GS_NearbyPlacesExplorer

@MainActor
final class OSMOpeningHoursParserTests: XCTestCase {
    
    // Helper to create a specific date for testing
    // Weekday: 1 = Sun, 2 = Mon, 3 = Tue, 4 = Wed, 5 = Thu, 6 = Fri, 7 = Sat
    private func date(weekday: Int, hour: Int, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        // August 2, 2026 is a Sunday (weekday 1)
        components.day = 2 + (weekday - 1)
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }

    func test_emptyString_returnsNotAvailable() {
        XCTAssertEqual(OSMOpeningHoursParser.state(for: ""), .notAvailable)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: nil), .notAvailable)
    }

    func test_unrecognizedFormat_returnsNotAvailable() {
        XCTAssertEqual(OSMOpeningHoursParser.state(for: "Random text 24/7"), .notAvailable)
    }

    func test_alwaysOpen_returnsOpen() {
        XCTAssertEqual(OSMOpeningHoursParser.state(for: "24/7"), .open)
    }

    func test_dailyHours_withoutDayRange_areEvaluated() {
        XCTAssertEqual(
            OSMOpeningHoursParser.state(for: "08:00-17:00", at: date(weekday: 1, hour: 10)),
            .open
        )
        XCTAssertEqual(
            OSMOpeningHoursParser.state(for: "08:00-17:00", at: date(weekday: 1, hour: 18)),
            .closed
        )
    }

    func test_overnightHours_areEvaluatedAcrossMidnight() {
        XCTAssertEqual(
            OSMOpeningHoursParser.state(for: "Mo-Su 18:00-02:00", at: date(weekday: 4, hour: 1)),
            .open
        )
    }

    func test_singleRange_open() {
        let rules = "Mo-Fr 08:00-17:00"
        let wednesdayAt10 = date(weekday: 4, hour: 10)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: wednesdayAt10), .open)
    }

    func test_singleRange_closed_time() {
        let rules = "Mo-Fr 08:00-17:00"
        let wednesdayAt18 = date(weekday: 4, hour: 18)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: wednesdayAt18), .closed)
    }
    
    func test_singleRange_closed_day() {
        let rules = "Mo-Fr 08:00-17:00"
        let saturdayAt10 = date(weekday: 7, hour: 10)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: saturdayAt10), .closed)
    }

    func test_splitTimes_open_firstBlock() {
        let rules = "Mo-Fr 08:00-12:00,13:00-17:30"
        let mondayAt10 = date(weekday: 2, hour: 10)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: mondayAt10), .open)
    }
    
    func test_splitTimes_open_secondBlock() {
        let rules = "Mo-Fr 08:00-12:00,13:00-17:30"
        let mondayAt14 = date(weekday: 2, hour: 14)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: mondayAt14), .open)
    }

    func test_splitTimes_closed_lunchBreak() {
        let rules = "Mo-Fr 08:00-12:00,13:00-17:30"
        let mondayAt1230 = date(weekday: 2, hour: 12, minute: 30)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: mondayAt1230), .closed)
    }

    func test_specificDays_open() {
        let rules = "Mo,We 08:00-12:00"
        let wednesdayAt10 = date(weekday: 4, hour: 10)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: wednesdayAt10), .open)
    }

    func test_specificDays_closed() {
        let rules = "Mo,We 08:00-12:00"
        let tuesdayAt10 = date(weekday: 3, hour: 10)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: tuesdayAt10), .closed)
    }

    func test_multipleRules_open_firstRule() {
        let rules = "Mo-Fr 08:00-12:00,13:00-17:30; Sa 08:00-12:00"
        let fridayAt14 = date(weekday: 6, hour: 14)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: fridayAt14), .open)
    }

    func test_multipleRules_open_secondRule() {
        let rules = "Mo-Fr 08:00-12:00,13:00-17:30; Sa 08:00-12:00"
        let saturdayAt10 = date(weekday: 7, hour: 10)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: saturdayAt10), .open)
    }

    func test_multipleRules_closed() {
        let rules = "Mo-Fr 08:00-12:00,13:00-17:30; Sa 08:00-12:00"
        let sundayAt10 = date(weekday: 1, hour: 10)
        XCTAssertEqual(OSMOpeningHoursParser.state(for: rules, at: sundayAt10), .closed)
    }
}
