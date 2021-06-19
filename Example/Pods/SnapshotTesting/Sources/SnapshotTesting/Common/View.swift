#if os(iOS) || os(macOS) || os(tvOS)
#if os(macOS)
import Cocoa
#endif
import SceneKit
import SpriteKit
#if os(iOS) || os(tvOS)
import UIKit
#endif
#if os(iOS) || os(macOS)
import WebKit
#endif

#if os(iOS) || os(tvOS)
public struct ViewImageConfig {
  public enum Orientation {
    case landscape
    case portrait
  }
  public enum TabletOrientation {
    public enum PortraitSplits {
      case oneThird
      case twoThirds
      case full
    }
    public enum LandscapeSplits {
      case oneThird
      case oneHalf
      case twoThirds
      case full
    }
    case landscape(splitView: LandscapeSplits)
    case portrait(splitView: PortraitSplits)
  }

  public var safeArea: UIEdgeInsets
  public var size: CGSize?
  public var traits: UITraitCollection

  public init(
    safeArea: UIEdgeInsets = .zero,
    size: CGSize? = nil,
    traits: UITraitCollection = .init()
    ) {
    self.safeArea = safeArea
    self.size = size
    self.traits = traits
  }

  #if os(iOS)
  public static let iPhoneSe = ViewImageConfig.iPhoneSe(.portrait)

  public static func iPhoneSe(_ orientation: Orientation) -> ViewImageConfig {
    let safeArea: UIEdgeInsets
    let size: CGSize
    switch orientation {
    case .landscape:
      safeArea = .zero
      size = .init(width: 568, height: 320)
    case .portrait:
      safeArea = .init(top: 20, left: 0, bottom: 0, right: 0)
      size = .init(width: 320, height: 568)
    }
    return .init(safeArea: safeArea, size: size, traits: .iPhoneSe(orientation))
  }

  public static let iPhone8 = ViewImageConfig.iPhone8(.portrait)

  public static func iPhone8(_ orientation: Orientation) -> ViewImageConfig {
    let safeArea: UIEdgeInsets
    let size: CGSize
    switch orientation {
    case .landscape:
      safeArea = .zero
      size = .init(width: 667, height: 375)
    case .portrait:
      safeArea = .init(top: 20, left: 0, bottom: 0, right: 0)
      size = .init(width: 375, height: 667)
    }
    return .init(safeArea: safeArea, size: size, traits: .iPhone8(orientation))
  }

  public static let iPhone8Plus = ViewImageConfig.iPhone8Plus(.portrait)

  public static func iPhone8Plus(_ orientation: Orientation) -> ViewImageConfig {
    let safeArea: UIEdgeInsets
    let size: CGSize
    switch orientation {
    case .landscape:
      safeArea = .zero
      size = .init(width: 736, height: 414)
    case .portrait:
      safeArea = .init(top: 20, left: 0, bottom: 0, right: 0)
      size = .init(width: 414, height: 736)
    }
    return .init(safeArea: safeArea, size: size, traits: .iPhone8Plus(orientation))
  }

  public static let iPhoneX = ViewImageConfig.iPhoneX(.portrait)

  public static func iPhoneX(_ orientation: Orientation) -> ViewImageConfig {
    let safeArea: UIEdgeInsets
    let size: CGSize
    switch orientation {
    case .landscape:
      safeArea = .init(top: 0, left: 44, bottom: 24, right: 44)
      size = .init(width: 812, height: 375)
    case .portrait:
      safeArea = .init(top: 44, left: 0, bottom: 34, right: 0)
      size = .init(width: 375, height: 812)
    }
    return .init(safeArea: safeArea, size: size, traits: .iPhoneX(orientation))
  }

  public static let iPhoneXsMax = ViewImageConfig.iPhoneXsMax(.portrait)

  public static func iPhoneXsMax(_ orientation: Orientation) -> ViewImageConfig {
    let safeArea: UIEdgeInsets
    let size: CGSize
    switch orientation {
    case .landscape:
      safeArea = .init(top: 0, left: 44, bottom: 24, right: 44)
      size = .init(width: 896, height: 414)
    case .portrait:
      safeArea = .init(top: 44, left: 0, bottom: 34, right: 0)
      size = .init(width: 414, height: 896)
    }
    return .init(safeArea: safeArea, size: size, traits: .iPhoneXsMax(orientation))
  }

  @available(iOS 11.0, *)
  public static let iPhoneXr = ViewImageConfig.iPhoneXr(.portrait)

