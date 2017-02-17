//
//  SignUpVc.swift
//  Chatter
//
//  Created by Cliff Choiniere on 2/17/17.
//  Copyright © 2017 Cliff Choiniere. All rights reserved.
//

import UIKit

class SignUpVc: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        profileImg.center = CGPoint(x: theWidth/2, y: 130)
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        addPhotoBtn.center = CGPoint(x: self.profileImg.frame.maxX + 50, y: 130)
        passwordTxt.frame = CGRect(x: 16, y: theHeight/2 + 40, width: theWidth - 32, height: 30)
        usernameTxt.frame = CGRect(x: 16, y: theHeight/2, width: theWidth - 32, height: 30)
        signupBtn.center = CGPoint(x: theWidth/2, y: theHeight/2 + 100)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = true
        self.present(image, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImg.image = image
        }
        
        picker.dismiss(animated: true, completion: nil);
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        if (UIScreen.main.bounds.height == 568) {
            if (textField == self.passwordTxt) {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                    
                    self.view.center = CGPoint(x: theWidth/2, y: theHeight/2 - 40)
                }, completion: {
                    (finished:Bool) in
                    //
                })
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        if (UIScreen.main.bounds.height == 568) {
            if (textField == self.passwordTxt) {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                    
                    self.view.center = CGPoint(x: theWidth/2, y: theHeight/2)
                }, completion: {
                    (finished:Bool) in
                    //
                })
            }
        }
    }
    
    @IBAction func signupBtnClick(_ sender: Any) {
        
        var user = 
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
