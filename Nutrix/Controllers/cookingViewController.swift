import UIKit
import GoogleSignIn
import Firebase
import AuthenticationServices
import Alamofire
import SwiftyJSON

class cookingViewController: UIViewController {
    
    var email: String!
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func homeAction(_ sender: UIButton) {
        performSegue(withIdentifier: "cookingToHome", sender: self)
    }
    
    
    @IBAction func envAction(_ sender: UIButton) {
        performSegue(withIdentifier: "cookingToEnv", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let uvHome = segue.destination as? userViewController{
            uvHome.email = self.email
            uvHome.username = self.username
        }
        else if let uvEnv = segue.destination as? enviromentViewController{
            uvEnv.email = self.email
            uvEnv.username = self.username
        }
        
    }
}

