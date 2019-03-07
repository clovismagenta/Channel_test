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
    
    var jsonDict : JSON?
    var catalogyDict : [String : Any] = ["":0]
    var programsArray = Array<Programs>()
    var fullProgramURL : String?
    var fullImageURL : URL?

    // MARK: Load all channels
    
    func getInitialChannels( externalURL: String, aParams : [String : String] , completion : @escaping ()->() ) {
        
        getCatalogJSONData(thisURL: externalURL, param: aParams, completion : {
            guard let jsonDict = self.jsonDict else { return }
            
            if jsonDict.count > 1 {
                self.formatJSONtoChannels(resultJSON : jsonDict)
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
                print("error on Alamofire resquest.")
                print("url:\(thisURL)")
                print("error:\(response.result.error?.localizedDescription)")
                return
            }
            completion()
        }
    }
    
    // Function to transform JSON in Programs, according to URL's return
    func formatJSONtoChannels( resultJSON : JSON ) {

        for item in resultJSON {
            
            if let thisItem = (item.1).dictionary {
                let newProgram = Programs()
                newProgram.channelTitle = (thisItem["Title"]?.string)!
                newProgram.callLetter = (thisItem["CallLetter"]?.string)!

                programsArray.append(newProgram)
            }
        }

    }
    
    // MARK: Focus in image integration.
    
    func downloadImage(thisURL:URL, completion: @escaping ( (NSData) -> Void ) ) {
        
        let thisResquest = NSURLRequest(url: thisURL)
        let dataTask = URLSession.shared.dataTask(with: thisResquest as URLRequest) { (thisData, thisResponse, thisError) in
            
            if thisError == nil {
                if let httpResponse = thisResponse as? HTTPURLResponse {
                    switch (httpResponse.statusCode) {
                    case 200:
                        if let data = thisData {
                            completion(data as NSData)
                        }
                    default:
                        break
                    }
                }

            } else {
                print("Error on downloading image: \(thisError?.localizedDescription ?? "error")")
            }
            
        }
        
        dataTask.resume()
        
    }
    
    func adaptURL4Images(dictionayImageDetails : [String:String] ) {
        
        if let title = dictionayImageDetails["Title"] {
            if let callLetter = dictionayImageDetails["CART"] {
                let originalString = "http://proxycache.app.iptv.telecom.pt:8080/eemstb/ImageHandler.ashx?evTitle="+title+"&chCallLetter="+callLetter+"&profile=16_9&width=320"
                let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                if let urlString2 = urlString {
                    fullImageURL = URL( string: urlString2)
                }
            }
        }
        
    }
    
    // MARK: Program Integration
    // Function to transform JSON in Programs, according to URL's return
    func formatJSONtoPrograms( arrayChannels : Array<Programs>, resultJSON : JSON ) {
        
        var trackPrograms = ""
        
        for item in resultJSON {
            
            if let thisItem = (item.1).dictionary {
                
                if let callLetter = thisItem["CallLetter"]?.string {
                    
                    let result = arrayChannels.first(where: { pair -> Bool in
                        return pair.callLetter.contains(callLetter)
                    })
                 
                    if let actualChannel = result {
                        
                        if trackPrograms.contains(callLetter) {
                            actualChannel.nextProgram = (thisItem["Title"]?.string)!
                        } else {
                            actualChannel.programTitle = (thisItem["Title"]?.string)!
                            trackPrograms = trackPrograms + (callLetter) + "|"
                        }
                    }
                }

            }

        }
        
    }
    
    
    func adaptURL4Program(dictionayProgramDetails : [String:String] ) {
        
        if let agent = dictionayProgramDetails["UserAgent"] {
            if let callLetter = dictionayProgramDetails["CART"] {
                fullProgramURL = "http://ott.online.meo.pt/Program/v7/Programs/NowAndNextLiveChannelPrograms?UserAgent="+agent+"&$filter=CallLetter%20eq%20%27"+callLetter+"%27&$orderby=StartDate%20asc"
            }
        }
        
    }
    
}
