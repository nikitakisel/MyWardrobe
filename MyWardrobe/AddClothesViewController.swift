//
//  AddClothesViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 18.03.2025.
//

import Foundation
import UIKit

class AddClothesViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var tempMinPickerView: UIPickerView!
    @IBOutlet weak var tempMaxPickerView: UIPickerView!
    
    var categories: [String] = ["Голова", "Верхняя", "Под верх", "Нижняя", "Обувь"]
    var temps: [Int] = []
    var addNewClothesDelegate: AddNewClothesDelegate?
    
    var category: String = ""
    var tempMinValue: Int = -1
    var tempMaxValue: Int = 1
    var image: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in -30...45 {
            temps.append(i)
        }
        temps.reverse()
        
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
    
    
    @IBAction func addPostButtonPressed(_ sender: UIButton) {
        guard let name = self.nameTextField.text, !name.isEmpty else {
            self.alert(message: "Вы не ввели название одежды!")
            return
        }
        
        if self.tempMinValue > self.tempMaxValue {
            self.alert(message: "Минимальная температура больше максимальной!")
        } else {
            let dbConnection = DBManager()
            dbConnection.insert(name: name, description: self.descriptionTextField.text!, category: self.category, tempMin: self.tempMinValue, tempMax: self.tempMaxValue, image: self.image)
            
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