  @available(iOS 11.0, *)
  public static func iPhoneXr(_ orientation: Orientation) -> ViewImageConfig {
    let safeArea: UIEdgeInsets
    let size: CGSize
    switch orientation {
    case .landscape:
      safeArea = .init(top: 0, left: 44, bottom: 24, right: 44)
      size = .init(width: 896, height: 414)
    case .portrait:
      safeArea = .init(top: 44, left: 0, bottom: 34, right: 0)
      size = .init(width: 414, height: 896)
    }
    return .init(safeArea: safeArea, size: size, traits: .iPhoneXr(orientation))
  }

  public static let iPadMini = ViewImageConfig.iPadMini(.landscape)

  public static func iPadMini(_ orientation: Orientation) -> ViewImageConfig {
    switch orientation {
    case .landscape:
      return ViewImageConfig.iPadMini(.landscape(splitView: .full))
    case .portrait:
      return ViewImageConfig.iPadMini(.portrait(splitView: .full))
    }
  }

  public static func iPadMini(_ orientation: TabletOrientation) -> ViewImageConfig {
    let size: CGSize
    let traits: UITraitCollection
    switch orientation {
    case .landscape(let splitView):
      switch splitView {
      case .oneThird:
        size = .init(width: 320, height: 768)
        traits = .iPadMini_Compact_SplitView
      case .oneHalf:
        size = .init(width: 507, height: 768)
        traits = .iPadMini_Compact_SplitView
      case .twoThirds:
        size = .init(width: 694, height: 768)
        traits = .iPadMini
      case .full:
        size = .init(width: 1024, height: 768)
        traits = .iPadMini
      }
    case .portrait(let splitView):
      switch splitView {
      case .oneThird:
        size = .init(width: 320, height: 1024)
        traits = .iPadMini_Compact_SplitView
      case .twoThirds:
        size = .init(width: 438, height: 1024)
        traits = .iPadMini_Compact_SplitView
      case .full:
        size = .init(width: 768, height: 1024)
        traits = .iPadMini
      }
    }
    return .init(safeArea: .init(top: 20, left: 0, bottom: 0, right: 0), size: size, traits: traits)
  }

  public static let iPadPro10_5 = ViewImageConfig.iPadPro10_5(.landscape)

  public static func iPadPro10_5(_ orientation: Orientation) -> ViewImageConfig {
    switch orientation {
    case .landscape:
      return ViewImageConfig.iPadPro10_5(.landscape(splitView: .full))
    case .portrait:
      return ViewImageConfig.iPadPro10_5(.portrait(splitView: .full))
    }
  }

  public static func iPadPro10_5(_ orientation: TabletOrientation) -> ViewImageConfig {
    let size: CGSize
    let traits: UITraitCollection
    switch orientation {
    case .landscape(let splitView):
      switch splitView {
      case .oneThird:
        size = .init(width: 320, height: 834)
        traits = .iPadPro10_5_Compact_SplitView
      case .oneHalf:
        size = .init(width: 551, height: 834)
        traits = .iPadPro10_5_Compact_SplitView
      case .twoThirds:
        size = .init(width: 782, height: 834)
        traits = .iPadPro10_5
      case .full:
        size = .init(width: 1112, height: 834)
        traits = .iPadPro10_5
      }
    case .portrait(let splitView):
      switch splitView {
      case .oneThird:
        size = .init(width: 320, height: 1112)
        traits = .iPadPro10_5_Compact_SplitView
      case .twoThirds:
        size = .init(width: 504, height: 1112)
        traits = .iPadPro10_5_Compact_SplitView
      case .full:
        size = .init(width: 834, height: 1112)
        traits = .iPadPro10_5
      }
    }
    return .init(safeArea: .init(top: 20, left: 0, bottom: 0, right: 0), size: size, traits: traits)
  }

  public static let iPadPro11 = ViewImageConfig.iPadPro11(.landscape)

  public static func iPadPro11(_ orientation: Orientation) -> ViewImageConfig {
    switch orientation {
    case .landscape:
      return ViewImageConfig.iPadPro11(.landscape(splitView: .full))
    case .portrait:
      return ViewImageConfig.iPadPro11(.portrait(splitView: .full))
    }
  }

