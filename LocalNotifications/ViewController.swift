//
//  ViewController.swift
//  LocalNotifications
//
//  Created by Николай Никитин on 29.01.2022.
//

import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

  //MARK: - Properties
  var delay: Bool = false
  var timeInterval: TimeInterval = 5

  //MARK: - UIViewController lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
  }

  //MARK: - UIMethods
  @objc func registerLocal() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if granted {
        print ("Ok!")
      } else {
        print ("Noooo!")
      }
    }
  }

  @objc func scheduleLocal() {
    registerCategories()
    let center = UNUserNotificationCenter.current()
    center.removeAllDeliveredNotifications()
    let content = UNMutableNotificationContent()
    content.title = "Late wake up call"
    content.body = "The early bird catches the worm, but the second mouse gets the cheese."
    content.categoryIdentifier = "alarm"
    content.userInfo = ["customData": "fizzbuzz"]
    content.sound = .default
    var dateComponents = DateComponents()
    dateComponents.hour = 10
    dateComponents.minute = 30
    //    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    timeInterval = delay ? 86400 : 5
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
    print ("Trigger created witn time interval \(timeInterval)")
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    center.add(request)
  }

  func registerCategories() {
    let center = UNUserNotificationCenter.current()
    center.delegate = self
    let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
    let later = UNNotificationAction(identifier: "later", title: "Remind me later", options: .foreground)
    let category = UNNotificationCategory(identifier: "alarm", actions: [show, later], intentIdentifiers: [])
    center.setNotificationCategories([category])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    if let customData = userInfo["customData"] as? String {
      print ("Custom data received: \(customData)")
      switch response.actionIdentifier {
      case UNNotificationDefaultActionIdentifier:
        print ("Default identifier")
      case "show":
        delay = false
        print ("Show more information...")
      case "later":
        delay = true
        print ("Later")
        scheduleLocal()
      default:
        break
      }
      completionHandler()
    }
  }
}

