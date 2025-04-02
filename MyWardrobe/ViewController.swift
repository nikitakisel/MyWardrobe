//
//  ViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 18.03.2025.
//

import UIKit
import UniformTypeIdentifiers


struct Clothes: Codable {
    var id: Int
    var name: String
    var description: String
    var category: String
    var tempMin: Int
    var tempMax: Int
    var image: Data?
}


struct Lookset: Codable {
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


struct JsonData: Codable {
    let clothes: [Clothes]
    let looksets: [Lookset]
}


protocol AddNewClothesDelegate: AnyObject {
    func updateAllClothesTable()
}

protocol ShowClothesItemInfoDelegate: AnyObject {
    func showClothesItemInfo(info: Clothes)
}

protocol ShowSelectedLooksetDelegate: AnyObject {
    func showSelectedLookset(currentLookset: Lookset)
}

class ViewController: UIViewController, AddNewClothesDelegate, ShowClothesItemInfoDelegate, ShowSelectedLooksetDelegate, UIDocumentPickerDelegate {
    
    @IBOutlet weak var clothesTableView: UITableView!
    @IBOutlet weak var clothesWithImageTableView: UITableView!
    @IBOutlet weak var currentTempPickerView: UIPickerView!
    @IBOutlet weak var saveLooksetButton: UIButton!
    
    var dbConnection = DBManager()
    var allClothes: [Clothes] = []
    var temps: [Int] = []
    var currentTempValue = 25
    var isClothesWithImageTableViewActivated = false
    
    //!!!!!!!
    var importedFilename: String = ""
    var exportedFilename: String = ""
    //!!!!!!!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveLooksetButton.isHidden = true
        
        clothesTableView.delegate = self
        clothesTableView.dataSource = self
        
        clothesWithImageTableView.dataSource = self
        clothesWithImageTableView.delegate = self
        
        currentTempPickerView.dataSource = self
        currentTempPickerView.delegate = self
        
        for i in -40...50 {
            temps.append(i)
        }
        temps.reverse()
        
        setCurrentTemp(currentTemp: 25)
        
        let clothesTableViewNib = UINib(nibName: "MainClothesTableViewCell", bundle: nil)
        clothesTableView.register(clothesTableViewNib, forCellReuseIdentifier: "MainClothesTableViewCell")
        
        let clothesWithImageTableViewNib = UINib(nibName: "ImageClothesTableViewCell", bundle: nil)
        clothesWithImageTableView.register(clothesWithImageTableViewNib, forCellReuseIdentifier: "ImageClothesTableViewCell")
        
        self.clothesWithImageTableView.isHidden = true
        self.clothesTableView.tag = 1
        self.clothesWithImageTableView.tag = 2
        
        updateAllClothesTable()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setCurrentTemp(currentTemp: Int) {
        if !temps.isEmpty {
            var defaultRow = 0
            
            if let elemIndex = temps.firstIndex(of: currentTemp) {
                defaultRow = elemIndex
                self.currentTempValue = currentTemp
            }
            self.currentTempPickerView.selectRow(defaultRow, inComponent: 0, animated: false)
        }
    }
    
    func updateAllClothesTable() {
        self.allClothes = dbConnection.readClothes()
        self.clothesTableView.reloadData()
        self.clothesWithImageTableView.reloadData()
    }
    
    func showClothesItemInfo(info: Clothes) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let clothesItemInfoVC = sb.instantiateViewController(withIdentifier: "ClothesItemInfoViewController") as! ClothesItemInfoViewController
        clothesItemInfoVC.addNewClothesDelegate = self
        
        sleep(1)
        clothesItemInfoVC.uploadInfo(info: info)
        navigationController?.pushViewController(clothesItemInfoVC, animated: true)
    }
    
    func showSelectedLookset(currentLookset: Lookset) {
        self.allClothes = dbConnection.unpackLooksetToArray(looksetClass: currentLookset)
        self.clothesTableView.reloadData()
        
        setCurrentTemp(currentTemp: currentLookset.looksetTemp)
        saveLooksetButton.isHidden = true
    }
    
    
    @IBAction func showCustomLooksetsButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let looksetVC = sb.instantiateViewController(withIdentifier: "LooksetViewController") as! LooksetViewController
        looksetVC.showSelectedLooksetDelegate = self
        
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
    
    
    @IBAction func saveDataButtonPressed(_ sender: UIButton) {
        do {
            let jsonData = JsonData(clothes: dbConnection.readClothes(), looksets: dbConnection.readLookset())
                let encoder = JSONEncoder()
                let data = try encoder.encode(jsonData)

                let tempDirURL = FileManager.default.temporaryDirectory
                let tempFileURL = tempDirURL.appendingPathComponent("data.json")
                try data.write(to: tempFileURL)

                let activityViewController = UIActivityViewController(activityItems: [tempFileURL], applicationActivities: nil)
                present(activityViewController, animated: true) {
                    
                    if let url = activityViewController.value(forKey: "activityItemsConfiguration") as? URL {  // Try to get the URL
                        self.exportedFilename = url.lastPathComponent  // Set the filename
                    } else {
                        self.exportedFilename = "Отменено пользователем"  // Indicate it was cancelled
                    }
                }
            self.alert(message: "Данные экспортированы")


            } catch {
                print("Ошибка сериализации или записи в файл: \(error)")
                exportedFilename = "Ошибка экспорта"
        }
    }
    
    
    @IBAction func uploadDataButtonPressed(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            importedFilename = "Ошибка: Файл не выбран"
            return
        }

