//
//  UsersCell.swift
//  talkON
//
//  Created by Nikola Ticojevic on 11/26/20.
//

import Foundation
import UIKit
import Firebase
class UsersCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var PofileImageView: UIImageView!
    
   
        
        var message: MessageModel? {
            didSet {
                setupNameAndProfileImage()
                
                detailTextLabel?.text = message?.text
                
                if let seconds = message?.timestamp?.doubleValue {
                    let timestampDate = Date(timeIntervalSince1970: seconds)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "hh:mm:ss a"
                }
                
                
            }
        }
        
        fileprivate func setupNameAndProfileImage() {
            
            if let id = message?.chatPartnerId() {
                let ref = Database.database().reference().child("users").child(id)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.textLabel?.text = dictionary["name"] as? String
                        
                  
                    }
                    
                    }, withCancel: nil)
            }
        }
        
    
        
     
       
        
        
    }


