//
//  Effect.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 9/9/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import Foundation
import QuartzCore

public enum EffectType: Int, Codable {
	case none
	case dropShadow = 25
	case controls = 5
	case blur = 29
	case fill = 21
	case color = 2
	case unknown
}

extension EffectType: ClassFamily {
	static var discriminator: Discriminator = .type
	
	func getType() -> AnyObject.Type {
		switch self {
		case .dropShadow:
			return DropShadowEffect.self
		default:
			return Effect.self
		}
	}
}

class Effect: Codable {
	
	private enum CodingKeys : String, CodingKey {
		case name = "nm"
		case index = "ix"
		case type = "ty"
		case values = "ef"
	}
	
	let name: String
	let index: Int
	let type: EffectType
	let values: [EffectValue]?
	
	public func apply(layer: CALayer) {}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Effect.CodingKeys.self)
		
		self.type = try container.decode(EffectType.self, forKey: .type)
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Effect"
		self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
		self.values = container.decodeIfPresent([EffectValue].self, ofFamily: EffectValueType.self, forKey: .values)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(type, forKey: .type)
		try container.encode(name, forKey: .name)
		try container.encode(index, forKey: .index)
		try container.encode(values, forKey: .values)
	}
}
