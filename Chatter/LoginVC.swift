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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }

    @IBAction func loginBtn_click(_ sender: Any) {
        let username = usernameTxt.text
        let pass = passwordTxt.text
        let params = "user=\(username!)&pass=\(pass!)"
        let url = URL(string: rootURL + "login?" + params.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, responce, error) in
            if error != nil {
                print(error ?? "no errors")
            } else {
                if let urlContent = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        let status = jsonResult.value(forKey: "status") as! String
                        
                        if status == "error" {
                            print("Error: \(jsonResult.value(forKey: "message") as! String)")
                        }
                        if status == "success" {
                            //process successful login.
                            DispatchQueue.main.async {
                                let idnum = jsonResult.value(forKey: "id") as! NSNumber
                                CurrentUser = "\(idnum.intValue)"
                                self.passwordTxt.text = ""
                                self.performSegue(withIdentifier: "loginToUserVC", sender: self)
                            }
                        }
                    } catch {
                      print("error logging in user")
                    }
                    
                }
            }
        }
        task.resume()
        
    }

}

