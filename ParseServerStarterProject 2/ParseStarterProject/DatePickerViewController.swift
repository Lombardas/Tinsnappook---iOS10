//
//  DatePickerViewController.swift
//  Tinsnappok
//
//  Created by Tasio on 22/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func saveDate(_ sender: UIButton) {
        //TODO: podríamos validar la fecha.
        let date = self.datePicker.date
        UsersFactory.sharedInstance.currentUser?.birthDate = date
        
       // self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    
    }
}
