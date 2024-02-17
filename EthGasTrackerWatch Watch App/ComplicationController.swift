//
//  ComplicationController.swift
//  EthGasTrackerWatch Watch App
//
//  Created by Tem on 2/16/24.
//

import Foundation
import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // Fetch data from SharedDataRepository
    func fetchComplicationData(completion: @escaping (GasIndexEntry?) -> Void) {
        SharedDataRepository.shared.fetchDataIfNeeded { result in
            switch result {
            case .success(let entry):
                completion(entry)
            case .failure:
                completion(nil)
            }
        }
    }
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "Gas Price", supportedFamilies: [.modularSmall, .circularSmall, .utilitarianSmall, .utilitarianSmallFlat]) // Adapt for your complication types
        ]
        handler(descriptors)
    }
    
    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil) // Indefinite timeline
    }
    
    // MARK: - Current Timeline Entry
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        guard complication.family == .modularSmall else {
            handler(nil)
            return
        }
        
        fetchComplicationData { entry in
            guard let entry = entry else {
                handler(nil)
                return
            }
            
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "ETH Gas")
            template.line2TextProvider = CLKSimpleTextProvider(text: String(format: "%.1f Gwei", entry.gas))
            
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
        }
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        guard complication.family == .modularSmall else {
            handler(nil)
            return
        }
        
        let template = CLKComplicationTemplateModularSmallStackText()
        template.line1TextProvider = CLKSimpleTextProvider(text: "ETH Gas")
        template.line2TextProvider = CLKSimpleTextProvider(text: "...")
        handler(template)
    }
    
    // Implement other required methods as needed...
}
