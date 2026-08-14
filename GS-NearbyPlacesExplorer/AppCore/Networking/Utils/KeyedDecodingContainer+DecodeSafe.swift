// 
//  KeyedDecodingContainer+DecodeSafe.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//


import Foundation

/// Extension providing safe decoding methods that handle type mismatches and flexible JSON structures.
///
/// This extension adds resilient decoding capabilities to `KeyedDecodingContainer`, allowing
/// automatic type conversion when the JSON value type doesn't match the expected Swift type.
/// It supports converting between String, Int, Double, Bool, and complex types (arrays/dictionaries).
extension KeyedDecodingContainer {

    /// Safely decodes a value of the specified type, attempting multiple conversion strategies.
    ///
    /// This method provides resilient decoding by trying multiple strategies in order:
    /// 1. Direct decoding of the expected type
    /// 2. String-based conversion (if the value is a String)
    /// 3. Numeric conversion (Int/Double) to String, then to target type
    /// 4. Boolean conversion to String, then to target type
    /// 5. Dictionary/Array conversion via JSON serialization
    ///
    /// This is particularly useful when dealing with APIs that may return inconsistent types
    /// (e.g., a number as a string, or a boolean as "true"/"false" strings).
    ///
    /// - Parameters:
    ///   - type: The target type to decode (must conform to `Decodable`)
    ///   - key: The coding key for the value to decode
    /// - Returns: The decoded value of type `T`, or `nil` if decoding fails through all strategies
    ///
    /// - Example:
    ///   ```swift
    ///   let userId: Int? = container.decodeSafe(Int.self, forKey: .userId)
    ///   // Works even if the JSON contains "123" (string) instead of 123 (number)
    ///   ```
    func decodeSafe<T: Decodable>(_ type: T.Type, forKey key: Key) -> T? {

        if let value = try? decodeIfPresent(T.self, forKey: key) {
            return value
        }

        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            return convertString(stringValue, to: T.self)
        }

        if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return convertString(String(intValue), to: T.self)
        }
        if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
            return convertString(String(doubleValue), to: T.self)
        }
        if let boolValue = try? decodeIfPresent(Bool.self, forKey: key) {
            return convertString(boolValue ? "true" : "false", to: T.self)
        }

        if let dictionary = try? decodeIfPresent([String: AnyDecodable].self, forKey: key) {
            let any = dictionary.mapValues { $0.value }
            return decodeViaJSON(any, as: T.self)
        }

        if let array = try? decodeIfPresent([AnyDecodable].self, forKey: key) {
            let any = array.map { $0.value }
            return decodeViaJSON(any, as: T.self)
        }

        return nil
    }

    /// Converts a string value to the target type.
    ///
    /// Supports conversion to String, Int, Double, and Bool types.
    /// For numeric types, trims whitespace before conversion.
    /// For Bool, uses flexible parsing (see `parseBool(_:)`).
    ///
    /// - Parameters:
    ///   - value: The string value to convert
    ///   - type: The target type to convert to
    /// - Returns: The converted value, or `nil` if conversion fails or type is unsupported
    private func convertString<T: Decodable>(_ value: String, to type: T.Type) -> T? {
        if type == String.self { return value as? T }
        if type == Int.self { return Int(value.trimmingCharacters(in: .whitespacesAndNewlines)) as? T }
        if type == Double.self { return Double(value.trimmingCharacters(in: .whitespacesAndNewlines)) as? T }
        if type == Bool.self { return parseBool(value) as? T }
        return nil
    }

    /// Parses a string value into a boolean using flexible rules.
    ///
    /// Accepts multiple string representations of boolean values:
    /// - `true`: "true", "t", "yes", "y", "1"
    /// - `false`: "false", "f", "no", "n", "0"
    ///
    /// The comparison is case-insensitive and trims whitespace.
    ///
    /// - Parameter stringValue: The string to parse as a boolean
    /// - Returns: The parsed boolean value, or `nil` if the string doesn't match any recognized pattern
    private func parseBool(_ stringValue: String) -> Bool? {
        switch stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "true", "t", "yes", "y", "1": return true
        case "false", "f", "no", "n", "0": return false
        default: return nil
        }
    }

    /// Decodes a value from an `Any` type by serializing to JSON and then decoding.
    ///
    /// This method is used for complex types (arrays, dictionaries) that need to be
    /// converted from their `Any` representation back to a strongly-typed `Decodable` type.
    ///
    /// - Parameters:
    ///   - any: The value to decode (must be a valid JSON object)
    ///   - type: The target `Decodable` type
    /// - Returns: The decoded value, or `nil` if serialization or decoding fails
    private func decodeViaJSON<T: Decodable>(_ any: Any, as type: T.Type) -> T? {
        guard JSONSerialization.isValidJSONObject(any) else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: any) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// A type-erased wrapper that can decode any JSON value into an `Any` type.
    ///
    /// `AnyDecodable` allows decoding of values without knowing their specific type upfront.
    /// It supports all JSON primitive types (Int, Double, Bool, String) as well as
    /// arrays and dictionaries, which are decoded recursively.
    ///
    /// This is used internally by `decodeSafe(_:forKey:)` to handle complex nested structures
    /// that may need type conversion.
    struct AnyDecodable: Decodable {
        /// The decoded value as a type-erased `Any`
        let value: Any

        /// Creates an `AnyDecodable` instance by decoding from the given decoder.
        ///
        /// Attempts to decode the value in this order:
        /// 1. Int
        /// 2. Double
        /// 3. Bool
        /// 4. String
        /// 5. Array of `AnyDecodable` (recursively)
        /// 6. Dictionary of `[String: AnyDecodable]` (recursively)
        /// 7. NSNull (if none of the above match)
        ///
        /// - Parameter decoder: The decoder to read data from
        /// - Throws: `DecodingError` if the value cannot be decoded
        init(from decoder: Decoder) throws {
            let codedValue = try decoder.singleValueContainer()
            if let intValue = try? codedValue.decode(Int.self) { value = intValue; return }
            if let doubleValue = try? codedValue.decode(Double.self) { value = doubleValue; return }
            if let boolValue = try? codedValue.decode(Bool.self) { value = boolValue; return }
            if let stringValue = try? codedValue.decode(String.self) { value = stringValue; return }
            if let arrayValue = try? codedValue.decode([AnyDecodable].self) { value = arrayValue.map(\.value); return }
            if let dictionaryValue = try? codedValue.decode([String: AnyDecodable].self) { value = dictionaryValue.mapValues(\.value); return }
            value = NSNull()
        }
    }
}
