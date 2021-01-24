//
//  ViewController.swift
//  Nutrix
//
//  Created by Zheyuan Xu on 1/11/21.
//

import UIKit
import RealityKit
import Vision
import ARKit


class ARViewController: UIViewController, ARSessionDelegate, UNUserNotificationCenterDelegate {
    var email: String!
    var username: String!
    var userFoodSaved: Int!
    var foodItemSaved: String!
    var ingredientsCount: Int!
    
    // loop counter for hand pose optimization
    var counter: Int! = 0
    
    var foodURL: String! = ""
    
    
    var configuration = ARWorldTrackingConfiguration()
    
    var tree: Entity!
    var statsBar: Entity!
    var statsText: Entity!
    var recipeText: Entity!
    
    private var gestureProcessor = HandGestureProcessor()
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput")
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    var imageTaken: UIImage!
    
    var fruitArray: [String] = ["Apple", "Banana", "Orange", "Pear", "Strawberry", "Blueberry", "Raspberry", "Blackberry", "Tomatoe", "Watermelloon", "Pinapple"]
    var grainsArray: [String] = ["Bread", "Cereal", "Pasta", "Rice"]
    var meat: [String] = ["Beef", "Bacon", "Pig", "Cow", "Lamb", "Mutton", "Pork", "Fish", "Chicken", "Laptop part", "Computer"]
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handPoseRequest.maximumHandCount = 1
        
        
        let arAnchor = try! ARExperience.loadScene()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(arAnchor)
        
        let imageAnchor = AnchorEntity(plane: .horizontal)
        var simpleMaterial = SimpleMaterial()
        
        let url = URL(string: self.foodURL!)
        
        if let data = try? Data( contentsOf:url!)
        {
            imageTaken = UIImage( data:data)
        }

        
        var documentsUrl: URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        
        do {
            let fileName = "placeholder.jpg"
            let fileURL = documentsUrl.appendingPathComponent(fileName)
            if let imageData = imageTaken.jpegData(compressionQuality: 1.0) {
                try? imageData.write(to: fileURL, options: .atomic)
                print(fileName)
                simpleMaterial.baseColor = try! .texture(.load(contentsOf: fileURL))
            }
        } catch {
            print("Unable to Write Data to Disk (\(error))")
        }
        
        
        let myMesh: MeshResource = .generatePlane(width: 0.2, depth: 0.2, cornerRadius: 0.01)

        let component = ModelComponent(mesh: myMesh,
                                  materials: [simpleMaterial])
        imageAnchor.components.set(component)
        
        arView.scene.addAnchor(imageAnchor)
        
        // set the initial position of the
        imageAnchor.transform.translation = [0, 0.5, -0.5]
        
        // rotate the image 90 degrees so it faces the user
        imageAnchor.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3(x: 1, y: 0, z: 0))
        
        tree = arAnchor.findEntity(named: "tree")
        statsBar = arAnchor.findEntity(named: "statsBar")
        statsText = arAnchor.findEntity(named: "carbonText")
        recipeText = arAnchor.findEntity(named: "recipeText")
        
        for i in 1...ingredientsCount {
            let tree_ = tree.clone(recursive: true)
            arAnchor.addChild(tree_)
            tree_.transform.translation = [Float(i) * 0.1, 0, -0.5]
            let statsBar_ = statsBar.clone(recursive: true)
            arAnchor.addChild(statsBar_)
            statsBar_.transform.translation = [0.5,  Float(i) * 0.05, -0.5]
            
        }
        
        arAnchor.addChild(statsText)
        arAnchor.addChild(recipeText)
        statsText.transform.translation = [0.5,  0.30, -0.5]
        recipeText.transform.translation = [0, 0.35, -0.5]
        
        //print(statsText.components.self)
        
//        var textModelComp: ModelComponent = (statsText.components.self[ModelComponent])!
//
//        var material = SimpleMaterial()
//        material.baseColor = .color(.red)
//        textModelComp.materials[0] = material
//
//        textModelComp.mesh = .generateText("Your Carbon Stats",
//            extrusionDepth: 0.01,
//                      font: .systemFont(ofSize: 0.08),
//            containerFrame: CGRect(),
//                 alignment: .left,
//             lineBreakMode: .byCharWrapping)
//
//        statsText.components.set(textModelComp)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        arView.session.delegate = self
        setupARView()
        
        self.togglePeopleOcclusion()
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    fileprivate func togglePeopleOcclusion() {
        guard let config = arView.session.configuration as? ARWorldTrackingConfiguration else {
            fatalError("Unexpectedly failed to get the configuration.")
        }
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        }
        switch config.frameSemantics {
        case [.personSegmentationWithDepth]:
            config.frameSemantics.remove(.personSegmentationWithDepth)
        
        default:
            config.frameSemantics.insert(.personSegmentationWithDepth)
            
        }
        arView.session.run(config)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Session failed. Changing worldAlignment property.")
        print(error.localizedDescription)

        if let arError = error as? ARError {
            switch arError.errorCode {
            case 102:
                configuration.worldAlignment = .gravity
                restartSessionWithoutDelete()
            default:
                restartSessionWithoutDelete()
            }
        }
    }
    
    func restartSessionWithoutDelete() {
        // Restart session with a different worldAlignment - prevents bug from crashing app
        self.arView.session.pause()

        self.arView.session.run(configuration, options: [
            .resetTracking,
            .removeExistingAnchors])
    }
    
    // function for handling tapping actions
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        
    }
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        //let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        //configuration.environmentTexturing = .automatic
        //arView.session.run(configuration)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {

        counter += 1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, orientation: .up, options: [:])
        do {
            if counter % 10 == 0 {
                try? handler.perform([handPoseRequest])
                guard let observation = handPoseRequest.results?.first else {return}
                
                let thumbPoints = try! observation.recognizedPoints(forGroupKey: .handLandmarkRegionKeyThumb)
                let indexFingerPoints = try observation.recognizedPoints(forGroupKey: .handLandmarkRegionKeyIndexFinger)
                let ringFingerPoints = try observation.recognizedPoints(forGroupKey: .handLandmarkRegionKeyRingFinger)
                // Look for tip points.
                guard let thumbTipPoint = thumbPoints[.handLandmarkKeyThumbTIP], let indexTipPoint = indexFingerPoints[.handLandmarkKeyIndexTIP], let ringTipPoint = ringFingerPoints[.handLandmarkKeyRingTIP] else {
                    return
                }
                // Ignore low confidence points.
                guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else {
                    return
                }
                
                let indexFingerAndThumbTipDistance = abs(thumbTipPoint.location.x - indexTipPoint.location.x) + abs(thumbTipPoint.location.y - indexTipPoint.location.y)
                
                
                print(indexFingerAndThumbTipDistance)
                
            }
        } catch {

        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let uvEnv = segue.destination as? enviromentViewController{
            uvEnv.email = self.email
            uvEnv.username = self.username
            uvEnv.userFoodSaved = self.userFoodSaved
            uvEnv.foodItemSaved = self.foodItemSaved
        }
    }
    
    @IBAction func ARToEnv(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ARToEnv", sender: self)
    }
    
}
