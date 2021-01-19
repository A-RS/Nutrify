import UIKit
import GoogleSignIn
import Firebase
import AuthenticationServices
import Alamofire
import SwiftyJSON

class enviromentViewController: UIViewController {
    
    var email: String!
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    @IBAction func homeAction(_ sender: UIButton) {
        performSegue(withIdentifier: "envToHome", sender: self)
    }
    
    
    @IBAction func cookingAction(_ sender: UIButton) {
        performSegue(withIdentifier: "envToCooking", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let uvCooking = segue.destination as? cookingViewController{
            uvCooking.email = self.email
            uvCooking.username = self.username
        }
        else if let uvHome = segue.destination as? userViewController{
            uvHome.email = self.email
            uvHome.username = self.username
        }
        
    }
}

