// 
//  AppInfo.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Provides basic information about the current application and operating system.
/// This type reads values from the main bundle and the current process.
public enum AppInfo {
  /// The display name of the application.
  /// Falls back to the bundle name if the display name is not available.
  public static var appName: String {
    if let displayName = bundleObject(forKey: "CFBundleDisplayName") as String? {
      return displayName
    }

    if let name = bundleObject(forKey: "CFBundleName") as String? {
      return name
    }

    return ""
  }

  /// The bundle identifier of the application.
  public static var bundleIdentifier: String {
    Bundle.main.bundleIdentifier ?? ""
  }

  /// The marketing version of the application (for example, "1.0" or "2.3.4").
  public static var shortVersion: String {
    bundleObject(forKey: "CFBundleShortVersionString") as String? ?? ""
  }

  /// The build number of the application.
  public static var bundleVersion: String {
    bundleObject(forKey: "CFBundleVersion") as String? ?? ""
  }

  /// A formatted string that combines the marketing version and build number.
  /// For example: "1.0 (42)".
  public static var fullVersion: String {
    let version = shortVersion
    let build = bundleVersion

    switch (version.isEmpty, build.isEmpty) {
    case (false, false):
      return "\(version) (\(build))"
    case (false, true):
      return version
    case (true, false):
      return build
    case (true, true):
      return ""
    }
  }

  /// Returns an object for the given Info.plist key if it exists.
  /// - Parameter key: The key to look up in the main bundle's information dictionary.
  /// - Returns: The value associated with the key, or `nil` if it does not exist.
  private static func bundleObject<T>(forKey key: String) -> T? {
    Bundle.main.object(forInfoDictionaryKey: key) as? T
  }
}

public extension AppInfo {
  /// The name of the operating system running the application.
  /// Resolved at compile time via platform conditional compilation.
  static let osName: String = {
    #if os(iOS)
    return "iOS"
    #elseif os(macOS)
    return "macOS"
    #elseif os(watchOS)
    return "watchOS"
    #elseif os(tvOS)
    return "tvOS"
    #elseif os(visionOS)
    return "visionOS"
    #else
    return "Unknown"
    #endif
  }()

  /// The version of the operating system running the application.
  /// The value is formatted as "major.minor.patch".
  static var osVersion: String {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
  }
}