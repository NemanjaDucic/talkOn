//
//  MessagesViewController.swift
//  talkON
//
//  Created by Ducic Nemanja on 11/26/20.
//

import Foundation
import Firebase
import FirebaseAuth
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class MessagesViewController:UITableViewController{

    var messages = [MessageModel]()
    var messagesDictionary = [String: MessageModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        navigationSetup()
        tableView.register(UsersCell.self, forCellReuseIdentifier: "cellId")
        tableView.backgroundColor = UIColor.talkOnPleasent
            
    }
    func navigationSetup(){
        
        navigationController?.isNavigationBarHidden = false
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.talkONOrange
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.talkONOrange
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UsersCell
        cell.backgroundColor = UIColor.talkOnPleasent
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = UserModel(dictionary: dictionary)
            user.id = chatPartnerId
            self.showChatControllerForUser(user)
            
            }, withCancel: nil)
    }
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginViewController()
        loginController.messagesController = self
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let LoginVC = storyboard.instantiateViewController(identifier: "login")
        show(LoginVC, sender: self)
       
    }
    @objc func handleNewMessage() {
        let newMessageController = NewMessagesViewController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let user = UserModel(dictionary: dictionary)
                self.setupNavBarWithUser(user)
            }
            
            }, withCancel: nil)
    }
    func setupNavBarWithUser(_ user: UserModel) {
            messages.removeAll()
            messagesDictionary.removeAll()
            tableView.reloadData()
            observeUserMessages()
            navigationItem.title = user.name
    }
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            print(uid, userId)
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId)
                
                }, withCancel: nil)
            
            }, withCancel: nil)
    }
    fileprivate func fetchMessageWithMessageId(_ messageId: String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = MessageModel(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                
                self.attemptReloadOfTable()
            }
            
            }, withCancel: nil)
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    var timer: Timer?
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
        })
            DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    func showChatControllerForUser(_ user: UserModel) {
        let chatLogController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        chatLogController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(chatLogController, animated: true)
    }
}
