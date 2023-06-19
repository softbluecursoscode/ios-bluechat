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
    
    var userNickname: String = ""
    var userPassword: String = ""
    
    var wsUrlCreateProfile: String = "http://code.softblue.com.br/bluechat/createProfile.php"
    
    var jsonDataCreateProfile: NSDictionary! = nil
    

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
    
    @IBAction func btCreateProfile()
    {
        userNickname = formTextFieldNickname.text!
        userPassword = formTextFieldPassword.text!
        
        wsCallCreateProfile(userNickname, password: userPassword)
    }
    
    func wsCallCreateProfile(nickname: String, password: String)
    {
        let nicknameUTF8: String = nickname.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let passwordUTF8: String = password.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let postParameters: String = "wsNickname=\(nicknameUTF8)&wsPassword=\(passwordUTF8)"
        
        let url: NSURL = NSURL(string: wsUrlCreateProfile)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postParameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let myTask = session.downloadTaskWithRequest(request, completionHandler:
            {
                (location, response, error) -> Void in
                
                if(error == nil)
                {
                    let objectData = NSData(contentsOfURL: location!)
                    
                    do
                    {
                        self.jsonDataCreateProfile = try NSJSONSerialization.JSONObjectWithData(objectData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    }
                    catch
                    {
                        print("JSON Error")
                    }
                }
                else
                {
                    print("Failed: \(error)")
                }
            }
        )
        
        myTask?.resume()

        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("wsReturnCreateProfile"), userInfo: nil, repeats: false)
    }
    
    func wsReturnCreateProfile()
    {
        if(jsonDataCreateProfile == nil)
        {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("wsReturnCreateProfile"), userInfo: nil, repeats: false)
            
            return
        }
        
        let wsResult: Int = jsonDataCreateProfile["wsResult"] as! Int
        
        if(wsResult == 1)
        {
            showMessage("Sucesso", messageToShow: "Usuário criado com sucesso!")
        }
        else
        {
            showMessage("Falha", messageToShow: jsonDataCreateProfile["wsDescription"] as! String)
        }
    }
    
    func showMessage(titleToShow: String, messageToShow: String)
    {
        let myActionSheet: UIAlertController = UIAlertController(title: titleToShow, message: messageToShow, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let myAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        myActionSheet.addAction(myAction)
        
        self.presentViewController(myActionSheet, animated: true, completion: nil)
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

