//
//  ChatViewController.swift
//  LIGChatApp
//
//  Created by Vivian on 7/1/18.
//  Copyright © 2018 Randolph. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var txtMessage: UITextField!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var btnLogout: UIButton!
    @IBOutlet var viewBottom: UIView!
    
    // Declarations
    private lazy var dbRef: DatabaseReference = Database.database().reference()
    private var refHandler: DatabaseHandle?
    var username: String!
    var messages = [DataSnapshot]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dbRef.child("messages").observe(.childAdded) { (snapshot) in
            print("snapshot: \(snapshot)")
            self.messages.append(snapshot)
            self.tableView.reloadData()
            self.updateTableContentInset()
            
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 79
        btnSend.layer.cornerRadius = 5
        self.view.bindToKeyboard()
        
        self.navigationItem.hidesBackButton = true
        self.btnLogout.layer.cornerRadius = 5
//        self.tableView.keyboardDismissMode = .interactive
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapEvent))
        self.view.addGestureRecognizer(tap)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.unbindToKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tapEvent(){
        txtMessage.resignFirstResponder()
    }
    
    @IBAction func sendMessage(sender: UIButton){
        if let message = txtMessage.text, message.count > 0 {
            dbRef.child("messages").childByAutoId().setValue(["sender" : username, "message": message])
            txtMessage.text = ""
        }
    }
    
    @IBAction func logout(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : MessageCell!
        let messageSnap = messages[indexPath.row].value as! NSDictionary
        let sender = messageSnap["sender"] as? String ?? ""
        if sender == username{
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! MessageCell
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MessageCell
        }
        
        cell.lblMessage.text = messageSnap["message"] as? String ?? " "
        cell.lblMessage.sizeToFit()
        cell.lblMessage.layer.cornerRadius = 6.0
        cell.lblMessage.clipsToBounds = true
        
        cell.lblSender.text = sender == username ? "You" : sender
        
        return cell
    }
    
    func updateTableContentInset() {
        let numRows = tableView(self.tableView, numberOfRowsInSection: 0)
        var contentInsetTop = self.tableView.bounds.size.height
        for i in 0..<numRows {
            let rowRect = self.tableView.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
            }
        }
        self.tableView.contentInset = UIEdgeInsetsMake(contentInsetTop, 0, 0, 0)
    }

    
}

extension UIView{
    func bindToKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(UIView.keyboardWillChange(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func unbindToKeyboard(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc
    func keyboardWillChange(notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y+=deltaY
        }) { (done) in
            
        }
    }
}
