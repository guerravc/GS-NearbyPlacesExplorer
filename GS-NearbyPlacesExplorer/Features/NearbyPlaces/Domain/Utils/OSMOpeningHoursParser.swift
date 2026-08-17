//
//  OSMOpeningHoursParser.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Parses simplified OSM opening_hours strings and evaluates if a place is open.
public struct OSMOpeningHoursParser {
    /// Evaluates an OSM opening_hours string against a specific date to determine if it is open or closed.
    /// - Parameters:
    ///   - hoursString: The opening_hours value (e.g. "Mo-Fr 08:00-17:00")
    ///   - date: The date to check against (defaults to now)
    /// - Returns: `open`, `closed`, or `notAvailable`
    public static func state(for hoursString: String?, at date: Date = Date()) -> PlaceOpeningState {
        guard let hoursString = hoursString, !hoursString.isEmpty else {
            return .notAvailable
        }
        
        let calendar = Calendar.current
        // Weekday: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
        let currentWeekday = calendar.component(.weekday, from: date)
        let currentHour = calendar.component(.hour, from: date)
        let currentMinute = calendar.component(.minute, from: date)
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        
        let rules = hoursString.split(separator: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        var parsedSuccessfully = false
        var matchesDay = false
        var isOpen = false
        
        for rule in rules {
            let components = rule.components(separatedBy: " ")
            guard components.count >= 2 else { continue }
            
            let daysString = components[0]
            let timesString = components[1]
            
            let ruleDays = parseDays(daysString)
            guard !ruleDays.isEmpty else { continue }
            
            parsedSuccessfully = true
            
            if ruleDays.contains(currentWeekday) {
                matchesDay = true
                let timeRanges = timesString.split(separator: ",")
                for range in timeRanges {
                    let times = range.split(separator: "-")
                    if times.count == 2 {
                        let startMins = parseTime(String(times[0]))
                        let endMins = parseTime(String(times[1]))
                        if startMins != -1 && endMins != -1 {
                            if currentTimeInMinutes >= startMins && currentTimeInMinutes <= endMins {
                                isOpen = true
                                break
                            }
                        }
                    }
                }
            }
        }
        
        if !parsedSuccessfully {
            return .notAvailable
        }
        
        if matchesDay {
            return isOpen ? .open : .closed
        }
        
        return .closed
    }
    
    private static func parseDays(_ daysString: String) -> Set<Int> {
        let dayMap: [String: Int] = ["Su": 1, "Mo": 2, "Tu": 3, "We": 4, "Th": 5, "Fr": 6, "Sa": 7]
        let orderedDays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        var result = Set<Int>()
        
        let parts = daysString.split(separator: ",")
        for part in parts {
            if part.contains("-") {
                let rangeParts = part.split(separator: "-")
                if rangeParts.count == 2 {
                    let startDay = String(rangeParts[0]).trimmingCharacters(in: .whitespaces).prefix(2).capitalized
                    let endDay = String(rangeParts[1]).trimmingCharacters(in: .whitespaces).prefix(2).capitalized
                    
                    if let startIndex = orderedDays.firstIndex(of: startDay),
                       let endIndex = orderedDays.firstIndex(of: endDay) {
                        
                        if startIndex <= endIndex {
                            for i in startIndex...endIndex {
                                if let val = dayMap[orderedDays[i]] { result.insert(val) }
                            }
                        } else {
                            for i in startIndex..<orderedDays.count {
                                if let val = dayMap[orderedDays[i]] { result.insert(val) }
                            }
                            for i in 0...endIndex {
                                if let val = dayMap[orderedDays[i]] { result.insert(val) }
                            }
                        }
                    }
                }
            } else {
                let day = String(part).trimmingCharacters(in: .whitespaces).prefix(2).capitalized
                if let val = dayMap[day] {
                    result.insert(val)
                }
            }
        }
        return result
    }
    
    private static func parseTime(_ timeString: String) -> Int {
        let parts = timeString.split(separator: ":")
        if parts.count == 2,
           let hour = Int(parts[0].trimmingCharacters(in: .whitespaces)),
           let minute = Int(parts[1].trimmingCharacters(in: .whitespaces)) {
            return hour * 60 + minute
        }
        return -1
    }
}