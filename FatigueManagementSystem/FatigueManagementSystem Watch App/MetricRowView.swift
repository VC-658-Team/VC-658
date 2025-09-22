//
//  MetricRowView.swift
//  FatigueTracker
//
//  Created by Josh on 9/9/2025.
//


import SwiftUI

struct MetricRowView: View {
    let iconName: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.title3) // Font size is okay, no change here
                .foregroundColor(iconColor)
                .frame(width: 30)

            Text(title)
                .font(.system(size: 16))

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        // CHANGED: Reduced vertical padding to make each row shorter
        .padding(.vertical, 4)
    }
}
