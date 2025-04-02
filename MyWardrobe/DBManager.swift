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
        createTableClothes()
        createTableLookset()
    }
  
    let dbPath: String = "MainDB.sqlite"
    var db: OpaquePointer?
    
    func getCurrentTime() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let formattedDate = dateFormatter.string(from: currentDate)
        return formattedDate
    }
  
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
      
    func createTableClothes() {
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
      
    func createTableLookset() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Lookset (id INTEGER PRIMARY KEY NOT NULL, lookset_name TEXT NOT NULL, lookset_description TEXT NOT NULL, lookset_temp INTEGER NOT NULL, head_id INTEGER NOT NULL, jacket_id INTEGER NOT NULL, tshirt_id INTEGER NOT NULL, trousers_id INTEGER NOT NULL, shoes_id INTEGER NOT NULL, creation_time TEXT NOT NULL);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("look table created.")
            } else {
                print("look table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
      
    func insertIntoClothes(name: String, description: String, category: String, tempMin: Int, tempMax: Int, image: String) {
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
    
    func insertIntoLookset(looksetName: String, looksetDescription: String, looksetTemp: Int, headId: Int, jacketId: Int, tshirtId: Int, trousersId: Int, shoesId: Int) {
        let insertStatementString = "INSERT INTO Lookset (lookset_name, lookset_description, lookset_temp, head_id, jacket_id, tshirt_id, trousers_id, shoes_id, creation_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertStatement, 1, (looksetName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (looksetDescription as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 3, Int32(looksetTemp))
            sqlite3_bind_int(insertStatement, 4, Int32(headId))
            sqlite3_bind_int(insertStatement, 5, Int32(jacketId))
            sqlite3_bind_int(insertStatement, 6, Int32(tshirtId))
            sqlite3_bind_int(insertStatement, 7, Int32(trousersId))
            sqlite3_bind_int(insertStatement, 8, Int32(shoesId))
            sqlite3_bind_text(insertStatement, 9, (getCurrentTime() as NSString).utf8String, -1, nil)
              
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
    
    func updateClothes(id: Int, name: String, description: String, category: String, tempMin: Int, tempMax: Int, image: String) {
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
    
    func updateLookset(id: Int, looksetName: String, looksetDescription: String, looksetTemp: Int, headId: Int, jacketId: Int, tshirtId: Int, trousersId: Int, shoesId: Int) {
        let updateStatementString = "UPDATE Lookset SET lookset_name = ?, lookset_description = ?, lookset_temp = ?, head_id = ?, jacket_id = ?, tshirt_id = ?, trousers_id = ?, shoes_id = ? WHERE id = ?;"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(updateStatement, 1, (looksetName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (looksetDescription as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 3, Int32(looksetTemp))
            sqlite3_bind_int(updateStatement, 4, Int32(headId))
            sqlite3_bind_int(updateStatement, 5, Int32(jacketId))
            sqlite3_bind_int(updateStatement, 6, Int32(tshirtId))
            sqlite3_bind_int(updateStatement, 7, Int32(trousersId))
            sqlite3_bind_int(updateStatement, 8, Int32(shoesId))
            sqlite3_bind_int(updateStatement, 9, Int32(id))
              
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
    
      
    func readClothes() -> [Clothes] {
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
    
    func readLookset() -> [Lookset] {
        let queryStatementString = "SELECT * FROM Lookset;"
        var queryStatement: OpaquePointer? = nil
        var lookset : [Lookset] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = sqlite3_column_int(queryStatement, 0)
                let looksetName = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let looksetDescription = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let looksetTemp = sqlite3_column_int(queryStatement, 3)
                
                let headId = sqlite3_column_int(queryStatement, 4)
                let jacketId = sqlite3_column_int(queryStatement, 5)
                let tshirtId = sqlite3_column_int(queryStatement, 6)
                let trousersId = sqlite3_column_int(queryStatement, 7)
                let shoesId = sqlite3_column_int(queryStatement, 8)
                let creationTime = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                
                lookset.append(Lookset(id: Int(id), looksetName: looksetName, looksetDescription: looksetDescription, looksetTemp: Int(looksetTemp), headId: Int(headId), jacketId: Int(jacketId), tshirtId: Int(tshirtId), trousersId: Int(trousersId), shoesId: Int(shoesId), creationTime: creationTime))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return lookset
    }
    
    func unpackLooksetToArray(looksetClass: Lookset) -> [Clothes] {
        var unpackedLookset: [Clothes] = []
        let clothesIndexes: [Int] = [looksetClass.headId, looksetClass.jacketId, looksetClass.tshirtId, looksetClass.trousersId, looksetClass.shoesId].filter { $0 != -1 }
        
        for index in clothesIndexes {
            let currentClothes = selectClothesById(id: index)
            if currentClothes.id != -1 {
                unpackedLookset.append(currentClothes)
            }
        }
        
        return unpackedLookset
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
    
    func selectByCategoryAndTemp(category: String, temp: Int) -> [Clothes] {
        let queryStatementString = "SELECT * FROM Clothes WHERE category = ? AND temp_min <= ? AND temp_max >= ?;"
        var queryStatement: OpaquePointer? = nil
        var clothes : [Clothes] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (category as NSString).utf8String, -1, nil)
            sqlite3_bind_int(queryStatement, 2, Int32(temp))
            sqlite3_bind_int(queryStatement, 3, Int32(temp))
            
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
    
    func selectClothesById(id: Int) -> Clothes {
        let queryStatementString = "SELECT * FROM Clothes WHERE id = ?;"
        var queryStatement: OpaquePointer? = nil
        var clothes: Clothes = Clothes(id: -1, name: "N/A", description: "undefined", category: "", tempMin: -1, tempMax: 1, image: Data(base64Encoded: "")!)
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(id))
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let description = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let category = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                let tempMin = sqlite3_column_int(queryStatement, 4)
                let tempMax = sqlite3_column_int(queryStatement, 5)
                let image = String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                
                clothes = Clothes(id: Int(id), name: name, description: description, category: category, tempMin: Int(tempMin), tempMax: Int(tempMax), image: (Data(base64Encoded: image)!))
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
      
    func deleteByIDFromClothes(id: Int) {
        deleteByID(id: id, tableName: "Clothes")
    }
    
    func deleteByIDFromLookset(id: Int) {
        deleteByID(id: id, tableName: "Lookset")
    }
    
    func deleteByID(id: Int, tableName: String) {
        let deleteStatementStirng = "DELETE FROM \(tableName) WHERE id = ?;"
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
    
    func clearTableClothes() {
        clearOrDropTable(statement: "DELETE FROM Clothes;")
    }
    
    func clearTableLookset() {
        clearOrDropTable(statement: "DELETE FROM Lookset;")
    }
    
    func dropTableLookset() {
        clearOrDropTable(statement: "DROP TABLE Lookset;")
    }
    
    func clearOrDropTable(statement: String) {
        let clearOrDropTableString = statement
        var clearOrDropTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, clearOrDropTableString, -1, &clearOrDropTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(clearOrDropTableStatement) == SQLITE_DONE
            {
                print("current table cleared or dropped.")
            } else {
                print("current table could not be cleared or dropped.")
            }
        } else {
            print("DELETE FROM/DROP TABLE statement could not be prepared.")
        }
        sqlite3_finalize(clearOrDropTableStatement)
    }
}
