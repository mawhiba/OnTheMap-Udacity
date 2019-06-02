//
//  UdacityAPI.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 22/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class UdacityAPI {
    
    static func postSessionForLogin(with email: String, password: String, completion: @escaping ([String:Any]?, String? , Error?) -> ())
    {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(nil,nil,error)
                return
            }
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {return}
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                // Since Status Code is valid. Process Data here only.
                if data != nil {
                    // This is syntax to create Range in Swift 5
                    let range = 5..<data!.count
                    let newData = data?.subdata(in: range) /* subset response data! */
                    
                    // Continue processing the data and deserialize it
                    if let dataResult = try! JSONSerialization.jsonObject(with: newData!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]{
                        completion(dataResult,nil,nil)
                    } else {
                        completion(nil,nil, error?.localizedDescription as? Error)
                    }
                    
                }
            } else {
                switch httpStatusCode {
                case 400:
                    completion(nil, "Bad Request", nil)
                    return
                case 401:
                    completion(nil, "Invalid Credentials", nil)
                    return
                case 403:
                    completion(nil, "Unauthorized", nil)
                    return
                case 405:
                    completion(nil, "HttpMethod Not Allowed", nil)
                    return
                case 410:
                    completion(nil, "URL Changed", nil)
                    return
                case 500:
                    completion(nil, "Server Error", nil)
                    return
                default:
                    completion(nil, "", error?.localizedDescription as? Error)
                }
            }

        }
        task.resume()
    }
    
    static func deleteSession(completion: @escaping (Error?) -> ())
    {
        var request = URLRequest(url: URL(string : "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        if let sharedStorageCookies = HTTPCookieStorage.shared.cookies {
            for cookie in sharedStorageCookies {
                if cookie.name == "XSRF-TOKEN" {
                    xsrfCookie = cookie
                }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error == nil {
                    let range = Range(5..<data!.count)
                    let newData = data?.subdata(in: range)
                    print(String(data: newData!, encoding: .utf8)!)
                    completion(nil)
                } else {
                    completion(error)
                    return
                }
            }
            task.resume()
        }
    }
    
    class Parse {
        
        static func postStudentLocation(link: String, locationCoordinate: CLLocationCoordinate2D, locationName: String, completion: @escaping (Error?) -> ())
        {
            var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
            request.httpMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"54321\", \"firstName\": \"Adam\", \"lastName\": \"Ahmed\", \"mapString\": \"\(locationName)\", \"mediaURL\": \"\(link)\", \"latitude\": \(locationCoordinate.latitude), \"longitude\": \(locationCoordinate.longitude)}".data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error == nil {
                    print(String(data: data!, encoding: .utf8)!)
                    completion(nil)
                } else {
                    completion(error)
                    return
                }
            }
            task.resume()
        }
        
        static func getStudentLocation(completion: @escaping ([StudentInformation]?, Error?) -> ())
        {
            let base = "https://onthemap-api.udacity.com/v1/StudentLocation"
            var request = URLRequest(url: URL(string: base + "?limit=100&order=-updatedAt")!)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error == nil {
                    if let dic = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String:Any] {
                        guard let results = dic["results"] as? [[String:Any]] else {return}
                        let resultsData = try! JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
                        let studentInfo = try! JSONDecoder().decode([StudentInformation].self, from: resultsData)
                        SharedState.shared.studentInfo = studentInfo
                        completion(studentInfo,nil)
                    } else {
                        completion(nil, error?.localizedDescription as? Error)
                    }
                } else {
                    completion(nil,error)
                    return
                }
            }
            task.resume()
        }
    }
    
}
