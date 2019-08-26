//
//  CalendarViewController.swift
//  RadioAndMutiSelect
//
//  Created by hope on 2019/8/26.
//  Copyright © 2019 Haitao. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calenderView: LWCalendarView!
    @objc dynamic var currentDate:Date! = Date()
    var obsver:NSKeyValueObservation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "日历"
        // 月报告日历添加点击动作
        calenderView.didSelectedCalendarCellHandler { [weak self] (targetDate, state, future) -> Void in
            self?.clickCalendarDateAction(targetDate as Date, state: state, future: future)
        }
        //添加KVO
        obsver = self.observe(\.currentDate, options: [.old,.new], changeHandler: { [weak self](vc, change) in
            if let newValue = change.newValue{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM"
                let dateStr = dateFormatter.string(from: newValue!)
                self?.dateLabel.text = dateStr
                self?.calenderView.reloadCalendarData(self!.currentDate, dayStatus: [])
            }
        })
        currentDate = Date()
//        self.applyCurvedShadow(view: calenderView)
    }
    //加阴影
    func applyCurvedShadow(view:UIView) {
        // 设置阴影
        view.layer.cornerRadius = 4;
        view.layer.masksToBounds = false;
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        
    }
    
    @IBAction func goBeforeDate(_ sender: Any) {
        currentDate = LWDateManager.monthDvalue(nowDate: currentDate, dValue: -1)
        
    }
    
    @IBAction func goNextDate(_ sender: Any) {
        currentDate = LWDateManager.monthDvalue(nowDate: currentDate, dValue: 1)
    }
    
    /**
     点击日历某天时触发动作
     
     :param: targetDate 点击日期
     :param: state      当天状态
     :param: future     是否是未来日期
     */
    func clickCalendarDateAction(_ targetDate: Date, state: LWCalendarDayState?, future: Bool) {
        
        let dateStr = LWDateManager.switchToStringFrom(targetDate, dateFormat: "yyyy-MM-dd")!
        if state == LWCalendarDayState.none {
            
           print("当天没有数据!")
            return
        }
        
        if !future {
            print(dateStr)
        }
    }
    
    /**计算并整理月报告每日随眠质量*/
    fileprivate func fetchMonthDayStatusAry(_ scores: [String : Int]) -> [LWCalendarDayState] {
        
        // 把scores字典转为【日 ：评分】
        var dayStatusDic: [Int : LWCalendarDayState] = [Int : LWCalendarDayState]()
        for (key, value) in scores {
            if let tmpKey = Int((key as NSString).substring(with: NSMakeRange(8, 2))) {
                var tmpValue: LWCalendarDayState = LWCalendarDayState.none
                if value >= 80 {
                    tmpValue = LWCalendarDayState.good
                } else if value < 80 && value >= 60 {
                    tmpValue = LWCalendarDayState.ordinary
                }else if value < 60 {
                    tmpValue = LWCalendarDayState.bad
                } else {
                    tmpValue = LWCalendarDayState.none
                }
                dayStatusDic.updateValue(tmpValue, forKey: tmpKey)
            }
        }
        
        // 计算目标月份有多少天
        let monthDayCount = LWDateManager.numberOfDaysInMonthDepandOn(currentDate)
        
        // 把拿到的字典值补全并转换为可用的数组
        var dayStatus: [LWCalendarDayState] = [LWCalendarDayState]()
        for i in 1...monthDayCount {
            let status = dayStatusDic[i] ?? LWCalendarDayState.none
            dayStatus.append(status)
        }
        
        return dayStatus
    }
    override func viewDidDisappear(_ animated: Bool) {
        deinitTheObserve()
    }
    
    func deinitTheObserve(){
        print("销毁观察者")
        obsver?.invalidate()
        obsver = nil
    }

    
}
