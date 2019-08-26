//
//  LWCalendarView.swift
//  CustomDemo
//
//  Created by haitao on 19/8/26.
//  Copyright (c) 2019年 haitao. All rights reserved.
//
//  日历

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


/**当天圆圈状态颜色*/
enum LWCalendarDayState: Int {
    /**木有数据*/
    case none
    /**很好*/
    case veryGood
    /**好*/
    case good
    /**一般*/
    case ordinary
    /**差*/
    case bad
    /**异常*/
    case unusual
}


// MARK: - LWCalendarViewDelegate

@objc protocol LWCalendarViewDelegate {
    
@objc optional
    /**周的名称（default = [Sun, Tue...]）*/
    func calendarWeekTitles() -> [String]
    
    /**周的名称的颜色（default = UIColor.whileColor）*/
    func calendarWeekTitleColor() -> UIColor
    
    /**过去包括今天的日期的颜色（default = UIColor.whileColor）*/
    func calendarPastDaysColor() -> UIColor
    
    /**本月未到日期的颜色(default - UIColor.lightGrayColor)*/
    func calendarFutureDaysColor() -> UIColor
    
    /**是否显示前一个月最后几天（default = false）*/
    func calendarShowPreviousMonthDays() -> Bool
    
    /**是否显示后一个月的前几天(default = false)*/
    func calendarShowFollowMonthDays() -> Bool
    
    /**是否显示横向分割线（default = true）*/
    func calendarShowHorizontalSeparator() -> Bool
    
    /**设置分割线颜色（default = UIColor(red: 66.0 / 255.0, green: 69.0 / 255.0, blue: 98.0 / 255.5, alpha: 0.7)）*/
    func calendarSeparatorColor() -> UIColor
    
    /**日历头部视图（default = nil）*/
    func calendarHeaderView() -> UIView?
    
    /**日历尾部视图(default = nil)*/
    func calendarFootererView() -> UIView?
    
}

@IBDesignable
class LWCalendarView: UIView {

    weak var delegate: LWCalendarViewDelegate?
    /**周名称数组*/
    fileprivate var weekTitles: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    /**周名称颜色*/
    fileprivate var weekTitleColor: UIColor = UIColor(red: 174 / 255.0, green: 174 / 255.0, blue: 174 / 255.0, alpha: 1)
    /**过去的日期的颜色*/
    fileprivate var pastDaysColor: UIColor = UIColor(red: 50 / 255.0, green: 50 / 255.0, blue: 50 / 255.0, alpha: 1)
    /**未来的日期的颜色*/
//    private var futureDaysColor: UIColor = UIColor.darkGrayColor()
     fileprivate var futureDaysColor: UIColor = UIColor.gray
    /**是否显示上一个月的最后几天*/
    fileprivate var showPreviousMonthDays: Bool = false
    /**是否显示下一个月的前几天*/
    fileprivate var showFollowMonthDays: Bool = false
    /**是否显示横向分割线*/
    fileprivate var showHorizontalSeparator: Bool = true
    /**分割线的颜色*/
//    private var separatorColor: UIColor = UIColor(red: 66.0 / 255.0, green: 69.0 / 255.0, blue: 98.0 / 255.5, alpha: 0.7)
     fileprivate var separatorColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    /**头部视图*/
    fileprivate var calendarHeader: UIView?
    /**尾部视图*/
    fileprivate var calendarFooter: UIView?
    
    /**当前日期*/
    fileprivate var currentDate: Date = Date() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /**日历里每天圆圆的颜色（value = LWCalendarDayState）*/
    fileprivate var dayStatus: [LWCalendarDayState]? = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    
    /**日历图表离两边间距*/
    fileprivate let spaceForCalendar: CGFloat = 10.0
    /**日历内容的高度(视图高度 - headerView.height - footerView.height)*/
    fileprivate var heightForContent: CGFloat!
    // 横向单元格间隔 和 纵向单元格间隔
    fileprivate var spaceFoHorizontal: CGFloat!
    fileprivate var spaceForVertical: CGFloat!
    
    
    /**周名称字体大小*/
    fileprivate let titleFont: CGFloat = 12
    /**日期内容字体大小*/
    fileprivate let contentFont: CGFloat = 15
    
