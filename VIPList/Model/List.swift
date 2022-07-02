//
//  List.swift
//  VIPList
//
//  Created by Ivan Ramirez on 4/12/22.
//


import Foundation
import CloudKit

class Exercise {
    var name: String
    var minuteCount: String?
    var recordID: CKRecord.ID
    
    //NOTE: - I'm passing in a recordID in the init
    init(name: String, minuteCount: String?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.minuteCount = minuteCount
        self.recordID = recordID
    }
}

//NOTE: - this is how we convert a cloud kit record and make sense of it in our project
extension Exercise {
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Constants.nameKey] as? String
        else { return nil }
        
        let minuteCount = ckRecord[Constants.minuteCountKey] as? String
        
        self.init(name: name, minuteCount: minuteCount, recordID: ckRecord.recordID)
    }
}

extension Exercise: Equatable {
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

//NOTE: - Exercise Object into CKRecord Object
extension CKRecord {
    convenience init(exercise: Exercise) {
        self.init(recordType: Constants.exerciseKey, recordID: exercise.recordID)
        self.setValue(exercise.name, forKey: Constants.nameKey)
        self.setValue(exercise.minuteCount, forKey: Constants.minuteCountKey)
    }
}
