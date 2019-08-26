//
//  LWDateManager.swift
//  LWDateManager
//
//  Created by 赖灵伟 on 15/4/2.
//  Copyright (c) 2015年 深圳创世易明科技有限公司. All rights reserved.
//

/*
yy: 年的后2位
yyyy: 完整年
MM: 月，显示为1-12
MMM: 月，显示为英文月份简写,如 Jan
MMMM: 月，显示为英文月份全称，如 Janualy
dd: 日，2位数表示，如02
d: 日，1-2位显示，如 2
EEE: 简写星期几，如Sun
EEEE: 全写星期几，如Sunday
aa: 上下午，AM/PM
H: 时，24小时制，0-23
K：时，12小时制，0-11
m: 分，1-2位
mm: 分，2位
s: 秒，1-2位
ss: 秒，2位
S: 毫秒

常用日期结构：
yyyy-MM-dd HH:mm:ss.SSS
yyyy-MM-dd HH:mm:ss
yyyy-MM-dd
MM dd yyyy

*/

import Foundation

/**时间日期管理器*/
class LWDateManager {
    
    // MARK: - 日期格式转字符串

    
    class func switchToNSDateFrom(_ dateString: String, dateFormat: String) -> Date? {
    
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return formatter.date(from: dateString)
    }
    
