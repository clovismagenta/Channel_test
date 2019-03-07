//
//  MEOChannelsTableViewController.swift
//  MEO Go Channel
//
//  Created by Clovis Magenta da Cunha on 04/03/19.
//  Copyright © 2019 CMC. All rights reserved.
//

import UIKit
import Alamofire

class MEOChannelsTableViewController: UITableViewController {

    @IBOutlet weak var channelTableView: UITableView!
    
    let userAgent = "IOS"
    let catalogInstance : CatalogIntegration = CatalogIntegration()
    var callLetter : String = ""
    var channelsList :Array<Programs>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        channelTableView.register(UINib(nibName: "CustomCell", bundle: nil) , forCellReuseIdentifier: "customCell")
        tableView.separatorStyle = .singleLine
        channelTableView.rowHeight = 80

        loadCatalogTable {
            self.updateUI()
        }
    }

    // MARK: - Table View data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8.0
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return channelsList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCellTableViewCell
        
        if let positionedList = channelsList?[indexPath.section] {
            cell.channelLabel.text = positionedList.channelTitle
            cell.programNameLabel.text = positionedList.programTitle
            cell.descriptonLabel.text = positionedList.nextProgram
            cell.imageView?.image = positionedList.image
        }
        
        return cell
    }
    
    // MARK: User Interface - Updates
    
    func updateUI() {

        self.delay(bySeconds: 3) {
            self.tableView.reloadData()
            
        }
    }

    // MARK: - Channels - Main Controlling Function
    
   let channelURL = "http://ott.online.meo.pt/catalog/v7/Channels?UserAgent=IOS&$filter=substringof(%27MEO_Mobile%27,AvailableOnChannels)%20and%20IsAdult%20eq%20false&$orderby=ChannelPosition%20asc&$inlinecount=allpages"
    
    func loadCatalogTable( completion: @escaping ()->Void ) {
        
        let params : [String : String] = ["UserAgent": userAgent, "CallLetter": callLetter]
        
        catalogInstance.getInitialChannels(externalURL: channelURL,aParams: params, completion: {
            
            self.channelsList = self.catalogInstance.programsArray
            
            for channel in self.channelsList! {
                self.getProgramsByChannel(thisChannel: channel, completion: {
                    self.getProgramImage(thisProgram: channel)
                })
                
            }
            completion()
        })
    }
    
    // MARK: - Program Function
    
    func getProgramsByChannel(thisChannel: Programs, completion : @escaping ()->() ) {
    
        let newinstance = CatalogIntegration()
        let parameters = keyInProgramURL(forChannel: thisChannel)
        
        newinstance.adaptURL4Program(dictionayProgramDetails: parameters)
        
        guard let url = newinstance.fullProgramURL else { return }
        
        newinstance.getCatalogJSONData(thisURL: url , param: parameters) {
            if let jsonData = newinstance.jsonDict {
                if jsonData.count > 1 {
                    newinstance.formatJSONtoPrograms(arrayChannels: self.channelsList! ,resultJSON : jsonData)
                }
            }
            completion()
        }
    }
    
    func keyInProgramURL( forChannel : Programs ) -> [String : String] {
    
        return ["UserAgent": "IOS" ,"CART": forChannel.callLetter]
        
    }
    
    // MARK: - Image Functions
    
    func getProgramImage(thisProgram : Programs) {
        
        let newinstance = CatalogIntegration()
        let parameters = keyInImageURL(forProgram: thisProgram)
        
        newinstance.adaptURL4Images(dictionayImageDetails: parameters)
        
        if let realURL = newinstance.fullImageURL {
            
            newinstance.downloadImage(thisURL: realURL
                , completion: { (data) in
                    
                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                        guard let self = self else {
                            return
                        }
                        
                        DispatchQueue.main.async { [weak self] in
                            //                            thisCell.imageView?.image = UIImage(data: data as Data)
                            thisProgram.image = UIImage(data: data as Data)
                            
                        }
                    }
            })
        }
    }
    
    
    func keyInImageURL( forProgram : Programs ) -> [String : String] {
        
        return ["Title": forProgram.programTitle ,"CART": forProgram.callLetter]
        
    }
    
    // MARK: Delay functionaly
    
    public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + seconds
        dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
    }
    
    public enum DispatchLevel {
        case main, userInteractive, userInitiated, utility, background
        var dispatchQueue: DispatchQueue {
            switch self {
            case .main:                 return DispatchQueue.main
            case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
            case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
            case .utility:              return DispatchQueue.global(qos: .utility)
            case .background:           return DispatchQueue.global(qos: .background)
            }
        }
    }
    
}

// Old Garbage
//var processingView : UIView?
//var processingLabel : UILabel?
//    override func viewWillAppear(_ animated: Bool) {
//
//        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width , height: self.view.frame.height)
//        let cRectLabel = CGRect(x: self.view.frame.width/4, y: self.view.frame.height/4, width: self.view.frame.width/2 , height: self.view.frame.height*0.1)
//
//        processingView = UIView(frame: rect)
//        processingView?.backgroundColor = .gray
//        self.view.addSubview(processingView!)
//
//        processingLabel = UILabel(frame: cRectLabel)
//        processingLabel?.textColor = .white
//        processingLabel?.textAlignment = .center
//        processingLabel?.text = "Loading Channels..."
//        self.view.addSubview(processingLabel!)
//    }

