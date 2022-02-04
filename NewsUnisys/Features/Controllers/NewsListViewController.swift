//
//  NewsListViewController.swift
//  NewsUnisys
//
//  Created by Ibrahim Hernández Jorge on 2/2/22.
//

import UIKit

//Protocol for the communications between the cell and the UIViewController
protocol ImageProtocol {
    func isCellInNotAvailableState(url: String) -> Bool
    func addCellToNotAvailableState(url: String)
    func removeCellFromNotAvailablesState(url: String)
    func downloadImage(url: String, success succeed: @escaping (UIImage?, Bool) -> (), error failed: @escaping () -> ())
}

class NewsListViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    let viewModel = NewsViewModel()
    var filteredData: [News]?
    let cellId = "NewsTableViewCell"
    
    var newsList: [News]? {
        //When newsList change, tableView data will be reloaded
        didSet {
            DispatchQueue.main.async {
                self.filteredData = self.newsList
                //Short array of news by date
                self.filteredData?.sort(by: { (($0.publishedAt ?? "").compare($1.publishedAt ?? "")) == .orderedDescending })
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initTableView()
        self.getNews()
    }
    
    private func initTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchBar.delegate = self
        
        self.tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //We use newsList like a copy of all the news. FilteredData only will contain the news that match when the text in the search bar
        self.filteredData = searchText.isEmpty ? self.newsList : self.newsList?.filter { $0.title?.contains(searchText) ?? false }
        
        tableView.reloadData()
    }

    private func getNews() {
        self.viewModel.getNewsData(success: { news in
            if let newsReceived = news {
                self.newsList = newsReceived
            }
        }, error: {
            self.showErrorState()
        })
    }
    
    private func showErrorState() {
        //Show retry button. When retry button is pressed, getNews() will be executated
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let filteredData = self.filteredData else { return 0 }
        
        return filteredData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell") as? NewsTableViewCell, let news =  self.filteredData?[indexPath.row] {
            if cell.imageProtocolDelegate == nil {
                cell.imageProtocolDelegate = self
            }
            
            cell.bind(news: news)
            
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at: indexPath) as? NewsTableViewCell) != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let viewController = storyboard.instantiateViewController(withIdentifier: "ShowNewsViewController") as? ShowNewsViewController, let newsList =  self.filteredData {
                viewController.news = newsList[indexPath.row]
                viewController.newsImage = self.viewModel.getImage(urlImage: newsList[indexPath.row].urlToImage ?? "")
                
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension NewsListViewController: ImageProtocol {
    func addCellToNotAvailableState(url: String) {
        self.viewModel.addToNotAvailableCells(url: url)
    }
    
    func removeCellFromNotAvailablesState(url: String) {
        self.viewModel.removeFromNotAvailableCells(url: url)
    }
    
    func isCellInNotAvailableState(url: String) -> Bool {
        self.viewModel.isCellNotAvailable(url: url)
    }
    
    func downloadImage(url: String, success succeed: @escaping (UIImage?, Bool) -> (), error failed: @escaping () -> ()) {
        self.viewModel.getImageData(url: url, success: { image, isFromDownload in
            succeed(image, isFromDownload)
        }, error: {
            failed()
        })
    }
}

