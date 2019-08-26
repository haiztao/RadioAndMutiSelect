//
//  EditBedViewController.swift
//  NursingSystem
//
//  Created by hope on 2019/5/31.
//  Copyright © 2019 Haitao. All rights reserved.
//

import UIKit

class EditBedViewController: UIViewController,UITextFieldDelegate,CBGroupAndStreamViewDelegate {

    @IBOutlet weak var viewWidthCons: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var zhurenTextF: UITextField!
    @IBOutlet weak var zhuzhiTextF: UITextField!
    @IBOutlet weak var yishiTextF: UITextField!
    @IBOutlet weak var huzhangTextF: UITextField!
    @IBOutlet weak var zuzhangTextF: UITextField!
    @IBOutlet weak var hushiTextF: UITextField!
    
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var sureBtn: UIButton!
    
    @IBOutlet weak var nurseDegreeView: UIView!
    @IBOutlet weak var foodRequestView: UIView!
    @IBOutlet weak var highWarmingView: UIView!
    
    @IBOutlet weak var nurseLevelTF: UITextField!
    @IBOutlet weak var warmOtherTF: UITextField!
    @IBOutlet weak var foodRequestTF: UITextField!
    
    var patientInfo:PatientInfo!
    
    var highWarmingDouble:CBGroupAndStreamView!
    var nurseDegree:CBGroupAndStreamView!
    var foodRequestSigle:CBGroupAndStreamView!
    
    var nurseArr = ["特级护理","一级护理","二级护理","三级护理"]
    var foodArr = ["普食","软食","半流食","流食","禁食"]
    var warmArr = ["跌倒","压疮","坠床","药物过敏","认知障碍","意外走失","禁止非医护人员进行护理操作"]
    var nurseLevel:String! = ""
    var foodLevel:String! = ""
    var warmLevel:String! = ""
    
    @IBOutlet weak var nurseLenLabel: UILabel!
    @IBOutlet weak var foodLenLabel: UILabel!
    @IBOutlet weak var warmLenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWidthCons.constant = kScreenWidth
        self.title = "单选多选"
        nurseDegreeSigle()
        foodRequest()
        highWarming()
        
        zhurenTextF.text = (patientInfo.archiater ?? "")
        zhuzhiTextF.text = (patientInfo.visitingStaff ?? "")
        yishiTextF.text = (patientInfo.competentPhysician ?? "")
        huzhangTextF.text = (patientInfo.headNurse ?? "")
        zuzhangTextF.text = (patientInfo.groupNurse ?? "")
        hushiTextF.text = (patientInfo.bedNurse ?? "")
        
        nurseLevelTF.delegate = self
        warmOtherTF.delegate = self
        foodRequestTF.delegate = self
        
        
        //食物
        if patientInfo.askForFoodType != "" && patientInfo.askForFoodType != nil{
            let index = Int(patientInfo.askForFoodType!)
            //设置默认选中
            self.reloadFoodRequestLevel(index: index!, haveChoice: true)
        }
        foodRequestTF.text = patientInfo.askForFoodOther ?? ""
        
        //高危
        var cautionArr = Array<Any>()
        if patientInfo.cautionType != "" && patientInfo.cautionType != nil{
            let cautionType = patientInfo.cautionType! as String
            if cautionType.contains("-") {
                let arr = patientInfo.cautionType!.components(separatedBy: "-")
                for value in arr {
                    cautionArr.append(Int(value)!)
                }
            }else{
                if cautionType != ""{
                     cautionArr.append(Int(cautionType)!)
                }
            }
        }
        
        highWarmingDouble.defaultSelIndexArr = [cautionArr]
        highWarmingDouble.reload()
        warmOtherTF.text = patientInfo.cautionOther ?? ""
        
        //护理
        if let nurseLv = patientInfo.levelName {
            var flag = false
            for (index,value) in nurseArr.enumerated() {
                if nurseLv == value {
                    self.reloadNurseLevel(index: index, haveChoice: true)
                    flag = true
                }
            }
            if !flag {
                nurseLevelTF.text = nurseLv
            }
        }
        nurseLevelTF.addTarget(self, action: #selector(nurseLevelChange(_:)), for: .editingChanged)
        foodRequestTF.addTarget(self, action: #selector(nurseLevelChange(_:)), for: .editingChanged)
        warmOtherTF.addTarget(self, action: #selector(nurseLevelChange(_:)), for: .editingChanged)
        textFiledLenCheck()
    }
    
    func textFiledLenCheck(){
        warmLenLabel.text = "\((warmOtherTF.text! as NSString).length)/20"
        foodLenLabel.text = "\((foodRequestTF.text! as NSString).length)/10"
        nurseLenLabel.text = "\((nurseLevelTF.text! as NSString).length)/10"
    }
    
    var warmOther:String!
    var foodRequestOther:String!
    var nurseLevelStr:String!
    
    
    @objc func nurseLevelChange(_ textField: UITextField){
        //非markedText才继续往下处理
        if (textField.markedTextRange != nil) {
            return
        }
        
        let text = textField.text! as NSString
        let len = text.length
        if textField == nurseLevelTF {
            nurseDegree.isDefaultChoice = false
            nurseDegree.reload()
        }
        if textField == warmOtherTF {
            if len <= 20 {
                warmOther = textField.text
            }else{
                textField.text = warmOther
            }
        }else if textField == foodRequestTF {
            if len <= 10 {
                foodRequestOther = textField.text
            }else{
                textField.text = foodRequestOther
            }
        }else if textField == nurseLevelTF{
            
            if len <= 10 {
                nurseLevelStr = textField.text
            }else{
                textField.text = nurseLevelStr
            }
        }
        textFiledLenCheck()
    }
    
    func nurseDegreeSigle(){
        let contentArr = [nurseArr]
        nurseDegree = CBGroupAndStreamView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth-20, height: nurseDegreeView.frame.size.height))
        nurseDegree.groundTitle = "nurseDegree"
//        nurseDegree.widthRadio = 142
        nurseDegree.titleTextFont = .systemFont(ofSize: 16)
        nurseDegree.delegate = self
        //分别设置每个组的单选与多选
        nurseDegree.defaultGroupSingleArr = [1]
        nurseDegree.setDataSource(contetnArr: contentArr, titleArr: ["nurseDegree"])
        self.nurseDegreeView.addSubview(nurseDegree)
        reloadNurseLevel(index: 0, haveChoice: false)
    }
    func reloadNurseLevel(index:Int,haveChoice:Bool){
        nurseDegree.isDefaultChoice = haveChoice
        nurseDegree.defaultSelIndexArr = [index]
        nurseDegree.reload()
    }
    
    
    func foodRequest(){
        let contentArr = [foodArr]
        foodRequestSigle = CBGroupAndStreamView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth-20, height: foodRequestView.frame.size.height))
        foodRequestSigle.groundTitle = "foodRequestSigle"
