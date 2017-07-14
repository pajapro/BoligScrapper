//
//  HouseRequest.swift
//  BoligScrapper
//
//  Created by Pavel Procházka on 27/05/2017.
//
//

import Foundation

private let kBoligPortalAPI = "https://www.boligportal.dk/RAP/ads"
private let kResultLimit = 20

public enum HouseType: Int {
	case flat = 3 // lejlighed
	case room = 9 // værelse
	case villa = 1 // villa
	case parking = 11 // parkering
}

public struct HouseRequest {
	
	// MARK: Required
	public let areas: [String]
	
	public let types: [HouseType]
	
	// MARK: Optional
	public let maxRent: Int?
	
	public let minRooms: Int?
	
	// MARK: Constants
	
	public let section = "RENTAL"
	
	public let limitRecords: Int = kResultLimit
	
	/// Returns URL to query the API.
	public var queryURL: URL? {
		var urlComponents = URLComponents(string: kBoligPortalAPI)
		urlComponents?.queryItems = []
		
		// Required
		for area in self.areas { urlComponents?.queryItems?.append(URLQueryItem(name: "ids[]", value: area)) }
		
		for type in self.types { urlComponents?.queryItems?.append(URLQueryItem(name: "housingTypes[]", value: String(type.rawValue))) }
		
		// Optionals
		if let unwrappedMaxRent = self.maxRent { urlComponents?.queryItems?.append(URLQueryItem(name: "maxRent", value: String(unwrappedMaxRent))) }
		
		if let unwrappedMinRooms = self.minRooms { urlComponents?.queryItems?.append(URLQueryItem(name: "minRooms", value: String(unwrappedMinRooms))) }
		
		// Constants
		urlComponents?.queryItems?.append(URLQueryItem(name: "section", value: self.section))
		urlComponents?.queryItems?.append(URLQueryItem(name: "limitRecords", value: String(self.limitRecords)))
		
		return urlComponents?.url
	}
	
	public init(areas: [String], types: [HouseType], maxRent: Int? = nil, minRooms: Int? = nil) {
		self.areas = areas
		self.types = types
		self.maxRent = maxRent
		self.minRooms = minRooms
	}
}
