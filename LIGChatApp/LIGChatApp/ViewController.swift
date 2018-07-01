//
//  ViewController.swift
//  LIGChatApp
//
//  Created by Vivian on 6/30/18.
//  Copyright © 2018 Randolph. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController {

    // Outlets
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var viewLoader: UIView!
    @IBOutlet var loader: UIActivityIndicatorView!
    
    // Declarations
    private lazy var dbRef: DatabaseReference = Database.database().reference()
    private var refHandler: DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnLogin.layer.cornerRadius = 5
        txtUsername.layer.cornerRadius = 5
        txtPassword.layer.cornerRadius = 5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapEvent))
        self.view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func tapEvent(){
        txtUsername.resignFirstResponder()
        txtPassword.resignFirstResponder()
    }
    
    @IBAction func onClickLogin(){
        if let username = txtUsername.text, username.count > 0, let password = txtPassword.text, password.count > 0 {
            viewLoader.isHidden = false
            loader.startAnimating()
            
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if let err = error {
                    print("error: \(err.localizedDescription)")
                    self.showDialog(title: "Login Failed", message: "Something's went wrong. Please try again.")
                    return
                }
                self.dbRef.child("users").queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    self.viewLoader.isHidden = true
                    
                    if snapshot.childrenCount > 0 {
                        for child in snapshot.children {
                            if let snap = child as? DataSnapshot {
                                let user = snap.value as? NSDictionary
                                let passwordValue = user!["password"] as? String ?? ""
                                if password == passwordValue {
                                    self.performSegue(withIdentifier: "LoginToChat", sender: nil)
                                }else{
                                    self.showDialog(title: "Login Failed", message: "Password is incorrect")
                                }
                            }
                        }
                    }else{
                        self.dbRef.child("users").childByAutoId().setValue(["username": username, "password": password])
                        self.performSegue(withIdentifier: "LoginToChat", sender: nil)
                    }
                })
            })
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToChat" {
            let vc = segue.destination as! ChatViewController
            vc.username = txtUsername.text
            
            txtUsername.text = ""
            txtPassword.text = ""
        }
    }

    func showDialog(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

