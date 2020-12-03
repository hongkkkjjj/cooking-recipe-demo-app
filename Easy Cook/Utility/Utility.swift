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
}
