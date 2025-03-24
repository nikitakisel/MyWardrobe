//
//  LooksetViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 24.03.2025.
//

import Foundation
import UIKit

class LooksetViewController: UIViewController {
    
    @IBOutlet weak var looksetTableView: UITableView!
    
    var dbConnection = DBManager()
    var allLookset: [Lookset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        looksetTableView.delegate = self
        looksetTableView.dataSource = self
        
        let nib = UINib(nibName: "LooksetTableViewCell", bundle: nil)
        looksetTableView.register(nib, forCellReuseIdentifier: "LooksetTableViewCell")
        
        updateLooksetTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func updateLooksetTable() {
        self.allLookset = dbConnection.readLookset()
        self.looksetTableView.reloadData()
    }
}

extension LooksetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
}

extension LooksetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLookset.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LooksetTableViewCell", for: indexPath) as! LooksetTableViewCell

        cell.configure(id: allLookset[indexPath.row].id, looksetName: allLookset[indexPath.row].looksetName, looksetDescription: allLookset[indexPath.row].looksetDescription, looksetTemp: allLookset[indexPath.row].looksetTemp, headId: allLookset[indexPath.row].headId, jacketId: allLookset[indexPath.row].jacketId, tshirtId: allLookset[indexPath.row].tshirtId, trousersId: allLookset[indexPath.row].trousersId, shoesId: allLookset[indexPath.row].shoesId, creationTime: allLookset[indexPath.row].creationTime)

        return cell
    }
}
