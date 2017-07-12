//
//  APIFetcher.swift
//  BoligScrapper
//
//  Created by Pavel Procházka on 27/05/2017.
//
//

import Foundation

final public class APIFetcher {
	
	// 🗂 Create `Set` for fetched `House`
	var foundHouses = Set<House>()
	
	private var timer: Timer?
	
	private var urlToQuery: URL?
	
	@available(OSX 10.12, *)
	public init(with interval: TimeInterval) {
		self.timer = Timer(timeInterval: interval, repeats: true) { _ in
			self.queryAPI()
		}
	}
	
	deinit {
		self.timer?.invalidate()
		self.timer = nil
	}
	
	public func startQuerying(_ url: URL) {
		guard let unwrappedTimer = self.timer else {
			assertionFailure("Cannot find valid instance of Timer")
			return
		}
		self.urlToQuery = url
		
		RunLoop.main.add(unwrappedTimer, forMode: .defaultRunLoopMode)
		RunLoop.main.run()
	}
	
	// 📥 Fetches data from provider URL
	public func queryAPI() {
		guard let url = self.urlToQuery else {
			assertionFailure("Cannot find valid instance of URL to query")
			return
		}
		
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			guard error == nil else {
				print("Received network error \(error!)")
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode <= 400 else {
				print("Received server-side error")
				return
			}
			
			guard let unwrappedData = data else {
				print("Received no data")
				return
			}
			
			let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: [])
			if let jsonRoot = json as? [String: Any], let data = jsonRoot["data"] as? [String: Any], let properties = data["properties"] as? [String: Any], let collection = properties["collection"] as? [[String: Any]] {
				
				let houses = Set(collection.flatMap { data in House(JSON: data) })
				let newHouses = houses.symmetricDifference(self.foundHouses)
				
				if !newHouses.isEmpty {
					print("Found \(newHouses.count) new houses 🏠, specifically:")
					
					for (index, house) in newHouses.enumerated() {
						print("\t\(index). \(house.description)")
						OperationQueue.main.addOperation { self.foundHouses.insert(house) }
					}
				}
			} else {
				print("Cannot parse JSON")
			}
		}
		print("🔎 Querying: \(url)")
		task.resume()
	}
}
