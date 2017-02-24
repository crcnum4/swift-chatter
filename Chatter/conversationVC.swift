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
var time = ""

class conversationVC: UIViewController, UIScrollViewDelegate {

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
    
    var messageArray:Array = [] as Array
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        refreshResults()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshResults() {
        
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        messageX = 37.0
        messageY = 26.0
        frameX = 32.0
        frameY = 21.0
        
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
                                        
                                        self.resultsScrollView.contentSize = CGSize(width: theWidth, height: self.messageY)
                                        
                                    } else {
                                        let messageLbl:UILabel = UILabel()
                                        messageLbl.frame = CGRect(x: 0, y: 0, width: self.resultsScrollView.frame.size.width-94, height: CGFloat.greatestFiniteMagnitude)
                                        messageLbl.backgroundColor = UIColor.green
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
                                        frameLbl.backgroundColor = UIColor.green
                                        frameLbl.layer.masksToBounds = true
                                        frameLbl.layer.cornerRadius = 10
                                        self.resultsScrollView.addSubview(frameLbl)
                                        self.frameY += frameLbl.frame.size.height + 20
                                        
                                        self.resultsScrollView.contentSize = CGSize(width: theWidth, height: self.messageY)

                                    }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
