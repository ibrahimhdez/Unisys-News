//
//  NewsTableViewCell.swift
//  NewsUnisys
//
//  Created by Ibrahim Hernández Jorge on 2/2/22.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsDescriptionTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var imageProtocolDelegate: ImageProtocol?
    
    func bind(news: News) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.titleLabel.text = news.title
        self.newsDescriptionTextView.text = news.description
        
        if let urlString = news.urlToImage {
            fetchImage(urlString: urlString)
        }
    }
    
    private func fetchImage(urlString: String) {
        if let delegate = imageProtocolDelegate {
            //Check if the cell is in Not Available State (when a download fail, a retry button will be showed) Not implemented.
            if !delegate.isCellInNotAvailableState(url: urlString) {
                imageProtocolDelegate?.downloadImage(url: urlString, success: { image, isFromDownload in
                    DispatchQueue.main.async {
                        self.setImage(newsImage: image, isFromDownload: isFromDownload)
                    }
                }, error: {
                    //SHOW FAILED STATE AND RETRY BUTTON FOR A NEW IMAGE DOWNLOAD
                })
            }
        }
    }
    
    private func setImage(newsImage: UIImage?, isFromDownload: Bool) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        
        //If the image come from a new download, the image will appear with a effect of transition
        if isFromDownload {
            setImageWithTransition(image: newsImage)
        } else {
            //If the image come from the movement of the cells, the effect is not displayed
            self.newsImage.image = newsImage
        }
    }
    
    private func setImageWithTransition(image: UIImage?) {
        UIView.transition(with: self.newsImage,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.newsImage.image = image },
                          completion: nil)
    }
}
