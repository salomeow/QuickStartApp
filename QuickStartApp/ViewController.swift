//
//  ViewController.swift
//  QuickStartApp
//
//  Created by Wang Yujia on 12/9/16.
//  Copyright © 2016 National University of Singapore Design Centric Program. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController
{
   override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("end view did load")
    }
    
    override func viewWillAppear(animated: Bool)
    {
        print("start viewWillAppear")
        super.viewWillAppear(animated) // original line
        
        let defaults = NSUserDefaults.standardUserDefaults()
        print("check if token is loading, result below: ")
        print(defaults.boolForKey("loadingOAuthToken"))
        print("token is")
        print(FitbitAPIHelper.sharedInstance.accessToken)
        loadInitialData()
        print("end viewWillAppear")
    }
    
    func loadInitialData()
    {
        if (!FitbitAPIHelper.sharedInstance.hasToken())
        {
            FitbitAPIHelper.sharedInstance.startFitbitLogin()
        }
        else
        {
            print("else of loadInitialData")
            FitbitAPIHelper.sharedInstance.getFitbitData
            { (json, filename, foldername, error) in
                if let anError = error
                {
                    print(anError)
                } else
                {
                    print(json)
                    // store data
                    // notification data is stored
                    // NSnotification, notify other code something is completed
                    FitbitAPIHelper.sharedInstance.saveJSONandCheck(json!, filename!, foldername!)
                    NSNotificationCenter.defaultCenter().postNotificationName("data has been stored", object: json)
                    
                }
            }
        }
    }
    
    @IBAction func SyncFitbit(sender: AnyObject)
    {
        // press button to sync fitbit data. note that the rate limit is 150.check response header for number of requests left and countdown to next 150 requests.
        loadInitialData()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

