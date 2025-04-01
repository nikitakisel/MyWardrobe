//
//  JSONManager.swift
//  MyWardrobe
//
//  Created by Никита Киселев on 30.03.2025.
//

import Foundation
import UIKit

class JSONManager {
    static func saveClothesToJson(object: Clothes, filename: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                try data.write(to: fileURL)
                print("Saved to \(fileURL)")
            }
        } catch {
            print("Error encoding: \(error)")
        }
    }

    static func saveLooksetToJson(object: Lookset, filename: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                try data.write(to: fileURL)
                print("Saved to \(fileURL)")
            }
        } catch {
            print("Error encoding: \(error)")
        }
    }

    static func loadClothesFromJson(filename: String) -> Clothes? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let object = try decoder.decode(Clothes.self, from: data)
                return object
            } catch {
                print("Error decoding: \(error)")
                return nil
            }
        }
        return nil
    }

    static func loadLooksetFromJson(filename: String) -> Lookset? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let object = try decoder.decode(Lookset.self, from: data)
                return object
            } catch {
                print("Error decoding: \(error)")
                return nil
            }
        }
        return nil
    }
}
