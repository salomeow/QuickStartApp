//
//  FileSaveHelper.swift
//  QuickStartApp
//
//  Created by Wang Yujia on 13/9/16.
//  Copyright © 2016 National University of Singapore Design Centric Program. All rights reserved.
//

import Foundation


class FileSaveHelper {
    
    //1
    // MARK:- Error Types
    fileprivate enum FileErrors:Error {
        case jsonNotSerialized
        case fileNotSaved
        
    }
    
    //2
    // MARK:- File Extension Types
    enum FileExension:String {
        case TXT = ".txt"
        case JPG = ".jpg"
        case JSON = ".json"
    }
    
    //3
    // MARK:- Private Properties
    fileprivate let directory:FileManager.SearchPathDirectory
    fileprivate let directoryPath: String
    fileprivate let fileManager = FileManager.default
    fileprivate let fileName:String
    fileprivate let filePath:String
    fileprivate let fullyQualifiedPath:String
    fileprivate let subDirectory:String
    
    //1
    var fileExists:Bool {
        get {
            return fileManager.fileExists(atPath: fullyQualifiedPath)
        }
    }
    
    var directoryExists:Bool {
        get {
            var isDir = ObjCBool(true)
            return fileManager.fileExists(atPath: filePath, isDirectory: &isDir )
        }
    }
    
    //2
    init(fileName:String, fileExtension:FileExension, subDirectory:String, directory:FileManager.SearchPathDirectory){
        self.fileName = fileName + fileExtension.rawValue
        self.subDirectory = "/\(subDirectory)"
        self.directory = directory
        //3
        self.directoryPath = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0]
        self.filePath = directoryPath + self.subDirectory
        self.fullyQualifiedPath = "\(filePath)/\(self.fileName)"
        //4
        print(self.fullyQualifiedPath)
        createDirectory()
    }
    
    fileprivate func createDirectory(){
        //1
        if !directoryExists {
            do {
                //2
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                print("An Error was generated creating directory")
            }
        }
    }
    
    //1
//    func saveFile(string fileContents:String) throws{
//        do {
//            //2
//            try fileContents.writeToFile(fullyQualifiedPath, atomically: true, encoding: NSUTF8StringEncoding)
//        }
//        catch  {
//            //3
//            throw error
//        }
//    }
    
    //for json file
    //1
    func saveFile(dataForJson:AnyObject) throws{
        do {
            //2
            let jsonData = try convertObjectToData(dataForJson)
            if !fileManager.createFile(atPath: fullyQualifiedPath, contents: jsonData, attributes: nil){
                print(fullyQualifiedPath)
                print(self.fileName)
                throw FileErrors.fileNotSaved
                
            }
        } catch {
            //3
            print(error)
            throw FileErrors.fileNotSaved
        }
        
    }
    
    //4
    fileprivate func convertObjectToData(_ data:AnyObject) throws -> Data {
        
        do {
            //5
            let newData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            return newData
        }
            //6
        catch {
            print("Error writing data: \(error)")
        }
        throw FileErrors.jsonNotSerialized
    }
}
