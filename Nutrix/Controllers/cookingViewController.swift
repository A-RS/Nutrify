import UIKit
import GoogleSignIn
import Firebase
import AuthenticationServices
import Alamofire
import SwiftyJSON

class cookingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    
    var email: String!
    var username: String!
    
    var ingredients: [String] = []
    var currentCell: foodLabel!
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var foodTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodTable.delegate = self
        foodTable.dataSource = self
        
        foodTable.register(UINib(nibName: "foodLabel", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        lookUpInfo()
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
    
    func lookUpInfo() {
        db.collection("Ingredients").getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    
                    DispatchQueue.main.async {
                        //
                        if  document.data()["username"] as? String == username{
                            let name = document.data()["name"]! as? String
                            
                            self.ingredients.append(name!)
                            self.foodTable.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print(ingredients)
        let foodItem = ingredients[indexPath.row]
        currentCell = foodTable.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as? foodLabel
        
        currentCell.ingredientField.text = "\(foodItem)"
        
        return currentCell
    }
}

