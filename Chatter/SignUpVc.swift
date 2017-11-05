//
//  SignUpVc.swift
//  Chatter
//
//  Created by Cliff Choiniere on 2/17/17.
//  Copyright © 2017 Cliff Choiniere. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import AWSCognito


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
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    @IBAction func signupBtnClick(_ sender: Any) {
        
//        let rootURL = "https://rails-api-test-crcnum4.c9users.io/"
        
        let username = usernameTxt.text!
        let password = passwordTxt.text!
        let pntoken = UserDefaults.standard.object(forKey: "chatterNotificationToken") as! String
        
        let params = "user=\(username)&pass=\(password)&pntoken=\(pntoken)"
        let url = URL(string: rootURL + "register?" + params.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        
        let request = NSMutableURLRequest(url: url!)
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
                            DispatchQueue.main.async {
                                let filename = jsonResult.value(forKey: "imgurl") as! String
                                if let imageData = UIImageJPEGRepresentation(self.profileImg.image!, 0.5) {
                                    let fileURL = self.getDocumentsDirectory().appendingPathComponent(filename)
                                    print("fileURL \(fileURL)")
                                    try? imageData.write(to: fileURL)
                                    
                                    let uploadRequest = AWSS3TransferManagerUploadRequest()
                                    uploadRequest!.bucket = "3cschatapp"
                                    uploadRequest!.key = filename
                                    uploadRequest!.body = self.getDocumentsDirectory().appendingPathComponent(filename)
                                    print("body: \(uploadRequest!.body)")
                                    
                                    
                                    transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                                        if let error = task.error as? NSError {
                                            if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                                                switch code {
                                                case .cancelled, .paused:
                                                    break
                                                default:
                                                    print("Error uploading: \(uploadRequest!.key!) Error: \(error)")
                                                }
                                            } else {
                                                print("Error uploading: \(uploadRequest!.key!) Error: \(error)")
                                            }
                                            //run process to destroy the recently created useraccount.
                                            return nil
                                        }
                            
                                        print("Upload complete for: \(uploadRequest!.key)")
                                        CurrentUser = jsonResult.value(forKey: "id") as! String
                                        self.performSegue(withIdentifier: "signupToUserVC", sender: self)
                                        return nil
                                    })
                                }
                            }
                        }
                    } catch {
                        print("error creating user")
                    }
                }
            }
        }
        task.resume()
        
        
//        if let imageData = UIImageJPEGRepresentation(self.profileImg.image!, 0.8) {
//            let filename = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("profileimg\(username).jpg")
//            try? imageData.write(to: filename)
//            
//            let uploadRequest = AWSS3TransferManagerUploadRequest()
//            uploadRequest?.bucket = "3cschatapp"
//            uploadRequest?.key = "profileimg\(username).jpg"
//            uploadRequest?.body = filename
//            
//            transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
//                if let error = task.error as? NSError {
//                    if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
//                        switch code {
//                        case .cancelled, .paused:
//                            break
//                        default:
//                             print("Error uploading: \(uploadRequest!.key) Error: \(error)")
//                        }
//                    } else {
//                        print("Error uploading: \(uploadRequest!.key) Error: \(error)")
//                    }
//                    return nil
//                }
//                
//                let uploadOutput = task.result
//                print("Upload complete for: \(uploadRequest!.key)")
//                print("Upload Output contents: \(uploadOutput)")
//                return nil
//            })
//            
//        }
        
        
        
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
