//
//  DateHelper.swift
//  QuickStartApp
//
//  Created by Wang Yujia on 22/12/16.
//  Copyright © 2016 National University of Singapore Design Centric Program. All rights reserved.
//

import Foundation

class DateHelper
{
    static let sharedInstance = DateHelper()
    func get_date_list(date_range_n: Int = 30) -> [String] {
        let now = Date()
        let myLocale = Locale(identifier: "sg_SG")
        let formatter = DateFormatter()
        formatter.locale = myLocale
        formatter.dateFormat = "y-MM-dd"
        var dateStr = formatter.string(from: now)
        var date_list=[dateStr]
        for i in 1...date_range_n {
            let interval_count = TimeInterval(24*60*60*i)
            let day = Date(timeIntervalSinceNow: -interval_count)
            dateStr = formatter.string(from: day)
            date_list.append(dateStr)
        }
        return date_list
    }

}
