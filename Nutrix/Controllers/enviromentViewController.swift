import UIKit
import GoogleSignIn
import Firebase
import AuthenticationServices
import Alamofire
import SwiftyJSON

class enviromentViewController: UIViewController{
    
    var email: String!
    var username: String!
    var ingredients: [String] = []
    var userFoodSaved: Int!
    var foodItemSaved: String!

                                                          
    @IBOutlet weak var fooditemsavedLabel: UILabel!
    @IBOutlet weak var foodSavedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(ingredients.count)
        fooditemsavedLabel.isHidden = false
        foodSavedLabel.text = "\(userFoodSaved!)" + "/" + "\(ingredients.count)" + " | " + "\(Float(userFoodSaved!)/Float((ingredients.count))*100)" + "%"
        fooditemsavedLabel.text = foodItemSaved!
        //print(fooditemsavedLabel.text!)
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


