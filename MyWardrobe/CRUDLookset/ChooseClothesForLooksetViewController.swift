//
//  ChooseClothesForLooksetViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 25.03.2025.
//

import Foundation
import UIKit


class ChooseClothesForLooksetViewController: UIViewController, AddClothesForLooksetDelegate {
    
    @IBOutlet weak var chooseClothesTableView: UITableView!
    weak var addClothesForLooksetDelegate: AddClothesForLooksetDelegate?
    var clothesForChoosing: [Clothes] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chooseClothesTableView.delegate = self
        chooseClothesTableView.dataSource = self
        
        let nib = UINib(nibName: "ChooseClothesForLooksetTableViewCell", bundle: nil)
        chooseClothesTableView.register(nib, forCellReuseIdentifier: "ChooseClothesForLooksetTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func updateChooseClothesTable(clothesForChoosing: [Clothes]) {
        DispatchQueue.main.async {
            self.clothesForChoosing = clothesForChoosing
            self.chooseClothesTableView.reloadData()
        }
    }
    
    func addClothesForLooksetDelegate(clothesItem: Clothes) {
        self.addClothesForLooksetDelegate?.addClothesForLooksetDelegate(clothesItem: clothesItem)
        navigationController?.popViewController(animated: true)
    }
}


extension ChooseClothesForLooksetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
}

extension ChooseClothesForLooksetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clothesForChoosing.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseClothesForLooksetTableViewCell", for: indexPath) as! ChooseClothesForLooksetTableViewCell
        cell.addClothesForLooksetDelegate = self

        cell.configure(id: clothesForChoosing[indexPath.row].id, name: clothesForChoosing[indexPath.row].name, description: clothesForChoosing[indexPath.row].description, category: clothesForChoosing[indexPath.row].category, tempMin: clothesForChoosing[indexPath.row].tempMin, tempMax: clothesForChoosing[indexPath.row].tempMax, image: clothesForChoosing[indexPath.row].image!)

        return cell
    }
}
