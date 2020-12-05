//
//  ViewController.swift
//  talkON
//
//  Created by Nemanja Ducic on 11/26/20.
//

import UIKit
import Firebase
import FirebaseAuth
class LoginViewController: UIViewController,UINavigationControllerDelegate {
    var messagesController: MessagesViewController?
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.backgroundColor = .talkOnPleasent
        navigationController?.isNavigationBarHidden = true
        
        
        
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        handleLogin()
    }
    func setupView(){
        emailTextField.layer.borderColor = UIColor.talkONOrange.cgColor
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.borderColor = UIColor.talkONOrange.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 10
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            self.performSegue(withIdentifier: "tomessages", sender: nil)
        })
        
    }
}
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

