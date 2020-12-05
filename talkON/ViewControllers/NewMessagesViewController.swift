//
//  NewMessagesViewController.swift
//  talkON
//
//  Created by Nemanja Ducic on 11/26/20.
//

import Foundation
import Firebase
class NewMessagesViewController:UITableViewController,UINavigationControllerDelegate{
    var users = [UserModel]()
    override func viewDidLoad() {

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action:#selector(handleCancel))
        fetchUser()
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.talkOnPleasent
        tableView.register(UsersCell.self, forCellReuseIdentifier: "cellId")
    }
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = UserModel(dictionary: dictionary)
                user.id = snapshot.key
                self.users.append(user)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            }
            
            }, withCancel: nil)
    }
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UsersCell
        cell.backgroundColor = UIColor.talkOnPleasent
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
     
        
        return cell
    }
    
    
    
    var messagesController: MessagesViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("Dismiss completed")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
        }
    }
    
}
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