    /**
    点击有效日期回调
    targetDate: 点击的目标日期, "yyyy-MM-dd"
    state： 当天状态
    future： 是否是未来日期
    */
    fileprivate var clickDateHandler: ((_ targetDate: Date, _ state: LWCalendarDayState?, _ future: Bool) -> Void)?
    
    
    // MARK: - Life cycle
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        backgroundColor = UIColor.clear
        
    }
    
    
    override func draw(_ rect: CGRect) {
        UIGraphicsGetCurrentContext()!.move(to: CGPoint(x: 0, y: 0))
        UIGraphicsGetCurrentContext()!.addLine(to: CGPoint(x: 100, y: 100))
        calendarHeader = delegate?.calendarHeaderView()
        calendarFooter = delegate?.calendarFootererView()
        // 计算日历内容高度
        let num: CGFloat = -5
        
        heightForContent = frame.size.height - (calendarHeader?.frame.height ?? 0) - (calendarFooter?.frame.height ?? 0) + num
        // 横向单元格间隔 和 纵向单元格间隔
        spaceForVertical = (frame.width - 2 * spaceForCalendar) / 7
        spaceFoHorizontal = heightForContent / 7
        
        // 绘制横向分割线
        drawHorizontalSeparator()
     
        // 绘制周名称字体
        drawWeekTitles()
        
        // 绘制当月日期
        drawCurrentMonthDays()
        
    }
    
    
    /**绘制横向分割线*/
    fileprivate func drawHorizontalSeparator() {
        
        // 判断代理是否要求显示分割线
        showHorizontalSeparator = delegate?.calendarShowHorizontalSeparator() ?? showHorizontalSeparator
        if !showHorizontalSeparator {
            return
        }
        
        // 每行间距
        let heightForCell = heightForContent / 7
        
        // 绘制7条分割线
        separatorColor.setStroke()
        
        let separatorBezier = UIBezierPath()
        for index in 0..<7 {
            separatorBezier.move(to: CGPoint(x: spaceForCalendar, y: heightForCell * CGFloat(index)))
            separatorBezier.addLine(to: CGPoint(x: frame.size.width - spaceForCalendar, y: heightForCell * CGFloat(index)))
            separatorBezier.close()
        }
        separatorBezier.stroke()
    }
    
    
    /**绘制周名称字体*/
    fileprivate func drawWeekTitles() {
        
        for index in 0..<weekTitles.count {
            let weekTitleStr = NSString(string: weekTitles[index])
            
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            weekTitleStr.draw(
                in: CGRect(x: spaceForCalendar + CGFloat(index) * spaceForVertical, y: spaceFoHorizontal - 20, width: spaceForVertical, height: spaceFoHorizontal),
                withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: titleFont), NSAttributedString.Key.foregroundColor : delegate?.calendarWeekTitleColor() ?? weekTitleColor, NSAttributedString.Key.paragraphStyle : style])
        }
        
    }
    
    
    // 绘制当月日期
    fileprivate func drawCurrentMonthDays() {
        
        // 获取当月天数
        let numbersOfDays = LWDateManager.numberOfDaysInMonthDepandOn(currentDate)
        // 拿到当月第一天的日期
        let firstDayInMonth = LWDateManager.fetchFirstDayInMonthDepandOn(currentDate)!
        // 计算当月第一天为周几
        let firstDayIndexAtWeek = LWDateManager.dayIndexInWeeklyDepandOn(firstDayInMonth)
        
        // 文字高度
        let str = NSString(string: "31")
        let textHeight = str.size(withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: contentFont)]).height
        
        let today = Date()
        
        for index in 0..<numbersOfDays {
            // 判断当前日期是否已过去
            let targetDate = firstDayInMonth.addingTimeInterval(TimeInterval(index * 24 * 60 * 60))
            
            // 日期颜色
            let textColor = targetDate.compare(today) == ComparisonResult.orderedAscending ? delegate?.calendarPastDaysColor() ?? pastDaysColor : delegate?.calendarFutureDaysColor() ?? futureDaysColor
            
            // 日期字符串
            let dateStr = NSString(string: String(index + 1))
            
            // frame
            let x: CGFloat = CGFloat((firstDayIndexAtWeek - 1 + index) % 7) * spaceForVertical + spaceForCalendar
            let y: CGFloat = spaceFoHorizontal + CGFloat((firstDayIndexAtWeek - 1 + index) / 7) * spaceFoHorizontal + (spaceFoHorizontal - textHeight) / 2
            let dateFrame = CGRect(x: x, y: y, width: spaceForVertical, height: spaceFoHorizontal)
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            dateStr.draw(in: dateFrame, withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: contentFont), NSAttributedString.Key.foregroundColor : textColor, NSAttributedString.Key.paragraphStyle : style])
            
            //适配小屏
            var r = 5 as CGFloat
            let per = 4 as CGFloat
            if kScreenWidth == 320 {
                r = 3
            }
            //今天画圈
            if LWDateManager.isInSameMonth(currentDate, date2: Date()) && index == LWDateManager.dayIndexInMonth(Date()) - 1 {
                
                UIColor.ColorHex("#382F5A").setStroke()
                let circleBezierPath2 = UIBezierPath()
                let pointY = y + 5 + per
                let point = CGPoint(x: x + spaceForVertical/2, y: pointY)
                circleBezierPath2.addArc(
                    withCenter: point,
                    radius: spaceFoHorizontal / 2.0,
                    startAngle: 0,
                    endAngle: CGFloat(2 * Double.pi),
                    clockwise: true)
                
                circleBezierPath2.close()
                circleBezierPath2.stroke()
           
            }
            
            // 画彩色圆圆
            if index < dayStatus?.count {
                if let status = dayStatus?[index] {
                    let strokeColor = fetchColor(status)

                    if strokeColor != UIColor.clear {
                        strokeColor.setFill()
                        
                        let circleBezierPath = UIBezierPath()
                        
                        let cutValu2 = textHeight / 2 + 10 * kScreenWidth / 414
                        let yPoint = y + cutValu2 + per
                        let point = CGPoint(x: x + spaceForVertical/2, y: yPoint)
                        circleBezierPath.addArc(
                            withCenter: point,
                            radius: r,
                            startAngle: 0,
                            endAngle: CGFloat(2 * Double.pi),
                            clockwise: true)
                        
                        circleBezierPath.close()
                        circleBezierPath.fill()
                    }
                }
            }
            
        }
        
    }
    
    
    // MARK: - Target actions
    
    var tmpRow: Int?
    var tmpColumn: Int?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        // 拿到触摸点
        let touch = touches.first!
        let location = touch.location(in: self)
        if location.y < (calendarHeader?.frame.height ?? 0) + spaceFoHorizontal || location.y > frame.height - (calendarFooter?.frame.height ?? 0) {
            // 点中周名时，或尾部视图时返回
            return
        }
        if location.x < spaceForCalendar || location.x > frame.width - spaceForCalendar {
            // 点中两边空白处时返回
            return
        }
        
        
        // 计算触摸点在有效范围内的行、列
        let result = (location.y - (calendarHeader?.frame.height ?? 0) - spaceFoHorizontal) / spaceFoHorizontal
        tmpRow = Int(result)
        tmpColumn = Int((location.x - spaceForCalendar) / spaceForVertical)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        super.touchesEnded(touches, with: event)
        
        // 拿到触摸点
        let touch = touches.first!
        let location = touch.location(in: self)
        if location.y < (calendarHeader?.frame.height ?? 0) + spaceFoHorizontal || location.y > frame.height - (calendarFooter?.frame.height ?? 0) {
            // 点中周名时，或尾部视图时返回
            return
        }
        if location.x < spaceForCalendar || location.x > frame.width - spaceForCalendar {
            // 点中两边空白处时返回
            return
        }
        
        
        // 计算触摸点在有效范围内的行、列
        let result = (location.y - (calendarHeader?.frame.height ?? 0) - spaceFoHorizontal) / spaceFoHorizontal
        let row = Int(result)
        let column = Int((location.x - spaceForCalendar) / spaceForVertical)
        
        if row != tmpRow || column != tmpColumn {
            return
        }
        
        
        // 获取当月天数
        let numbersOfDays = LWDateManager.numberOfDaysInMonthDepandOn(currentDate)
        // 拿到当月第一天的日期
        let firstDayInMonth = LWDateManager.fetchFirstDayInMonthDepandOn(currentDate)!
        // 计算当月第一天为周几
        let firstDayIndexAtWeek = LWDateManager.dayIndexInWeeklyDepandOn(firstDayInMonth)
        
        
        
        //--------点击回调--------------
        
        // 拿到点击位置的有效日期
        var dayString: String!
        let day = row * 7 + (column + 1) - firstDayIndexAtWeek + 1
        if day <= 0 || day > numbersOfDays {
            return
        }
        dayString = day < 10 ? "0\(day)" : "\(day)"
        let currentDateString = LWDateManager.switchToStringFrom(currentDate, dateFormat: "yyyy-MM-dd")
        let currentDateComposes = currentDateString!.components(separatedBy: "-")
        let targetYearStr = currentDateComposes.first!
        let targetMonthStr = currentDateComposes[1]
        //let targetDate = LWDateManager.switchToNSDateFrom("\(targetYearStr)-\(targetMonthStr)-\(dayString)", dateFormat: "yyyy-MM-dd")!
        let targetDate = LWDateManager.switchToNSDateFrom("\(targetYearStr)-\(targetMonthStr)-\(dayString!)", dateFormat: "yyyy-MM-dd")!
        // 当前状态
        var state: LWCalendarDayState? = LWCalendarDayState.none
        if day <= dayStatus?.count {
            if let tmpState = dayStatus?[day - 1] {
                state = tmpState
            }
        }
        
        // 是否为未来日期
        let isFuture = targetDate.compare(Date()) == ComparisonResult.orderedAscending ? false : true
        
        // 点击回调
        clickDateHandler?(targetDate, state, isFuture)
        
        tmpRow = nil
        tmpColumn = nil
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        tmpRow = nil
        tmpColumn = nil
    }
    

    
    // MARK: - Helper methods
    
    /**根据当天日期的状态获取对应的颜色*/
    fileprivate func fetchColor(_ state: LWCalendarDayState) -> UIColor {
        let alp: CGFloat = 1
        switch state {
        case .none:
            return UIColor.clear
        case .good:
            return UIColor(red: 34 / 255.0, green: 231 / 255.0, blue: 214 / 255.0, alpha: alp)
        case .ordinary:
            return UIColor(red: 208.0 / 255, green: 155.0 / 255.0, blue: 85.0 / 255.0, alpha: alp)
        case .bad:
            return UIColor(red: 192.0 / 255.0, green: 117.0 / 255.0, blue: 120.0 / 255.0, alpha: alp)
        default:
            return UIColor(red: 34 / 255.0, green: 231 / 255.0, blue: 214 / 255.0, alpha: alp)
        }
       
    }
    
    
    // MARK: - Public
    
    /**刷新当前日历*/
    func reloadCalendarData(_ date: Date, dayStatus: [LWCalendarDayState]?) {
        self.dayStatus = dayStatus
        currentDate = date
        self.setNeedsDisplay()
    }
    
    /**
    点击有效日期回调
    targetDate: 点击的目标日期
    state： 当天状态
    future： 是否是未来日期
    */
    func didSelectedCalendarCellHandler(_ handler: ((_ targetDate: Date, _ state: LWCalendarDayState?, _ future: Bool) -> Void)?) {
        clickDateHandler = handler
    }
    
    
}





