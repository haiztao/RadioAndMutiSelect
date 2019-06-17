//
//  Macros.swift
//  Sleep
//
//  Created by 赖灵伟 on 15/9/7.
//  Copyright (c) 2015年 深圳创世易明科技有限公司. All rights reserved.
//
//  宏定义

import Foundation
import UIKit

let kScreenHeight = UIScreen.main.bounds.size.height
let kScreenWidth = UIScreen.main.bounds.size.width
let kStatusBarHeight = UIApplication.shared.statusBarFrame.size.height
let phoneIdiom = UIDevice.current.userInterfaceIdiom

let isPad:Bool = (phoneIdiom == .pad)
let isIPHONEX :Bool = (kScreenHeight >= 812 && !isPad)//(kScreenWidth == 375 && kScreenHeight == 812)

let kModeClear = true


//最后一次读取的地址
let kLastAddress = "lastAddress"

//关闭重发检查
let kCloseCheckResend = "closeCheckResend"

/**顶部滚轮高度*/
let kHeightForTopPicker: CGFloat = 40

/**动画时间*/
let kAnimationTime: CGFloat = 2.0

/**检查数据库上传服务器的时间间隔*/
let kTimeToUpload: TimeInterval = TimeInterval(5)

/**睡眠日记加载的天数*/
let kSleepDataCount: Int = 30

/**验证码等待时间*/
let kVerifyTime = 60

/**满分睡眠时长为10小时*/
let kFullScoreHour: Float = 10.0
/**最大心跳数*/
let kMaxHeartCount: Int = 100
/**最大呼吸数*/
let kMaxBreatheCount: Int = 30

/**最小电量*/
let kMinBattle: Int = 10



// MARK: - NSNotification


/**丢包或等待响应时间*/
let timeInterval: TimeInterval = TimeInterval(0.100)
/**失败重复请求时间间隔*/
let intervalSecond: TimeInterval = TimeInterval(0.100)
/**每次获取数据间隔时间*/
let waitTime: TimeInterval = TimeInterval(0.008)
/**失败重复请求次数*/
let maxTimes: Int = 3


// MARK: - NSUserDefault
//选择fang楼层房间
let kIsSelectRoom = "kIsSelectRoom"
//选择门牌
let kIsSelectDoor = "kIsSelectDoor"
//选择床头牌
let kIsSelectBed = "kIsSelectBed"
/**是否已登录*/
let kIsLogined = "isLogined"
/**当前账号id*/
let kUserId = "kUserId"



//启动页类型缓存key
let kLaunchType = "launchType"

//设备电量缓存key
let kBattleValue = "battleValue"
//缓存设备电量时间key
let kBattleDate = "battleDate"

//同步数据标志key
let kSyncDataFlog = "syncDataFlog"

//上次拉取日报告的的userId
let kPullDiaryUserId = "pullDiaryUserId"

let kIntroductionCache = "introductionCache"
let kHelpCache = "helpCache"


//主色调
let kMainColor = "#6059a3"

let kKickOffLogin = "kKickOffLogin"



let kMainPath = NSHomeDirectory() + "/Documents/"

let kUsers = kMainPath + "users.archiver"

let kAlertSoundName = "wusheng.mp3"

let kAmarmMusicPlay = "kAmarmMusicPlay"