    // MARK: - 日期转字符串格式
    /**日期转字符串格式*/
    class func switchToStringFrom(_ date: Date, dateFormat: String) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return formatter.string(from: date)
    }
    
    
    //1、一个小时内：  xx分钟前
    //2、今天之内     HH:mm
    //3、今年之内：   MM-dd HH:mm
    //4、其他年份：   yy-MM-dd
    // MARK: - 日期简化
    class func compareForNowWith(_ date: Date) -> String {
        
        // switch NSDate to String
        let nowDateString = LWDateManager.switchToStringFrom(Date(), dateFormat: "yyyy-MM-dd HH:mm:ss")!
        let targetDateString = LWDateManager.switchToStringFrom(date, dateFormat: "yyyy-MM-dd HH:mm:ss")!
        
        // Compare two date string
        if (nowDateString as NSString).substring(with: NSMakeRange(2, 2)) == (targetDateString as NSString).substring(with: NSMakeRange(2, 2)) {
            
            //在同一年内
            if (nowDateString as NSString).substring(with: NSMakeRange(5, 5)) == (targetDateString as NSString).substring(with: NSMakeRange(5, 5)) {
                
                //同一天内
                let distanceInterval = -date.timeIntervalSinceNow
                let oneHourInterval = 60*60 as TimeInterval
                if oneHourInterval < distanceInterval {
                    
                    //在同一个小时内
                    if distanceInterval/60 < 1 {
                        
                        //在一分钟内
                        return NSLocalizedString("不到1分钟前", comment: "")
                        
                    } else {
                        //在同一小时，但不在同一分钟内
                        return "\(distanceInterval/60)分钟前"
                    }
                    
                } else {
                    //在同一天，但不在同一个小时内
                    return NSLocalizedString("不到1分钟前", comment: "") + (targetDateString as NSString).substring(with: NSMakeRange(11, 5))
                }
            
            } else {
                //同一年内，但不在同一天
                return (targetDateString as NSString).substring(with: NSMakeRange(5, 11))
            }
            
        } else {
            //不在同一年内
            return (targetDateString as NSString).substring(with: NSMakeRange(2, 8))
        }
        
    }
    
    
    // MARK: - 计算两日期间相差的天数
    /**计算两日期间相差的天数*/
    class func distancesFrom(_ startingDate: Date, to resultDate: Date) -> Int {
        
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        
        //如果计算相差的小时数，可改为.CalendarUnitHour; day改为hour
        let comps = (gregorian as NSCalendar).components(NSCalendar.Unit.day, from: startingDate, to: resultDate, options:.wrapComponents)
        
        return comps.day!
    }
    
    
    // MARK: - 获取本地时区与世界零时区的时差
    /**获取本地时区与世界零时区的时差*/
    class func distanceIntervalForLocalTimeZon() -> Int {
        
        return TimeZone.autoupdatingCurrent.secondsFromGMT(for: Date())
    }
    
    
    
    // MARK: - 指定日期,所在的“day”单元，在“month”中有多少个（即指定日期所在月有多少天）
    /**
    指定日期,所在的“day”单元，在“month”中有多少个（即指定日期所在月有多少天）
    */
    class func numberOfDaysInMonthDepandOn(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: date).length
    }
    
    
    // MARK: - 指定日期，所在“month“单元里，该单元的第一个日期(即目标日期所在月的第一天)
    /**
    指定日期，所在“month“单元里，该单元的第一个日期(即目标日期所在月的第一天)
    */
    class func fetchFirstDayInMonthDepandOn(_ date: Date) -> Date? {
        var startDate: Date?
        var interval: TimeInterval = 0
        
        //(Calendar.current as NSCalendar).range(of: NSCalendar.Unit.month, start: startDate as! NSDate, interval: &interval, for: date)
        
        startDate = Date()
        
        Calendar.current.dateInterval(of: .month, start: &startDate!, interval: &interval, for: date)
        
        return startDate as Date?
    }
    
    
    // MARK: - 指定日期为当周的周几(1为周日)
    /**
    指定日期为当周的周几(1为周日)
    */
    class func dayIndexInWeeklyDepandOn(_ date: Date) -> Int {
        
        // 把目标日期转为yyy-MM-dd字符串
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // 取出对应的 年、月、日
        var dateArr: [String] = dateString.components(separatedBy: "-")
        
        // 设置NSDateComponts
        var dateComponts = DateComponents()
        /*
        (dateComponts as NSDateComponents).setValue(Int(NumberFormatter().number(from: dateArr[0])!), forComponent: NSCalendar.Unit.year)
        (dateComponts as NSDateComponents).setValue(Int(NumberFormatter().number(from: dateArr[1])!), forComponent: NSCalendar.Unit.month)
        (dateComponts as NSDateComponents).setValue(Int(NumberFormatter().number(from: dateArr[2])!), forComponent: NSCalendar.Unit.day)
        */
        
        dateComponts.setValue(Int(truncating: NumberFormatter().number(from: dateArr[0])!), for: .year)
        dateComponts.setValue(Int(truncating: NumberFormatter().number(from: dateArr[1])!), for: .month)
        dateComponts.setValue(Int(truncating: NumberFormatter().number(from: dateArr[2])!), for: .day)

        let targetDate = Calendar.current.date(from: dateComponts)!
        
        print("targetDate:\(targetDate)")
        
        
        let weekdayIndex = (Calendar.current as NSCalendar).component(NSCalendar.Unit.weekday, from: targetDate)
        
        return weekdayIndex
    }
    
    // MARK: - 指定日期为周几
    
    class func getDayNameBy(stringDate: String) -> String
    {
        let df  = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        let date = df.date(from: stringDate)!
        df.dateFormat = "EEEE"
        return df.string(from: date);
    }
 
 
    // MARK: - 指定日期所在月一共有多少个周
    /**
    指定日期所在月一共有多少个周
    */
    class func numberOfWeeksInMonthDepandOn(_ date: Date) -> Int {
        
        // 指定日期当月第一天为周几（周日为1）
        let firstDayIndex = dayIndexInWeeklyDepandOn(fetchFirstDayInMonthDepandOn(date)!)
        
        // 指定日期所在月有多少天
        let daysInMonth = numberOfDaysInMonthDepandOn(date)
        
        var weeks: Int = 0
        
        // 第一周有多少天
        let firstWeekSurplusDays: Int = 7 - firstDayIndex + 1
        
        weeks += (daysInMonth - firstWeekSurplusDays) / 7 + 1
        weeks += (daysInMonth - firstWeekSurplusDays) % 7 == 0 ? 0 : 1
        
        return weeks
    }
    
    
    
    // MARK: - 指定日期在所在月为第几周
    /**
    指定日期在所在月为第几周(第一周为0)
    */
    class func weekIndexInMonthDepandOn(_ date: Date) -> Int {
        
        // 指定日期当月第一天为周几（周日为1）
        let firstDayIndex = dayIndexInWeeklyDepandOn(fetchFirstDayInMonthDepandOn(date)!)
        // 第一周拥有的天数
        let daysInFirstWeek = 7 - firstDayIndex + 1
        
        // 指定日期为当月的几号
        let dateString = LWDateManager.switchToStringFrom(date, dateFormat: "yyyy-MM-dd")
        let dateComposes = dateString?.components(separatedBy: "-")
        let days = NumberFormatter().number(from: dateComposes!.last!)!.intValue
        
        var weeks: Int = 0
        if days <= daysInFirstWeek {
            weeks += 0
        } else {
            weeks += (days - daysInFirstWeek) / 7
            if (days - daysInFirstWeek) % 7 > 0 {
                weeks += 1
            }
        }
        
        return weeks
    }
    // MARK: - 获取日期所在当月的序号
    class func dayIndexInMonth(_ date: Date) -> Int {
        let calendar = Calendar.current
        let index = (calendar as NSCalendar).component(NSCalendar.Unit.day, from: date)
        return index
    }
    class func isInSameMonth(_ date1: Date, date2: Date) -> Bool{
        let calendar = Calendar.current
        let com1 = (calendar as NSCalendar).components( NSCalendar.Unit.init(rawValue: (NSCalendar.Unit.year.rawValue | NSCalendar.Unit.month.rawValue)), from: date1)
        let com2 = (calendar as NSCalendar).components( NSCalendar.Unit.init(rawValue: (NSCalendar.Unit.year.rawValue | NSCalendar.Unit.month.rawValue)), from: date2)
        
        if com1.year != com2.year {
            return false
        }
        if com1.month != com2.month {
            return false
        }
        return true
    }
    
    //返回当前天的字符串
    class func currentDayString()->String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let date = Date()
        return dateformatter.string(from: date)
    }
    
    //返回月份的英文简写
    class func monthString(_ Index: Int)->String{
        switch Index {
        case 1: return "Jan"
        case 2: return "Feb"
        case 3: return "Mar"
        case 4: return "Apr"
        case 5: return "May"
        case 6: return "Jun"
        case 7: return "Jul"
        case 8: return "Aug"
        case 9: return "Sep"
        case 10: return "Oct"
        case 11: return "Nov"
        case 12: return "Dec"
        default:return ""
        }
    }
    //返回当前数字的序数
   class func indexStringOfWeek(_ Index:Int)->String{
        if Index == 1 {
            return "1st"
        }else if Index == 2 {
            return "2nd"
        }else if Index == 3 {
            return "3rd"
        }else{
            return "\(Index)th"
        }
    }
    
    // MARK: 前一天的时间
    // nowDay 是传入的需要计算的日期
    class func getLastDay(nowDay: String,dValue:Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        // 先把传入的时间转为 date
        let date = dateFormatter.date(from: nowDay)
        let lastTime: TimeInterval = TimeInterval(dValue*24*60*60) // 往前减去一天的秒数，昨天
        //        let nextTime: TimeInterval = 24*60*60 // 这是后一天的时间，明天
        
        let lastDate = date?.addingTimeInterval(lastTime)
        let lastDay = dateFormatter.string(from: lastDate!)
        return lastDay
    }
    //获取当前月相差dValue的月份日期
    class func monthDvalue(nowDate: Date,dValue:Int)->Date{
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian);
        var adcomps = DateComponents.init();
        adcomps.year = 0;
        adcomps.month = dValue;
        adcomps.day = 0;
        let date = calendar?.date(byAdding: adcomps , to: nowDate, options: [])
        return date!
    }
    
    //输入日期 yyyy/mm/dd
    class func changeDateStringFormat(timeStr:String,beforeFormat:String,afterFormat:String)->String{
        let date = LWDateManager.switchToNSDateFrom(timeStr, dateFormat: beforeFormat)
        let time = LWDateManager.switchToStringFrom(date!, dateFormat: afterFormat)
        return time!
    }
    
    //输入日期 yyyy/mm/dd
    class func changeDateString(timeStr:String)->String{
        let date = LWDateManager.switchToNSDateFrom(timeStr, dateFormat: "yyyy-MM-dd")
        let time = LWDateManager.switchToStringFrom(date!, dateFormat: "yyyy/MM/dd")
        return time!
    }
    
    //格式：mm-dd xxx
    class func dateTimeToMonthDayTime(timeStr:String)->String{
        let date = LWDateManager.switchToNSDateFrom(timeStr, dateFormat: "yyyy-MM-dd")
        let time = LWDateManager.switchToStringFrom(date!, dateFormat: "MM-dd ")
        let week = LWDateManager.getWeekDay(dateTime:timeStr)
        return time! + week
    }
    /*
     timeStr:yyyy-MM-dd HH:mm:ss
     reutrn格式：HH:mm
     */
    class func dateTimeToHourTime(timeStr:String)->String{
        if timeStr.count <= 5 {
            return timeStr
        }
        let date = LWDateManager.switchToNSDateFrom(timeStr, dateFormat: "yyyy-MM-dd HH:mm")
        let time = LWDateManager.switchToStringFrom(date!, dateFormat: "HH:mm")
        return time!
    }
    
    //时间差
    class func timeInterval(endTime:String,startTime:String)->Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timeNumber = Int(dateFormatter.date(from: endTime)!.timeIntervalSince1970-dateFormatter.date(from: startTime)!.timeIntervalSince1970)
        return timeNumber / 60
    }
    //n秒后的日期
    class func timeIntervalToDateString(startTime:String,timeInterval:Int)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: startTime)?.addingTimeInterval(TimeInterval(timeInterval))
        return dateFormatter.string(from: date!)
    }
    
    
    class func getWeekDay(dateTime:String)->String{
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd"
        let date = dateFmt.date(from: dateTime)
        let weekday = NSCalendar.autoupdatingCurrent.component(.weekday, from: date!);
        let weekArray = ["星期日","星期一","星期二","星期三","星期四","星期五","星期六"];
        return weekArray[weekday-1];

    }
    
    
    
    
}