  public static func iPadPro11(_ orientation: TabletOrientation) -> ViewImageConfig {
    let size: CGSize
    let traits: UITraitCollection
    switch orientation {
    case .landscape(let splitView):
      switch splitView {
      case .oneThird:
        size = .init(width: 375, height: 834)
        traits = .iPadPro11_Compact_SplitView
      case .oneHalf:
        size = .init(width: 592, height: 834)
        traits = .iPadPro11_Compact_SplitView
      case .twoThirds:
        size = .init(width: 809, height: 834)
        traits = .iPadPro11
      case .full:
        size = .init(width: 1194, height: 834)
        traits = .iPadPro11
      }
    case .portrait(let splitView):
      switch splitView {
      case .oneThird:
        size = .init(width: 320, height: 1194)
        traits = .iPadPro11_Compact_SplitView
      case .twoThirds:
        size = .init(width: 504, height: 1194)
        traits = .iPadPro11_Compact_SplitView
      case .full:
        size = .init(width: 834, height: 1194)
        traits = .iPadPro11
      }
    }
    return .init(safeArea: .init(top: 24, left: 0, bottom: 20, right: 0), size: size, traits: traits)
  }

  public static let iPadPro12_9 = ViewImageConfig.iPadPro12_9(.landscape)

  public static func iPadPro12_9(_ orientation: Orientation) -> ViewImageConfig {
    switch orientation {
    case .landscape:
      return ViewImageConfig.iPadPro12_9(.landscape(splitView: .full))
    case .portrait:
      return ViewImageConfig.iPadPro12_9(.portrait(splitView: .full))
    }
  }

  public static func iPadPro12_9(_ orientation: TabletOrientation) -> ViewImageConfig {
    let size: CGSize
    let traits: UITraitCollection
    switch orientation {
    case .landscape(let splitView):
      switch splitView {
      case .oneThird:
        size = .init(width: 375, height: 1024)
        traits = .iPadPro12_9_Compact_SplitView
      case .oneHalf:
        size = .init(width: 678, height: 1024)
        traits = .iPadPro12_9
      case .twoThirds:
        size = .init(width: 981, height: 1024)
        traits = .iPadPro12_9
      case .full:
        size = .init(width: 1366, height: 1024)
        traits = .iPadPro12_9
      }

    case .portrait(let splitView):
      switch splitView {
      case .oneThird:
        size = .init(width: 375, height: 1366)
        traits = .iPadPro12_9_Compact_SplitView
      case .twoThirds:
        size = .init(width: 639, height: 1366)
        traits = .iPadPro12_9_Compact_SplitView
      case .full:
        size = .init(width: 1024, height: 1366)
        traits = .iPadPro12_9
      }

    }
    return .init(safeArea: .init(top: 20, left: 0, bottom: 0, right: 0), size: size, traits: traits)
  }
  #elseif os(tvOS)
  public static let tv = ViewImageConfig(
    safeArea: .init(top: 60, left: 90, bottom: 60, right: 90),
    size: .init(width: 1920, height: 1080),
    traits: .init()
  )
  public static let tv4K = ViewImageConfig(
    safeArea: .init(top: 120, left: 180, bottom: 120, right: 180),
    size: .init(width: 3840, height: 2160),
    traits: .init()
  )
  #endif
}

