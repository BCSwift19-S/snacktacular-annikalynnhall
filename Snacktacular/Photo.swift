//
//  Photo.swift
//  Snacktacular
//
//  Created by Annika Lynn Nordstrom Hall on 4/14/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage!
    var description: String!
    var postedBy: String
    var date: Date
    var documentUUID: String
    var dictionary: [String: Any]{
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    init(image: UIImage, description: String, postedBy: String, date: Date, documentID: String){
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentID
    }
    
    convenience init(){
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentID: "")
    }
    
    
    
    func saveData(spot:Spot, completed: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        let storage = Storage.storage()
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            return completed(false)
        }
        
        documentUUID = UUID().uuidString
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)
        let uploadTask = storageRef.putData(photoData)
        uploadTask.observe(.success) { snapshot in
            let dataToSave = self.dictionary
            let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    completed(false)
                } else{
                    completed(true)
                }
            }
        }
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                return completed(false)
            }
        }
    }

    
}
