import UIKit
import GoogleSignIn
import Firebase
import AuthenticationServices
import Alamofire
import SwiftyJSON

class cookingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, checkButtonDelagate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    
    var email: String!
    var username: String!
    
    var ingredients: [String] = []
    var currentCell: foodLabel!
    var foodItemSaved: String! = ""
    var foodItem1: String!
    var foodURL: String!
    
    var ingredientsCount: Int! = 0
    
    var userFoodSaved: Int! = 0
    
    var selectedCells: [foodLabel] = []
    
    var fruitArray: [String] = ["Apple", "Banana", "Orange", "Pear", "Strawberry", "Blueberry", "Raspberry", "Blackberry", "Tomatoe", "Watermelloon", "Pinapple"]
    var grainsArray: [String] = ["Bread", "Cereal", "Pasta", "Rice"]
    var meat: [String] = ["Beef", "Bacon", "Pig", "Cow", "Lamb", "Mutton", "Pork", "Fish", "Chicken", "Laptop part", "Computer"]
    
    
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var foodTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodTable.delegate = self
        foodTable.dataSource = self
        
        foodTable.register(UINib(nibName: "foodLabel", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        lookUpInfo()
        //didTapCheckBtn()
        //print(ingredients.count)
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
            uvHome.foodURL = self.foodURL
        }
        else if let uvEnv = segue.destination as? enviromentViewController{
            uvEnv.email = self.email
            uvEnv.username = self.username
            uvEnv.ingredients = self.ingredients
            uvEnv.userFoodSaved = self.userFoodSaved
            uvEnv.foodItemSaved = self.foodItemSaved
            uvEnv.foodURL = self.foodURL
            uvEnv.ingredientsCount = self.ingredientsCount
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect the row, and instead, show the state with a checkmark.
        tableView.deselectRow(at: indexPath, animated: false)
//
//        guard let cellSelected = foodTable.cellForRow(at: indexPath) as? foodLabel else { return }
//
//
//        // append the selected cell to the selection list
//        selectedCells.append(cellSelected)
        
        // Update the selected item to indicate whether the user packed it or not.
        let item = ingredients[indexPath.row]
        foodItem1 = item
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print(ingredients)
        let foodItem = ingredients[indexPath.row]
        self.foodItem1 = foodItem
        currentCell = foodTable.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as? foodLabel
        
        currentCell.ingredientField.text = "\(foodItem)"
        currentCell.delegate = self
        
        return currentCell
    }
    
    func didTapCheckBtn() {
        userFoodSaved = userFoodSaved + 1
        for i in fruitArray{
            if i == foodItem1{
                foodItemSaved = foodItemSaved + i + ": 3,000 grams of CO2" + "\n"
                ingredientsCount += 1
                break
            }
        }
        for i in grainsArray{
            if i == foodItem1{
                foodItemSaved = foodItemSaved + i + ": 1,000 grams of CO2" + "\n"
                ingredientsCount += 1
                break
            }
        }
        for i in meat{
            if i == foodItem1{
                foodItemSaved = foodItemSaved + i + ": 14,000 grams of CO2" + "\n"
                ingredientsCount += 1
                break
            }
        }
        print(userFoodSaved!)
    }
}   

