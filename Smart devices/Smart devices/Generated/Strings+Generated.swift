// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum DevicesList {
    /// AUTO-GENERATED
    internal static let title = L10n.tr("Localizable", "devicesList.title", fallback: #"Devices List"#)
    internal enum Cells {
      internal enum Heater {
        /// Off
        internal static let off = L10n.tr("Localizable", "devicesList.cells.heater.off", fallback: #"Off"#)
        /// On at %@°C
        internal static func temperature(_ p1: Any) -> String {
          return L10n.tr("Localizable", "devicesList.cells.heater.temperature", String(describing: p1), fallback: #"On at %@°C"#)
        }
      }
      internal enum Lights {
        /// Intensity %d%%
        internal static func intensity(_ p1: Int) -> String {
          return L10n.tr("Localizable", "devicesList.cells.lights.intensity", p1, fallback: #"Intensity %d%%"#)
        }
        /// Turned off
        internal static let off = L10n.tr("Localizable", "devicesList.cells.lights.off", fallback: #"Turned off"#)
      }
      internal enum RollerShutter {
        /// Closed
        internal static let closed = L10n.tr("Localizable", "devicesList.cells.rollerShutter.closed", fallback: #"Closed"#)
        /// Opened
        internal static let opened = L10n.tr("Localizable", "devicesList.cells.rollerShutter.opened", fallback: #"Opened"#)
        /// Opened at %d%%
        internal static func openedAtPosition(_ p1: Int) -> String {
          return L10n.tr("Localizable", "devicesList.cells.rollerShutter.openedAtPosition", p1, fallback: #"Opened at %d%%"#)
        }
      }
    }
  }
  internal enum HeaterControl {
    internal enum Description {
      /// On at %@°C
      internal static func temperature(_ p1: Any) -> String {
        return L10n.tr("Localizable", "heaterControl.description.temperature", String(describing: p1), fallback: #"On at %@°C"#)
      }
    }
  }
  internal enum LightControl {
    internal enum IntensityDescription {
      /// Intensity %d%%
      internal static func intensity(_ p1: Int) -> String {
        return L10n.tr("Localizable", "lightControl.intensityDescription.intensity", p1, fallback: #"Intensity %d%%"#)
      }
      /// Turned off
      internal static let off = L10n.tr("Localizable", "lightControl.intensityDescription.off", fallback: #"Turned off"#)
    }
  }
  internal enum RollerShuttersControl {
    internal enum Description {
      /// Closed
      internal static let closed = L10n.tr("Localizable", "rollerShuttersControl.description.closed", fallback: #"Closed"#)
      /// Opened
      internal static let opened = L10n.tr("Localizable", "rollerShuttersControl.description.opened", fallback: #"Opened"#)
      /// Opened at %d%%
      internal static func openedAtPosition(_ p1: Int) -> String {
        return L10n.tr("Localizable", "rollerShuttersControl.description.openedAtPosition", p1, fallback: #"Opened at %d%%"#)
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
