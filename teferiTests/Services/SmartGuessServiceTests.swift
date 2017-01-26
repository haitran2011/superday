@testable import teferi
import XCTest
import Foundation
import CoreLocation
import Nimble

class SmartGuessServiceTests : XCTestCase
{
    private var timeService : MockTimeService!
    private var loggingService : MockLoggingService!
    private var settingsService : MockSettingsService!
    private var persistencyService : MockSmartGuessPersistencyService!
    private let date = Date()
    
    private var smartGuessService : DefaultSmartGuessService!
    
    override func setUp()
    {
        self.timeService = MockTimeService()
        self.loggingService = MockLoggingService()
        self.settingsService = MockSettingsService()
        self.persistencyService = MockSmartGuessPersistencyService()
        
        
        self.smartGuessService = DefaultSmartGuessService(timeService: self.timeService,
                                                          loggingService: self.loggingService,
                                                          settingsService: self.settingsService,
                                                          persistencyService: self.persistencyService)
    }
    
//    func testGuessesAreFromSameWeekDayAsLocation()
//    {
//        self.persistencyService.smartGuesses =
//            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work, date.add(days: -1).addingTimeInterval(100) ),
//               ( 41.9753319073047, -71.0223522246947, teferi.Category.work, date.add(days: -2).addingTimeInterval(200) ),
//               ( 41.9753219072949, -71.0224522245947, teferi.Category.work, date.add(days: -3).addingTimeInterval(300) ),
//               ( 41.9754219072948, -71.0229522245947, teferi.Category.leisure, date.add(days: -4).addingTimeInterval(400) ),
//               ( 41.9754219072950, -71.0222522245947, teferi.Category.work, date.add(days: -5).addingTimeInterval(500) ),
//               ( 41.9757219072951, -71.0225522245947, teferi.Category.leisure, date.add(days: -6).addingTimeInterval(600) )]
//                .map(toLocation)
//                .map(toSmartGuess)
//        
//        let targetLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 41.9754219072948, longitude: -71.0230522245947), altitude: 1, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date.add(days: -11))
//        
//        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)!
//        let sameDay = smartGuess.location.timestamp.dayOfWeek == targetLocation.timestamp.dayOfWeek
//        
//        expect(sameDay).to(be(true))
//    }
//    
//    func testNoGuessesAreReturnedForWeekDayDifferentFromLocation()
//    {
//        self.persistencyService.smartGuesses =
//            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work, date.add(days: -1) ),
//               ( 41.9753319073047, -71.0223522246947, teferi.Category.work, date.add(days: -2) ),
//               ( 41.9753219072949, -71.0224522245947, teferi.Category.work, date.add(days: -3) )]
//                .map(toLocation)
//                .map(toSmartGuess)
//        
//        let targetLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 41.9754219072948, longitude: -71.0230522245947), altitude: 1, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date.add(days: -11))
//        
//        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)
//        
//        expect(smartGuess).to(beNil())
//    }
    
//    func testGuessesVeryCloseToTheLocationShouldOutweighMultipleGuessesSlightlyFurtherAway()
//    {
//        self.persistencyService.smartGuesses =
//            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work, date ),
//               ( 41.9753319073047, -71.0223522246947, teferi.Category.work, date ),
//               ( 41.9753219072949, -71.0224522245947, teferi.Category.work, date ),
//               ( 41.9754219072948, -71.0229522245947, teferi.Category.leisure, date ),
//               ( 41.9754219072950, -71.0222522245947, teferi.Category.work, date ),
//               ( 41.9757219072951, -71.0225522245947, teferi.Category.leisure, date ) ]
//                .map(toLocation)
//                .map(toSmartGuess)
//        
//        let targetLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 41.9754219072948, longitude: -71.0230522245947), altitude: 1, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
//        
//        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)!
//        
//        expect(smartGuess.category).to(equal(teferi.Category.leisure))
//    }
    
