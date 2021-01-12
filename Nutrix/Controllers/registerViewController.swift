//
//  ViewController.swift
//  Nutrix
//
//  Created by Zheyuan Xu on 1/11/21.
//

import UIKit
import GoogleSignIn
import Firebase
import AuthenticationServices

class registerViewController: UIViewController {
    
    //Declare database instance
    let db = Firestore.firestore()
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var registeredField: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        registeredField.isHidden = true
    }
    
    
    func addUsername(withName username: String, withEmail email: String) {
        var ref: DocumentReference? = nil
        ref = db.collection("usersInfo").addDocument(data: [
            "username": username,
            "email": email
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        let email = emailField.text!
        let password = passwordField.text!
        let username = usernameField.text!
        
        addUsername(withName: username, withEmail: email)
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            // [START_EXCLUDE]
          guard let user = authResult?.user, error == nil else {
            return
          }
          print("\(user.email!) created")
        }
        registeredField.isHidden = false
    }
}
