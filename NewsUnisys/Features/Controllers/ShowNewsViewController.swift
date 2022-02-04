//
//  ShowNewsViewController.swift
//  NewsUnisys
//
//  Created by Ibrahim Hernández Jorge on 4/2/22.
//

import Foundation
import UIKit

class ShowNewsViewController: UIViewController {
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsText: UITextView!
    @IBOutlet weak var newsDate: UILabel!
    var news: News?
    var newsImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.paint()
    }
    
    private func paint() {
        self.newsImageView.image = self.newsImage
        self.newsTitle.text = self.news?.title
        self.newsText.text = self.news?.description
        self.newsDate.text = "Published at: \(formattedDate(dateString: self.news?.publishedAt))"
    }
    
    //Formatting date for show like: dd-MM-yyyy
    private func formattedDate(dateString: String?) -> String {
        guard let date = dateString else { return "" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let formattedDate = dateFormatter.date(from: date)
        
        if let formattedDate = formattedDate {
            let calendarDate = Calendar.current.dateComponents([.day, .year, .month], from: formattedDate)
            
            if let day = calendarDate.day, let month = calendarDate.month, let year = calendarDate.year {
                return "\(day)/\(month)/\(year)"
            }
        }
        return ""
    }
}
