//
//  AppDelegate.swift
//  FOAV
//
//  Created by hoon Kim on 30/09/2019.
//  Copyright © 2019 hoon Kim. All rights reserved.
//

import UIKit
import RxSwift
import DropDown
import Foundation
import IQKeyboardManagerSwift
import UserNotifications
import FirebaseMessaging
import Firebase
import SwiftyIamport
import Kingfisher
import TAKUUID
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var updateVersion = 2
    var window: UIWindow?
    var deviceToken: Data? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
      
      KingfisherManager.shared.cache.memoryStorage.config.totalCostLimit = 100000
      
        Thread.sleep(forTimeInterval: 1.0)
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        self.window = UIWindow(frame: UIScreen.main.bounds)
        // 스토리보드 인스턴스
        let loginStoryboard = UIStoryboard(name: "Splash", bundle: nil)
        // 뷰 컨트롤러 인스턴스
        let viewController = loginStoryboard.instantiateViewController(withIdentifier: "SplashVC")
        // 윈도우의 루트 뷰 컨트롤러 설정
        self.window?.rootViewController = viewController
        // 이제 화면에 보여주자.
        self.window?.makeKeyAndVisible()
      
      DropDown.startListeningToKeyboard()
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self as MessagingDelegate
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions,completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        IQKeyboardManager.shared.enable = true
        return true
    }
    // 화면 세로 고정
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme {
            if scheme.hasPrefix(IAMPortPay.sharedInstance.appScheme ?? "") {
                return IAMPortPay.sharedInstance.application(app, open: url, options: options)
            }
        }
        if KOSession.isKakaoAccountLoginCallback(url.absoluteURL) {
            return KOSession.handleOpen(url)
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url.absoluteURL) {
            return KOSession.handleOpen(url)
        }
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       Messaging.messaging().apnsToken = deviceToken
    }


    func applicationWillResignActive(_ application: UIApplication) {
        UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
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
        KOSession.handleDidBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("\(#function)")
    }
}
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]
        FcmDeviceToken = fcmToken
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
//extension UIApplication {
//    var statusBarView: UIView? {
//        return value(forKey: "statusBar") as? UIView
//    }
//}
