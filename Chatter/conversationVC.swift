//
//  conversationVC.swift
//  Chatter
//
//  Created by Cliff Choiniere on 2/23/17.
//  Copyright © 2017 Cliff Choiniere. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import AWSCognito

var otherUser = ""
var myImg = ""
var oppImg = ""

class conversationVC: UIViewController, UIScrollViewDelegate, UITextViewDelegate {

    @IBOutlet weak var resultsScrollView: UIScrollView!
    @IBOutlet weak var frameMessageView: UIView!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var senBtn: UIButton!
    
    var scrollViewOriginalY:CGFloat = 0
    var frameMessageOriginalY:CGFloat = 0
    
    let mLbl = UILabel(frame: CGRect(x: 5, y: 8, width: 200, height: 20))
    
    var messageX: CGFloat = 37.0
    var messageY: CGFloat = 26.0
    var frameX: CGFloat = 32.0
    var frameY: CGFloat = 21.0
    var imageX: CGFloat = 3
    var imageY: CGFloat = 3
    
    var myImgFile:UIImage? = UIImage()
    var oppImgFile:UIImage? = UIImage()
    
    var messageArray:Array = [] as Array
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messageTextView.delegate = self

        // Do any additional setup after loading the view.
        
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        resultsScrollView.frame = CGRect(x: 0, y: 64, width: theWidth, height: theHeight-114)
        resultsScrollView.layer.zPosition = 20
        frameMessageView.frame = CGRect(x: 0, y: resultsScrollView.frame.maxY, width: theWidth, height: 50)
        lineLabel.frame = CGRect(x: 0, y: 0, width: theWidth, height: 1)
        messageTextView.frame = CGRect(x: 2, y: 1, width: self.frameMessageView.frame.size.width-52, height: 48)
        senBtn.center = CGPoint(x: frameMessageView.frame.size.width-30, y: 24)
        
        scrollViewOriginalY = self.resultsScrollView.frame.origin.y
        frameMessageOriginalY = self.frameMessageView.frame.origin.y
        
        self.title = otherUser
        
