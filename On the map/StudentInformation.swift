//
//  StudentInformation.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 22/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation

struct StudentInformation: Codable {
    let createdAt: String?
    let firstName: String?
    let lastName: String?
    let latitude: Double?
    let longitude: Double?
    let mapString: String?
    let mediaURL: String?
    let objectId: String?
    let uniqueKey: String?
    let updatedAt: String?
}
