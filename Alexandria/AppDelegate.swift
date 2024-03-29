//
//  AppDelegate.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 6/30/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import CoreData
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var persistentContainer: NSPersistentContainer!
    
    var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        createAlexandriaContainer() { container in
            self.persistentContainer = container
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            guard let window = self.window else { return }
            window.backgroundColor = .white
            
            self.appCoordinator = AppCoordinator(managedObjectContext: container.viewContext)
            window.rootViewController = self.appCoordinator.navigationController
            self.appCoordinator.start()
            
            window.makeKeyAndVisible()
        }
        
        #if DEBUG
            print("App version number: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)")
            print("App build number: \(Bundle.main.infoDictionary!["CFBundleVersion"]!)")
        #endif
        
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.host == "oauth-callback") {
            print(url.absoluteURL)
            OAuthSwift.handle(url: url)
        }
        
        return true
    }
}

