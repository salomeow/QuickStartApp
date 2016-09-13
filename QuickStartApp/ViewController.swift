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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //fetchMyRepos()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // testing FileSaveHelper
        let testFile = FileSaveHelper(fileName: "testFile", fileExtension: .TXT, subDirectory: "SavingFiles", directory: .DocumentDirectory)
        
        print("Directory exists: \(testFile.directoryExists)")
        print("File exists: \(testFile.fileExists)")
        // end testing
    }

    @IBAction func FitbitAuthorize(sender: AnyObject) {
        print("button pressed")
        
        // redirect to fitbit authorization page
        let authPath = "https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=227ZFK&redirect_uri=nusdcp2016://&scope=activity%20heartrate"
        
        // open authorization page in Safari
        if let authURL:NSURL = NSURL(string: authPath)
        {
            // save a bool to the NSUserDefaults to indicate currently loading the OAuth token:
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "loadingOAuthToken")
            // open safari page for authorization
            UIApplication.sharedApplication().openURL(authURL)
        }
        
        // 1. request authorization code
        Alamofire.request(
            .GET,
            authPath,
            parameters: ["expires_in":"2592000", "prompt":"login consent"],
            encoding: .URL)
            .validate()
            .responseString { (response) -> Void in
                // response: request, response, data, result
                print("start receiving authorization code")
                print(response.response?.statusCode) // URL response
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

