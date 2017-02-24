//
//  UserVC.swift
//  Chatter
//
//  Created by Cliff Choiniere on 2/22/17.
//  Copyright © 2017 Cliff Choiniere. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import AWSCognito

class UserVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var resultsTable: UITableView!
    
    var resultsUsers:Array = [] as Array
    var userImg = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        resultsTable.frame = CGRect(x: 0, y: 0, width: theWidth, height: theHeight-64)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let params = "user=\(CurrentUser)"
        
        let url = URL(string: rootURL + "users?" + params.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        let request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                print(error ?? "no errors")
            } else {
                if let urlContent = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        let resultInfo = jsonResult.value(forKey: "status") as! NSDictionary
                        let status = resultInfo.value(forKey: "status") as! String
                        
                        if status == "error" {
                            print("Error: \(jsonResult.value(forKey: "message") as! String)")
                        }
                        
                        if status == "success" {
                            DispatchQueue.main.async {
                                self.userImg = jsonResult.value(forKey: "userimg") as! String
                                self.resultsUsers = jsonResult.value(forKey: "users") as! Array<Any>
                                self.resultsTable.reloadData()
                            }
                        }
                    } catch {
                        print("error collecting user list from api")
                    }
                }
            }
        }
        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ResultsCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ResultsCell
        
        let aUser = resultsUsers[indexPath.row] as! NSDictionary
        
        cell.profileNameLabel.text = aUser.value(forKey: "username") as! String?
        
        
        let filename = aUser.value(forKey: "profile_url") as! String
        cell.usernameLabel.text =  filename
        
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: downloadingFileURL.path) {
            cell.profileImage.image = UIImage(contentsOfFile: downloadingFileURL.path)
        } else {
        
            let downloadRequest = AWSS3TransferManagerDownloadRequest()
            downloadRequest!.bucket = "3cschatapp"
            downloadRequest!.key = filename
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
                cell.profileImage.image = UIImage(contentsOfFile: downloadingFileURL.path)
                return nil
            })
        }
        return cell
    }
    
    
    @IBAction func logoutBtn_click(_ sender: Any) {
        
        CurrentUser = ""
        _ = self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ResultsCell
        
        otherUser = cell.profileNameLabel.text!
        myImg = userImg
        oppImg = cell.usernameLabel.text!
        
        self.performSegue(withIdentifier: "toConversationVC", sender: self)
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
