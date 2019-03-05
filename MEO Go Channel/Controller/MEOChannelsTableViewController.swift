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
    
    var channelsList :Array<Programs>?
    let userAgent = "IOS"
    var callLetter : String = ""
    let catalogInstance : CatalogIntegration = CatalogIntegration()
    var myTeste : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        channelTableView.register(UINib(nibName: "CustomCell", bundle: nil) , forCellReuseIdentifier: "customCell")
        loadCatalogTable()
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channelsList?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCellTableViewCell

        if let positionedList = channelsList?[indexPath.row] {
            
            cell.channelLabel.text = positionedList.callLetter
            cell.programNameLabel.text = positionedList.title
            cell.descriptonLabel.text = positionedList.description
        
            let param : [String : String] = ["evTitle":positionedList.title,"chCallLetter": positionedList.callLetter, "profile":"16_9", "width":"320"]
            getProperImage(param: param)
//            cell.programImage.image = myTeste
            
        } else {
            cell.channelLabel.text = "- x -"
            cell.programNameLabel.text = "Nothing found"
            cell.descriptonLabel.text = "no description"

        }

        return cell
    }

    func getProperImage(param : [String : String]) {
        
        let urlImage = "http://proxycache.app.iptv.telecom.pt:8080/eemstb/ImageHandler.ashx?"
        
        DispatchQueue.global().async {
            Alamofire.request(urlImage, method: .get, parameters: param).responseData(completionHandler: { (data) in
                if data.result.isSuccess {
                    let imageDownloaded = data.result.value
                    self.myTeste = UIImage(data: imageDownloaded!)
                }
            })
        }
        
    }

    // MARK: - Integration & JSON Functions --> CatalogIntegration.swift
    func loadCatalogTable() {
        
        let params : [String : String] = ["UserAgent": userAgent, "CallLetter": callLetter]

        catalogInstance.getInitialPrograms(aParams: params, completion: {
            self.channelsList = self.catalogInstance.getProgramsArray()
            self.tableView.reloadData()
        })
        tableView.reloadData()
    }
    
}