        mLbl.text = "Type a message..."
        mLbl.backgroundColor = UIColor.clear
        mLbl.textColor = UIColor.lightGray
        messageTextView.addSubview(mLbl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(conversationVC.keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(conversationVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapScrollViewGesture = UITapGestureRecognizer(target: self, action: #selector(conversationVC.didTapScrollView))
        tapScrollViewGesture.numberOfTapsRequired = 1
        resultsScrollView.addGestureRecognizer(tapScrollViewGesture)
    }
    
    func didTapScrollView() {
        self.view.endEditing(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !messageTextView.hasText {
            self.mLbl.isHidden = false
        } else {
            self.mLbl.isHidden = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if !messageTextView.hasText {
            self.mLbl.isHidden = false
        }
    }
    
    func keyboardWasShown(notification:NSNotification) {
        
        let dict:NSDictionary = notification.userInfo! as NSDictionary
        let s:NSValue = dict.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let rect:CGRect = s.cgRectValue
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            
            self.resultsScrollView.frame.origin.y = self.scrollViewOriginalY - rect.height
            self.frameMessageView.frame.origin.y = self.frameMessageOriginalY - rect.height
            
            let bottomOffset:CGPoint = CGPoint(x: 0, y: self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
            self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
            
        }, completion: {
            (finished:Bool) in
        })
        
    }
    
    func keyboardWillHide(notification:NSNotification) {
//        let dict:NSDictionary = notification.userInfo! as NSDictionary
//        let s:NSValue = dict.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
//        let rect:CGRect = s.cgRectValue
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            
            self.resultsScrollView.frame.origin.y = self.scrollViewOriginalY
            self.frameMessageView.frame.origin.y = self.frameMessageOriginalY
            
            let bottomOffset:CGPoint = CGPoint(x: 0, y: self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
            self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
            
        }, completion: {
            (finished:Bool) in
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //get the current user first
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        var downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(myImg)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: downloadingFileURL.path) {
            myImgFile = UIImage(contentsOfFile: downloadingFileURL.path)
        } else {
            
            downloadRequest!.bucket = "3cschatapp"
            downloadRequest!.key = myImg
            downloadRequest!.downloadingFileURL = downloadingFileURL
            
            
            transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                if let error = task.error as? NSError {
                    if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch code {
                        case .cancelled, .paused:
                            break
                        default:
                            print("Error downloading: \(downloadRequest?.key) Error: \(error)")
                        }
                    } else {
                        print("Error downloading: \(downloadRequest?.key) Error: \(error)")
                    }
                    return nil
                }
                //successful download
                self.myImgFile = UIImage(contentsOfFile: downloadingFileURL.path)
                return nil
            })

        }
        
        //get opp file now
        
        downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(oppImg)
        if fileManager.fileExists(atPath: downloadingFileURL.path) {
            oppImgFile = UIImage(contentsOfFile: downloadingFileURL.path)
        } else {
            
            downloadRequest!.bucket = "3cschatapp"
            downloadRequest!.key = oppImg
            downloadRequest!.downloadingFileURL = downloadingFileURL
            
            
            transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
                if let error = task.error as? NSError {
                    if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch code {
                        case .cancelled, .paused:
                            break
                        default:
                            print("Error downloading: \(downloadRequest?.key) Error: \(error)")
                        }
                    } else {
                        print("Error downloading: \(downloadRequest?.key) Error: \(error)")
                    }
                    return nil
                }
                //successful download
                self.oppImgFile = UIImage(contentsOfFile: downloadingFileURL.path)
                return nil
            })
            
        }
        
        refreshResults()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(conversationVC.updateMessages), userInfo: nil, repeats: true)
        
    }
    
    func updateMessages() {
        self.refreshResults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshResults() {
        
        let theWidth = view.frame.size.width
//        let theHeight = view.frame.size.height
        
        messageX = 37.0
        messageY = 26.0
        frameX = 32.0
        frameY = 21.0
        imageX = 3
        imageY = 3
        
        messageArray.removeAll(keepingCapacity: false)
        
        let params = "user=\(CurrentUser)&opp=\(otherUser)"
        
        let url = URL(string: rootURL + "/chat?" + params.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        let request = NSURLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, responce, error) in
            
            if error != nil {
                print(error ?? "no errors")
            } else {
                if let urlContent = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        let resultInfo = jsonResult.value(forKey: "status") as! NSDictionary
                        let status = resultInfo.value(forKey: "status") as! String
                        
                        if status == "error" {
                            print ("Error: \(jsonResult.value(forKey: "message") as! String)")
                        }
                        
                        if status == "success" {
                            DispatchQueue.main.async {
                                self.messageArray = jsonResult.value(forKey: "messages") as! Array<Any>
                                
                                for subView in self.resultsScrollView.subviews {
                                    subView.removeFromSuperview()
                                }
                                
                                for i in 0 ..< self.messageArray.count {
                                    let message = self.messageArray[i] as! NSDictionary
                                    
                                    if "\((message.value(forKey: "origin") as! NSNumber).intValue)" == CurrentUser {
                                        //message from logged in user.
                                        let messageLbl:UILabel = UILabel()
                                        messageLbl.frame = CGRect(x: 0, y: 0, width: self.resultsScrollView.frame.size.width-94, height: CGFloat.greatestFiniteMagnitude)
                                        messageLbl.backgroundColor = UIColor.blue
                                        messageLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
                                        messageLbl.textAlignment = NSTextAlignment.left
                                        messageLbl.numberOfLines = 0
                                        messageLbl.font = UIFont(name: "Helvetica Neuse", size: 17)
                                        messageLbl.textColor = UIColor.white
                                        messageLbl.text = "\(message.value(forKey: "message") as! String)"
                                        messageLbl.sizeToFit()
                                        messageLbl.layer.zPosition = 20
                                        messageLbl.frame.origin.x = (self.resultsScrollView.frame.size.width - self.messageX) - messageLbl.frame.size.width
                                        messageLbl.frame.origin.y = self.messageY
                                        self.resultsScrollView.addSubview(messageLbl)
                                        self.messageY += messageLbl.frame.size.height + 30
                                        
                                        let frameLbl:UILabel = UILabel()
                                        frameLbl.frame.size = CGSize(width: messageLbl.frame.size.width+10, height: messageLbl.frame.size.height+10)
                                        frameLbl.frame.origin.x = (self.resultsScrollView.frame.size.width - self.frameX) - frameLbl.frame.size.width
                                        frameLbl.frame.origin.y = self.frameY
                                        frameLbl.backgroundColor = UIColor.blue
                                        frameLbl.layer.masksToBounds = true
                                        frameLbl.layer.cornerRadius = 10
                                        self.resultsScrollView.addSubview(frameLbl)
                                        self.frameY += frameLbl.frame.size.height + 20
                                        
                                        let img:UIImageView = UIImageView()
                                        img.image = self.myImgFile
                                        img.frame.size = CGSize(width: 34, height: 34)
                                        img.frame.origin.x = (self.resultsScrollView.frame.size.width - self.imageX) - img.frame.size.width
                                        img.frame.origin.y = self.imageY
                                        img.layer.zPosition = 30
                                        img.layer.cornerRadius = img.frame.size.width/2
                                        img.clipsToBounds = true
                                        self.resultsScrollView.addSubview(img)
                                        self.imageY += frameLbl.frame.size.height + 20
                                        
                                        self.resultsScrollView.contentSize = CGSize(width: theWidth, height: self.messageY)
                                        
                                    } else {
                                        let messageLbl:UILabel = UILabel()
                                        messageLbl.frame = CGRect(x: 0, y: 0, width: self.resultsScrollView.frame.size.width-94, height: CGFloat.greatestFiniteMagnitude)
                                        messageLbl.backgroundColor = UIColor.lightGray
                                        messageLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
                                        messageLbl.textAlignment = NSTextAlignment.left
                                        messageLbl.numberOfLines = 0
                                        messageLbl.font = UIFont(name: "Helvetica Neuse", size: 17)
                                        messageLbl.textColor = UIColor.black
                                        messageLbl.text = "\(message.value(forKey: "message") as! String)"
                                        messageLbl.sizeToFit()
                                        messageLbl.layer.zPosition = 20
                                        messageLbl.frame.origin.x = self.messageX
                                        messageLbl.frame.origin.y = self.messageY
                                        self.resultsScrollView.addSubview(messageLbl)
                                        self.messageY += messageLbl.frame.size.height + 30
                                        
                                        let frameLbl:UILabel = UILabel()
                                        frameLbl.frame = CGRect(x: self.frameX, y: self.frameY, width: messageLbl.frame.size.width + 10, height: messageLbl.frame.size.height + 10)
                                        frameLbl.backgroundColor = UIColor.lightGray
                                        frameLbl.layer.masksToBounds = true
                                        frameLbl.layer.cornerRadius = 10
                                        self.resultsScrollView.addSubview(frameLbl)
                                        self.frameY += frameLbl.frame.size.height + 20
                                        
                                        let img:UIImageView = UIImageView()
                                        img.image = self.oppImgFile
                                        img.frame = CGRect(x: self.imageX, y: self.imageY, width:  34, height: 34)
                                        img.layer.zPosition = 30
                                        img.layer.cornerRadius = img.frame.size.width/2
                                        img.clipsToBounds = true
                                        self.resultsScrollView.addSubview(img)
                                        self.imageY += frameLbl.frame.size.height + 20
                                        
                                        self.resultsScrollView.contentSize = CGSize(width: theWidth, height: self.messageY)

                                    }
                                    
                                    let bottomOffset:CGPoint = CGPoint(x: 0, y: self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
                                    self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
                                }
                            }
                        }
                    } catch {
                        print("error getting messages")
                    }
                }
            }
        }
        task.resume()
    }
    
    @IBAction func sendBtn_click(_ sender: Any) {
        messageTextView.isEditable = false
        if messageTextView.text == "" {
            print("no text")
        } else {
            let params = "user=\(CurrentUser)&opp=\(otherUser)&message=\(messageTextView.text!)"
            
            let url = URL(string: rootURL + "send?" + params.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
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
                                    self.messageTextView.text = ""
                                    self.refreshResults()
                                }
                            }
                            
                            
                        } catch {
                            print("error sending message via api")
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.messageTextView.isEditable = true
                }
            }
            task.resume()
        }
        
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
