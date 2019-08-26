//
//  ViewController.swift
//  RadioAndMutiSelect
//
//  Created by hope on 2019/6/17.
//  Copyright © 2019 Haitao. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    let itemList = ["单选多选","日历"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false;
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = itemList[indexPath.row] as String
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            gorRadioAndMutiSelectView()
        case 1:
            goCalendarView()
        default:
            break
        }
    }
    
    func gorRadioAndMutiSelectView() {
        let model = PatientInfo.init()
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "EditBedViewController") as! EditBedViewController
        vc.patientInfo = model
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func goCalendarView(){
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