    func testGuessesVeryCloseToTheLocationShouldOutweighMultipleGuessesSlightlyFurtherAway()
    {
        self.persistencyService.smartGuesses =
            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work, date ),
               ( 41.9753319073047, -71.0223522246947, teferi.Category.work, date ),
               ( 41.9753219072949, -71.0224522245947, teferi.Category.work, date ),
               ( 41.9754219072948, -71.0229522245947, teferi.Category.leisure, date ),
               ( 41.9754219072950, -71.0222522245947, teferi.Category.work, date ),
               ( 41.9757219072951, -71.0225522245947, teferi.Category.leisure, date ) ]
                .map(toLocation)
                .map(toSmartGuess)
        
        let targetLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 41.9754219072948, longitude: -71.0230522245947), altitude: 1, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
        
        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.leisure))
    }
    
    func testGuessesVeryCloseToTheLocationShouldOutweighMultipleGuessesSlightlyFurtherAwayEvenWithoutExtraGuessesHelpingTheWeight()
    {
        self.persistencyService.smartGuesses =
            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work, date ),
               ( 41.9753319073047, -71.0223522246947, teferi.Category.work, date ),
               ( 41.9753219072949, -71.0224522245947, teferi.Category.work, date ),
               ( 41.9754219072948, -71.0229522245947, teferi.Category.leisure, date ),
               ( 41.9754219072950, -71.0222522245947, teferi.Category.work, date ) ]
                .map(toLocation)
                .map(toSmartGuess)
        
        let targetLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 41.9754219072948, longitude: -71.0230522245947), altitude: 1, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
        
        print(targetLocation.distance(from: CLLocation(latitude: 41.9752219072946, longitude: -71.0224522245947)))
        print(targetLocation.distance(from: CLLocation(latitude: 41.9753319073047, longitude: -71.0223522246947)))
        print(targetLocation.distance(from: CLLocation(latitude: 41.9753219072949, longitude: -71.0224522245947)))
        print(targetLocation.distance(from: CLLocation(latitude: 41.9754219072948, longitude: -71.0229522245947)))
        print(targetLocation.distance(from: CLLocation(latitude: 41.9754219072950, longitude: -71.0222522245947)))
        
        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.leisure))
    }
    
    func testTheAmountOfGuessesInTheSameCategoryShouldMatterWhenComparingSimilarlyDistantGuessesEvenIfTheOutnumberedGuessIsCloser()
    {
        self.persistencyService.smartGuesses =
            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work, date ),
               ( 41.9753319073047, -71.0223522246947, teferi.Category.work, date ),
               ( 41.9753219072949, -71.0224522245947, teferi.Category.work, date ),
               ( 41.9754219072950, -71.0222522245947, teferi.Category.work, date ),
               ( 41.9757219072951, -71.0225522245947, teferi.Category.leisure, date ) ]
                .map(toLocation)
                .map(toSmartGuess)
        
        let targetLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 41.9754219072948, longitude: -71.0230522245947), altitude: 1, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
        
        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.work))
    }
    
    func testTheAmountOfGuessesInTheSameCategoryShouldMatterWhenComparingSimilarlyDistantGuesses()
    {
        self.persistencyService.smartGuesses =
            [  ( 41.9752219072946, -71.0224522245947, teferi.Category.work, date ),
               ( 41.9753319073047, -71.0223522246947, teferi.Category.work, date ),
               ( 41.9753219072949, -71.0224522245947, teferi.Category.work, date ),
               ( 41.9754219072948, -71.0229522245947, teferi.Category.leisure, date ),
               ( 41.9754219072950, -71.0222522245947, teferi.Category.work, date ),
               ( 41.9754219072948, -71.0230522245947, teferi.Category.leisure, date ) ]
                .map(toLocation)
                .map(toSmartGuess)
        
        let targetLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 41.9757219072951, longitude: -71.0225522245947), altitude: 1, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: date)
        
        let smartGuess = self.smartGuessService.get(forLocation: targetLocation)!
        
        expect(smartGuess.category).to(equal(teferi.Category.work))
    }
    
    private func toLocation(latLngCategory: (Double, Double, teferi.Category, Date)) -> (CLLocation, teferi.Category)
    {
        return (CLLocation(coordinate: CLLocationCoordinate2D(latitude: latLngCategory.0, longitude: latLngCategory.1),
                           altitude: 0,
                           horizontalAccuracy: 1,
                           verticalAccuracy: 1,
                           timestamp: latLngCategory.3),
                latLngCategory.2)
    }
    
    private func toSmartGuess(locationAndCategory: (CLLocation, teferi.Category)) -> SmartGuess
    {
        return SmartGuess(withId: 0, category: locationAndCategory.1, location: locationAndCategory.0, lastUsed: Date())
    }
}
