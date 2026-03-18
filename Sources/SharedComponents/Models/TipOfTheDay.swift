//
//  TipOfTheDay.swift
//  UIComponents
//
//  Created by Friedrich Ewald on 3/17/26.
//

import SwiftData

@Model
public final class TipOfTheDay {
    public var tipId: String = ""
    public var message: String = ""
    public var isShown: Bool = false

    public init(tipId: String, message: String, isShown: Bool = false) {
        self.tipId = tipId
        self.message = message
        self.isShown = isShown
    }
}