        do {
            // 2. Проверяем, доступен ли файл
            let isSecuredURL = selectedFileURL.startAccessingSecurityScopedResource()

            // 3. Считываем данные из файла JSON
            let data = try Data(contentsOf: selectedFileURL)
            let decoder = JSONDecoder()

            do {
                let jsonData = try decoder.decode(JsonData.self, from: data)

                dbConnection.clearTableClothes()
                dbConnection.clearTableLookset()

                for item in jsonData.clothes {
                    dbConnection.insertIntoClothes(name: item.name, description: item.description, category: item.category, tempMin: item.tempMin, tempMax: item.tempMax, image: item.image!.base64EncodedString())
                }

                for item in jsonData.looksets {
                    dbConnection.insertIntoLookset(looksetName: item.looksetName, looksetDescription: item.looksetDescription, looksetTemp: item.looksetTemp, headId: item.headId, jacketId: item.jacketId, tshirtId: item.tshirtId, trousersId: item.trousersId, shoesId: item.shoesId)
                }

                // Stop accessing the resource:
                if isSecuredURL {
                    selectedFileURL.stopAccessingSecurityScopedResource()
                }

                // 5. Обновляем UI
                importedFilename = selectedFileURL.lastPathComponent // Set the filename.
                self.alert(message: "Данные импортированы")

            } catch let decodingError as DecodingError {
                // Обработка ошибки десериализации JSON
                print("Ошибка десериализации JSON: \(decodingError)")
                importedFilename = "Ошибка: Неправильный формат файла JSON"
                handleDecodingError(decodingError) // Вызываем функцию для детальной обработки ошибки
                self.error(message: "Неправильный формат файла JSON")
            } catch {
                // Обработка других ошибок (например, ошибка чтения файла)
                print("Ошибка чтения файла: \(error)")
                importedFilename = "Ошибка импорта"
                self.error(message: "Ошибка чтения файла")
            }
        } catch {
            print("Ошибка чтения или десериализации файла: \(error)")
            importedFilename = "Ошибка импорта"
            self.error(message: "Ошибка чтения или десериализации файла")
        }
    }

    // Функция для детальной обработки ошибок десериализации
    func handleDecodingError(_ error: DecodingError) {
        switch error {
        case .typeMismatch(let type, let context):
            print("Type mismatch: \(type) mismatch, codingPath: \(context.codingPath), debugDescription: \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            print("Value not found: \(type) not found, codingPath: \(context.codingPath), debugDescription: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            print("Key not found: \(key) not found, codingPath: \(context.codingPath), debugDescription: \(context.debugDescription)")
        case .dataCorrupted(let context):
            print("Data corrupted: codingPath: \(context.codingPath), debugDescription: \(context.debugDescription)")
        @unknown default:
            print("Unknown decoding error")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
        importedFilename = "Импорт отменен пользователем"
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
            let alert = UIAlertController(title: "Успешно!", message: "Ваш стиль добавлен в гардероб", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func swapTableViewsButtonPressed(_ sender: UIButton) {
        if self.isClothesWithImageTableViewActivated == false {
            self.clothesTableView.isHidden = true
            self.clothesWithImageTableView.isHidden = false
            self.isClothesWithImageTableViewActivated = true
        } else {
            self.clothesTableView.isHidden = false
            self.clothesWithImageTableView.isHidden = true
            self.isClothesWithImageTableViewActivated = false
        }
    }
    
    
    func alert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Успешно!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.updateAllClothesTable()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func error(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Ошибка!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 1 {
            return 80.0
        } else {
            return 260.0
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allClothes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainClothesTableViewCell", for: indexPath) as! MainClothesTableViewCell
            cell.showClothesItemInfoDelegate = self

            cell.configure(id: allClothes[indexPath.row].id, name: allClothes[indexPath.row].name, description: allClothes[indexPath.row].description, category: allClothes[indexPath.row].category, tempMin: allClothes[indexPath.row].tempMin, tempMax: allClothes[indexPath.row].tempMax, image: allClothes[indexPath.row].image!)

            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageClothesTableViewCell", for: indexPath) as! ImageClothesTableViewCell
            cell.showClothesItemInfoDelegate = self

            cell.configure(id: allClothes[indexPath.row].id, name: allClothes[indexPath.row].name, description: allClothes[indexPath.row].description, category: allClothes[indexPath.row].category, tempMin: allClothes[indexPath.row].tempMin, tempMax: allClothes[indexPath.row].tempMax, image: allClothes[indexPath.row].image!)

            return cell
        }
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
