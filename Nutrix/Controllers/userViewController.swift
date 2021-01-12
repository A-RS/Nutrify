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

class userViewController: UIViewController {
    let db = Firestore.firestore()
    
    var email: String!
    var username: String!
    
    @IBOutlet weak var welcomeUsername: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lookUpUsername()
    }
    
    func lookUpUsername(){
        db.collection("usersInfo").getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    
                    if document.data()["email"] as? String == email {
                        self.username = document.data()["username"]! as? String
                        
                    }
                }
            }
            
            welcomeUsername.text = "Welcome back! \(username!)"
        }
    }
}
