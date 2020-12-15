//
//  Utility.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 1/12/2020.
//

import UIKit

public class Util {
    static func getTableViewHeightMethod(tableView: UITableView) -> CGFloat {
        tableView.layoutIfNeeded()
        
        return tableView.contentSize.height
    }
    
    static func runInMainThread(execute: @escaping (() -> Void)) {
        if Thread.isMainThread {
            execute()
        }
        else {
            DispatchQueue.main.async(execute: {
                execute()
            })
        }
    }
    
    static func showAlertController(style: UIAlertController.Style = .alert, title: String? = nil, message: String?, alertActions: [UIAlertAction], vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        for alertAction: UIAlertAction in alertActions {
            alertController.addAction(alertAction)
        }
        vc.present(alertController, animated: true)
    }
    
    static func showNormalAlertController(style: UIAlertController.Style = .alert, title: String? = nil, message: String?, vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alertController, animated: true)
    }
}

extension UIView {
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 4
    }
}

extension UIViewController {
    func navigateBackToViewController(_ aClass: AnyClass, animated: Bool) -> UIViewController? {
        if let currentNavigationController: UINavigationController = self.navigationController {
            let navViewControllers: [UIViewController] = currentNavigationController.viewControllers.reversed()
            for vc in navViewControllers {
                if vc.isMember(of: aClass) {
                    currentNavigationController.popToViewController(vc, animated: animated)
                    return vc
                }
            }
        }
        return nil
    }
}

extension String {
    func trimString() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func fromBase64() -> Data? {
        return Data(base64Encoded: self)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
