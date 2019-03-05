//
//  CatalogIntegration.swift
//  MEO Go Channel
//
//  Created by Clovis Magenta da Cunha on 04/03/19.
//  Copyright © 2019 CMC. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CatalogIntegration {
    
    let url1 = "http://ott.online.meo.pt/catalog/v7/Channels?UserAgent=IOS&$filter=substringof(%27MEO_Mobile%27,AvailableOnChannels)%20and%20IsAdult%20eq%20false&$orderby=ChannelPosition%20asc&$inlinecount=allpages"
    let url2 = "http://ott.online.meo.pt/catalog/v7/Channels"
    let url3 = "http://ott.online.meo.pt/catalog/v7/Channels?UserAgent=IOS"
    
    var jsonDict : JSON?
    var catalogyDict : [String : Any] = ["":0]
    var programsArray = Array<Programs>()
    
    func getProgramsArray() -> Array<Programs> {
    
        return programsArray
    }
    
    // Function to get all initial programs from URL declared
    func getInitialPrograms( aParams : [String : String] , completion : @escaping ()->() ) {
        
        // take first JSON
        getCatalogJSONData(thisURL: url1, param: aParams, completion : {
            guard let jsonDict = self.jsonDict else { return }
            
            if jsonDict.count > 1 {
                self.formatJSONtoPrograms(resultJSON : jsonDict)
            }

            completion()
        })
    }

    // Function to extract ONLY JSON information
    func getCatalogJSONData(thisURL: String, param: [String : String], completion : @escaping ()->() ) {

        Alamofire.request(thisURL).validate().responseJSON
        {
            response in
            
            if response.result.isSuccess {
                self.jsonDict = JSON(response.result.value!)["value"]
            } else {
                return
            }
            completion()
        }
    }
    
    // Function to transform JSON in Programs, according to URL's return
    private func formatJSONtoPrograms( resultJSON : JSON ) {

        var newProgram = Programs()

        for item in resultJSON {
            
            if let thisItem = (item.1).dictionary {
                newProgram.title = (thisItem["Title"]?.string)!
                newProgram.description = (thisItem["Description"]?.string)!
                newProgram.callLetter = (thisItem["CallLetter"]?.string)!

                programsArray.append(newProgram)
            }
        }

    }
}
