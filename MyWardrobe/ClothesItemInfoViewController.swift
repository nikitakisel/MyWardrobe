//
//  ClothesItemInfoViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 19.03.2025.
//

import Foundation
import UIKit

protocol UploadInfoDelegate: AnyObject {
    func uploadInfo(info: Clothes)
}

class ClothesItemInfoViewController: UIViewController, AddNewClothesDelegate, UploadInfoDelegate {
    
    
    @IBOutlet weak var clothesItemImageView: UIImageView!
    @IBOutlet weak var clothesItemNameLabel: UILabel!
    @IBOutlet weak var clothesItemDescriptionLabel: UILabel!
    @IBOutlet weak var clothesItemTempsLabel: UILabel!
    
    var info: Clothes = Clothes(id: -1, name: "", description: "", category: "", tempMin: -1, tempMax: 1, image: Data(base64Encoded: "")!)
    weak var addNewClothesDelegate: AddNewClothesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func uploadInfo(info: Clothes) {
        DispatchQueue.main.async {
            self.info.copy(info)
            self.clothesItemNameLabel.text = self.info.name
            self.clothesItemDescriptionLabel.text = self.info.description
            self.clothesItemTempsLabel.text = "Температура: от \(self.info.tempMin)°C до \(self.info.tempMax)°C"
            displayBase64Image(imageData: self.info.image, imageView: self.clothesItemImageView)
        }
    }
    
    func updateAllClothesTable() {
        self.addNewClothesDelegate?.updateAllClothesTable()
    }
    
    
    @IBAction func editClothesItemButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let addClothesVC = sb.instantiateViewController(withIdentifier: "AddClothesViewController") as! AddClothesViewController
        addClothesVC.startClothesEditing(clothesInfo: info)
        addClothesVC.addNewClothesDelegate = self
        addClothesVC.uploadInfoDelegate = self
        
        navigationController?.pushViewController(addClothesVC, animated: true)
    }
    
    @IBAction func deleteClothesItemButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Удаление", message: "Вы уверены, что хотите удалить данную вещь?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
                self?.deleteClothesItem()
            }))

            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteClothesItem() {
        let dbConnection = DBManager()
        dbConnection.deleteByID(id: self.info.id)
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Успешно", message: "Выбранная вещь удалена!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: { [weak self] _ in
                self?.addNewClothesDelegate?.updateAllClothesTable()
                self?.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


func displayBase64Image(imageData: Data?, imageView: UIImageView) {
    if let image = imageData {
        imageView.image = UIImage(data: image) // imageView - ваш UIImageView
        imageView.contentMode = .scaleAspectFill
    } else {
        // Обработка ошибки:
        print("Ошибка: Не удалось создать изображение из предоставленных данных.")
        // Например, можно установить placeholder image:
        imageView.image = UIImage(systemName: "newspaper")
    }
}
