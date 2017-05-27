//
//  APIFetcher.swift
//  BoligScrapper
//
//  Created by Pavel Procházka on 27/05/2017.
//
//

import Foundation

final public class APIFetcher {
	
	// 🚦 Create semaphore to keep the script alive while performing asynchronous network request
//	let semaphore = DispatchSemaphore(value: 0)
	
	// 🗂 Create `Set` for fetched `House`
	var foundHouses = Set<House>()
	
	public init() {}
	
	public func startQuerying(_ url: URL, with interval: TimeInterval) {
//		self.query(url)
		if #available(OSX 10.12, *) {
//			self.semaphore.wait()
			Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { timer in
				print("🚀 Firing a new request")
//				self.semaphore.signal()
				self.query(url)
			}
		} else {
			// Fallback on earlier versions
		}
	}
	
	// 📥 Fetches data from provider URL
	public func query(_ url: URL) {
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			guard error == nil else {
				print("Received network error \(error!)")
//				self.semaphore.signal() // 🏁 Terminate on network error
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode <= 400 else {
				print("Received server-side error")
//				self.semaphore.signal() // 🏁 Terminate on server-side error
				return
			}
			
			guard let unwrappedData = data else {
				print("Received no data")
//				self.semaphore.signal() // 🏁 Terminate on empty data
				return
			}
			
			let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: [])
			if let jsonRoot = json as? [String: Any], let data = jsonRoot["data"] as? [String: Any], let properties = data["properties"] as? [String: Any], let collection = properties["collection"] as? [[String: Any]] {
				
				let houses = collection.flatMap { data in House(JSON: data) }
				for house in houses {
					print("Found a new 🏠: \(house.description)")
					self.foundHouses.insert(house)
					
				}
//				self.semaphore.signal()
			} else {
				print("Cannot parse JSON")
//				self.semaphore.signal() // 🏁 Terminate on empty data
			}
			
		}
		
		print("🔎 Querying: \(url)")
		task.resume()
//		self.semaphore.wait()
	}
}
