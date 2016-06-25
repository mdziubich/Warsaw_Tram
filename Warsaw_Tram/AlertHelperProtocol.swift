//
//  AlertHelperProtocol.swift
//  Warsaw_Tram
//
//  Created by Małgorzata Dziubich on 28/06/16.
//  Copyright © 2016 Małgorzata Dziubich. All rights reserved.
//

import UIKit

protocol AlertHelperProtocol {
    
    func showAlert(title: String, message: String, okAction: UIAlertAction, cancelAction: UIAlertAction)
    func showAlert(title: String, message: String, okAction: UIAlertAction)
}

extension AlertHelperProtocol where Self: UIViewController {
    
    func showAlert(title: String, message: String, okAction: UIAlertAction, cancelAction: UIAlertAction) {
        // Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, okAction: UIAlertAction) {
        // Create the alert controller with action
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(okAction)
        
        // Present the controller
        presentViewController(alertController, animated: true, completion: nil)
    }
}
