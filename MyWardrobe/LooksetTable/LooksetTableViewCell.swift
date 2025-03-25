//
//  LooksetTableViewCell.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 24.03.2025.
//

import Foundation
import UIKit

class LooksetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var setNameLabel: UILabel!
    @IBOutlet weak var setTempLabel: UILabel!
    @IBOutlet weak var setCreationTimeLabel: UILabel!
    
    weak var deleteLooksetDelegate: DeleteLooksetDelegate?
    weak var showSelectedLooksetDelegate: ShowSelectedLooksetDelegate?
    
    var looksetInfo: Lookset = Lookset(id: -1, looksetName: "", looksetDescription: "", looksetTemp: 0, headId: -1, jacketId: -1, tshirtId: -1, trousersId: -1, shoesId: -1, creationTime: "")
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(id: Int, looksetName: String, looksetDescription: String, looksetTemp: Int, headId: Int, jacketId: Int, tshirtId: Int, trousersId: Int, shoesId: Int, creationTime: String) {
        self.looksetInfo.id = id
        self.looksetInfo.looksetName = looksetName
        self.looksetInfo.looksetDescription = looksetDescription
        self.looksetInfo.looksetTemp = looksetTemp
        
        self.looksetInfo.headId = headId
        self.looksetInfo.jacketId = jacketId
        self.looksetInfo.tshirtId = tshirtId
        self.looksetInfo.trousersId = trousersId
        self.looksetInfo.shoesId = shoesId
        self.looksetInfo.creationTime = creationTime
        
        self.setNameLabel.text = self.looksetInfo.looksetName == "" ? "Набор \(self.looksetInfo.id)" : self.looksetInfo.looksetName
        self.setTempLabel.text = "Рекомендовано при \(self.looksetInfo.looksetTemp)°C"
        self.setCreationTimeLabel.text = "Дата и время: \(self.looksetInfo.creationTime)"
    }
    
    
    @IBAction func deleteLooksetButtonPressed(_ sender: UIButton) {
        deleteLooksetDelegate?.offerToDeleteLooksetItem(id: self.looksetInfo.id)
    }
    
    
    @IBAction func showLooksetInfoButtonPressed(_ sender: UIButton) {
        showSelectedLooksetDelegate?.showSelectedLookset(currentLookset: looksetInfo)
    }
}
