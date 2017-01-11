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

////////////////////////////////////////////////////////////////////////////////////////////////
// TODO: store and retrieve stored token from phone                                           //
// TODO: refresh token                                                                        //
// TODO: check list of files >> write a file for downloaded files                             //
// TODO: NSDate >> generate a list of files                                                   //
////////////////////////////////////////////////////////////////////////////////////////////////


class FitbitAPIHelper
{
    static let sharedInstance = FitbitAPIHelper()
    var OAuthTokenCompletionHandler:((NSError?) -> Void)?
    
    // declare credentials
    let client_id = "227ZFK"
    let client_secret = "47e5382a22367a094b075587fb559f05"
    let redirect_url = "nusdcp2016://"
    let FitbitauthPath = "https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=227ZFK&redirect_uri=nusdcp2016://&scope=activity%20heartrate"
    let FitbitTokenPath = "https://api.fitbit.com/oauth2/token"
    // store token
    var accessToken: String?
    var refreshToken: String?
    
    // API call list
    // 4 weeks data
    var download_step_counter: Int = 0
    var download_heart_counter: Int = 0
    let download_date_list = DateHelper().get_date_list(date_range_n: 60)
    
    // 5: make API call
    // TODO: need a completion handler
    func getFitbitStepData(_ completionHandler: @escaping (Int?, NSError?) -> Void)
    {
        let theAPIHeader: String = "Bearer " + self.accessToken!
        var download_step_filename: String

        download_step_filename = "step" + download_date_list[self.download_step_counter]
        Alamofire.request("https://api.fitbit.com/1/user/-/activities/steps/date/\(download_date_list[self.download_step_counter])/1d/15min.json", method: .get, headers: ["Authorization" : theAPIHeader]).validate().responseJSON
            { (response) -> Void in
                if let anError = response.result.error
                {
                    print(anError)
                    completionHandler(nil, anError as NSError)
                    // print(response.response?.allHeaderFields)
                    return
                }
                // print(response.response?.statusCode)
                if let stepJSON = response.result.value {
                    self.download_step_counter += 1
                    let savedData = FileSaveHelper(fileName:download_step_filename, fileExtension: .JSON, subDirectory: "FitbitData", directory: .documentDirectory)
                    do {
                        try savedData.saveFile(dataForJson: stepJSON as AnyObject)
                    }
                    catch {
                        print(error)
                    }
                    completionHandler(self.download_step_counter, nil)
                }
        }
    }
    
