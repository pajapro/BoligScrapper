//
//  House.swift
//  BoligScrapper
//
//  Created by Pavel Procházka on 27/05/2017.
//
//

import Foundation

public struct House {
	
	public let id: Int
	
	public let title: String
	
	public let rent: Int
	
	public let rooms: Int
	
	public var address: String {
		return "\(self.street), \(self.city) \(self.zipcode)"
	}
	
	public let street: String
	
	public let city: String
	
	public let zipcode: Int
	
	public init?(JSON: [String: Any]) {
		guard let id = JSON["adId"] as? Int, let title = JSON["title"] as? String, let rent = JSON["monthlyPrice"] as? Int, let rooms = JSON["numRooms"] as? Int, let street = JSON["street"] as? String, let city = JSON["city"] as? String, let zipcode = JSON["zipcode"] as? Int else {
			assertionFailure("Missing required JSON properties")
			return nil
		}
		
		self.id = id
		self.title = title
		self.rent = rent
		self.rooms = rooms
		self.street = street
		self.city = city
		self.zipcode = zipcode
	}
}

extension House: CustomStringConvertible {
	
	public var description: String {
		return String(format: "%@ with %d \(self.rooms > 1 ? "rooms" : "room") for %d a month at %@", self.title, self.rooms, self.rent, self.address)
	}
}

extension House: Equatable {
	
	public static func == (lhs: House, rhs: House) -> Bool {
		return lhs.id == rhs.id
	}
}


extension House: Hashable {
	
	public var hashValue: Int {
		return self.id.hashValue ^ self.title.hashValue ^ self.address.hashValue
	}
}
