//
//  MainClothesTableViewCell.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 18.03.2025.
//

import Foundation
import UIKit

class MainClothesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var clothesSmalllImageView: UIImageView!
    @IBOutlet weak var clothesNameLabel: UILabel!
    @IBOutlet weak var clothesDescriptionLabel: UILabel!
    @IBOutlet weak var clothesTempLabel: UILabel!
    
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
        self.clothesDescriptionLabel.text = self.info.description
        self.clothesTempLabel.text = "Температура: от \(self.info.tempMin)°C до \(self.info.tempMax)°C"
        
        switch (self.info.category) {
        case "Голова":
            self.clothesSmalllImageView.image = UIImage(systemName: "sunglasses.fill")
        case "Верхняя":
            self.clothesSmalllImageView.image = UIImage(systemName: "jacket.fill")
        case "Под верх":
            self.clothesSmalllImageView.image = UIImage(systemName: "tshirt.fill")
        case "Обувь":
            self.clothesSmalllImageView.image = UIImage(systemName: "shoe.fill")
        default:
            self.clothesSmalllImageView.image = UIImage(systemName: "person.fill")
        }
    }
    
    
    @IBAction func showClothesItemInfoButtonPressed(_ sender: UIButton) {
        self.showClothesItemInfoDelegate?.showClothesItemInfo(info: self.info)
    }
}
