import SwiftUI
import Models

struct ChartDataPointView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.textBackgroundColor))
                .frame(width: 14, height: 14, alignment: .center)
                .shadow(color: Color(.textColor), radius: 2.0, x: 0.0, y: 0.0)
            Circle()
                .fill(Color(.textColor))
                .frame(width: 9, height: 9, alignment: .center)
        }
    }
}

struct ChartCalloutLabelView: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.caption)
            .foregroundColor(Color(.textBackgroundColor))
            .lineLimit(1)
            .padding(EdgeInsets(top: 3.0, leading: 10.0, bottom: 3.0, trailing: 10.0))
            .background(Color(.textColor))
            .cornerRadius(4.0)
            .shadow(color: Color(.textColor), radius: 2.0, x: 0.0, y: 0.0)
    }
}

struct ChartCalloutView: View {
    let label: String

    var body: some View {
        ZStack {
            ChartDataPointView()
            ChartCalloutLabelView(label: label)
                .offset(x: 0.0, y: -26.0)
        }
    }
}

struct ChartCalloutLineView: View {
    let start: CGPoint
    let end: CGPoint

    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(style: StrokeStyle(dash: [3.0]))
        .foregroundColor(Color(.textColor))
    }
}

struct ChartAxisLabelView: View {
    let labels: [(String, CGPoint)]

    var body: some View {
        ForEach(0..<labels.count) { idx in
            let (label, point) = labels[idx]

            Text(label)
                .italic()
                .font(.caption2)
                .fontWeight(.ultraLight)
                .position(point)
        }
    }
}

struct ChartView: View {
    private var series: DrawableDataSeries
    @State var highlightIndex: Int = 5

    init(data: [CGPoint]) {
        self.series = DrawableDataSeries(points: data)
    }

    var path: Path {
        return series.path
    }

    func transformPoint(at idx: Int, in rect: CGRect) -> CGPoint {
        return series.transformPoint(at: idx, to: rect)
    }

    func highlightPosition(in rect: CGRect) -> CGPoint {
        return transformPoint(at: highlightIndex, in: rect)
    }

    func axisLabels(in rect: CGRect) -> [(String, CGPoint)] {
        if series.count < 2 {
            return []
        }
        
        let range = 1..<series.count-1

        return range.map { (idx) -> (String, CGPoint) in
            let point = transformPoint(at: idx, in: rect)
            let labelPoint = CGPoint(x: point.x, y: rect.maxY)

            return ("7/\(idx)", labelPoint)
        }
    }

    var gradientPath: Path {
        var closedPath = path

        let bounds = closedPath.boundingRect

        closedPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        closedPath.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
        closedPath.closeSubpath()

        return closedPath
    }

    var body: some View {
        ZStack {
            Fill(path: self.path)
                .stroke(lineWidth: 3.0)
                .foregroundColor(primaryColor)
            Fill(path: self.gradientPath)
                .fill(LinearGradient(
                    gradient: .init(colors: gradientColors),
                    startPoint: .top,
                    endPoint: .bottom
                ))
//            GeometryReader(content: { geometry in
//                let rect = geometry.frame(in: .named("Graph"))
//                let highlightPos = highlightPosition(in: rect)
//                let labels = axisLabels(in: rect)
//
//                ZStack {
//                    ChartCalloutLineView(start: highlightPos, end: CGPoint(x: highlightPos.x, y: rect.maxY))
//
//                    ChartCalloutView(label: "1.5k")
//                        .position(highlightPos)
//
//                    ChartAxisLabelView(labels: labels)
//                        .padding([.top], 30.0)
//                }
//            })
        }
        .coordinateSpace(name: "Graph")
        .padding(EdgeInsets(top: 10.0, leading: 10.0, bottom: 40.0, trailing: 10.0))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    var primaryColor: Color {
        Color(.textColor)
    }

    var gradientColors: [Color] {
        [primaryColor.opacity(0.6), primaryColor.opacity(0.0)]
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 20.0),
            CGPoint(x: 1, y: 50.0),
            CGPoint(x: 2, y: 0.0),
            CGPoint(x: 3, y: -5.0),
            CGPoint(x: 4, y: 60.0),
            CGPoint(x: 5, y: 10.0),
            CGPoint(x: 6, y: 15.0),
            CGPoint(x: 7, y: 0.0)
        ]

        return ChartView(data: points)
    }
}
