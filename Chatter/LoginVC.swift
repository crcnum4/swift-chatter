//
//  ViewController.swift
//  Chatter
//
//  Created by Cliff Choiniere on 2/16/17.
//  Copyright © 2017 Cliff Choiniere. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        titleLabel.center = CGPoint(x: theWidth/2, y: 130)
        usernameTxt.frame = CGRect(x: 16, y: theHeight/2 - 40, width: theWidth - 32, height: 30)
        passwordTxt.frame = CGRect(x: 16, y: theHeight/2, width: theWidth - 32, height: 30)
        loginBtn.center = CGPoint(x: theWidth/2, y: theHeight/2 + 60)
        signUpBtn.center = CGPoint(x: theWidth/2, y: theHeight - 30)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

