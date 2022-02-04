//
//  RestSingleton.swift
//  NewsUnisys
//
//  Created by Ibrahim Hernández Jorge on 3/2/22.
//

import Foundation
import UIKit

class RestSingleton {
    private init() {}
    
    static var shared: RestSingleton = {
        let instance = RestSingleton()

        return instance
    }()
    
    func getData(url: String, success succeed: @escaping ((Data) -> ()),
                 error failed: @escaping (() -> ())) {
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let dataReceived = data, let responseReceived = response as? HTTPURLResponse {
                    do {
                        if responseReceived.statusCode == 200 {
                            succeed(dataReceived)
                        } else {
                            failed()
                        }
                    }
                } else {
                    failed()
                }
            }.resume()
        }
    }
}
