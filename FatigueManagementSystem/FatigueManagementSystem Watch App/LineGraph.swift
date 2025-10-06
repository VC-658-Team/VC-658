//
//  LineGraph.swift
//  FatigueManagementSystem
//
//  Created by Tom Vo on 6/10/2025.
//


//
//  LineGraph.swift
//  FatigueManagementSystem Watch App
//
//  Created by Apple on 6/10/2025.
//

import SwiftUI

// A custom Shape that draws a line graph based on an array of data points.
struct LineGraph: Shape {
    // An array of values (normalized between 0.0 and 1.0) to plot.
    var dataPoints: [CGFloat]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Ensure there are at least two points to draw a line.
        guard dataPoints.count > 1 else {
            return path
        }

        // Move to the starting point of the graph.
        // The y-coordinate is inverted because SwiftUI's coordinate system starts from the top-left.
        let startPoint = CGPoint(x: 0, y: rect.height - (rect.height * dataPoints[0]))
        path.move(to: startPoint)

        // Iterate through the rest of the data points to draw the line segments.
        for index in 1..<dataPoints.count {
            let xPosition = rect.width * (CGFloat(index) / CGFloat(dataPoints.count - 1))
            let yPosition = rect.height - (rect.height * dataPoints[index])
            let newPoint = CGPoint(x: xPosition, y: yPosition)
            
            path.addLine(to: newPoint)
        }

        return path
    }
}
