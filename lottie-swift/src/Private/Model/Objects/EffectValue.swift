//
//  EffectValue.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 9/10/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Foundation

public enum EffectValueType: Int, Codable {
	case doubleValue = 0
	case arrayValue = 2
	case boolValue = 7
}

extension EffectValueType: ClassFamily {
	static var discriminator: Discriminator = .type
	
	func getType() -> AnyObject.Type {
		switch self {
		case .doubleValue:
			return DoubleEffectValue.self
		case .arrayValue:
			return ArrayEffectValue.self
		case .boolValue:
			return BoolEffectValue.self
		}
	}
}

class EffectValue: Codable {
	fileprivate enum CodingKeys : String, CodingKey {
		case name = "nm"
		case index = "ix"
		case type = "ty"
		case value = "v"
		case attribute = "a"
		case key = "k"
	}
	
	let type: EffectValueType
	let index: Int
	let name: String
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.type = try container.decode(EffectValueType.self, forKey: .type)
		self.index = try container.decode(Int.self, forKey: .index)
		self.name = try container.decode(String.self, forKey: .name)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(type, forKey: .type)
		try container.encode(index, forKey: .index)
		try container.encode(name, forKey: .name)
	}
}

class DoubleEffectValue: EffectValue {
	let value: Double
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let dictionary: [String: Double] = try container.decode([String: Double].self, forKey: CodingKeys.value)
		self.value = dictionary[CodingKeys.key.rawValue] ?? 0.0
		try super.init(from: decoder)
	}
}

class ArrayEffectValue: EffectValue {
	let value: [Double]
	
	struct ArrayEffectValueContainer: Decodable {
		let a: Double
		let k: [Double]
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let dictionary: ArrayEffectValueContainer = try container.decode(ArrayEffectValueContainer.self, forKey: .value)
		self.value = dictionary.k
		
		try super.init(from: decoder)
	}
}

class BoolEffectValue: EffectValue {
	let value: Bool
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let dictionary: [String: Int] = try container.decode([String: Int].self, forKey: CodingKeys.value)
		self.value = dictionary[CodingKeys.key.rawValue] == 0 ? false : true
		try super.init(from: decoder)
	}
}