extension UITraitCollection {
  #if os(iOS)
  public static func iPhoneSe(_ orientation: ViewImageConfig.Orientation)
    -> UITraitCollection {
      let base: [UITraitCollection] = [
//        .init(displayGamut: .SRGB),
//        .init(displayScale: 2),
        .init(forceTouchCapability: .available),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: .medium),
        .init(userInterfaceIdiom: .phone)
      ]
      switch orientation {
      case .landscape:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .compact),
            .init(verticalSizeClass: .compact)
          ]
        )
      case .portrait:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .compact),
            .init(verticalSizeClass: .regular),
          ]
        )
      }
  }

  public static func iPhone8(_ orientation: ViewImageConfig.Orientation)
    -> UITraitCollection {
      let base: [UITraitCollection] = [
//        .init(displayGamut: .P3),
//        .init(displayScale: 2),
        .init(forceTouchCapability: .available),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: .medium),
        .init(userInterfaceIdiom: .phone)
      ]
      switch orientation {
      case .landscape:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .compact),
            .init(verticalSizeClass: .compact)
          ]
        )
      case .portrait:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .compact),
            .init(verticalSizeClass: .regular)
          ]
        )
      }
  }

  public static func iPhone8Plus(_ orientation: ViewImageConfig.Orientation)
    -> UITraitCollection {
      let base: [UITraitCollection] = [
//        .init(displayGamut: .P3),
//        .init(displayScale: 3),
        .init(forceTouchCapability: .available),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: .medium),
        .init(userInterfaceIdiom: .phone)
      ]
      switch orientation {
      case .landscape:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .regular),
            .init(verticalSizeClass: .compact)
          ]
        )
      case .portrait:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .compact),
            .init(verticalSizeClass: .regular)
          ]
        )
      }
  }

  public static func iPhoneX(_ orientation: ViewImageConfig.Orientation)
    -> UITraitCollection {
      let base: [UITraitCollection] = [
//        .init(displayGamut: .P3),
//        .init(displayScale: 3),
        .init(forceTouchCapability: .available),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: .medium),
        .init(userInterfaceIdiom: .phone)
      ]
      switch orientation {
      case .landscape:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .compact),
            .init(verticalSizeClass: .compact)
          ]
        )
      case .portrait:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .compact),
            .init(verticalSizeClass: .regular)
          ]
        )
      }
  }

  public static func iPhoneXr(_ orientation: ViewImageConfig.Orientation)
    -> UITraitCollection {
      let base: [UITraitCollection] = [
//        .init(displayGamut: .P3),
//        .init(displayScale: 2),
        .init(forceTouchCapability: .unavailable),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: .medium),
        .init(userInterfaceIdiom: .phone)
      ]
      switch orientation {
      case .landscape:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .regular),
            .init(verticalSizeClass: .compact)
          ]
        )
      case .portrait:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .compact),
            .init(verticalSizeClass: .regular)
          ]
        )
      }
  }

  public static func iPhoneXsMax(_ orientation: ViewImageConfig.Orientation)
    -> UITraitCollection {
      let base: [UITraitCollection] = [
//        .init(displayGamut: .P3),
//        .init(displayScale: 3),
        .init(forceTouchCapability: .available),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: .medium),
        .init(userInterfaceIdiom: .phone)
      ]
      switch orientation {
      case .landscape:
        return .init(
          traitsFrom: base + [
            .init(horizontalSizeClass: .regular),
            .init(verticalSizeClass: .compact)
          ]
        )
      case .portrait:
        return .init(
          traitsFrom: [
            .init(horizontalSizeClass: .compact),
            .init(verticalSizeClass: .regular)
          ]
        )
      }
  }

  public static let iPadMini = iPad
  public static let iPadMini_Compact_SplitView = iPadCompactSplitView
  public static let iPadPro10_5 = iPad
  public static let iPadPro10_5_Compact_SplitView = iPadCompactSplitView
  public static let iPadPro11 = iPad
  public static let iPadPro11_Compact_SplitView = iPadCompactSplitView
  public static let iPadPro12_9 = iPad
  public static let iPadPro12_9_Compact_SplitView = iPadCompactSplitView

  private static let iPad = UITraitCollection(
    traitsFrom: [
//      .init(displayScale: 2),
      .init(horizontalSizeClass: .regular),
      .init(verticalSizeClass: .regular),
      .init(userInterfaceIdiom: .pad)
    ]
  )

  private static let iPadCompactSplitView = UITraitCollection(
    traitsFrom: [
      .init(horizontalSizeClass: .compact),
      .init(verticalSizeClass: .regular),
      .init(userInterfaceIdiom: .pad)
    ]
  )
  #elseif os(tvOS)
  // TODO
  #endif
}
#endif

func addImagesForRenderedViews(_ view: View) -> [Async<View>] {
  return view.snapshot
    .map { async in
      [
        Async { callback in
          async.run { image in
            let imageView = ImageView()
            imageView.image = image
            imageView.frame = view.frame
            #if os(macOS)
            view.superview?.addSubview(imageView, positioned: .above, relativeTo: view)
            #elseif os(iOS) || os(tvOS)
            view.superview?.insertSubview(imageView, aboveSubview: view)
            #endif
            callback(imageView)
          }
        }
      ]
    }
    ?? view.subviews.flatMap(addImagesForRenderedViews)
}

