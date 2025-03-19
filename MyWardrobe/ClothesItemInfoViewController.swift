//
//  ClothesItemInfoViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 19.03.2025.
//

import Foundation
import UIKit

class ClothesItemInfoViewController: UIViewController {
    
    
    @IBOutlet weak var clothesItemImageView: UIImageView!
    @IBOutlet weak var clothesItemNameLabel: UILabel!
    @IBOutlet weak var clothesItemDescriptionLabel: UILabel!
    @IBOutlet weak var clothesItemTempsLabel: UILabel!
    
    var info: Clothes = Clothes(id: -1, name: "", description: "", category: "", tempMin: -1, tempMax: 1, image: Data(base64Encoded: "")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clothesItemImageView.contentMode = .scaleAspectFill
    }
    
    func uploadInfo(info: Clothes) {
        self.info = info
        self.initialize()
    }
    
    func initialize() {
        self.clothesItemImageView.image = UIImage(data: self.info.image)
        self.clothesItemNameLabel.text = self.info.name
        self.clothesItemDescriptionLabel.text = self.info.description
        self.clothesItemTempsLabel.text = "Температура: от \(self.info.tempMin)°C до \(self.info.tempMax)°C"
    }
}
