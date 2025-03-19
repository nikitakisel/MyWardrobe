//
//  ViewController.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 18.03.2025.
//

import UIKit
import SQLite3


struct Clothes {
    var id: Int
    var name: String
    var description: String
    var category: String
    var tempMin: Int
    var tempMax: Int
    var image: Data
}


class DBManager
{
    init() {
        db = openDatabase()
        createTable()
    }
  
    let dbPath: String = "MainDB.sqlite"
    var db: OpaquePointer?
  
    func openDatabase() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(filePath.path, &db) != SQLITE_OK
        {
            debugPrint("can't open database")
            return nil
        }
        else
        {
            print("Successfully created connection to database at \(dbPath)")
            return db
        }
    }
      
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Clothes (id INTEGER PRIMARY KEY NOT NULL, name TEXT NOT NULL, description TEXT, category TEXT NOT NULL, temp_min INTEGER NOT NULL, temp_max INTEGER NOT NULL, image TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("clothes table created.")
            } else {
                print("clothes table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
      
      
    func insert(name: String, description: String, category: String, tempMin: Int, tempMax: Int, image: String) {
        let insertStatementString = "INSERT INTO Clothes (name, description, category, temp_min, temp_max, image) VALUES (?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (description as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (category as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(tempMin))
            sqlite3_bind_int(insertStatement, 5, Int32(tempMax))
            sqlite3_bind_text(insertStatement, 6, (image as NSString).utf8String, -1, nil)
              
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
      
    func read() -> [Clothes] {
        let queryStatementString = "SELECT * FROM Clothes;"
        var queryStatement: OpaquePointer? = nil
        var clothes : [Clothes] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let description = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let category = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let tempMin = sqlite3_column_int(queryStatement, 4)
                let tempMax = sqlite3_column_int(queryStatement, 5)
                let image = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                
                clothes.append(Clothes(id: Int(id), name: name, description: description, category: category, tempMin: Int(tempMin), tempMax: Int(tempMax), image: (Data(base64Encoded: image)!)))
                print("Query Result:")
                print("\(id) | \(name) | \(description) | \(category) | \(tempMin) | \(tempMax)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return clothes
    }
      
    func deleteByID(id:Int) {
        let deleteStatementStirng = "DELETE FROM Clothes WHERE id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
      
}


protocol AddNewClothesDelegate: AnyObject {
    func updateAllClothesTable()
}

protocol ShowClothesItemInfoDelegate: AnyObject {
    func showClothesItemInfo(vc: UIViewController)
}


class ViewController: UIViewController, AddNewClothesDelegate, ShowClothesItemInfoDelegate {
    
    
    @IBOutlet weak var clothesTableView: UITableView!
    var dbConnection = DBManager()
    var allClothes: [Clothes] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clothesTableView.delegate = self
        clothesTableView.dataSource = self
        
        let nib = UINib(nibName: "MainClothesTableViewCell", bundle: nil)
        clothesTableView.register(nib, forCellReuseIdentifier: "MainClothesTableViewCell")
        
        updateAllClothesTable()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func updateAllClothesTable() {
        self.allClothes = dbConnection.read()
        self.clothesTableView.reloadData()
    }
    
    func showClothesItemInfo(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addClothesButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let addClothesVC = sb.instantiateViewController(withIdentifier: "AddClothesViewController") as! AddClothesViewController
        addClothesVC.addNewClothesDelegate = self
        
        navigationController?.pushViewController(addClothesVC, animated: true)
    }
}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allClothes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainClothesTableViewCell", for: indexPath) as! MainClothesTableViewCell
        cell.showClothesItemInfoDelegate = self

        cell.configure(id: allClothes[indexPath.row].id, name: allClothes[indexPath.row].name, description: allClothes[indexPath.row].description, category: allClothes[indexPath.row].category, tempMin: allClothes[indexPath.row].tempMin, tempMax: allClothes[indexPath.row].tempMax, image: allClothes[indexPath.row].image)

        return cell
    }
}


