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
		
		self.queryAPI() // Query manually to execute immediately the first time
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
				print("Received network error \(error!) 💣")
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode <= 400 else {
				print("Received server-side error 💣")
				return
			}
			
			guard let unwrappedData = data else {
				print("Received no data 💢")
				return
			}
			
			do {
				let decoder = JSONDecoder()
				let parsedResponse = try decoder.decode(SearchResult.self, from: unwrappedData)
				let newHouses = parsedResponse.data.properties.collection.symmetricDifference(self.foundHouses)
				
				if !newHouses.isEmpty {
					print("🎉 Found \(newHouses.count) new houses 🏠, specifically:")
					
					for (index, house) in newHouses.enumerated() {
						print("\t\(index+1). \(house.description)")
						OperationQueue.main.addOperation { self.foundHouses.insert(house) }
					}
				} else {
					print("💢 No new houses found...")
				}
			} catch {
				print("An error has occured: \(error) 💣")
			}
		}
		print("🔎 Querying: \(url)")
		task.resume()
	}
}
