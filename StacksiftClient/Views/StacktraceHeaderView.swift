import SwiftUI

struct StacktraceHeaderView: View {
    var title: String
    var subtitle: String
    var extraInfo: String

    var body: some View {
        HStack(alignment: .center, spacing: 0, content: {
            VStack(alignment: .leading, spacing: 5.0, content: {
                Text(title)
                    .font(.system(.headline, design: .monospaced))
                if subtitle != "" {
                    Text(subtitle)
                        .font(.system(.subheadline, design: .monospaced))
                }
                if extraInfo != "" {
                    Text(extraInfo)
                        .font(.system(.subheadline, design: .monospaced))
                }
            })
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        })
    }
}

struct StacktraceHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StacktraceHeaderView(title: "Crashed Thread: 0", subtitle: "", extraInfo: "")
            StacktraceHeaderView(title: "Crashed Thread: 0",
                                 subtitle: "EXC_BAD_ACCESS",
                                 extraInfo: "Something bad happened here")
        }
    }
}

