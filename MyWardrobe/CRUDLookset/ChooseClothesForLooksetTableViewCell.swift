//
//  ChooseClothesForLooksetTableViewCell.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 25.03.2025.
//

import Foundation
import UIKit


class ChooseClothesForLooksetTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var chooseClothesNameLabel: UILabel!
    @IBOutlet weak var chooseClothesImageView: UIImageView!
    var clothesInfo: Clothes = Clothes(id: -1, name: "", description: "", category: "", tempMin: -1, tempMax: 1, image: Data(base64Encoded: "")!)
    weak var addClothesForLooksetDelegate: AddClothesForLooksetDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(id: Int, name: String, description: String, category: String, tempMin: Int, tempMax: Int, image: Data) {
        self.clothesInfo.id = id
        self.clothesInfo.name = name
        self.clothesInfo.description = description
        self.clothesInfo.category = category
        self.clothesInfo.tempMin = tempMin
        self.clothesInfo.tempMax = tempMax
        self.clothesInfo.image = image
        
        self.chooseClothesNameLabel.text = self.clothesInfo.name
        self.chooseClothesImageView.contentMode = .scaleAspectFill
        displayBase64Image(imageData: self.clothesInfo.image, imageView: self.chooseClothesImageView)
    }
    
    
    @IBAction func acceptClothesButtonPressed(_ sender: UIButton) {
        self.addClothesForLooksetDelegate?.addClothesForLooksetDelegate(clothesItem: self.clothesInfo)
    }
}
