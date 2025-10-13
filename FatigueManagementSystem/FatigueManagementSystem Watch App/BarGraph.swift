//
//  BarGraph.swift
//  FatigueManagementSystem
//
//  Created by Tom Vo on 6/10/2025.
//
//
//  BarGraph.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 6/10/2025.
//

import SwiftUI

struct BarGraph: View {
    // An array of values (normalized between 0.0 and 1.0) to plot as bars.
    let dataPoints: [CGFloat]
    let barColor: Color
    
    init(dataPoints: [CGFloat], barColor: Color = .red) {
        self.dataPoints = dataPoints
        self.barColor = barColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(dataPoints.indices, id: \.self) { index in
                    let barHeight = geometry.size.height * self.dataPoints[index]
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor)
                        .frame(height: barHeight)
                }
            }
        }
    }
}
