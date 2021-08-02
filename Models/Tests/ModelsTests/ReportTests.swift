import XCTest
@testable import Models

final class ReportTests: XCTestCase {
    func testRenderReport() throws {
        let bundle = Bundle.module
        let reportDataURL = try XCTUnwrap(bundle.url(forResource: "08a3eb98c83a4ab9b9cc7a890967b4a8", withExtension: "report"))
        let reportData = try Data(contentsOf: reportDataURL)
        let report = try JSONDecoder().decode(Report.self, from: reportData)

        let expectedOutputURL = try XCTUnwrap(bundle.url(forResource: "08a3eb98c83a4ab9b9cc7a890967b4a8", withExtension: "crash"))
        let expectedOutput = try String(contentsOf: expectedOutputURL)

        let output = try report.renderReportCrash().string

        XCTAssertEqual(output, expectedOutput)
    }
}
