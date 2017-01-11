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
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated) // original line
        
        /*let defaults = UserDefaults.standard
        print("check if token is loading: \(defaults.bool(forKey: "loadingOAuthToken"))")
        print("token is \(FitbitAPIHelper.sharedInstance.accessToken)")*/
        loadInitialData()
    }
    
    
    func loadInitialData()
    {
        if (!FitbitAPIHelper.sharedInstance.hasToken())
        {
            FitbitAPIHelper.sharedInstance.startFitbitLogin()
        }
        else
        {
            func stepLoop () {
                FitbitAPIHelper.sharedInstance.getFitbitStepData
                    { (counter, error) in
                        if let anError = error
                        {
                            print(anError)
                        } else
                        {
                            let loop_length: Int = FitbitAPIHelper.sharedInstance.download_date_list.count - 1
                            if counter! <= loop_length {
                                stepLoop()
                            }
                            if counter == loop_length {
                                // FitbitAPIHelper.sharedInstance.download_step_counter = 0
                            }
                        }
                        /*NotificationCenter.default.post(name: Notification.Name(rawValue: "data has been stored"), object: json)*/
                }
            }
            stepLoop()
            func heartLoop () {
                FitbitAPIHelper.sharedInstance.getFitbitHeartData
                    { (counter, error) in
                        if let anError = error
                        {
                            print(anError)
                        } else
                        {
                            let loop_length: Int = FitbitAPIHelper.sharedInstance.download_date_list.count - 1
                            if counter! <= loop_length {
                                heartLoop()
                            }
                            if counter == loop_length {
                                // check if all files are received here
                                // FitbitAPIHelper.sharedInstance.download_heart_counter = 0
                                print("Now heart file downloading counter is set to: \(FitbitAPIHelper.sharedInstance.download_heart_counter)")
                            }
                        }
                        /*NotificationCenter.default.post(name: Notification.Name(rawValue: "data has been stored"), object: json)*/
                }
            }
            heartLoop()
        }
    }
    
    
    
    
    
    
    
    
    ////// TODO
    @IBAction func SyncFitbit(_ sender: AnyObject)
    {
        // press button to sync fitbit data. note that the rate limit is 150.check response header for number of requests left and countdown to next 150 requests.

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

