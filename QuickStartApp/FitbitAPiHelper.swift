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

class FitbitAPIHelper {
    static let sharedInstance = FitbitAPIHelper()
    
    let getTokenPath:String = "https://api.fitbit.com/oauth2/token"
    let client_id = "227ZFK"
    let client_secret = "47e5382a22367a094b075587fb559f05"
    let download_date_list = ["2016-09-04", "2016-09-05", "2016-09-06"]
    // TODO: error cases
    // TODO: store and retrieve stored token
    // TODO: refresh token
    // TODO: check list of files >> write a file for downloaded files
    // TODO: NSDate >> generate a list of files
    
    // step 1: request authorization code

    // step 2: exchange authorizatin code for access token
    func requestFitbitAccessToken(authorization_code: String?) -> String {
        
        let tokenParams = ["client_id":"227ZFK",
                           "client_secret":"47e5382a22367a094b075587fb559f05",
                           "code": authorization_code!,
                           "grant_type":"authorization_code",
                           "redirect_uri":"nusdcp2016://",
                           "expires_in":"28800"]
        // base64 encode client id and secret
        let apiLoginString = NSString(format: "%@:%@", client_id, client_secret)
        let apiLoginData = apiLoginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64ApiLoginString = apiLoginData.base64EncodedStringWithOptions([])
        
        let theHeader = "Basic " + base64ApiLoginString
        
        Alamofire.request(
            .POST,
            getTokenPath,
            headers: ["Authorization" : theHeader],
            parameters: tokenParams)
            .responseJSON { (response) -> Void in
                // TODO: handle response to extract OAuth token
                print(response.response?.statusCode)
                let access_token = response.result.value!["access_token"] as! String
                let theAPIHeader: String = "Bearer " + access_token
                // 3. make API call and download data
                // config data storage
                self.FitbitAPICall(self.download_date_list, header: theAPIHeader)
                // end of API call
        }
    }

    // helper function for step 3
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
    
    // step 3: make API call
    func FitbitAPICall(download_date_list: Array<String>, header theAPIHeader: String) {
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
            Alamofire.request(
                .GET,
                "https://api.fitbit.com/1/user/-/activities/heart/date/\(download_date)/1d/15min.json",
                //use - afer user/ for current logged in user
                headers: ["Authorization" : theAPIHeader])
                .validate()
                .responseJSON { (response) -> Void in
                    print(response.response?.statusCode)
                    if let heartJSON = response.result.value {
                        // save json file locally
                        self.saveJSONandCheck(heartJSON, download_heart_filename, download_heart_foldername)
                    }
            }
            
        }
        
    }

}