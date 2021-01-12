//
//  ViewController.swift
//  Nutrix
//
//  Created by Zheyuan Xu on 1/11/21.
//

import UIKit

class homeViewController: UIViewController {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 20
        registerBtn.layer.cornerRadius = 20
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginSegue", sender: self)
    }
    
    
    @IBAction func registerAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "registerSegue", sender: self)
    }
}
