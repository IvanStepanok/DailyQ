//
//  ViewExtension.swift
//  Daily Meeting
//
//  Created by  Stepanok Ivan on 03.08.2023.
//

import SwiftUI
import Swinject

extension View {
    
    func hideScrollContentBackground() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
        } else {
            return self.onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
    
    func ipadWidthLimit() -> some View {
        return self.frame(maxWidth: 500)
    }
    
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(FirstAppear(action: action))
    }
}

private struct FirstAppear: ViewModifier {
    let action: () -> Void
    
    // Use this to only fire your block one time
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        // And then, track it here
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}

extension UIResponder {
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    private weak static var _currentFirstResponder: UIResponder?

    @objc private func findFirstResponder(_: Any) {
        UIResponder._currentFirstResponder = self
    }

    var globalFrame: CGRect? {
        guard let view = self as? UIView else {
            return nil
        }

        return view.superview?.convert(view.frame, to: nil)
    }
}

extension UIApplication {
    
    public var keyWindow: UIWindow? {
        UIApplication.shared.windows.first { $0.isKeyWindow }
    }
    
    public func endEditing(force: Bool = true) {
        windows.forEach { $0.endEditing(force) }
    }
    
    public class func topViewController(
        controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    ) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension UIView {
    func enclosingScrollView() -> UIScrollView? {
        var next: UIView? = self

        repeat {
            next = next?.superview
            if let scrollview = next as? UIScrollView {
                return scrollview
            }
        } while next != nil

        return nil
    }
}

extension Container {
    static var shared: Container = {
        let container = Container()
        return container
    }()
}
