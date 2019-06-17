//
//  ViewController.swift
//  RadioAndMutiSelect
//
//  Created by hope on 2019/6/17.
//  Copyright © 2019 Haitao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    @IBAction func pushView(_ sender: Any) {
        let model = PatientInfo.init()
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "EditBedViewController") as! EditBedViewController
        vc.patientInfo = model
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    

}

