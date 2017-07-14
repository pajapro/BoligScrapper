//
//  House.swift
//  BoligScrapper
//
//  Created by Pavel Procházka on 27/05/2017.
//
//

import Foundation

/// 1. level object representing search response
public struct SearchResult: Codable {
	
	public let data: ResultData
}

/// 2. level object wrapping property data
public struct ResultData: Codable {
	
	public let properties: PagedProperties
}

/// 3. level object wrapping an array of houses
public struct PagedProperties: Codable {
	
	public let count: Int
	
	public let collection: Set<House>
}

/// Encapsulating information about a house.
public struct House: Codable {
	
	public let id: Int
	
	public let title: String
	
	public let rent: Int
	
	public let rooms: Int
	
	public var address: String {
		return "\(self.street), \(self.city) \(self.zipcode)"
	}
	
	let street: String
	
	let city: String
	
	let zipcode: Int
	
	public var url: URL {
		return URL(string: "https://www.boligportal.dk/".appending(self.relativeUrl))!
	}
	
	let relativeUrl: String
	
	enum CodingKeys: String, CodingKey {
		case id = "adId"
		case title
		case rent = "monthlyPrice"
		case rooms = "numRooms"
		case street
		case city
		case zipcode
		case relativeUrl = "url"
	}
}

extension House: CustomStringConvertible {
	
	public var description: String {
		return String(format: "%@ (%d) with %d \(self.rooms > 1 ? "rooms" : "room") for %d a month at %@ (👉 %@ )", self.title, self.id, self.rooms, self.rent, self.address, self.url.absoluteString)
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

