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
    private enum FileErrors:ErrorType {
        case JsonNotSerialized
        case FileNotSaved
        
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
    private let directory:NSSearchPathDirectory
    private let directoryPath: String
    private let fileManager = NSFileManager.defaultManager()
    private let fileName:String
    private let filePath:String
    private let fullyQualifiedPath:String
    private let subDirectory:String
    
    //1
    var fileExists:Bool {
        get {
            return fileManager.fileExistsAtPath(fullyQualifiedPath)
        }
    }
    
    var directoryExists:Bool {
        get {
            var isDir = ObjCBool(true)
            return fileManager.fileExistsAtPath(filePath, isDirectory: &isDir )
        }
    }
    
    //2
    init(fileName:String, fileExtension:FileExension, subDirectory:String, directory:NSSearchPathDirectory){
        self.fileName = fileName + fileExtension.rawValue
        self.subDirectory = "/\(subDirectory)"
        self.directory = directory
        //3
        self.directoryPath = NSSearchPathForDirectoriesInDomains(directory, .UserDomainMask, true)[0]
        self.filePath = directoryPath + self.subDirectory
        self.fullyQualifiedPath = "\(filePath)/\(self.fileName)"
        //4
        print(self.directoryPath)
        createDirectory()
    }
    
    private func createDirectory(){
        //1
        if !directoryExists {
            do {
                //2
                try fileManager.createDirectoryAtPath(filePath, withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                print("An Error was generated creating directory")
            }
        }
    }
    
    //1
    func saveFile(string fileContents:String) throws{
        do {
            //2
            try fileContents.writeToFile(fullyQualifiedPath, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch  {
            //3
            throw error
        }
    }
    
    //for json file
    //1
    func saveFile(dataForJson dataForJson:AnyObject) throws{
        do {
            //2
            let jsonData = try convertObjectToData(dataForJson)
            if !fileManager.createFileAtPath(fullyQualifiedPath, contents: jsonData, attributes: nil){
                throw FileErrors.FileNotSaved
            }
        } catch {
            //3
            print(error)
            throw FileErrors.FileNotSaved
        }
        
    }
    
    //4
    private func convertObjectToData(data:AnyObject) throws -> NSData {
        
        do {
            //5
            let newData = try NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
            return newData
        }
            //6
        catch {
            print("Error writing data: \(error)")
        }
        throw FileErrors.JsonNotSerialized
    }
}