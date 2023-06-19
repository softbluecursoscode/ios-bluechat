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
    // Outlets
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
    
    // Variáveis gerais de funcionamento do chat
    var userNickname: String = ""
    var userPassword: String = ""
    var lastIdMessage: String = "0"
    var isConnected: Bool = false
    var toId: String = ""
    
    // URL dos Web Services
    let wsUrlCreateProfile: String = "http://code.softblue.com.br/bluechat/createProfile.php"
    let wsUrlGetMessages: String = "http://code.softblue.com.br/bluechat/getMessages.php"
    let wsUrlSendMessage: String = "http://code.softblue.com.br/bluechat/sendMessage.php"
    
    // Variáveis auxiliares para tratamento de retorno dos Web Services
    var jsonDataCreateProfile: NSDictionary! = nil
    var jsonDataGetMessages: NSDictionary! = nil
    var jsonDataSendMessage: NSDictionary! = nil
    
    // Variáveis auxiliares para funcionamento do TableView
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
    
    // Tratamento do fechamento do teclado: tecla RETURN
    @IBAction func textFieldReturn(sender: AnyObject)
    {
        sender.resignFirstResponder()
        
        if(sender.tag == 5)
        {
            btSendMessage()
        }
    }
    
    // Tratamento do fechamento do teclado: tocando o fundo da tela
    @IBAction func backgroundTouch()
    {
        formTextFieldNickname.resignFirstResponder()
        formTextFieldPassword.resignFirstResponder()
        formTextFieldMessage.resignFirstResponder()
    }
    
    // Comportamento da interface gráfica ao desconectar o chat
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
    
    // Comportamento da interface gráfica ao conectar o chat
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
    
    // Botão de criação de profile (usuário)
    @IBAction func btCreateProfile()
    {
        userNickname = formTextFieldNickname.text!
        userPassword = formTextFieldPassword.text!
        
        wsCallCreateProfile(userNickname, password: userPassword)
    }
    
    // Botão para iniciar a captura das mensagens do chat (login)
    @IBAction func btGetMessages()
    {
        userNickname = formTextFieldNickname.text!
        userPassword = formTextFieldPassword.text!
        
        wsCallGetMessages(userNickname, password: userPassword, lastIdMessage: lastIdMessage)
    }
    
    // Botão para envio de mensagem
    @IBAction func btSendMessage()
    {
        userNickname = formTextFieldNickname.text!
        userPassword = formTextFieldPassword.text!
        
        let userMessage: String = formTextFieldMessage.text!
        formTextFieldMessage.text = ""
        
        wsCallSendMessage(userNickname, password: userPassword, to: toId, message: userMessage)
    }
    
    // Chamada do Web Service de envio de mensagem
    func wsCallSendMessage(nickname: String, password: String, to: String, message: String)
    {
        let nicknameUTF8: String = nickname.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let passwordUTF8: String = password.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let messageUTF8: String = message.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var postParameters: String = "wsNickname=\(nicknameUTF8)&wsPassword=\(passwordUTF8)&wsMessage=\(messageUTF8)"
        
        if(!to.isEmpty)
        {
            postParameters = "\(postParameters)&wsTo=\(to)"
        }
        
        let url: NSURL = NSURL(string: wsUrlSendMessage)!
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
                        self.jsonDataSendMessage = try NSJSONSerialization.JSONObjectWithData(objectData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
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
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("wsReturnSendMessage"), userInfo: nil, repeats: false)
    }
    
    // Chamada do Web Service de captura de mensagens
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
    
    // Chamada do Web Service de criação de usuário
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
    
    // Tratamento do retorno do Web Service de captura de mensagens
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
    
    // Tratamento do retorno do Web Service de envio de mensagem
    func wsReturnSendMessage()
    {
        if(jsonDataSendMessage == nil)
        {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("wsReturnSendMessage"), userInfo: nil, repeats: false)
            
            return
        }
        
        let wsResult: Int = jsonDataSendMessage["wsResult"] as! Int
        
        if(wsResult == 1)
        {
            print("Mensagem enviada com sucesso")
        }
        else
        {
            showMessage("Falha", messageToShow: jsonDataSendMessage["wsDescription"] as! String)
        }
    }
    
    // Tratamento do retorno do Web Service de criação de profile
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
            
            btGetMessages()
        }
        else
        {
            showMessage("Falha", messageToShow: jsonDataCreateProfile["wsDescription"] as! String)
        }
    }
    
    // Exibição de um alerta na tela, para o usuário
    func showMessage(titleToShow: String, messageToShow: String)
    {
        let myActionSheet: UIAlertController = UIAlertController(title: titleToShow, message: messageToShow, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let myAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        myActionSheet.addAction(myAction)
        
        self.presentViewController(myActionSheet, animated: true, completion: nil)
    }
    
    // Botão de logout
    @IBAction func btLogout()
    {
        appDisconnect()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Botão de seleção de usuários
    @IBAction func btSelectUser()
    {
        userTableViewListIds = userListIds
        userTableViewListNicknames = userListNicknames
        
        formTableViewUsers.reloadData()
        formTableViewUsers.hidden = false
    }
    
    // Implementações do TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return userTableViewListNicknames.count
    }
    
    // Implementações do TableView
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
    
    // Implementações do TableView
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let nickname: String = userTableViewListNicknames.objectAtIndex(indexPath.row) as! String
        
        toId = userTableViewListIds.objectAtIndex(indexPath.row) as! String
        
        formButtonWho.setTitle(nickname, forState: UIControlState.Normal)
        
        formTableViewUsers.hidden = true
    }
    
}

