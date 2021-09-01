import SwiftUI

fileprivate extension CGFloat {
    func isBetween(_ a: CGFloat, _ b: CGFloat) -> Bool {
        return self >= Swift.min(a, b) && self <= Swift.max(a, b)
    }
}

fileprivate extension CGPoint {
    func antipodal(at center: CGPoint) -> CGPoint {
        let newX = 2 * center.x - self.x
        let diffY = abs(self.y - center.y)
        let newY = center.y + diffY * (self.y < center.y ? 1 : -1)

        return CGPoint(x: newX, y: newY)
    }

    func midpoint(to other: CGPoint) -> CGPoint {
        return CGPoint(x: (x + other.x) / 2, y: (y + other.y) / 2);
    }
}

public struct DataSeries {
    let points: [CGPoint]

    init(points: [CGPoint]) {
        self.points = points
    }

    var dataSpace: CGRect {
        guard let firstPoint = points.first else {
            return .zero
        }

        var minX = firstPoint.x
        var maxX = firstPoint.x
        var minY = firstPoint.y
        var maxY = firstPoint.y

        for point in points {
            minX = min(point.x, minX)
            maxX = max(point.x, maxX)
            minY = min(point.y, minY)
            maxY = max(point.y, maxY)
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    var path: Path {
        var path = Path()

        guard points.count > 1 else { return path }

        var p1 = points[0]

        path.move(to: p1)

        guard points.count > 2 else {
            path.addLine(to: points[1])
            return path
        }

        var oldControlP: CGPoint?

        for i in 1..<points.count {
            let p2 = points[i]
            var p3: CGPoint?

            if i < points.count - 1 {
                p3 = points[i + 1]
            }

            let newControlP = controlPointForPoints(p1: p1, p2: p2, next: p3)

            path.addCurve(to: p2, control1: oldControlP ?? p1, control2: newControlP ?? p2)

            p1 = p2
            oldControlP = newControlP?.antipodal(at: p2)
        }

        return path
    }

    private func controlPointForPoints(p1: CGPoint, p2: CGPoint, next p3: CGPoint?) -> CGPoint? {
        guard let p3 = p3 else {
            return nil
        }

        let leftMidPoint  = p1.midpoint(to: p2)
        let rightMidPoint = p2.midpoint(to: p3)

        var controlPoint = leftMidPoint.midpoint(to: rightMidPoint.antipodal(at: p2))

        if p1.y.isBetween(p2.y, controlPoint.y) {
            controlPoint.y = p1.y
        } else if p2.y.isBetween(p1.y, controlPoint.y) {
            controlPoint.y = p2.y
        }

        let imaginControl = controlPoint.antipodal(at: p2)
        if p2.y.isBetween(p3.y, imaginControl.y) {
            controlPoint.y = p2.y
        }

        if p3.y.isBetween(p2.y, imaginControl.y) {
            let diffY = abs(p2.y - p3.y)
            controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
        }

        // I don't understand this part of the algorithm...
        controlPoint.x += (p2.x - p1.x) * 0.1

        return controlPoint
    }
}

public extension CGAffineTransform {
    static func spaceTransform(sourceSpace: CGRect, destinationSpace: CGRect, centering: Bool = true) -> CGAffineTransform {
        // move our path into drawing space by
        //
        // - translating to the path origin
        // - scaling by our size ratios
        // - translating to the drawing origin

        var transform = CGAffineTransform.identity

        transform = transform.scaledBy(x: 1.0, y: -1.0)
        transform = transform.translatedBy(x: 0.0, y: -destinationSpace.height)
        transform = transform.translatedBy(x: destinationSpace.minX, y: destinationSpace.minY)
        transform = transform.scaledBy(x: destinationSpace.width / sourceSpace.width, y: destinationSpace.height / sourceSpace.height)
        transform = transform.translatedBy(x: -sourceSpace.minX, y: -sourceSpace.minY)

        return transform
    }
}

public struct DrawableDataSeries {
    public var series: DataSeries
    public var path: Path

    public init(points: [CGPoint]) {
        self.series = DataSeries(points: points)
        self.path = self.series.path
    }

    public var count: Int {
        return series.points.count
    }

    public var boundingRect: CGRect {
        return path.boundingRect
    }

    public func transformPoint(at index: Int, to spaceRect: CGRect) -> CGPoint {
        let transform = CGAffineTransform.spaceTransform(sourceSpace: boundingRect, destinationSpace: spaceRect, centering: true)

        if index >= count {
            return CGPoint.zero
        }

        return series.points[index].applying(transform)
    }
}