extension View {
  var snapshot: Async<Image>? {
    func inWindow<T>(_ perform: () -> T) -> T {
      #if os(macOS)
      let superview = self.superview
      defer { superview?.addSubview(self) }
      let window = ScaledWindow()
      window.contentView = NSView()
      window.contentView?.addSubview(self)
      window.makeKey()
      #endif
      return perform()
    }
    #if (os(iOS) && !targetEnvironment(macCatalyst)) || os(tvOS)
    if let glkView = self as? GLKView {
      return Async(value: inWindow { glkView.snapshot })
    }
    #endif
    if let scnView = self as? SCNView {
      return Async(value: inWindow { scnView.snapshot() })
    } else if let skView = self as? SKView {
      if #available(macOS 10.11, *) {
        let cgImage = inWindow { skView.texture(from: skView.scene!)!.cgImage() }
        #if os(macOS)
        let image = Image(cgImage: cgImage, size: skView.bounds.size)
        #elseif os(iOS) || os(tvOS)
        let image = Image(cgImage: cgImage)
        #endif
        return Async(value: image)
      } else {
        fatalError("Taking SKView snapshots requires macOS 10.11 or greater")
      }
    }
    #if os(iOS) || os(macOS)
    if let wkWebView = self as? WKWebView {
      return Async<Image> { callback in
        let delegate = NavigationDelegate()
        let work = {
          if #available(iOS 11.0, macOS 10.13, *) {
            inWindow {
              guard wkWebView.frame.width != 0, wkWebView.frame.height != 0 else {
                callback(Image())
                return
              }
              wkWebView.takeSnapshot(with: nil) { image, _ in
                _ = delegate
                callback(image!)
              }
            }
          } else {
            #if os(iOS)
            fatalError("Taking WKWebView snapshots requires iOS 11.0 or greater")
            #elseif os(macOS)
            fatalError("Taking WKWebView snapshots requires macOS 10.13 or greater")
            #endif
          }
        }

        if wkWebView.isLoading {
          delegate.didFinish = work
          wkWebView.navigationDelegate = delegate
        } else {
          work()
        }
      }
    }
    #endif
    return nil
  }
  #if os(iOS) || os(tvOS)
  func asImage() -> Image {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { rendererContext in
      layer.render(in: rendererContext.cgContext)
    }
  }
  #endif
}

#if os(iOS) || os(macOS)
private final class NavigationDelegate: NSObject, WKNavigationDelegate {
  var didFinish: () -> Void

  init(didFinish: @escaping () -> Void = {}) {
    self.didFinish = didFinish
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    webView.evaluateJavaScript("document.readyState") { _, _ in
      self.didFinish()
    }
  }
}
#endif

#if os(iOS) || os(tvOS)
extension UIApplication {
    static var sharedIfAvailable: UIApplication? {
      let sharedSelector = NSSelectorFromString("sharedApplication")
      guard UIApplication.responds(to: sharedSelector) else {
        return nil
      }

      let shared = UIApplication.perform(sharedSelector)
      return shared?.takeUnretainedValue() as! UIApplication?
  }
}

func prepareView(
  config: ViewImageConfig,
  drawHierarchyInKeyWindow: Bool,
  traits: UITraitCollection,
  view: UIView,
  viewController: UIViewController
  ) -> () -> Void {
  let size = config.size ?? viewController.view.frame.size
  view.frame.size = size
  if view != viewController.view {
    viewController.view.bounds = view.bounds
    viewController.view.addSubview(view)
  }
  let traits = UITraitCollection(traitsFrom: [config.traits, traits])
  let window: UIWindow
  if drawHierarchyInKeyWindow {
    guard let keyWindow = getKeyWindow() else {
      fatalError("'drawHierarchyInKeyWindow' requires tests to be run in a host application")
    }
    window = keyWindow
    window.frame.size = size
  } else {
    window = Window(
      config: .init(safeArea: config.safeArea, size: config.size ?? size, traits: traits),
      viewController: viewController
    )
  }
  let dispose = add(traits: traits, viewController: viewController, to: window)

  if size.width == 0 || size.height == 0 {
    // Try to call sizeToFit() if the view still has invalid size
    view.sizeToFit()
    view.setNeedsLayout()
    view.layoutIfNeeded()
  }

  return dispose
}

func snapshotView(
  config: ViewImageConfig,
  drawHierarchyInKeyWindow: Bool,
  traits: UITraitCollection,
  view: UIView,
  viewController: UIViewController
  )
  -> Async<UIImage> {
    let initialFrame = view.frame
    let dispose = prepareView(
      config: config,
      drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
      traits: traits,
      view: view,
      viewController: viewController
    )
    // NB: Avoid safe area influence.
    if config.safeArea == .zero { view.frame.origin = .init(x: offscreen, y: offscreen) }

    return (view.snapshot ?? Async { callback in
      addImagesForRenderedViews(view).sequence().run { views in
        callback(
          renderer(bounds: view.bounds, for: traits).image { ctx in
            if drawHierarchyInKeyWindow {
              view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            } else {
              view.layer.render(in: ctx.cgContext)
            }
          }
        )
        views.forEach { $0.removeFromSuperview() }
        view.frame = initialFrame
      }
    }).map { dispose(); return $0 }
}

