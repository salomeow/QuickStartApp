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
//////////////////////////////////////////////////////////////////////////////////////////////
//func > (left: NSDate, right: NSDate) -> Bool {
//    return left.compare(right) == .OrderedDescending
//}
//
//extension NSCalendar {
//    func dateRange(startDate startDate: NSDate, endDate: NSDate, stepUnits: NSCalendarUnit, stepValue: Int) -> DateRange {
//        let dateRange = DateRange(calendar: self, startDate: startDate, endDate: endDate,
//                                  stepUnits: stepUnits, stepValue: stepValue, multiplier: 0)
//        return dateRange
//    }
//}
//
//struct DateRange :SequenceType {
//    
//    var calendar: NSCalendar
//    var startDate: NSDate
//    var endDate: NSDate
//    var stepUnits: NSCalendarUnit
//    var stepValue: Int
//    private var multiplier: Int
//    
//    func generate() -> Generator {
//        return Generator(range: self)
//    }
//    
//    struct Generator: GeneratorType {
//        
//        var range: DateRange
//        
//        mutating func next() -> NSDate? {
//            guard let nextDate = range.calendar.dateByAddingUnit(range.stepUnits,
//                                                                 value: range.stepValue * range.multiplier,
//                                                                 toDate: range.startDate,
//                                                                 options: []) else {
//                                                                    return nil
//            }
//            if nextDate > range.endDate {
//                return nil
//            }
//            else {
//                range.multiplier += 1
//                return nextDate
//            }
//        }
//    }
//}
//


class FitbitAPIHelper
{
    static let sharedInstance = FitbitAPIHelper()
    var OAuthTokenCompletionHandler:(NSError? -> Void)?
    
    // declare credentials
    let client_id = "227ZFK"
    let client_secret = "47e5382a22367a094b075587fb559f05"
    let redirect_url = "nusdcp2016://"
    
    // store token
    var accessToken: String?
    var refreshToken: String?
    
    // API call list
    // 4 weeks data
    let download_date_list = ["2016-09-05", "2016-09-06", "2016-09-07", "2016-09-08", "2016-09-09",
                              "2016-09-10", "2016-09-11"]
    
    // 5: make API call
    // TODO: need a completion handler
    func getFitbitData(completionHandler: (NSDictionary?, String?, String?, NSError?) -> Void)
    {
        
        let theAPIHeader: String = "Bearer " + self.accessToken!
        let download_step_foldername = "step_data"
        let download_heart_foldername = "heart_data"
        var download_step_filename: String
        var download_heart_filename: String
        
        ////////////////////////////////////////////////////////////////////////////////////////////
//        // Usage:
//        func testDateRange() -> DateRange {
//            
//            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//            let startDate = NSDate(timeIntervalSinceNow: -(24*60*60*10-1))
//            let endDate = NSDate(timeIntervalSinceNow: 0)
//            let dateRange = calendar.dateRange(startDate: startDate,
//                                               endDate: endDate,
//                                               stepUnits: .Day,
//                                               stepValue: 1)
//            return dateRange
//        }
//        
//        let dates = testDateRange()
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        var download_date: String
        ////////////////////////////////////////////////////////////////////////////////////////////

        
        for download_date in download_date_list {
            ////////////////////////////////////////////////////////////////////////////////////////
            // download_date = dateFormatter.stringFromDate(date)
            // print(download_date)
            ////////////////////////////////////////////////////////////////////////////////////////
            
            download_step_filename = "step" + download_date
            download_heart_filename = "heart" + download_date
            
            // request intraday step data
            Alamofire.request(.GET,
                "https://api.fitbit.com/1/user/-/activities/steps/date/\(download_date)/1d/15min.json",
                headers: ["Authorization" : theAPIHeader])
                .validate()
                .responseJSON
                { (response) -> Void in
                    
                    if let anError = response.result.error
                    {
                        print(anError)
                        print(response.response?.allHeaderFields)
                        completionHandler(nil, nil, nil, anError)
                        return
                    }
                    print(response.response?.statusCode)
                    if let stepJSON = response.result.value {
                        // print(download_date)
                        // print(stepJSON)
                        completionHandler(stepJSON as? NSDictionary, download_step_filename, download_step_foldername, nil)
                        // save json file locally
                        // self.saveJSONandCheck(stepJSON, download_step_filename, download_step_foldername)
                    }
            }
            
            // request intraday heartrate data
//            Alamofire.request(.GET,
//                "https://api.fitbit.com/1/user/-/activities/heart/date/\(download_date)/1d/15min.json",
//                headers: ["Authorization" : theAPIHeader])
//                .validate()
//                .responseJSON
//                { (response) -> Void in
//                    if let anError = response.result.error
//                    {
//                        print(anError)
//                        completionHandler(nil, anError)
//                        return
//                    }
//                    print(response.response?.statusCode)
//                    if let heartJSON = response.result.value
//                    {
//                        print(download_date)
//                        print(heartJSON)
//                        // save json file locally
//                        // self.saveJSONandCheck(heartJSON, download_heart_filename, download_heart_foldername)
//                    }
//            }
        }
        // completionHandler("success", nil)
        
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
                    break
                }
            }
        }
        
        // 4: exchange authorization code for access token
        if let authorizationCode = code
        {
            // token request path and parameters
            let getTokenPath:String = "https://api.fitbit.com/oauth2/token"
            let tokenParams = ["client_id": client_id,
                               "client_secret":client_secret,
                               "code": authorizationCode,
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
                    if let anError = response.result.error
                    {
                        print(anError)
                        if let completionHandler = self.OAuthTokenCompletionHandler
                        {
                            let nOAuthError = NSError(domain: "AlamofireErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not obtain an OAuth token", NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"])
                            completionHandler(nOAuthError)
                        }
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setBool(false, forKey: "loadingOAuthToken")
                        return
                    }
                    if let receivedToken = response.result.value!["access_token"] as? String
                    {
                        print(response.response?.statusCode)
                        self.accessToken = receivedToken
                        self.refreshToken = response.result.value!["refresh_token"] as? String
                        print("access token stored:  ")
                        print(self.accessToken)
                        print("check if hasToken() updated. the current value is: ")
                        print(self.hasToken())
                        self.getFitbitData
                            { (json, filename, foldername, error) in
                                if let anError = error
                                {
                                    print(anError)
                                } else
                                {
                                    print(json!)
                                    // store data
                                    // notification data is stored
                                    // NSnotification, notify other code something is completed
                                    self.saveJSONandCheck(json!, filename!, foldername!)
                                    NSNotificationCenter.defaultCenter().postNotificationName("data has been stored", object: json)
                                    
                                }
                        }
                    }
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(false, forKey: "loadingOAuthToken")
                    
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
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: "loadingOAuthToken")
        }
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
        // print("JSON file exists: \(savedJSON.fileExists)")
    }
    
    
    
}