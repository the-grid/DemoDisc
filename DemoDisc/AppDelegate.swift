//
//  AppDelegate.swift
//  DemoDisc
//
//  Created by Paul Young on 10/20/15.
//  Copyright © 2015 The Grid. All rights reserved.
//

import Disc
import UIKit
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WKNavigationDelegate {

    var window: UIWindow?
    var oauth: OAuthClient?
    var webView: WKWebView?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let viewController = UIViewController()
        viewController.view.frame = window!.frame
        let navigationController = UINavigationController(rootViewController: viewController)
        
        
        // MARK: - Create an OAuth client
        
        let clientId = "FIXME"
        let clientSecret = "FIXME"
        let redirectUri = "fixme://oauth"
        
        oauth = OAuthClient(clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri)
        
        
        // MARK: - Create a login URL
        
        let loginUrl = oauth!.createLoginUrl()
        print("---------")
        print("The login URL is \(loginUrl!.absoluteString)")
        
        
        // MARK: - Request access from a user
        
        if let url = loginUrl {
            webView = WKWebView(frame: window!.frame)
            webView!.navigationDelegate = self
            viewController.view.addSubview(webView!)

            let request = NSURLRequest(URL: url)
            webView!.loadRequest(request)
        }
        
        
        // MARK: - Create an API client
        
        let api = APIClient(token: "FIXME")
        
        
        // MARK: - Get the current user
        
        api.getUser { result in
            print("---------")
            switch result {
            case let .Success(user):
                print("The current user is \(user.name)")
            case let .Failure(error):
                print("Error, getUser():", error.localizedDescription)
            }
        }
        
        
        // MARK: - Get a user by ID
        
        let userId = "FIXME"

        api.getUser(userId) { result in
            print("---------")
            switch result {
            case let .Success(user):
                print("The user with id \(userId) is \(user.name)")
            case let .Failure(error):
                print("Error, getUser(\(userId)):", error.localizedDescription)
            }
        }
        
        
        // MARK: - Get the current user's identities
        
        api.getIdentities() { result in
            print("---------")
            switch result {
            case let .Success(identities):
                let providers = identities.map({ $0.provider.rawValue }).joinWithSeparator(", ")
                print("The current user's identity providers are", providers)
            case let .Failure(error):
                print("Error, getIdentities():", error.localizedDescription)
            }
        }
        
        
        // MARK: - Delete an identity
        
        let identityId = -1 // FIXME

        api.deleteIdentity(identityId) { result in
            print("---------")
            switch result {
            case .Success:
                print("Deleted identity with id \(identityId)")
            case let .Failure(error):
                print("Error, deleteIdentity(\(identityId)):", error.localizedDescription)
            }
        }
        
        
        // MARK: - Get the current user's public GitHub token
        
        api.getPublicGitHubToken { result in
            print("---------")
            switch result {
            case let .Success(token):
                print("The current user's public GitHub token is", token)
            case let .Failure(error):
                print("Error, getPublicGitHubToken():", error.localizedDescription)
            }
        }
        
        
        // MARK: - Get the current user's public GitHub token
        
        api.getPrivateGitHubToken { result in
            print("---------")
            switch result {
            case let .Success(token):
                print("The current user's private GitHub token is", token)
            case let .Failure(error):
                print("Error, getPrivateGitHubToken():", error.localizedDescription)
            }
        }
        
        
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false),
            host = components.host,
            queryItems = components.queryItems,
            item: NSURLQueryItem = queryItems.map({ $0 }).filter({ $0.name == "code" }).first,
            code = item.value
        where host == "oauth" {
            print("---------")
            print("The OAuth access grant code is \(code)")

            oauth!.getAccessToken(code) { [weak self] result in
                print("---------")
                
                switch result {
                case let .Success(token):
                    print("The current user's access token is", token.value)
                case let .Failure(error):
                    print("Error, getAccessToken():", error.localizedDescription)
                }
                
                self?.webView!.removeFromSuperview()
            }
        }
        
        return true
    }
    
    
    // MARK: - WKNavigationDelegate
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let URL = navigationAction.request.URL where URL.scheme == "test" {
            decisionHandler(WKNavigationActionPolicy.Cancel)
            UIApplication.sharedApplication().openURL(URL)
        } else {
            decisionHandler(WKNavigationActionPolicy.Allow)
        }
    }
}
