//
//  NewsViewModel.swift
//  NewsUnisys
//
//  Created by Ibrahim Hernández Jorge on 2/2/22.
//

import Foundation
import UIKit

class NewsViewModel {
    var model: NewsList?
    lazy var notAvailableCells: [String] = []
    lazy var newsImages: [String : UIImage] = [:]
    lazy var loadingResponses: [String:[(UIImage?, Bool) -> ()]] = [:]
    var restSingleton = RestSingleton.shared
    let url = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=a98733f3d384438eba3ebbc2db9c7594"
   
    private func setModel(model: Codable) -> Bool {
        if let model = model as? NewsList {
            self.model = model
 
            return true
        }
        return false
    }
    
    func getImage(urlImage: String) -> UIImage? {
        return self.newsImages[urlImage]
    }
    
    private func storageImage(url: String, image: UIImage) {
        self.newsImages[url] = image
    }
    
    func getImageData(url: String, success succeed: @escaping ((UIImage?, Bool) -> ()),
                      error failed: @escaping (() -> ())) {
        //If the image is already downloaded, we send it without download again
        if let image = getImage(urlImage: url) {
            DispatchQueue.main.async {
                succeed(image, false)
            }
            return
        }
        
        //Storing the responses to avoid multiples REST connections for download the same image
        //If the response already exists, we append it
        if self.loadingResponses[url] != nil {
            self.loadingResponses[url]?.append(succeed)
            
            return
        } else {
            //If is the first response for this image, we create one entry on the dict for it
            self.loadingResponses[url] = [succeed]
        }
        
        self.restSingleton.getData(url: url, success: { data in
            guard let image = UIImage(data: data), let responses = self.loadingResponses[url] else {
                //If the data downloaded not are an image, we remove the response and send a failed state
                DispatchQueue.main.async {
                    self.loadingResponses.removeValue(forKey: url)
                    failed()
                }
                return
            }
            
            //Storing the image to use later if is necessary
            self.storageImage(url: url, image: image)
            
            //If the user move the cells in the table view, will create more than one request for download the same image. When the image is downloaded, we say to all the requests that the download has finished
            for response in responses {
                DispatchQueue.main.async {
                    response(image, true)
                }
            }
            
            succeed(image, true)
        }, error: {
            //If the download was failed, we remove the request and set the cell like "notAvailableState". With a "notAvailableState" we can show a retry button for the user in the image. NOT IMPLEMENTED
            DispatchQueue.main.async {
                self.loadingResponses.removeValue(forKey: url)
                if !self.isCellNotAvailable(url: url) {
                    self.notAvailableCells.append(url)
                }
                failed()
            }
        })
    }
    
    func getNewsData(success succeedx: @escaping (([News]?) -> ()),
                     error failed: @escaping (() -> ())) {
        self.restSingleton.getData(url: self.url, success: { data in
            do {
                let model = try JSONDecoder().decode(NewsList.self, from: data)
                
                if self.setModel(model: model) {
                    succeedx(self.model?.articles)
                } else {
                    failed()
                }
            } catch {
                failed()
            }
        }, error: {
            failed()
        })
    }
    
    func removeFromNotAvailableCells(url: String) {
        if let index = self.notAvailableCells.firstIndex(of: url) {
            self.notAvailableCells.remove(at: index)
        }
    }
    
    func addToNotAvailableCells(url: String) {
        if !self.notAvailableCells.contains(url) {
            self.notAvailableCells.append(url)
        }
    }
    
    func isCellNotAvailable(url: String) -> Bool {
        return self.notAvailableCells.contains(url)
    }
}
