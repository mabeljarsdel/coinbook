//
//  AppDelegate.swift
//  CoinBookApp
//
//  Created by Hoon H. on 2021/10/03.
//

import UIKit
import CoinBook

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var root = Root?.none
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        root = Root()
        return true
    }
    func applicationWillTerminate(_ application: UIApplication) {
        root = nil
    }
}

