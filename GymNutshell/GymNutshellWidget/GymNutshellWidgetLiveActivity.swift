// ⌘
//  GymNutshellWidget/GymNutshellWidgetLiveActivity.swift
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-29.
// ⌘

import ActivityKit
import WidgetKit
import SwiftUI

struct GymNutshellWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GymNutshellWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GymNutshellWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GymNutshellWidgetAttributes {
    fileprivate static var preview: GymNutshellWidgetAttributes {
        GymNutshellWidgetAttributes(name: "World")
    }
}

extension GymNutshellWidgetAttributes.ContentState {
    fileprivate static var smiley: GymNutshellWidgetAttributes.ContentState {
        GymNutshellWidgetAttributes.ContentState(emoji: "😀")
     }

     fileprivate static var starEyes: GymNutshellWidgetAttributes.ContentState {
         GymNutshellWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GymNutshellWidgetAttributes.preview) {
   GymNutshellWidgetLiveActivity()
} contentStates: {
    GymNutshellWidgetAttributes.ContentState.smiley
    GymNutshellWidgetAttributes.ContentState.starEyes
}
