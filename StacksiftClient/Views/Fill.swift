import SwiftUI

struct Fill: Shape {
    let path: Path
    let closed: Bool

    init(path: Path, closed: Bool = false) {
        self.path = path
        self.closed = closed
    }

    func path(in rect: CGRect) -> Path {
        let bounds = path.boundingRect

        let transform = CGAffineTransform.spaceTransform(sourceSpace: bounds, destinationSpace: rect, centering: true)

        var drawingPath = path.applying(transform)

        if closed {
            drawingPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            drawingPath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            drawingPath.closeSubpath()
        }

        return drawingPath
    }
}
