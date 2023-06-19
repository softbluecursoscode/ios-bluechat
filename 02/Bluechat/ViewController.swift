//
//  ViewController.swift
//  Bluechat
//
//  Created by Andre Milani.
//  Copyright © Softblue. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var formTextFieldNickname: UITextField!
    @IBOutlet weak var formTextFieldPassword: UITextField!
    @IBOutlet weak var formButtonCreate: UIButton!
    @IBOutlet weak var formButtonLogin: UIButton!
    @IBOutlet weak var formButtonLogout: UIButton!
    @IBOutlet weak var formTextViewChat: UITextView!
    @IBOutlet weak var formTextFieldMessage: UITextField!
    @IBOutlet weak var formButtonSend: UIButton!
    @IBOutlet weak var formButtonWho: UIButton!
    @IBOutlet weak var formTableViewUsers: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appDisconnect()
    }
    
    @IBAction func textFieldReturn(sender: AnyObject)
    {
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTouch()
    {
        formTextFieldNickname.resignFirstResponder()
        formTextFieldPassword.resignFirstResponder()
        formTextFieldMessage.resignFirstResponder()
    }
    
    func appDisconnect()
    {
        formTextFieldNickname.hidden = false
        formTextFieldPassword.hidden = false
        formButtonCreate.hidden = false
        formButtonLogin.hidden = false;
        
        formButtonLogout.hidden = true
        formTextViewChat.hidden = true
        formTextFieldMessage.hidden = true
        formButtonSend.hidden = true
        formButtonWho.hidden = true
        formTableViewUsers.hidden = true
        
        formTextFieldMessage.resignFirstResponder()
    }
    
    func appConnect()
    {
        formTextFieldNickname.hidden = true
        formTextFieldPassword.hidden = true
        formButtonCreate.hidden = true
        formButtonLogin.hidden = true;
        
        formButtonLogout.hidden = false
        formTextViewChat.hidden = false
        formTextFieldMessage.hidden = false
        formButtonSend.hidden = false
        formButtonWho.hidden = false
        formTableViewUsers.hidden = false
        
        formTextFieldNickname.resignFirstResponder()
        formTextFieldPassword.resignFirstResponder()
    }
    
    @IBAction func btLogout()
    {
        appDisconnect()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

