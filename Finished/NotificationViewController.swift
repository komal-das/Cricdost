//
//  NotificationViewController.swift
//  Finished
//
//  Created by Karthik on 12/16/19.
//  Copyright © 2019 XCEL Solutions Corp. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var uploadingView: RoundedviewWithShadow!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func didReceive(_ notification: UNNotification) {
        if let percentage = notification.request.content.userInfo["percentage"] as? Double {
            uploadingView.isHidden = false
            percentageLabel.text = "uploading \(Int(percentage * 100))%"
            progressBar.progress = Float(percentage)
        }
    }

}