    func getFitbitHeartData(_ completionHandler: @escaping (Int?, NSError?) -> Void)
    {
        let theAPIHeader: String = "Bearer " + self.accessToken!
        var download_heart_filename: String
        
        download_heart_filename = "heart" + download_date_list[self.download_heart_counter]
        Alamofire.request("https://api.fitbit.com/1/user/-/activities/heart/date/\(download_date_list[self.download_heart_counter])/1d/15min.json", method: .get, headers: ["Authorization" : theAPIHeader]).validate().responseJSON
            { (response) -> Void in
                if let anError = response.result.error
                {
                    print(anError)
                    completionHandler(nil, anError as NSError)
                    // print(response.response?.allHeaderFields)
                    return
                }
                // print(response.response?.statusCode)
                if let heartJSON = response.result.value {
                    self.download_heart_counter += 1
                    let savedData = FileSaveHelper(fileName:download_heart_filename, fileExtension: .JSON, subDirectory: "FitbitData", directory: .documentDirectory)
                    do {
                        try savedData.saveFile(dataForJson: heartJSON as AnyObject)
                    }
                    catch {
                        print(error)
                    }
                    completionHandler(self.download_heart_counter, nil)
                }
        }
    }

    
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
        if let authURL: URL = URL(string: FitbitauthPath)
        {
            /*/ set defaults.boolForKey("loadingOAuthToken") here
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "loadingOAuthToken")*/
            // open authorization page
            UIApplication.shared.openURL(authURL)
        }
    }
    
    // 3: get authorization code
    func startFitbitOAuth2Flow(_ url: URL) //processOauthStep1response
    {
        print("getFitbitAuthorizationCode is executing")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var code:String?
        if let queryItems = components?.queryItems
        {
            for queryItem in queryItems
            {
                if (queryItem.name.lowercased() == "code")
                {
                    // authorization code
                    code = queryItem.value
                    break
                }
            }
        }
        
        // 4: exchange authorization code for access token
        if let authorizationCode = code
        {
            // token request path and parameters
            let getTokenPath:String = FitbitTokenPath
            let tokenParams = ["client_id": client_id,
                               "client_secret":client_secret,
                               "code": authorizationCode,
                               "grant_type":"authorization_code",
                               "redirect_uri":redirect_url,
                               "expires_in":"28800"]
            // base64 encode client id and secret
            let apiLoginString = NSString(format: "%@:%@", client_id, client_secret)
            let apiLoginData = apiLoginString.data(using: String.Encoding.utf8.rawValue)!
            let base64ApiLoginString = apiLoginData.base64EncodedString(options: [])
            // header containing authorization code used for requesting access token
            let theHeader = "Basic " + base64ApiLoginString
            Alamofire.request(getTokenPath, method: .post, parameters: tokenParams, encoding: URLEncoding.default, headers: ["Authorization" : theHeader]).responseJSON {
                response in
                    print(response.result.value)
                    if let anError = response.result.error
                    {
                        print(anError)
                        if let completionHandler = self.OAuthTokenCompletionHandler
                        {
                            let nOAuthError = NSError(domain: "AlamofireErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not obtain an OAuth token", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
                            completionHandler(nOAuthError)
                        }
                        let defaults = UserDefaults.standard
                        defaults.set(false, forKey: "loadingOAuthToken")
                        return
                    }
                    if let Tokens = response.result.value as? NSDictionary
                    {
                        print(response.response?.statusCode)
                        print(Tokens)
                        self.accessToken = Tokens["access_token"] as? String
                        self.refreshToken = Tokens["refresh_token"] as? String
                        print("check if hasToken() updated. the current value is: \(self.hasToken())")
                        

                        func stepLoop () {
                            self.getFitbitStepData
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
                            self.getFitbitHeartData
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
                                            // FitbitAPIHelper.sharedInstance.download_heart_counter = 0
                                            print("Now heart file downloading counter is set to: \(FitbitAPIHelper.sharedInstance.download_heart_counter)")
                                        }
                                    }
                                    /*NotificationCenter.default.post(name: Notification.Name(rawValue: "data has been stored"), object: json)*/
                            }
                        }
                        heartLoop()
                    }
                    let defaults = UserDefaults.standard
                    defaults.set(false, forKey: "loadingOAuthToken")
                    
                    if self.hasToken()
                    {
                        if let completionHandler = self.OAuthTokenCompletionHandler
                        {
                            completionHandler(nil)
                        }
                    }
                    else
                    {
                        if let completionHandler = self.OAuthTokenCompletionHandler
                        {
                            let nOAuthError = NSError(domain: "AlamofireErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not obtain an OAuth token", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
                            completionHandler(nOAuthError)
                        }
                    }
                    
                    
                    
                    
                    // 5: make Fitbit API call, request data, and store data locally
                    // self.getFitbitData()
                    // completionHandler(str, response.result.error)
                    
            }
            
        } else // no received code
        {
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "loadingOAuthToken")
        }
    }
    
    // helper function for 5
    
    func saveJSONandCheck(_ JSONfile: AnyObject, _ file_name: String) {
        let savedJSON = FileSaveHelper(fileName:file_name, fileExtension: .JSON, subDirectory: "FitbitData", directory: .documentDirectory)
        do {
            try savedJSON.saveFile(dataForJson: JSONfile)
        }
        catch {
            print(error)
        }
        // print("JSON file exists: \(savedJSON.fileExists)")
    }
    
    
    
}
