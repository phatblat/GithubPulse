//
//  ContentViewController.swift
//  GithubPulse
//
//  Created by Tadeu Zagallo on 12/28/14.
//  Copyright (c) 2014 Tadeu Zagallo. All rights reserved.
//

import Cocoa
import WebKit

class ContentViewController: NSViewController, XMLParserDelegate {
  @IBOutlet var webView: WebView!
  @IBOutlet var lastUpdate: NSTextField!
  
  var regex = try? NSRegularExpression(pattern: "^osx:(\\w+)\\((.*)\\)$", options: NSRegularExpression.Options.caseInsensitive)
  var calls: [String: ([String]) -> Void] = [:]
  
  func loadCalls() {
    calls["contributions"] = { [weak self] (args) in
      Contributions().fetch(args[0]) { (success, commits, streak, today) in
        if success {
          if args.count < 2 || args[1] == "true" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "check_icon"), object: nil, userInfo: ["today": today])
          }
        }
        _ = self?.webView?.stringByEvaluatingJavaScript(from: "contributions(\"\(args[0])\", \(success), \(today),\(streak),\(commits))")
      }
    }
    
    calls["set"] = { (args) in
      let userDefaults = UserDefaults.standard
      userDefaults.setValue(args[1], forKey: args[0])
      userDefaults.synchronize()
      
      if args[0] == "username" {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "check_username"), object: self, userInfo: nil)
      }
      
    }
    
    calls["get"] = { [weak self] (args) in
      var value = UserDefaults.standard.value(forKey: args[0]) as? String
      
      if value == nil {
        value = ""
      }
      
      let key = args[0].replacingOccurrences(of: "'", with: "\\'", options: [], range: nil)
      let v = value!.replacingOccurrences(of: "'", with: "\\'", options: [], range: nil)
      
      _ = self?.webView?.stringByEvaluatingJavaScript(from: "get('\(key)', '\(v)', \(args[1]))");
    }
    
    calls["remove"] = { (args) in
      let userDefaults = UserDefaults.standard
      userDefaults.removeObject(forKey: args[0])
      userDefaults.synchronize()
      
      if args[0] == "username" {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "check_username"), object: self, userInfo: nil)
      }
    }
    
    calls["check_login"] = { [weak self] (args) in
      let active = Bundle.main.isLoginItem()
      _ = self?.webView?.stringByEvaluatingJavaScript(from: "raw('check_login', \(active))")
    }
    
    calls["toggle_login"] = { (args) in
      if Bundle.main.isLoginItem() {
        Bundle.main.removeFromLoginItems()
      } else {
        Bundle.main.addToLoginItems()
      }
    }
    
    calls["quit"] = { (args) in
      NSApplication.shared.terminate(self)
    }
    
    calls["update"] = { (args) in
      GithubUpdate.check(true)
    }

    calls["open_url"] = { (args) in
      if let checkURL = URL(string: args[0]) {
        NSWorkspace.shared.open(checkURL)
      }
    }
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    loadCalls()
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    loadCalls()
  }

  override func viewDidLoad() {
#if DEBUG
    let url = URL(string: "http://0.0.0.0:8080")!
#else
    let indexPath = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "front")
    let url = URL(fileURLWithPath: indexPath!)
#endif
    let request = URLRequest(url: url)

    webView.policyDelegate = self
    webView.resourceLoadDelegate = self
    webView.drawsBackground = false
    webView.wantsLayer = true
    if let layer = webView.layer {
      layer.cornerRadius = 5
      layer.masksToBounds = true
    }

    webView.mainFrame.load(request)

    super.viewDidLoad()
  }

  @IBAction func refresh(_ sender: AnyObject?) {
    webView.reload(sender)
  }
}

extension ContentViewController: WebPolicyDelegate {
  func webView(_ webView: WebView!, decidePolicyForNavigationAction actionInformation: [AnyHashable: Any]!, request: URLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
    let url:String = request.url!.absoluteString.removingPercentEncoding!

    if url.hasPrefix("osx:") {
      let matches = regex?.matches(in: url, options: [], range: NSMakeRange(0, url.count))
      if let match = matches?[0] {
        let fn = (url as NSString).substring(with: match.range(at: 1))
        let args = (url as NSString).substring(with: match.range(at: 2)).components(separatedBy: "%%")
        
        #if DEBUG
          print(fn, args)
        #endif
        
        let closure = calls[fn]
        closure?(args)
      }
    } else if (url.hasPrefix("log:")) {
#if DEBUG
      print(url)
#endif
    } else {
      listener.use()
    }
  }
}

extension ContentViewController: WebResourceLoadDelegate {
  func webView(_ sender: WebView!, resource identifier: Any!, didFinishLoadingFrom dataSource: WebDataSource!) {
    debugPrint("didFinishLoadingFrom: \(String(describing: dataSource.response.url))")
  }

  func webView(_ sender: WebView!, resource identifier: Any!, didFailLoadingWithError error: Error!, from dataSource: WebDataSource!) {
    debugPrint("didFailLoadingWithError: \(String(describing: error)), \(String(describing: dataSource.response.url))")
  }
}

/*
 1100 means NSURLErrorFileDoesNotExist
 */
