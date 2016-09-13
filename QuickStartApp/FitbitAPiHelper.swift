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
    func downloadFitbitData(download_date_list: Array<String>, header theAPIHeader: String) {
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