//
//  FitbitAPiHelper.swift
//  QuickStartApp
//
//  Created by Wang Yujia on 13/9/16.
//  Copyright © 2016 National University of Singapore Design Centric Program. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// TODO: error cases
// TODO: store and retrieve stored token
// TODO: refresh token
// TODO: check list of files >> write a file for downloaded files
// TODO: NSDate >> generate a list of files




class FitbitAPIHelper
{
    static let sharedInstance = FitbitAPIHelper()
    
    // declare credentials
    let client_id = "227ZFK"
    let client_secret = "47e5382a22367a094b075587fb559f05"
    let redirect_url = "nusdcp2016://"
    
    // store token
    var authorizationCode: String?
    var accessToken: String?
    var refreshToken: String?
    
    // API call list
    let download_date_list = ["2016-09-03", "2016-09-04", "2016-09-05", "2016-09-06"]

    // 1: check if access token exists
    func hasToken() -> Bool
    {
        // default false, return true after token is called/stored
        if let token = self.accessToken
        {
            return !token.isEmpty
        }
        return false
    }
    
    // 2: start Fitbit authorization flow: code grant
    func startFitbitLogin()
    {
        print("start fitbit login process")
        let authPath: String = "https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=227ZFK&redirect_uri=nusdcp2016://&scope=activity%20heartrate"
        if let authURL: NSURL = NSURL(string: authPath)
        {
            // set defaults.boolForKey("loadingOAuthToken") here
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: "loadingOAuthToken")
            // open authorization page
            print("opening authorization page")
            UIApplication.sharedApplication().openURL(authURL)
        }
    }
    
    // 3: get authorization code
    func getFitbitAuthorizationCode(url: NSURL) //processOauthStep1response
    {
        print("getFitbitAuthorizationCode is executing")
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        var code:String?
        if let queryItems = components?.queryItems
        {
            for queryItem in queryItems
            {
                if (queryItem.name.lowercaseString == "code")
                {
                    // authorization code
                    code = queryItem.value
                    self.authorizationCode = code
                    break
                }
            }
        }
        print("request access token in getFitbitAuthorizationCode function")
        // 4: exchange authorization code for access token
        FitbitAPIHelper.sharedInstance.getFitbitAccessToken
            { (str, error) in
                if str != nil
                {
                // Use str value
                } else
                {
                // Handle error / nil value
                }
        }

    }
    
    // 4: exchange authorizatin code for access token
    func getFitbitAccessToken(completionHandler: (String?, NSError?) -> ())
    {
        // token request path and parameters
        let getTokenPath:String = "https://api.fitbit.com/oauth2/token"
        let tokenParams = ["client_id": client_id,
                           "client_secret":client_secret,
                           "code": authorizationCode!,
                           "grant_type":"authorization_code",
                           "redirect_uri":redirect_url,
                           "expires_in":"28800"]
        // base64 encode client id and secret
        let apiLoginString = NSString(format: "%@:%@", client_id, client_secret)
        let apiLoginData = apiLoginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64ApiLoginString = apiLoginData.base64EncodedStringWithOptions([])
        // header containing authorization code used for requesting access token
        let theHeader = "Basic " + base64ApiLoginString
        Alamofire.request(
            .POST,
            getTokenPath,
            headers: ["Authorization" : theHeader],
            parameters: tokenParams)
            .responseJSON { (response) -> Void in
                // TODO: handle response to extract OAuth token
                print(response.response?.statusCode)
                print(response.result.value)
                let str = response.result.value!["access_token"] as? String
                self.accessToken = str
                self.refreshToken = response.result.value!["refresh_token"] as? String
                
                // 5: make Fitbit API call, request data, and store data locally
                self.getFitbitData()
                completionHandler(str, response.result.error)
                
        }
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setBool(false, forKey: "loadingOAuthToken")
    }

    // helper function for 5
    func saveJSONandCheck(JSONfile: AnyObject, _ file_name: String, _ folder_name: String) {
        let savedJSON = FileSaveHelper(fileName:file_name, fileExtension: .JSON, subDirectory: folder_name, directory: .DocumentDirectory)
        do {
            try savedJSON.saveFile(dataForJson: JSONfile)
        }
        catch {
            print(error)
        }
        print("JSON file exists: \(savedJSON.fileExists)")
    }
    
    // 5: make API call 
    // TODO: need a completion handler
    func getFitbitData()
    {
        
        let theAPIHeader: String = "Bearer " + self.accessToken!
        var requestPath: String
        for download_date in download_date_list {
            let download_step_filename = "step" + download_date
            let download_step_foldername = "step_data"
            let download_heart_filename = "heart" + download_date
            let download_heart_foldername = "heart_data"
            // request intraday step data
            Alamofire.request(
                .GET,
                "https://api.fitbit.com/1/user/-/activities/steps/date/\(download_date)/1d/15min.json",
                //use - afer user/ for current logged in user
                headers: ["Authorization" : theAPIHeader])
                .validate()
                .responseJSON { (response) -> Void in
                    print(response.response?.statusCode)
                    if let stepJSON = response.result.value {
                        // save json file locally
                        self.saveJSONandCheck(stepJSON, download_step_filename, download_step_foldername)
                    }
            }
            
            // request intraday heartrate data
            requestPath = "https://api.fitbit.com/1/user/-/activities/heart/date/\(download_date)/1d/15min.json"
            Alamofire.request(
                .GET,
                requestPath,
                //use - afer user/ for current logged in user
                headers: ["Authorization" : theAPIHeader])
                .validate()
                .responseJSON { (response) -> Void in
                    print(response.response?.statusCode)
                    if let heartJSON = response.result.value
                    {
                        // save json file locally
                        self.saveJSONandCheck(heartJSON, download_heart_filename, download_heart_foldername)
                    }
            }
            
        }
        
    }

}