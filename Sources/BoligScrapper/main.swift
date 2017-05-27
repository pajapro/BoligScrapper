import BoligScrapperCore
import Commander
import Foundation

let main = command(
	VariadicOption<String>("area", description: "Area identifier - use Chrome Developer Tools to obtain the appropriate ID for the area of interest"),
	VariadicOption<Int>("type", description: "Housing type of interest: 1 = villa, 3 = flat, 9 = room, 11 = parking"),
	Option<Int>("maxRent", 0, description: "Maximum rent per month"),
	Option<Int>("minRooms", 1, description: "Minumim number of rooms"),
	Option<Int>("interval", 1, description: "Time internal (in seconds) to scrape API")
) { area, type, maxRent, minRooms, interval in
	
	// ⛏ Parse user input
	let parsedType: [HouseType] = type.flatMap { HouseType(rawValue: $0) }
	print("Areas: \(area)")
	print("Types: \(type) with parsed types :\(parsedType)")
	print("Max rent: \(maxRent)")
	print("Min rooms: \(minRooms)")
	
	// 💠 Create request
	let request = HouseRequest(areas: area, types: parsedType, maxRent: maxRent, minRooms: minRooms)
	
	// 🚦 Create semaphore to keep the script alive while performing asynchronous network request
	let semaphore = DispatchSemaphore(value: 0)
	
	// 🌍 Create API fetcher
	let fetcher = APIFetcher()
//	fetcher.startQuerying(request.queryURL!, with: TimeInterval(interval))
	fetcher.query(request.queryURL!)
	
	semaphore.wait()
}

main.run()