private let offscreen: CGFloat = 10_000

func renderer(bounds: CGRect, for traits: UITraitCollection) -> UIGraphicsImageRenderer {
  let renderer: UIGraphicsImageRenderer
  if #available(iOS 11.0, tvOS 11.0, *) {
    renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traits))
  } else {
    renderer = UIGraphicsImageRenderer(bounds: bounds)
  }
  return renderer
}

private func add(traits: UITraitCollection, viewController: UIViewController, to window: UIWindow) -> () -> Void {
  let rootViewController: UIViewController
  if viewController != window.rootViewController {
    rootViewController = UIViewController()
    rootViewController.view.backgroundColor = .clear
    rootViewController.view.frame = window.frame
    rootViewController.view.translatesAutoresizingMaskIntoConstraints =
      viewController.view.translatesAutoresizingMaskIntoConstraints
    rootViewController.preferredContentSize = rootViewController.view.frame.size
    viewController.view.frame = rootViewController.view.frame
    rootViewController.view.addSubview(viewController.view)
    if viewController.view.translatesAutoresizingMaskIntoConstraints {
      viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    } else {
      NSLayoutConstraint.activate([
        viewController.view.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
        viewController.view.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor),
        viewController.view.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
        viewController.view.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor),
      ])
    }
    rootViewController.addChild(viewController)
  } else {
    rootViewController = viewController
  }
  rootViewController.setOverrideTraitCollection(traits, forChild: viewController)
  viewController.didMove(toParent: rootViewController)

  window.rootViewController = rootViewController

  rootViewController.beginAppearanceTransition(true, animated: false)
  rootViewController.endAppearanceTransition()

  rootViewController.view.setNeedsLayout()
  rootViewController.view.layoutIfNeeded()

  viewController.view.setNeedsLayout()
  viewController.view.layoutIfNeeded()

  return {
    rootViewController.beginAppearanceTransition(false, animated: false)
    rootViewController.endAppearanceTransition()
    window.rootViewController = nil
  }
}

private func getKeyWindow() -> UIWindow? {
  var window: UIWindow?
  if #available(iOS 13.0, *) {
      window = UIApplication.sharedIfAvailable?.windows.first { $0.isKeyWindow }
  } else {
      window = UIApplication.sharedIfAvailable?.keyWindow
  }
  return window
}

private final class Window: UIWindow {
  var config: ViewImageConfig

  init(config: ViewImageConfig, viewController: UIViewController) {
    let size = config.size ?? viewController.view.bounds.size
    self.config = config
    super.init(frame: .init(origin: .zero, size: size))

    // NB: Safe area renders inaccurately for UI{Navigation,TabBar}Controller.
    // Fixes welcome!
    if viewController is UINavigationController {
      self.frame.size.height -= self.config.safeArea.top
      self.config.safeArea.top = 0
    } else if let viewController = viewController as? UITabBarController {
      self.frame.size.height -= self.config.safeArea.bottom
      self.config.safeArea.bottom = 0
      if viewController.selectedViewController is UINavigationController {
        self.frame.size.height -= self.config.safeArea.top
        self.config.safeArea.top = 0
      }
    }
    self.isHidden = false
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @available(iOS 11.0, *)
  override var safeAreaInsets: UIEdgeInsets {
    #if os(iOS)
    let removeTopInset = self.config.safeArea == .init(top: 20, left: 0, bottom: 0, right: 0)
      && self.rootViewController?.prefersStatusBarHidden ?? false
    if removeTopInset { return .zero }
    #endif
    return self.config.safeArea
  }
}
#endif

#if os(macOS)
import Cocoa

private final class ScaledWindow: NSWindow {
  override var backingScaleFactor: CGFloat {
    return 2
  }
}
#endif
#endif

extension Array {
  func sequence<A>() -> Async<[A]> where Element == Async<A> {
    guard !self.isEmpty else { return Async(value: []) }
    return Async<[A]> { callback in
      var result = [A?](repeating: nil, count: self.count)
      result.reserveCapacity(self.count)
      var count = 0
      zip(self.indices, self).forEach { idx, async in
        async.run {
          result[idx] = $0
          count += 1
          if count == self.count {
            callback(result as! [A])
          }
        }
      }
    }
  }
}
