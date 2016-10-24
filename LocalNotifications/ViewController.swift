//
//  ViewController.swift
//  LocalNotifications
//
//  Created by Bart Jacobs on 22/10/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    struct Notification {

        struct Category {
            static let tutorial = "tutorial"
        }

        struct Action {
            static let readLater = "readLater"
            static let showDetails = "showDetails"
            static let unsubscribe = "unsubscribe"
        }

    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUserNotificationsCenter()
    }

    // MARK: - Actions

    @IBAction func didTapButton(sender: UIButton) {
        // Request Notification Settings
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }

                    // Schedule Local Notification
                    self.scheduleLocalNotification()
                })
            case .authorized:
                // Schedule Local Notification
                self.scheduleLocalNotification()
            case .denied:
                print("Application Not Allowed to Display Notifications")
            }
        }
    }

    // MARK: - Private Methods

    private func configureUserNotificationsCenter() {
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self

        // Define Actions
        let actionReadLater = UNNotificationAction(identifier: Notification.Action.readLater, title: "Read Later", options: [])
        let actionShowDetails = UNNotificationAction(identifier: Notification.Action.showDetails, title: "Show Details", options: [.foreground])
        let actionUnsubscribe = UNNotificationAction(identifier: Notification.Action.unsubscribe, title: "Unsubscribe", options: [.destructive, .authenticationRequired])

        // Define Category
        let tutorialCategory = UNNotificationCategory(identifier: Notification.Category.tutorial, actions: [actionReadLater, actionShowDetails, actionUnsubscribe], intentIdentifiers: [], options: [])

        // Register Category
        UNUserNotificationCenter.current().setNotificationCategories([tutorialCategory])
    }

    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }

            completionHandler(success)
        }
    }

    private func scheduleLocalNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()

        // Configure Notification Content
        notificationContent.title = "Cocoacasts"
        notificationContent.subtitle = "Local Notifications"
        notificationContent.body = "In this tutorial, you learn how to schedule local notifications with the User Notifications framework."

        // Set Category Identifier
        notificationContent.categoryIdentifier = Notification.Category.tutorial

        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)

        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)

        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }

}

extension ViewController: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case Notification.Action.readLater:
            print("Save Tutorial For Later")
        case Notification.Action.unsubscribe:
            print("Unsubscribe Reader")
        default:
            print("Other Action")
        }

        completionHandler()
    }
}
