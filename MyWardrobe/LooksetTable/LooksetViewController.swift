//
//  LooksetViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 24.03.2025.
//

import Foundation
import UIKit


protocol DeleteLooksetDelegate: AnyObject {
    func offerToDeleteLooksetItem(id: Int)
}


protocol UpdateLooksetDelegate: AnyObject {
    func updateLooksetTable()
}


class LooksetViewController: UIViewController, DeleteLooksetDelegate, ShowSelectedLooksetDelegate, UpdateLooksetDelegate {
    
    @IBOutlet weak var looksetTableView: UITableView!
    
    var dbConnection = DBManager()
    var allLookset: [Lookset] = []
    weak var showSelectedLooksetDelegate: ShowSelectedLooksetDelegate?
    
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
    
    
    @IBAction func addLooksetButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let addLooksetVC = sb.instantiateViewController(withIdentifier: "AddLooksetViewController") as! AddLooksetViewController
        addLooksetVC.updateLooksetDelegate = self
        
        navigationController?.pushViewController(addLooksetVC, animated: true)
    }
    
    
    func updateLooksetTable() {
        self.allLookset = dbConnection.readLookset()
        self.looksetTableView.reloadData()
    }
    
    func offerToDeleteLooksetItem(id: Int) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Удаление", message: "Вы уверены, что хотите удалить данный набор?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
                self?.deleteLooksetItem(id: id)
            }))

            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteLooksetItem(id: Int) {
        dbConnection.deleteByIDFromLookset(id: id)
        self.updateLooksetTable()
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Успешно!", message: "Выбранный набор одежды удалён", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showSelectedLookset(currentLookset: Lookset) {
        showSelectedLooksetDelegate?.showSelectedLookset(currentLookset: currentLookset)
        navigationController?.popViewController(animated: true)
    }
}

extension LooksetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}

extension LooksetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLookset.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LooksetTableViewCell", for: indexPath) as! LooksetTableViewCell
        cell.deleteLooksetDelegate = self
        cell.showSelectedLooksetDelegate = self

        cell.configure(id: allLookset[indexPath.row].id, looksetName: allLookset[indexPath.row].looksetName, looksetDescription: allLookset[indexPath.row].looksetDescription, looksetTemp: allLookset[indexPath.row].looksetTemp, headId: allLookset[indexPath.row].headId, jacketId: allLookset[indexPath.row].jacketId, tshirtId: allLookset[indexPath.row].tshirtId, trousersId: allLookset[indexPath.row].trousersId, shoesId: allLookset[indexPath.row].shoesId, creationTime: allLookset[indexPath.row].creationTime)

        return cell
    }
}
