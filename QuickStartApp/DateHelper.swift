//
//  DateHelper.swift
//  QuickStartApp
//
//  Created by Wang Yujia on 28/9/16.
//  Copyright © 2016 National University of Singapore Design Centric Program. All rights reserved.
//

import Foundation
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
