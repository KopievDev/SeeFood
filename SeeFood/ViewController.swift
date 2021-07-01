//
//  ViewController.swift
//  SeeFood
//
//  Created by Ivan Kopiev on 01.07.2021.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func setUp() {
        title = "SeeFood"
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
    }

    @IBAction func showImagePicker(sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Error to get image from camera")
        }
        imageView.image = image
        guard let ciImage = CIImage(image: image) else {
            fatalError("Error to make CIImage from photo")
        }
        detect(image: ciImage)
        imagePicker.dismiss(animated: true)
    }
    
    func detect(image: CIImage) {
        guard let model =  try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Error to loading CoreML model")
        }
        
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Error to loading results from CoreML")
            }
            if let firstResult = result.first {
                if firstResult.identifier.contains("hotdog") {
                    self?.title = "Это Хот-Дог"
                } else {
                    self?.title = "Это не Хот-Дог"

                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch let error {
            print(error.localizedDescription)
        }
        
        
    }
}
