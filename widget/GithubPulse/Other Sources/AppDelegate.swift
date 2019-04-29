//
//  AppDelegate.swift
//  GithubPulse
//
//  Created by Tadeu Zagallo on 12/27/14.
//  Copyright (c) 2014 Tadeu Zagallo. All rights reserved.
//

import Cocoa

private var myContext = 0

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
//  var window = MainWindow().window
  var contentViewController: ContentViewController!
  var popover: INPopoverController!

  var open: Bool = false
  var statusItem: NSStatusItem!
  var statusButton: CustomButton!
  var timer: Timer!

  override init() {}

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    contentViewController = ContentViewController(nibName: nil, bundle: nil)
    popover = INPopoverController(contentViewController: contentViewController)
    
    popover.animates = false;
    popover.color = NSColor.white
    popover.borderWidth = 1
    popover.cornerRadius = 5;
    popover.borderColor = NSColor(calibratedWhite: 0.76, alpha: 1)
    
    NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate._checkUsernameNotification(_:)), name: NSNotification.Name( "check_username"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate._checkIconNotification(_:)), name: NSNotification.Name("check_icon"), object: nil)
    DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate._darkModeChanged), name: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil)

    statusButton = CustomButton(frame: NSRect(x: 0, y: 0, width: 32, height: 24))
    statusButton.isBordered = false
    statusButton.target = self
    statusButton.action = #selector(AppDelegate.toggle(_:))
    updateIcon(1)
    statusButton.rightAction = { _ in
      self.contentViewController.refresh(nil)
    }
    
    statusItem = NSStatusBar.system.statusItem(withLength: 32)
    statusItem.title = "Github Pulse"
    statusItem.highlightMode = true
    statusItem.view = statusButton
    
    timer = Timer(fireAt: Date(), interval: 15*60, target: self, selector: #selector(AppDelegate.checkForCommits), userInfo: nil, repeats: true)
    RunLoop.current.add(timer, forMode: RunLoop.Mode.default)

    if let window = NSApplication.shared.mainWindow {
      window.contentViewController = contentViewController
      //window.showWindow(self)
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    DistributedNotificationCenter.default().removeObserver(self)
    timer.invalidate()
    timer = nil
  }

  @objc func checkForCommits() {
    GithubUpdate.check()

    if let username = parseData("username") as? String {
      fetchCommits(username)
    }
  }

  func parseData(_ key: String) -> AnyObject? {
    if let input = UserDefaults.standard.value(forKey: key) as? String {
      if let data = input.data(using: String.Encoding.utf8, allowLossyConversion: false) {
        if let object = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)) as? [String: AnyObject] {
          return object["data"]
        }
      }
    }

    return nil
  }

  func fetchCommits(_ username: String) {
    let dontNotify = parseData("dont_notify") as? Bool
    
    Contributions().fetch(username) { success, _, _, today in
      if success {
        self.updateIcon(today)
        
        
        if today == 0 && (dontNotify == nil || !dontNotify!) {
          self.checkForNotification()
        }
      }
    }
  }
  
  var lastIconCount = 0
  func updateIcon(_ _count: Int) {
    var count:Int
    
    if _count == -1 {
      count = lastIconCount
    } else {
      count = _count
      lastIconCount = count
    }
    
    var imageName = count == 0 ?  "icon_notification" : "icon"
    
    if let domain = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain) {
      if let style = domain["AppleInterfaceStyle"] as? String {
        if style == "Dark" {
          imageName += "_dark"
        }
      }
    }
    
    statusButton.image = NSImage(named: imageName)
  }
  
  func checkForNotification() {
    let userDefaults = UserDefaults.standard
    let now = Date()
    let components = (Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: now)
          

    if components.hour! >= 18 {
      let lastNotification = userDefaults.value(forKey: "last_notification") as? Date
      let todayStart = (Calendar.current as NSCalendar).date(bySettingHour: 1, minute: 0, second: 0, of: now, options: [])
      
      if lastNotification == nil || todayStart!.timeIntervalSince(lastNotification!) > 0 {
        let notification = NSUserNotification()
        notification.title = "You haven't committed yet today...";
        notification.subtitle = "Rush to keep your streak going!"
        
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.scheduleNotification(notification)
        
        userDefaults.setValue(now, forKey: "last_notification")
      }
    }
  }

  func applicationWillResignActive(_ notification: Notification) {
    open = false
    popover.closePopover(nil)
  }
  
  @objc func toggle(_: AnyObject) {
    if open {
      popover.closePopover(nil)
    } else {
      let controller = popover.contentViewController as! ContentViewController

      guard let webView = controller.webView else { return }

      let js = "update(false)"

      webView.evaluateJavaScript(js) { (result: Any?, error: Error?) in
        if let error = error {
          debugPrint("JS error: \(error)")
        }
        if let result = result {
          debugPrint("JS result: \(result)")
        }
      }
      
      popover.presentPopover(from: statusItem.view!.bounds, in: statusItem.view!, preferredArrowDirection: INPopoverArrowDirection.up, anchorsToPositionView: true)
      NSApp.activate(ignoringOtherApps: true)
    }

    open.toggle()
  }
  
  @objc func _checkIconNotification(_ notification:Notification) {
    updateIcon(notification.userInfo?["today"] as! Int)
  }
  
  @objc func _darkModeChanged(_ notification:Notification) {
    updateIcon(-1)
  }
  
  @objc func _checkUsernameNotification(_ notification:Notification) {
    if let username = parseData("username") as? String {
      fetchCommits(username)
    } else {
      updateIcon(1)
    }
  }
}
