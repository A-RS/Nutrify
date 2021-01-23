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

class userViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate{
    let db = Firestore.firestore()
    
    var email: String!
    var username: String!
    
    @IBOutlet weak var generateBtn: UIButton!
    
    @IBOutlet weak var cameraBtn: UIButton!
    
    var foodItems: [String] = ["banana", "Apple", "bread", "pasta", "Touchpad", "Computer", "Laptop part"]
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var foodLabels: UILabel!
    
    var imagePicker = UIImagePickerController()
    
    var imageTaken: UIImage!
    
    var inString: String! = ""
    
    
    
    
    @IBOutlet weak var ingrediantLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var servingLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lookUpUsername()
        imageView.isHidden = false
        imagePicker.delegate = self
        ingrediantLabel.isHidden = true
        titleLabel!.isHidden = true
        servingLabel.isHidden = true
        instructionLabel.isHidden = true
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
                    self.instructionLabel.isHidden = false
                    self.servingLabel.isHidden = false
                    self.servingLabel.text = "\(data[2])"
                    self.ingrediantLabel.isHidden = false
                    self.instructionLabel.text = "\(data[4])"
                    self.generateBtn.isHidden = true
                    self.cameraBtn.isHidden = true
                    //self.ingrediantLabel.isHidden = false
                    //self.ingrediantLabel.text = "\(data[3])"
                    //print(data[3][0]) // Hello
                    var ingLabel = ""
                    for n in 0...data.count{
                        ingLabel = ingLabel + "\(data[3][n])" + "\n"
                    }
                    self.ingrediantLabel.text = ingLabel
                    print(self.ingrediantLabel.text)
                    
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

