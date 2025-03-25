//
//  AddLooksetViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 25.03.2025.
//

import Foundation
import UIKit


protocol AddClothesForLooksetDelegate: AnyObject {
    func addClothesForLooksetDelegate(clothesItem: Clothes)
}


class AddLooksetViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, AddClothesForLooksetDelegate {
    
    @IBOutlet weak var addLooksetVCTitle: UILabel!
    @IBOutlet weak var looksetNameTextField: UITextField!
    @IBOutlet weak var looksetDescriptionTextField: UITextField!
    
    
    @IBOutlet weak var headClothesNameLabel: UILabel!
    @IBOutlet weak var jacketClothesNameLabel: UILabel!
    @IBOutlet weak var tshirtClothesNameLabel: UILabel!
    @IBOutlet weak var trousersClothesNameLabel: UILabel!
    @IBOutlet weak var shoesClothesNameLabel: UILabel!
    
    @IBOutlet weak var selectedTempPickerView: UIPickerView!
    weak var updateLooksetDelegate: UpdateLooksetDelegate?
    
    var dbConnection = DBManager()
    var temps: [Int] = []
    var currentTempValue: Int = -1
    var looksetDict: [String: Int] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedTempPickerView.dataSource = self
        selectedTempPickerView.delegate = self
        
        for i in -40...50 {
            temps.append(i)
        }
        temps.reverse()
        
        setCurrentTemp(currentTemp: 25)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false // Allows touches to be passed to other views
        self.view.addGestureRecognizer(tapGesture)

        self.looksetNameTextField.delegate = self
        self.looksetDescriptionTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func handleTap() {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setCurrentTemp(currentTemp: Int) {
        if !temps.isEmpty {
            var defaultRow = 0
            
            if let elemIndex = temps.firstIndex(of: currentTemp) {
                defaultRow = elemIndex
                self.currentTempValue = currentTemp
            }
            self.selectedTempPickerView.selectRow(defaultRow, inComponent: 0, animated: false)
        }
    }
    
    func addClothesForLooksetDelegate(clothesItem: Clothes) {
        self.looksetDict[clothesItem.category] = clothesItem.id
        DispatchQueue.main.async {
            switch (clothesItem.category) {
            case "Голова":
                self.headClothesNameLabel.text = clothesItem.name
            case "Верхняя":
                self.jacketClothesNameLabel.text = clothesItem.name
            case "Под верх":
                self.tshirtClothesNameLabel.text = clothesItem.name
            case "Нижняя":
                self.trousersClothesNameLabel.text = clothesItem.name
            default:
                self.shoesClothesNameLabel.text = clothesItem.name
            }
        }
    }
    
    
    @IBAction func addHeadButtonPressed(_ sender: UIButton) {
        self.initChooseClothesForLooksetVC(category: "Голова")
    }
    
    @IBAction func addJacketButtonPressed(_ sender: UIButton) {
        self.initChooseClothesForLooksetVC(category: "Верхняя")
    }
    
    @IBAction func addTshirtButtonPressed(_ sender: UIButton) {
        self.initChooseClothesForLooksetVC(category: "Под верх")
    }
    
    @IBAction func addTrousersButtonPressed(_ sender: UIButton) {
        self.initChooseClothesForLooksetVC(category: "Нижняя")
    }
    
    @IBAction func addShoesButtonPressed(_ sender: UIButton) {
        self.initChooseClothesForLooksetVC(category: "Обувь")
    }
    
    
    @IBAction func addLooksetButtonPressed(_ sender: UIButton) {
        dbConnection.insertIntoLookset(looksetName: self.looksetNameTextField.text ?? "", looksetDescription: self.looksetDescriptionTextField.text ?? "", looksetTemp: self.currentTempValue, headId: self.looksetDict["Голова"] ?? -1, jacketId: self.looksetDict["Верхняя"] ?? -1, tshirtId: self.looksetDict["Под верх"] ?? -1, trousersId: self.looksetDict["Нижняя"] ?? -1, shoesId: self.looksetDict["Обувь"] ?? -1)
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Успешно!", message: "Новый стиль добавлен в гардероб", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
                self?.updateLooksetDelegate?.updateLooksetTable()
            }))
            self.present(alert, animated: true, completion: nil)

            self.clearForm()
        }
    }
    
    func initChooseClothesForLooksetVC(category: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let chooseClothesForLooksetVC = sb.instantiateViewController(withIdentifier: "ChooseClothesForLooksetViewController") as! ChooseClothesForLooksetViewController
        chooseClothesForLooksetVC.addClothesForLooksetDelegate = self
        
        chooseClothesForLooksetVC.updateChooseClothesTable(clothesForChoosing: dbConnection.selectByCategoryAndTemp(category: category, temp: self.currentTempValue))
        navigationController?.pushViewController(chooseClothesForLooksetVC, animated: true)
    }
    
    func clearForm() {
        self.looksetNameTextField.text = ""
        self.looksetDescriptionTextField.text = ""
    }
    
    
}


extension AddLooksetViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return temps.count
    }
}


extension AddLooksetViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(temps[row])°C"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentTempValue = temps[row]
    }
}
