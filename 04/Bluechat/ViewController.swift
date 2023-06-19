//
//  ViewController.swift
//  Bluechat
//
//  Created by Andre Milani.
//  Copyright © Softblue. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
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
    var lastIdMessage: String = "0"
    var isConnected: Bool = false
    var toId: String = ""
    
    let wsUrlCreateProfile: String = "http://code.softblue.com.br/bluechat/createProfile.php"
    let wsUrlGetMessages: String = "http://code.softblue.com.br/bluechat/getMessages.php"
    
    var jsonDataCreateProfile: NSDictionary! = nil
    var jsonDataGetMessages: NSDictionary! = nil
    
    var userListNicknames: NSMutableArray = NSMutableArray()
    var userListIds: NSMutableArray = NSMutableArray()
    var userTableViewListNicknames: NSMutableArray = NSMutableArray()
    var userTableViewListIds: NSMutableArray = NSMutableArray()
    

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
        isConnected = false
        
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
        isConnected = true
        
        formTextFieldNickname.hidden = true
        formTextFieldPassword.hidden = true
        formButtonCreate.hidden = true
        formButtonLogin.hidden = true;
        
        formButtonLogout.hidden = false
        formTextViewChat.hidden = false
        formTextFieldMessage.hidden = false
        formButtonSend.hidden = false
        formButtonWho.hidden = false
        
        formTextFieldNickname.resignFirstResponder()
        formTextFieldPassword.resignFirstResponder()
    }
    
    @IBAction func btCreateProfile()
    {
        userNickname = formTextFieldNickname.text!
        userPassword = formTextFieldPassword.text!
        
        wsCallCreateProfile(userNickname, password: userPassword)
    }
    
    @IBAction func btGetMessages()
    {
        userNickname = formTextFieldNickname.text!
        userPassword = formTextFieldPassword.text!
        
        wsCallGetMessages(userNickname, password: userPassword, lastIdMessage: lastIdMessage)
    }
    
    func wsCallGetMessages(nickname: String, password: String, lastIdMessage: String)
    {
        let nicknameUTF8: String = nickname.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let passwordUTF8: String = password.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var postParameters: String = "wsNickname=\(nicknameUTF8)&wsPassword=\(passwordUTF8)"
        
        if(!lastIdMessage.isEmpty)
        {
            postParameters = "\(postParameters)&wsLastIdMessage=\(lastIdMessage)"
        }
        
        let url: NSURL = NSURL(string: wsUrlGetMessages)!
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
                        self.jsonDataGetMessages = try NSJSONSerialization.JSONObjectWithData(objectData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
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
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("wsReturnGetMessages"), userInfo: nil, repeats: false)
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
    
    func wsReturnGetMessages()
    {
        if(jsonDataGetMessages == nil)
        {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("wsReturnGetMessages"), userInfo: nil, repeats: false)
            
            return
        }
        
        let wsResult: Int = jsonDataGetMessages["wsResult"] as! Int
        
        if(wsResult == 1)
        {
            print("Mensagens recebidas com sucesso!")
            
            let messagesCount: Int = jsonDataGetMessages["wsMessagesCount"] as! Int
            let messages: NSArray = jsonDataGetMessages["wsMessages"] as! NSArray
            
            if(messagesCount > 0)
            {
                for x in 0 ... messagesCount - 1
                {
                    let message: NSDictionary = messages[x] as! NSDictionary
                    
                    let msgId: String = message["msgId"] as! String
                    let msgMessage: String = message["msgMessage"] as! String
                    let msgNickname: String = message["msgNickname"] as! String
                    let msgToId: String = message["msgToId"] as! String
                    
                    // Controle do ID mais recente de mensagem recebida pelo aplicativo
                    if(Int(msgId) > Int(lastIdMessage))
                    {
                        lastIdMessage = msgId
                    }
                    
                    var msgPrivateChar: String = ""
                    if(!msgToId.isEmpty)
                    {
                        msgPrivateChar = "* "
                    }
                    
                    let msgBuffer: String = "Mensagem: \(msgPrivateChar) \(msgId) \(msgToId) \(msgNickname): \(msgMessage)"
                    print(msgBuffer)
                    
                    if(formTextViewChat.text == "")
                    {
                        formTextViewChat.text = "\(msgBuffer)"
                    }
                    else
                    {
                        formTextViewChat.text = "\(formTextViewChat.text)\n\(msgBuffer)"
                    }
                    
                    formTextViewChat.scrollRangeToVisible(formTextViewChat.selectedRange)
                }
            }
            
            let usersCount: Int = jsonDataGetMessages["wsUsersCount"] as! Int
            let users: NSArray = jsonDataGetMessages["wsUsers"] as! NSArray
            
            userListNicknames = NSMutableArray()
            userListIds = NSMutableArray()
            
            userListNicknames.addObject("Todos")
            userListIds.addObject("")
            
            for x in 0 ... usersCount - 1
            {
                let user: NSDictionary = users[x] as! NSDictionary
                
                let userId: String = user["userId"] as! String
                let userNickname: String = user["userNickname"] as! String
                
                userListNicknames.addObject(userNickname)
                userListIds.addObject(userId)
                
                let userBuffer: String = "Usuário: \(userId) \(userNickname)"
                print(userBuffer)
            }
            
            appConnect()
            NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: Selector("btGetMessagesTimer"), userInfo: nil, repeats: false)
        }
        else
        {
            showMessage("Falha", messageToShow: jsonDataGetMessages["wsDescription"] as! String)
        }
    }
    
    func btGetMessagesTimer()
    {
        if(isConnected)
        {
            btGetMessages()
        }
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
    
    @IBAction func btSelectUser()
    {
        userTableViewListIds = userListIds
        userTableViewListNicknames = userListNicknames
        
        formTableViewUsers.reloadData()
        formTableViewUsers.hidden = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return userTableViewListNicknames.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let myId: String = "MinhaCelula"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(myId) as UITableViewCell!
        
        if(cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: myId)
        }
        
        cell?.textLabel?.text = userTableViewListNicknames.objectAtIndex(indexPath.row) as? String
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let nickname: String = userTableViewListNicknames.objectAtIndex(indexPath.row) as! String
        
        toId = userTableViewListIds.objectAtIndex(indexPath.row) as! String
        
        formButtonWho.setTitle(nickname, forState: UIControlState.Normal)
        
        formTableViewUsers.hidden = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
}

