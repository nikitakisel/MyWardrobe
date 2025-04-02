//
//  ImageClothesTableViewCell.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 02.04.2025.
//

import Foundation
import UIKit

class ImageClothesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var clothesSmalllImageView: UIImageView!
    @IBOutlet weak var clothesNameLabel: UILabel!
    @IBOutlet weak var clothesTempLabel: UILabel!
    @IBOutlet weak var clothesPhotoImageView: UIImageView!
    
    var info: Clothes = Clothes(id: -1, name: "", description: "", category: "", tempMin: -1, tempMax: 1, image: Data(base64Encoded: "")!)
    weak var showClothesItemInfoDelegate: ShowClothesItemInfoDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(id: Int, name: String, description: String, category: String, tempMin: Int, tempMax: Int, image: Data) {
        self.info.id = id
        self.info.name = name
        self.info.description = description
        self.info.category = category
        self.info.tempMin = tempMin
        self.info.tempMax = tempMax
        self.info.image = image
        self.setText()
    }
    
    func setText() {
        self.clothesNameLabel.text = self.info.name
        self.clothesTempLabel.text = "Температура: от \(self.info.tempMin)°C до \(self.info.tempMax)°C"
        
        switch (self.info.category) {
        case "Голова":
            self.clothesSmalllImageView.image = UIImage(systemName: "sunglasses.fill")
        case "Верхняя":
            self.clothesSmalllImageView.image = UIImage(systemName: "jacket.fill")
        case "Под верх":
            self.clothesSmalllImageView.image = UIImage(systemName: "tshirt.fill")
        case "Нижняя":
            self.clothesSmalllImageView.image = UIImage(systemName: "figure.highintensity.intervaltraining")
        case "Обувь":
            self.clothesSmalllImageView.image = UIImage(systemName: "shoe.fill")
        default:
            self.clothesSmalllImageView.image = UIImage(systemName: "person.fill")
        }
        
        self.clothesPhotoImageView.contentMode = .scaleAspectFill
        displayBase64Image(imageData: self.info.image, imageView: self.clothesPhotoImageView)
    }
    
    
    @IBAction func showClothesItemInfoButtonPressed(_ sender: UIButton) {
        self.showClothesItemInfoDelegate?.showClothesItemInfo(info: self.info)
    }
}

