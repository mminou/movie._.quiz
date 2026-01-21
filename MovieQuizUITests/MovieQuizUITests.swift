import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        try super.tearDownWithError()
    }
    
    func testYesButtom() throws {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        var indexLabel = app.staticTexts["Index"].label
        XCTAssertEqual(indexLabel, "1/10")
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        indexLabel = app.staticTexts["Index"].label
        XCTAssertEqual(indexLabel, "2/10")
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoBuuton() throws {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        var indexLabel = app.staticTexts["Index"].label
        XCTAssertEqual(indexLabel, "1/10")
        
        app.buttons["No"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        indexLabel = app.staticTexts["Index"].label
        XCTAssertEqual(indexLabel, "2/10")
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testAlertPresenter() throws {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(1)
        }
        
        sleep(3)
        let alert = app.alerts["Этот раунд окончен!"]   //.firstMatch
        XCTAssert(alert.exists)
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }
    
    func testAlertDismiss() throws {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(1)
        }
        
        sleep(3)
        let alert = app.alerts.firstMatch
        alert.buttons.firstMatch.tap()
        sleep(1)
        XCTAssertFalse(alert.exists)
        let indexLabel = app.staticTexts["Index"].label
        XCTAssertEqual(indexLabel, "1/10")
    }
}
