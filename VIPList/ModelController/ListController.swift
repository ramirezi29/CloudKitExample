//
//  ListController.swift
//  VIPList
//
//  Created by Ivan Ramirez on 4/12/22.
//

import Foundation
import CloudKit

class ExerciseController {
    
    static let shared = ExerciseController()
    
    var exercises: [Exercise] = []
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: - Save
    func saveExercise(with name: String, minuteCount: String?, completion: @escaping (Bool) -> Void) {
        
        let newExercise = Exercise(name: name, minuteCount: minuteCount)
        
        let exerciseRecord = CKRecord(exercise: newExercise)
        
        //lets save n
        publicDB.save(exerciseRecord) { record, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)\n---\n ")
                completion(false)
                return
            }
            
            //make sure the records are valid
            guard let record = record, let saveRecord = Exercise(ckRecord: record) else {
                print("Error in \(#function) : \n---\n \(String(describing: error))")
                completion(false)
                return completion(false)
            }
            
            //append to our array if successful
            self.exercises.append(saveRecord)
            completion(true)
        }
    }
    
    // MARK: - fetch
    func fetchExercise(completion: @escaping (Result<[Exercise]?, ExerciseError>) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: Constants.exerciseKey, predicate: predicate)
        
        var operation = CKQueryOperation(query: query)
        
        var fetchedExercises: [Exercise] = []
        
        operation.recordMatchedBlock = { (_, result) in
            
            switch result {
                
            case .success(let record):
                guard let fetchedExercise = Exercise(ckRecord: record) else {
                    return completion(.failure(.noRecord))
                }
                fetchedExercises.append(fetchedExercise)
                
                
            case .failure(let error):
                print(error.localizedDescription)
                return completion(.failure(.ckError(error)))
            }
            print("Inside operation.recordMatchBlock Switch")
        }
        
        // look for records that match query
        operation.queryResultBlock = { result in
            
            switch result {
                
            case .success(let cursor):
                if let cursor = cursor {
                    let nextOperation = CKQueryOperation(cursor: cursor)
                    
                    nextOperation.queryResultBlock = operation.queryResultBlock
                    
                    nextOperation.recordMatchedBlock = operation.recordMatchedBlock
                    
                    nextOperation.qualityOfService = .userInteractive
                    
                    operation = nextOperation
                    
                    self.publicDB.add(nextOperation)
                } else {
                    
                    print(fetchedExercises.description)
                    return completion(.success(fetchedExercises))
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                return completion(.failure(.ckError(error)))
            }
            print("Inside operation query block switch")
        }
        publicDB.add(operation)
    }
    
    // MARK: - Delete
    func delete(_ contact: Exercise, completion: @escaping (Bool) -> Void) {
        let operation = CKModifyRecordsOperation(recordIDsToDelete: [contact.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                print("Record removed")
                return completion(true)
            case .failure(_):
                print("Issue attempting to delete record")
                return completion(false)
            }
        }
        publicDB.add(operation)
    }
}