//        foodRequestSigle.widthRadio = 64*2
        foodRequestSigle.titleTextFont = .systemFont(ofSize: 16)
        //分别设置每个组的单选与多选
        foodRequestSigle.defaultGroupSingleArr = [1]
        foodRequestSigle.delegate = self
        foodRequestSigle.setDataSource(contetnArr: contentArr, titleArr: ["foodRequestSigle"])
        self.foodRequestView.addSubview(foodRequestSigle)

        //设置默认选中
        self.reloadFoodRequestLevel(index: 0, haveChoice: false)
    }
    func reloadFoodRequestLevel(index:Int,haveChoice:Bool){
        foodRequestSigle.isDefaultChoice = haveChoice
        foodRequestSigle.defaultSelIndexArr = [index]
        foodRequestSigle.reload()
    }
    
    
    func highWarming(){
        let contentArr = [warmArr]
        highWarmingDouble = CBGroupAndStreamView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth-20, height: highWarmingView.frame.size.height))
        highWarmingDouble.groundTitle = "highWarmingDouble"
//        highWarmingDouble.widthRadio = 120
        highWarmingDouble.titleTextFont = .systemFont(ofSize: 16)
        highWarmingDouble.delegate = self
        highWarmingDouble.isSingle = false
        //分别设置每个组的单选与多选
        highWarmingDouble.defaultGroupSingleArr = [0]
        highWarmingDouble.setDataSource(contetnArr: contentArr, titleArr: ["highWarmingDouble"])
        self.highWarmingView.addSubview(highWarmingDouble)
        
        highWarmingDouble.defaultSelIndexArr = [[]]
        highWarmingDouble.reload()
    }
    
    @IBAction func cancleAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func comfirmAction(_ sender: Any) {
        nurseDegree.comfirm()
        foodRequestSigle.comfirm()
        highWarmingDouble.comfirm()
        
    }
    
    func updateUserInfo(){
        let nurseLv = self.nurseLevel != "" ? self.nurseLevel : nurseLevelTF.text
        print("nurseLv",nurseLv)
        
    }
    

    func currentSelValueWithDelegate(valueStr: String, index: Int, groupId: Int, groundTitle:String) {
//        print("\(valueStr) index = \(index), groupid = \(groupId)")
        if groundTitle == "nurseDegree" {
            nurseLevelTF.text = ""
        }
    }
    
    func confimrReturnAllSelValueWithDelegate(selArr: Array<Any>, groupArr: Array<Any>, groundTitle: String) {
        print(selArr,groundTitle)
   
        if groundTitle == "highWarmingDouble" {
            self.warmLevel = ""
            var array = Array<Any>()
            if selArr[0] is Array<Any> {
                array = selArr[0] as! Array
            }else{
                array = selArr
            }
            for (index,warm) in array.enumerated() {
                let arr = (warm as! NSString).components(separatedBy: "/")
                if index > 0 {
                    self.warmLevel.append("-")
                }
                self.warmLevel.append(arr[0])
            }
            //上传到服务器
            self.updateUserInfo()
        }else {
            var array = Array<Any>()
            if selArr[0] is Array<Any> {
                array = selArr[0] as! Array
            }else{
                array = selArr
            }
            if array.count == 0 {
                self.nurseLevel = ""
                self.foodLevel = ""
            }else{
                let value = array[0] as! String
                if groundTitle == "nurseDegree" {
                    if value.contains("/") {
                        let arr = value.components(separatedBy: "/")
                        self.nurseLevel = arr[1]
                    }else{
                        self.nurseLevel = ""
                    }
                }else if groundTitle == "foodRequestSigle" {
                    if value.contains("/") {
                        let arr = value.components(separatedBy: "/")
                        self.foodLevel = arr[0]
                    }else{
                        self.foodLevel = ""
                    }
                }
            }
            
        }
    }

}
