//
//  TipOfTheDayService.swift
//
//  Created by Claude Code on 2/22/26.
//

import Foundation
import SwiftData

public struct TipOfTheDayService {
    /// Called at app startup to sync bundled tips into SwiftData.
    /// Inserts new tips, updates message text of existing tips,
    /// does NOT delete tips removed from JSON (preserves isShown state),
    /// does NOT overwrite isShown.
    public static func syncTips(from filename: String, modelContext: ModelContext) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            #if DEBUG
            print("TipOfTheDayService: tips_of_the_day.json not found in bundle")
            #endif
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let tipsData = try JSONDecoder().decode(TipsData.self, from: data)

            let descriptor = FetchDescriptor<TipOfTheDay>()
            let existingTips = try modelContext.fetch(descriptor)
            var existingDict: [String: TipOfTheDay] = [:]
            for tip in existingTips {
                existingDict[tip.tipId] = tip
            }

            for jsonTip in tipsData.tips {
                if let existing = existingDict[jsonTip.id] {
                    existing.message = jsonTip.message
                } else {
                    let newTip = TipOfTheDay(tipId: jsonTip.id, message: jsonTip.message)
                    modelContext.insert(newTip)
                }
            }

            try modelContext.save()
        } catch {
            #if DEBUG
            print("TipOfTheDayService: Error syncing tips: \(error)")
            #endif
        }
    }

    /// Returns a random tip where isShown == false, or nil if all dismissed.
    public static func randomUnshownTip(modelContext: ModelContext) -> TipOfTheDay? {
        var descriptor = FetchDescriptor<TipOfTheDay>(
            predicate: #Predicate { $0.isShown == false }
        )
        descriptor.fetchLimit = nil

        do {
            let unshownTips = try modelContext.fetch(descriptor)
            return unshownTips.randomElement()
        } catch {
            #if DEBUG
            print("TipOfTheDayService: Error fetching unshown tips: \(error)")
            #endif
            return nil
        }
    }

    /// Returns all tips sorted by tipId, regardless of isShown state.
    public static func allTips(modelContext: ModelContext) -> [TipOfTheDay] {
        let descriptor = FetchDescriptor<TipOfTheDay>(sortBy: [SortDescriptor(\.tipId)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            #if DEBUG
            print("TipOfTheDayService: Error fetching all tips: \(error)")
            #endif
            return []
        }
    }

    /// Marks a tip as shown (dismissed) so it won't appear again.
    public static func markAsShown(_ tip: TipOfTheDay, modelContext: ModelContext) {
        #if DEBUG
        print("Marking tip as shown")
        #endif
        
        tip.isShown = true
        do {
            try modelContext.save()
        } catch {
            #if DEBUG
            print("TipOfTheDayService: Error marking tip as shown: \(error)")
            #endif
        }
    }
    
    /// Marks all tips as not shown
    public static func resetShown(_ modelContext: ModelContext) {
        let descriptor = FetchDescriptor<TipOfTheDay>()
        guard let records = try? modelContext.fetch(descriptor) else { return }
        
        for record in records {
            record.isShown = false
        }
        
        try? modelContext.save()
    }
}

public struct TipsData: Decodable {
    public let tips: [TipJSON]
    public let version: String
}

public struct TipJSON: Decodable {
    public let id: String
    public let message: String
}
