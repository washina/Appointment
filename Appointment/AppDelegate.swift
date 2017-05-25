//
//  AppDelegate.swift
//  Appointment
//
//  Created by YutaIwashina on 2017/04/25.
//  Copyright © 2017年 Yuta.Iwashina. All rights reserved.
//

import UIKit
import Firebase
import SlideMenuControllerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    typealias Location = (delegateAddress: String, delegateLatitude: Double, delegateLongitude: Double)
    var delegateLocation: Location = ("", 0.0, 0.0)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? ) -> Bool {
        
        FirebaseApp.configure()
        
        // 初回起動時に通知の許可を促す処理
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().remoteMessageDelegate = self as? MessagingDelegate
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        
//        コメントアウトはトピック作成の為のコード
//        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotificaiton), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
//        if let refreshedToken = InstanceID.instanceID().token() {
//            print("InstanceID token: \(refreshedToken)")
//            connectToFcm()
//        }
        
        
        return true
    }
    
//    func tokenRefreshNotificaiton(notification: NSNotification) {
//        if let refreshedToken = InstanceID.instanceID().token() {
//            print("InstanceID token: \(refreshedToken)")
//            connectToFcm()
//        }
//    }
    
//    func connectToFcm() {
//        Messaging.messaging().connect { (error) in
//            if error != nil {
//                print("Unable to connect with FCM. \(String(describing: error))")
//            } else {
//                print("Connected to FCM.")
//                let postId = Auth.auth().currentUser?.email
//                Messaging.messaging().subscribe(toTopic: "/topics/\(postId!)")
//            }
//        }
//    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceID.instanceID().setAPNSToken(deviceToken as Data, type: .sandbox)
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
    }


}

