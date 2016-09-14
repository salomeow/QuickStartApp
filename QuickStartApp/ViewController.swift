//
//  ViewController.swift
//  QuickStartApp
//
//  Created by Wang Yujia on 12/9/16.
//  Copyright © 2016 National University of Singapore Design Centric Program. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    

    
    override func viewDidLoad()
    {
        print("start view did load")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // check whether we’re loading the OAuth token before we start loading data or start the OAuth login process
        let defaults = NSUserDefaults.standardUserDefaults()
        // defaults.boolForKey("loadingOAuthToken") is set in FitbitStartLogin in FitbitAPIHelper
        print(defaults.boolForKey("loadingOAuthToken")) // false if token is loading
        
        if (!FitbitAPIHelper.sharedInstance.hasToken()) // if token does not exist
        {
            // token does not exist, starting requesting authorization page
            print(FitbitAPIHelper.sharedInstance.accessToken)
            FitbitAPIHelper.sharedInstance.startFitbitLogin()
        } else
        {
            // token exists, use stored token to fetch Fitbit data
            print(FitbitAPIHelper.sharedInstance.accessToken)
            FitbitAPIHelper.sharedInstance.getFitbitData()
        }

        
        print("end view did load")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        print("start view will appear")
        super.viewWillAppear(animated)
        
//        if (!defaults.boolForKey("loadingOAuthToken")) // if token is not loading
//        {
//            if (!FitbitAPIHelper.sharedInstance.hasToken()) // if token does not exist
//            {
//                // token does not exist, starting requesting authorization page
//                FitbitAPIHelper.sharedInstance.startFitbitLogin()
//            } else
//            {
//                // token exists, use stored token to fetch Fitbit data
//                FitbitAPIHelper.sharedInstance.FitbitAPICall()
//            }
//        } else
//        {
//            // token exists, use stored token to fetch Fitbit data
//            FitbitAPIHelper.sharedInstance.FitbitAPICall()
//        }
        print("end view will appear")
    }

    
    
    
    
    
    
    
//    @IBAction func FitbitAuthorize(sender: AnyObject)
//    {
//        print("button pressed")
//        
//        // redirect to fitbit authorization page
//        let authPath = "https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=227ZFK&redirect_uri=nusdcp2016://&scope=activity%20heartrate"
//        
//        // open authorization page in Safari
//        if let authURL:NSURL = NSURL(string: authPath)
//        {
//            // save a bool to the NSUserDefaults to indicate currently loading the OAuth token:
//            let defaults = NSUserDefaults.standardUserDefaults()
//            defaults.setBool(true, forKey: "loadingOAuthToken")
//            // open safari page for authorization
//            UIApplication.sharedApplication().openURL(authURL)
//        }
//        
//        // 1. request authorization code
//        Alamofire.request(
//            .GET,
//            authPath,
//            parameters: ["expires_in":"2592000", "prompt":"login consent"],
//            encoding: .URL)
//            .validate()
//            .responseString { (response) -> Void in
//                // response: request, response, data, result
//                print("start receiving authorization code")
//                print(response.response?.statusCode) // URL response
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

