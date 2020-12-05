//
//  RegisterViewController.swift
//  talkON
//
//  Created by Nemanja Ducic on 11/26/20.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
class RegisterViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    var messagesController:MessagesViewController?
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        
    }
    
    func viewSetup(){
        view.backgroundColor = .talkOnPleasent
        usernameTextField.layer.borderColor = UIColor.talkONOrange.cgColor
        usernameTextField.layer.borderWidth = 1
        usernameTextField.layer.cornerRadius = 10
        emailTextField.layer.borderColor = UIColor.talkONOrange.cgColor
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 10
        passwordTextField.layer.borderColor = UIColor.talkONOrange.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 10
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "backToLogin", sender: nil)
    }
    @IBAction func registerButtonTapped(_ sender: Any) {
        handleRegister()
    }
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = usernameTextField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.user.uid else {
                return
            }
            
            let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1) {
            
                storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, err) in
                        if let err = err {
                            print(err)
                            return
                        }
                        
                        guard let url = url else { return }
                        let values = ["name": name, "email": email, "profileImageUrl": url.absoluteString]
                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String: AnyObject])
                        self.performSegue(withIdentifier: "backToLogin", sender: nil)
                    })
                    
                })
            }
        })
    }
    func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
       let ref = Database.database().reference()
       let usersReference = ref.child("users").child(uid)
       
       usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
           
           if err != nil {
               print(err!)
               return
           }
           let user = UserModel(dictionary: values)
           self.messagesController?.setupNavBarWithUser(user)

           self.dismiss(animated: true, completion: nil)
       })
   }
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
                    }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
