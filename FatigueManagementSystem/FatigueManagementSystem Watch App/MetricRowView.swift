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
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 14))
                .foregroundColor(iconColor)
                .frame(width: 18)

            Text(title)
                .font(.system(size: 13))

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12)).font(.system(size: 10))
                .foregroundColor(.gray)
        }
        // CHANGED: Reduced vertical padding to make each row shorter
        .padding(.vertical, 0.5)
    }
}
