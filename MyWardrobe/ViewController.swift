//
//  ViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 18.03.2025.
//

import UIKit


struct Clothes {
    var id: Int
    var name: String
    var description: String
    var category: String
    var tempMin: Int
    var tempMax: Int
    var image: Data?
    
    mutating func copy(_ obj: Clothes) {
        self.id = obj.id
        self.name = obj.name
        self.description = obj.description
        self.category = obj.category
        self.tempMin = obj.tempMin
        self.tempMax = obj.tempMax
        self.image = obj.image
    }
}


struct Lookset {
    var id: Int
    var looksetName: String
    var looksetDescription: String
    var looksetTemp: Int
    
    var headId: Int
    var jacketId: Int
    var tshirtId: Int
    var trousersId: Int
    var shoesId: Int
    
    var creationTime: String
}


protocol AddNewClothesDelegate: AnyObject {
    func updateAllClothesTable()
}

protocol ShowClothesItemInfoDelegate: AnyObject {
    func showClothesItemInfo(info: Clothes)
}

class ViewController: UIViewController, AddNewClothesDelegate, ShowClothesItemInfoDelegate {
    
    @IBOutlet weak var clothesTableView: UITableView!
    @IBOutlet weak var currentTempPickerView: UIPickerView!
    @IBOutlet weak var saveLooksetButton: UIButton!
    
    var dbConnection = DBManager()
    var allClothes: [Clothes] = []
    var temps: [Int] = []
    var currentTempValue = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveLooksetButton.isHidden = true
        clothesTableView.delegate = self
        clothesTableView.dataSource = self
        
        currentTempPickerView.dataSource = self
        currentTempPickerView.delegate = self
        
        for i in -40...50 {
            temps.append(i)
        }
        temps.reverse()
        
        if !temps.isEmpty {
            var defaultRow = 0
            
            if let elemIndex = temps.firstIndex(of: 25) {
                defaultRow = elemIndex
                self.currentTempValue = 25
            }
            self.currentTempPickerView.selectRow(defaultRow, inComponent: 0, animated: false)
        }
        
        let nib = UINib(nibName: "MainClothesTableViewCell", bundle: nil)
        clothesTableView.register(nib, forCellReuseIdentifier: "MainClothesTableViewCell")
        
        updateAllClothesTable()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func updateAllClothesTable() {
        self.allClothes = dbConnection.readClothes()
        self.clothesTableView.reloadData()
    }
    
    func showClothesItemInfo(info: Clothes) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let clothesItemInfoVC = sb.instantiateViewController(withIdentifier: "ClothesItemInfoViewController") as! ClothesItemInfoViewController
        clothesItemInfoVC.addNewClothesDelegate = self
        
        clothesItemInfoVC.uploadInfo(info: info)
        navigationController?.pushViewController(clothesItemInfoVC, animated: true)
    }
    
    
    @IBAction func showCustomLooksetsButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let looksetVC = sb.instantiateViewController(withIdentifier: "LooksetViewController") as! LooksetViewController
        navigationController?.pushViewController(looksetVC, animated: true)
    }
    
    @IBAction func addClothesButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let addClothesVC = sb.instantiateViewController(withIdentifier: "AddClothesViewController") as! AddClothesViewController
        addClothesVC.addNewClothesDelegate = self
        
        navigationController?.pushViewController(addClothesVC, animated: true)
    }
    
    func loadClothesTableByCategory(category: String) {
        self.allClothes = dbConnection.selectByCategory(category: category)
        self.clothesTableView.reloadData()
        saveLooksetButton.isHidden = true
    }
    
    
    @IBAction func headClothesButtonPressed(_ sender: UIButton) {
        loadClothesTableByCategory(category: "Голова")
    }
    
    
    @IBAction func jacketClothesButtonPressed(_ sender: UIButton) {
        loadClothesTableByCategory(category: "Верхняя")
    }
    
    
    @IBAction func tshirtClothesButtonPressed(_ sender: UIButton) {
        loadClothesTableByCategory(category: "Под верх")
    }
    
    
    @IBAction func trousersClothesButtonPressed(_ sender: UIButton) {
        loadClothesTableByCategory(category: "Нижняя")
    }
    
    
    @IBAction func shoesClothesButtonPressed(_ sender: UIButton) {
        loadClothesTableByCategory(category: "Обувь")
    }
    
    
    @IBAction func homeButtonPressed(_ sender: UIButton) {
        self.updateAllClothesTable()
        saveLooksetButton.isHidden = true
    }
    
    
    @IBAction func diceButtonPressed(_ sender: UIButton) {
        self.allClothes = dbConnection.selectDice(currentTemp: self.currentTempValue)
        self.clothesTableView.reloadData()
        saveLooksetButton.isHidden = false
    }
    
    
    @IBAction func saveDiceLooksetButtonPressed(_ sender: UIButton) {
        var currentLookset = Lookset(id: -1, looksetName: "", looksetDescription: "", looksetTemp: self.currentTempValue, headId: -1, jacketId: -1, tshirtId: -1, trousersId: -1, shoesId: -1, creationTime: "")
        for item in self.allClothes {
        switch (item.category) {
            case "Голова":
                currentLookset.headId = item.id
            case "Верхняя":
                currentLookset.jacketId = item.id
            case "Под верх":
                currentLookset.tshirtId = item.id
            case "Нижняя":
                currentLookset.trousersId = item.id
            default:
                currentLookset.shoesId = item.id
            }
        }
        
        dbConnection.insertIntoLookset(looksetName: currentLookset.looksetName, looksetDescription: currentLookset.looksetDescription, looksetTemp: currentLookset.looksetTemp, headId: currentLookset.headId, jacketId: currentLookset.jacketId, tshirtId: currentLookset.tshirtId, trousersId: currentLookset.trousersId, shoesId: currentLookset.shoesId)
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Успешно!", message: "Ващ стиль добавлен в гардероб", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allClothes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainClothesTableViewCell", for: indexPath) as! MainClothesTableViewCell
        cell.showClothesItemInfoDelegate = self

        cell.configure(id: allClothes[indexPath.row].id, name: allClothes[indexPath.row].name, description: allClothes[indexPath.row].description, category: allClothes[indexPath.row].category, tempMin: allClothes[indexPath.row].tempMin, tempMax: allClothes[indexPath.row].tempMax, image: allClothes[indexPath.row].image!)

        return cell
    }
}


extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return temps.count
    }
}


extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(temps[row])°C"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentTempValue = temps[row]
    }
}
