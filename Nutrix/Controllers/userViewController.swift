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
import Alamofire
import SwiftyJSON

class userViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let db = Firestore.firestore()
    
    var email: String!
    var username: String!
    
    @IBOutlet weak var generateBtn: UIButton!
    
    @IBOutlet weak var cameraBtn: UIButton!
    
    var foodItems: [String] = ["Apple", "Banana", "Orange", "Pear", "Strawberry", "Blueberry", "Raspberry", "Blackberry", "Tomatoe", "Watermelloon", "Pinapple", "Bread", "Cereal", "Pasta", "Rice", "Beef", "Bacon", "Pig", "Cow", "Lamb", "Mutton", "Pork", "Fish", "Chicken"]
    
    @IBOutlet weak var foodLabels: UILabel!
    
    var imagePicker = UIImagePickerController()
    
    var imageTaken: UIImage! 
    
    var inString: String! = ""
    
    var ingredients: String!
    var servings: String!
    var instructions: String!
    
    var foodArray: [String] = []
    
    
    @IBOutlet weak var ingLabel: UIButton!
    @IBOutlet weak var intrLabel: UIButton!
    @IBOutlet weak var servLabel: UIButton!
    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lookUpUsername()
        imageView.isHidden = false
        imagePicker.delegate = self
        titleLabel!.isHidden = true
        ingLabel.isHidden = true
        intrLabel.isHidden = true
        servLabel.isHidden = true
        
        ingLabel.layer.cornerRadius = 30
        intrLabel.layer.cornerRadius = 30
        servLabel.layer.cornerRadius = 30
    }
    
    @IBAction func takeImage(_ sender: UIButton) {
        openCamera()
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
            
        }
    }
    
    func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.showsCameraControls = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey :
    Any]) {
        if let img = info[.originalImage] as? UIImage {
            //self.imageView.image = img
            imageTaken = img
            print("image taken")
            self.dismiss(animated: true, completion: nil)
        }
        else {
            print("error")
        }
        
        //imagePicker.dismiss(animated: true, completion: nil)
        imageView.isHidden = false
        imageView.image = imageTaken
        
        // convert the image to base64
        let imageData: NSData = imageTaken.jpeg(.medium)! as NSData
        let strBase64 = imageData.base64EncodedString(options: [])
        getFoodLabel(with: strBase64)
    }
    
    func getFoodLabel(with imageStrBase64: String){
        
        let parameters: [String: Any] = [
            "image": imageStrBase64
        ]

        
        AF.request("http://ec2-54-90-166-180.compute-1.amazonaws.com:5000/getFoodLabels", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData {response in
            if let json = response.data {
                do{
                    let data = try JSON(data: json)
                    print(data)
                    let convertedString = String(data: response.data!, encoding: String.Encoding.utf8)
                    //let locationJSON = data["addresses"][0]["formattedAddress"]
                    //print("location: \(location)")
                    for item1 in data{
                        print(item1)
                        for item2 in self.foodItems{
                            if "\(item1)".contains(item2){
                                print("\(item2)")
                                self.saveToDatabase(withIngredient: item2)
                            }
                        }
                    }
                    //self.location = self.locationField.text
                }
                catch{
                    print("JSON Error")
                }
            }
        }
    }
    
    func getRecipe(){
        print(inString!)
        let parameters: [String: Any] = [
            "ingredients": "tasty " + inString!
        ]

        
        AF.request("http://ec2-54-90-166-180.compute-1.amazonaws.com:5000/getRecipe", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData {response in
            if let json = response.data {
                do{
                    let data = try JSON(data: json)
                    print(data)
                    let convertedString = String(data: response.data!, encoding: String.Encoding.utf8)
                    self.titleLabel?.isHidden = false
                    self.titleLabel?.text = "\(data[0])"
                    
                    self.generateBtn.isHidden = true
                    self.cameraBtn.isHidden = true
                    
                    //self.ingrediantLabel.isHidden = false
                    //self.ingrediantLabel.text = "\(data[3])"
                    //print(data[3][0]) // Hello
                    var ingLabel = ""
                    for n in 0...data.count{
                        ingLabel = ingLabel + "\(data[3][n])" + "\n"
                    }
                    
                    self.ingredients = ingLabel
                    self.servings = "\(data[2])"
                    self.instructions = "\(data[4])"
                    
                    self.intrLabel.isHidden = false
                    self.ingLabel.isHidden = false
                    self.servLabel.isHidden = false
                }
                catch{
                    print("JSON Error")
                }
            }
        }
    }
    
    func lookUpIngrediants() {
        db.collection("Ingredients").getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    
                    if  document.data()["username"] as? String == username{
                        let name = document.data()["name"]! as? String
                        inString  = inString + " " + name!
                    }
                }
                print(inString!)
                getRecipe()
            }
        }
    }
    
    func saveToDatabase(withIngredient ingredient: String) {
        var ref: DocumentReference? = nil
        
        ref = db.collection("Ingredients").addDocument(data:
            ["name": ingredient,
             "username": username!,
             "email": email!,
             "quantity": 1
            ]
        )
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
        performSegue(withIdentifier: "homeToCooking", sender: self)
        
    }
    
    @IBAction func cookingAction(_ sender: UIButton) {
        performSegue(withIdentifier: "homeToCooking", sender: self)
    }
    

    @IBAction func homeToEnv(_ sender: UIButton) {
        performSegue(withIdentifier: "homeToEnv", sender: self)
    }
    
    
    @IBAction func generateRecipe(_ sender: UIButton) {
        lookUpIngrediants()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let uvCooking = segue.destination as? cookingViewController{
            uvCooking.email = self.email
            uvCooking.username = self.username
        }
        else if let uvEnv = segue.destination as? enviromentViewController{
            uvEnv.email = self.email
            uvEnv.username = self.username
        }
        
    }
    
    @IBAction func showIngredients(_ sender: Any) {
        let alertController = UIAlertController(title: "Ingredients", message:
                ingredients, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func showInstructions(_ sender: Any) {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle

        paragraphStyle.alignment = NSTextAlignment.left

        let messageText = NSMutableAttributedString(
            string: instructions,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                //NSAttributedString.Key.foregroundColor: UIColor.gray
            ]
        )
        
        let alertController = UIAlertController(title: "Instructions", message:
                instructions, preferredStyle: .alert)
        
        alertController.setValue(messageText, forKey: "attributedMessage")
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func showServing(_ sender: Any) {
        let alertController = UIAlertController(title: "Servings", message:
                servings, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

