//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 04.09.2026.
//

import ProgressHUD
import UIKit

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }

    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
