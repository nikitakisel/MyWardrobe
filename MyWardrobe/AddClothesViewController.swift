//
//  AddClothesViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 18.03.2025.
//

import Foundation
import UIKit

class AddClothesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var tempMinPickerView: UIPickerView!
    @IBOutlet weak var tempMaxPickerView: UIPickerView!
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var imageNameLabel: UILabel!
    
    var categories: [String] = ["Голова", "Верхняя", "Под верх", "Нижняя", "Обувь"]
    var temps: [Int] = []
    var addNewClothesDelegate: AddNewClothesDelegate?
    
    var category: String = ""
    var tempMinValue: Int = -1
    var tempMaxValue: Int = 1
    
    var imageName: String = ""
    var imageData: Data = Data(base64Encoded: "")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in -30...45 {
            temps.append(i)
        }
        
        temps.reverse()
        self.previewImageView.contentMode = .scaleAspectFill
        
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        categoryPickerView.tag = 1
        
        tempMinPickerView.dataSource = self
        tempMinPickerView.delegate = self
        tempMinPickerView.tag = 2
        
        tempMaxPickerView.dataSource = self
        tempMaxPickerView.delegate = self
        tempMaxPickerView.tag = 3

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary // Choose photo library as source
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func addPostButtonPressed(_ sender: UIButton) {
        guard let name = self.nameTextField.text, !name.isEmpty else {
            self.alert(message: "Вы не ввели название одежды!")
            return
        }
        
        if self.tempMinValue > self.tempMaxValue {
            self.alert(message: "Минимальная температура больше максимальной!")
        } else {
            let dbConnection = DBManager()
            dbConnection.insert(name: name, description: self.descriptionTextField.text!, category: self.category, tempMin: self.tempMinValue, tempMax: self.tempMaxValue, image: self.imageData.base64EncodedString())
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Успешно!", message: "Вещь добавлена в гардероб!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                    self?.addNewClothesDelegate?.updateAllClothesTable()
                }))
                self.present(alert, animated: true, completion: nil)

                self.clearForm()
            }
            
        }
    }
    
    func alert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let image = info[.originalImage] as? UIImage,
           let imageName = info[.imageURL] as? URL {
            self.imageName = imageName.lastPathComponent
            self.imageNameLabel.text = self.imageName

            if let imageData = image.jpegData(compressionQuality: 1.0) {
                self.imageData = imageData
                self.previewImageView.image = UIImage(data: self.imageData)
                // postImageData теперь содержит строку Base64
            } else if let imageData = image.pngData() {
                self.imageData = imageData
                self.previewImageView.image = UIImage(data: self.imageData)
                // postImageData теперь содержит строку Base64
            } else {
                print("Не удалось преобразовать изображение в данные.")
            }

        } else {
            print("Error: No image found or URL couldn't be accessed.")
            self.imageName = "" // Reset the name if there's an issue.
            self.imageData = Data(base64Encoded: "")! // Reset the data if there's an issue.
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func clearForm() {
        self.nameTextField.text = ""
        self.descriptionTextField.text = ""
    }
}


extension AddClothesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return categories.count
        } else {
            return temps.count
        }
    }
}


extension AddClothesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return categories[row]
        } else {
            return String(temps[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            self.category = categories[row]
        } else if pickerView.tag == 2 {
            self.tempMinValue = temps[row]
        } else {
            self.tempMaxValue = temps[row]
        }
    }

}
