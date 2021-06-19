#if os(macOS)
import Cocoa

extension Snapshotting where Value == CGPath, Format == NSImage {
  /// A snapshot strategy for comparing bezier paths based on pixel equality.
  public static var image: Snapshotting {
    return .image()
  }

  /// A snapshot strategy for comparing bezier paths based on pixel equality.
  ///
  /// - Parameter precision: The percentage of pixels that must match.
  public static func image(precision: Float = 1, drawingMode: CGPathDrawingMode = .eoFill) -> Snapshotting {
    return SimplySnapshotting.image(precision: precision).pullback { path in
      let bounds = path.boundingBoxOfPath
      var transform = CGAffineTransform(translationX: -bounds.origin.x, y: -bounds.origin.y)
      let path = path.copy(using: &transform)!

      let image = NSImage(size: bounds.size)
      image.lockFocus()
      let context = NSGraphicsContext.current!.cgContext

      context.addPath(path)
      context.drawPath(using: drawingMode)
      image.unlockFocus()
      return image
    }
  }
}
#elseif os(iOS) || os(tvOS)
import UIKit

extension Snapshotting where Value == CGPath, Format == UIImage {
  /// A snapshot strategy for comparing bezier paths based on pixel equality.
  public static var image: Snapshotting {
    return .image()
  }

  /// A snapshot strategy for comparing bezier paths based on pixel equality.
  ///
  /// - Parameter precision: The percentage of pixels that must match.
  public static func image(precision: Float = 1, scale: CGFloat = 1, drawingMode: CGPathDrawingMode = .eoFill) -> Snapshotting {
    return SimplySnapshotting.image(precision: precision).pullback { path in
      let bounds = path.boundingBoxOfPath
      let format: UIGraphicsImageRendererFormat
      if #available(iOS 11.0, tvOS 11.0, *) {
        format = UIGraphicsImageRendererFormat.preferred()
      } else {
        format = UIGraphicsImageRendererFormat.default()
      }
      format.scale = scale
      return UIGraphicsImageRenderer(bounds: bounds, format: format).image { ctx in
        let cgContext = ctx.cgContext
        cgContext.addPath(path)
        cgContext.drawPath(using: drawingMode)
      }
    }
  }
}
#endif

#if os(macOS) || os(iOS) || os(tvOS)
@available(iOS 11.0, OSX 10.13, tvOS 11.0, *)
extension Snapshotting where Value == CGPath, Format == String {
  /// A snapshot strategy for comparing bezier paths based on element descriptions.
  public static var elementsDescription: Snapshotting {
    return .elementsDescription(numberFormatter: defaultNumberFormatter)
  }

  /// A snapshot strategy for comparing bezier paths based on element descriptions.
  ///
  /// - Parameter numberFormatter: The number formatter used for formatting points.
  public static func elementsDescription(numberFormatter: NumberFormatter) -> Snapshotting {
    let namesByType: [CGPathElementType: String] = [
      .moveToPoint: "MoveTo",
      .addLineToPoint: "LineTo",
      .addQuadCurveToPoint: "QuadCurveTo",
      .addCurveToPoint: "CurveTo",
      .closeSubpath: "Close",
    ]

    let numberOfPointsByType: [CGPathElementType: Int] = [
      .moveToPoint: 1,
      .addLineToPoint: 1,
      .addQuadCurveToPoint: 2,
      .addCurveToPoint: 3,
      .closeSubpath: 0,
    ]

    return SimplySnapshotting.lines.pullback { path in
      var string: String = ""

      path.applyWithBlock { elementPointer in
        let element = elementPointer.pointee
        let name = namesByType[element.type] ?? "Unknown"

        if element.type == .moveToPoint && !string.isEmpty {
          string += "\n"
        }

        string += name

        if let numberOfPoints = numberOfPointsByType[element.type] {
          let points = UnsafeBufferPointer(start: element.points, count: numberOfPoints)
          string += " " + points.map { point in
            let x = numberFormatter.string(from: point.x as NSNumber)!
            let y = numberFormatter.string(from: point.y as NSNumber)!
            return "(\(x), \(y))"
          }.joined(separator: " ")
        }

        string += "\n"
      }

      return string
    }
  }
}

private let defaultNumberFormatter: NumberFormatter = {
  let numberFormatter = NumberFormatter()
  numberFormatter.minimumFractionDigits = 1
  numberFormatter.maximumFractionDigits = 3
  return numberFormatter
}()
#endif
