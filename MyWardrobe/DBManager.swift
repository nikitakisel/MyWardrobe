//
//  DBManager.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 21.03.2025.
//

import Foundation
import UIKit
import SQLite3


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
    
    func update(id: Int, name: String, description: String, category: String, tempMin: Int, tempMax: Int, image: String) {
        let updateStatementString = "UPDATE Clothes SET name = ?, description = ?, category = ?, temp_min = ?, temp_max = ?, image = ? WHERE id = ?;"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(updateStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (description as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 3, (category as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 4, Int32(tempMin))
            sqlite3_bind_int(updateStatement, 5, Int32(tempMax))
            sqlite3_bind_text(updateStatement, 6, (image as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 7, Int32(id))
              
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
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
//                print("Query Result:")
//                print("\(id) | \(name) | \(description) | \(category) | \(tempMin) | \(tempMax)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return clothes
    }
    
    func selectByCategory(category: String) -> [Clothes] {
        let queryStatementString = "SELECT * FROM Clothes WHERE category = ?;"
        var queryStatement: OpaquePointer? = nil
        var clothes : [Clothes] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (category as NSString).utf8String, -1, nil)
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let description = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let category = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let tempMin = sqlite3_column_int(queryStatement, 4)
                let tempMax = sqlite3_column_int(queryStatement, 5)
                let image = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                
                clothes.append(Clothes(id: Int(id), name: name, description: description, category: category, tempMin: Int(tempMin), tempMax: Int(tempMax), image: (Data(base64Encoded: image)!)))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return clothes
    }
    
    func selectDice(currentTemp: Int) -> [Clothes] {
        var finallySet: [Clothes] = []
        var potentialClothes: [Clothes]
        
        for category in ["Голова", "Верхняя", "Под верх", "Нижняя", "Обувь"] {
            let queryStatementString = "SELECT * FROM Clothes WHERE category = ? AND temp_min <= ? AND temp_max >= ?;"
            var queryStatement: OpaquePointer? = nil
            potentialClothes = []
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                sqlite3_bind_text(queryStatement, 1, (category as NSString).utf8String, -1, nil)
                sqlite3_bind_int(queryStatement, 2, Int32(currentTemp))
                sqlite3_bind_int(queryStatement, 3, Int32(currentTemp))
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    
                    let id = sqlite3_column_int(queryStatement, 0)
                    let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                    let description = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                    let category = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                    let tempMin = sqlite3_column_int(queryStatement, 4)
                    let tempMax = sqlite3_column_int(queryStatement, 5)
                    let image = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                    
                    potentialClothes.append(Clothes(id: Int(id), name: name, description: description, category: category, tempMin: Int(tempMin), tempMax: Int(tempMax), image: (Data(base64Encoded: image)!)))
                }
                
                if let randomIndex = potentialClothes.indices.randomElement() {
                    finallySet.append(potentialClothes[randomIndex])
                }
                
            } else {
                print("SELECT statement could not be prepared")
            }
            sqlite3_finalize(queryStatement)
        }
        
        return finallySet
    }
      
    func deleteByID(id: Int) {
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
