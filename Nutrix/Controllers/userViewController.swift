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

class userViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let db = Firestore.firestore()
    
    var email: String!
    var username: String!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    var imageTaken: UIImage!
    
    @IBOutlet weak var welcomeUsername: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lookUpUsername()
        imageView.isHidden = false
        imagePicker.delegate = self
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
            
            welcomeUsername.text = "Welcome back! \(username!)"
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
    
    func getFoodLabel(with imageStrBase64: String) {
        //define API url
//        let url = URL(string: "http://ec2-54-90-166-180.compute-1.amazonaws.com:5000/getFoodLabels")!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "image": imageStrBase64
        ]

//        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
//
//        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
//
//            guard let data = data else {
//                return
//            }
//        })
//
//        task.resume()
        
        AF.request("http://ec2-54-90-166-180.compute-1.amazonaws.com:5000/getFoodLabels", method: .post, parameters: parameters, encoding: JSONEncoding.default).response {_ in
            
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

