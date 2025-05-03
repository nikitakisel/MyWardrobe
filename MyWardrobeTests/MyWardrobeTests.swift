//
//  MyWardrobeTests.swift
//  MyWardrobeTests
//
//  Created by Никита Киселев on 18.03.2025.
//

import Testing
import XCTest
@testable import MyWardrobe
import UIKit


class DBManagerTests: XCTestCase {
    var dbConnection: DBManager? = DBManager()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        dbConnection = nil
        super.tearDown()
    }
    
    //MARK: - Tests
    
    func testInsertIntoClothes() {
        let clothesTableRecordsCount = dbConnection!.readClothes().count
        dbConnection!.insertIntoClothes(name: "Example", description: "", category: "Голова", tempMin: -1, tempMax: 1, image: "")
        XCTAssertEqual(dbConnection!.readClothes().count, clothesTableRecordsCount + 1)
    }
    
    func testDeleteFromClothes() {
        let clothes = dbConnection!.readClothes()
        let clothesTableRecordsCount = clothes.count
        
        var maxId = -1
        for item in clothes {
            if item.id > maxId {
                maxId = item.id
            }
        }
        
        dbConnection!.deleteByIDFromClothes(id: maxId)
        XCTAssertEqual(dbConnection!.readClothes().count, clothesTableRecordsCount - 1)
    }
}


class AddClothesViewControllerTests: XCTestCase {

    var viewController: AddClothesViewController!
    var mockDelegate: MockAddNewClothesDelegate!
    var mockDBManager: MockDBManager!
    var dbConnection: DBManager!

    override func setUp() {
        super.setUp()

        // Instantiate the view controller from the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name
        viewController = storyboard.instantiateViewController(withIdentifier: "AddClothesViewController") as? AddClothesViewController
        viewController.loadViewIfNeeded()

        // Instantiate mock delegate and DBManager
        mockDelegate = MockAddNewClothesDelegate()
        viewController.addNewClothesDelegate = mockDelegate
        
        dbConnection = DBManager()
        mockDBManager = MockDBManager()
        // Replace DBManager with MockDBManager (assuming you have access to it)
        // In order to do this you will need to replace all instances of the real DBManager with calls to your mock object
        // This will enable you to test functionality without needing to setup and use an actual database.
        
        //viewController.dbConnection = mockDBManager
    }
    

    override func tearDown() {
        viewController = nil
        mockDelegate = nil
        super.tearDown()
    }
    

    // MARK: - Helper Functions
    func populateTextFields(name: String = "TestName", description: String = "TestDescription") {
        viewController.nameTextField.text = name
        viewController.descriptionTextField.text = description
    }
    

    // MARK: - Tests

    func testViewDidLoad() {
        XCTAssertEqual(viewController.viewControllerTitle.text, "Новая одежда", "ViewController title should be 'Новая одежда'")
        XCTAssertNotNil(viewController.categoryPickerView.delegate, "categoryPickerView delegate should not be nil")
        XCTAssertNotNil(viewController.categoryPickerView.dataSource, "categoryPickerView dataSource should not be nil")
        XCTAssertNotNil(viewController.tempMinPickerView.delegate, "tempMinPickerView delegate should not be nil")
        XCTAssertNotNil(viewController.tempMinPickerView.dataSource, "tempMinPickerView dataSource should not be nil")
        XCTAssertNotNil(viewController.tempMaxPickerView.delegate, "tempMaxPickerView delegate should not be nil")
        XCTAssertNotNil(viewController.tempMaxPickerView.dataSource, "tempMaxPickerView dataSource should not be nil")
        XCTAssertFalse(viewController.temps.isEmpty, "temps array should not be empty")
        XCTAssertEqual(viewController.categories.count, 5, "categories array should have 5 elements")
    }
    

    func testInitTempPickerViews() {
        viewController.initTempPickerViews(minValue: -10, maxValue: 30)
        XCTAssertEqual(viewController.tempMinValue, -10, "tempMinValue should be -10")
        XCTAssertEqual(viewController.tempMaxValue, 30, "tempMaxValue should be 30")
    }
    

    func testInitStringPickerView() {
        viewController.initStringPickerView(categoryValue: "Нижняя")
        XCTAssertEqual(viewController.category, "Нижняя", "category should be 'Нижняя'")
    }
    

    func testTextFieldShouldReturn() {
        let textField = UITextField()
        let result = viewController.textFieldShouldReturn(textField)
        XCTAssertTrue(result, "textFieldShouldReturn should return true")
        XCTAssertNil(textField.isFirstResponder ? textField : nil, "textField should resign first responder")
    }
    

    func testAddPostButtonPressed_normalCase() {
        let clothesTableRecordsCount = dbConnection.readClothes().count
        
        viewController.nameTextField.text = "Кросовки Nike Pro"
        viewController.descriptionTextField.text = "Четкие педали для четких пацанов"
        viewController.initStringPickerView(categoryValue: "Обувь")
        viewController.initTempPickerViews(minValue: -10, maxValue: 30)
        viewController.addPostButtonPressed(UIButton())
        
        XCTAssertEqual(dbConnection.readClothes().count, clothesTableRecordsCount + 1)
    }
    
    
    func testAddPostButtonPressed_emptyName() {
        let clothesTableRecordsCount = dbConnection.readClothes().count
        
        viewController.nameTextField.text = ""
        viewController.descriptionTextField.text = "-"
        viewController.initStringPickerView(categoryValue: "Голова")
        viewController.initTempPickerViews(minValue: -10, maxValue: 30)
        viewController.addPostButtonPressed(UIButton())
        
        XCTAssertEqual(dbConnection.readClothes().count, clothesTableRecordsCount)
    }
    
    
    func testAddPostButtonPressed_incorrectTemp() {
        let clothesTableRecordsCount = dbConnection.readClothes().count
        
        viewController.nameTextField.text = "Кросовки Nike Pro"
        viewController.descriptionTextField.text = "Четкие педали для четких пацанов"
        viewController.initStringPickerView(categoryValue: "Обувь")
        viewController.initTempPickerViews(minValue: 40, maxValue: 30)
        viewController.addPostButtonPressed(UIButton())
        
        XCTAssertEqual(dbConnection.readClothes().count, clothesTableRecordsCount)
    }
    
    
    func testClearForm() {
        // Given
        populateTextFields(name: "InitialName", description: "InitialDescription")

        // When
        viewController.clearForm()

        // Then
        XCTAssertTrue((viewController.nameTextField.text?.isEmpty)!, "NameTextField should be empty")
        XCTAssertTrue((viewController.descriptionTextField.text?.isEmpty)!, "DescriptionTextField should be empty")
    }

    // MARK: - Mock Classes
    class MockAddNewClothesDelegate: AddNewClothesDelegate {
        var updateAllClothesTableCalled = false
        func updateAllClothesTable() {
            updateAllClothesTableCalled = true
        }
    }

    class MockDBManager: DBManager {
        var insertIntoClothesCalled = false
        var updateClothesCalled = false

        override func insertIntoClothes(name: String, description: String, category: String, tempMin: Int, tempMax: Int, image: String) {
            insertIntoClothesCalled = true
        }

        override func updateClothes(id: Int, name: String, description: String, category: String, tempMin: Int, tempMax: Int, image: String) {
            updateClothesCalled = true
        }
    }
    
    class MockAddClothesViewController: AddClothesViewController {
        var alertClosure: ((String?, String?) -> Void)?

        override func alert(message: String) {
            alertClosure?("Ошибка", message)
        }
    }
}


class AddLooksetViewControllerTests: XCTestCase {

    var viewController: AddLooksetViewController!
    var mockDBManager: MockDBManager!
    var mockDelegate: MockUpdateLooksetDelegate!

    override func setUp() {
        super.setUp()

        // Instantiate the view controller from the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "AddLooksetViewController") as? AddLooksetViewController
        viewController.loadViewIfNeeded()

        // Instantiate mock objects
        mockDBManager = MockDBManager()
        viewController.dbConnection = mockDBManager

        mockDelegate = MockUpdateLooksetDelegate()
        viewController.updateLooksetDelegate = mockDelegate
    }

    override func tearDown() {
        viewController = nil
        mockDBManager = nil
        mockDelegate = nil
        super.tearDown()
    }

    // MARK: - Helper Functions
    func populateTextFields(name: String = "TestName", description: String = "TestDescription") {
        viewController.looksetNameTextField.text = name
        viewController.looksetDescriptionTextField.text = description
    }

    // MARK: - Tests

    func testViewDidLoad() {
        XCTAssertEqual(viewController.addLooksetVCTitle.text, "Новый стиль", "ViewController title should be 'Новый стиль'")
        XCTAssertNotNil(viewController.selectedTempPickerView.delegate, "selectedTempPickerView delegate should not be nil")
        XCTAssertNotNil(viewController.selectedTempPickerView.dataSource, "selectedTempPickerView dataSource should not be nil")
        XCTAssertFalse(viewController.temps.isEmpty, "temps array should not be empty")
        XCTAssertEqual(viewController.temps.count, 91, "temps array should have 91 elements")
        XCTAssertEqual(viewController.currentTempValue, 25, "currentTempValue should be 25")
    }

    func testSetCurrentTemp() {
        viewController.setCurrentTemp(currentTemp: 10)
        XCTAssertEqual(viewController.currentTempValue, 10, "currentTempValue should be updated to 10")
        let selectedRow = viewController.selectedTempPickerView.selectedRow(inComponent: 0)
        XCTAssertEqual(viewController.temps[selectedRow], 10, "Picker view should select row with value 10")
    }

    func testTextFieldShouldReturn() {
        let textField = UITextField()
        let result = viewController.textFieldShouldReturn(textField)
        XCTAssertTrue(result, "textFieldShouldReturn should return true")
        XCTAssertNil(textField.isFirstResponder ? textField : nil, "textField should resign first responder")
    }

    func testAddLookset() {
        // Given
        populateTextFields()
        viewController.currentTempValue = 20
        viewController.looksetDict = ["Голова": 1, "Верхняя": 2, "Под верх": 3, "Нижняя": 4, "Обувь": 5]

        // When
        viewController.addLookset()

        // Then
        XCTAssertTrue(mockDBManager.insertIntoLooksetCalled, "insertIntoLookset should be called")
        XCTAssertEqual(mockDBManager.insertedLooksetName, "TestName", "Lookset name should match")
        XCTAssertEqual(mockDBManager.insertedLooksetDescription, "TestDescription", "Lookset description should match")
        XCTAssertEqual(mockDBManager.insertedLooksetTemp, 20, "Lookset temp should match")
        XCTAssertEqual(mockDBManager.insertedHeadId, 1, "Head ID should match")
        XCTAssertEqual(mockDBManager.insertedJacketId, 2, "Jacket ID should match")
        XCTAssertEqual(mockDBManager.insertedTshirtId, 3, "T-shirt ID should match")
        XCTAssertEqual(mockDBManager.insertedTrousersId, 4, "Trousers ID should match")
        XCTAssertEqual(mockDBManager.insertedShoesId, 5, "Shoes ID should match")
    }

    func testUpdateLookset() {
        // Given
        populateTextFields()
        viewController.currentTempValue = 20
        viewController.looksetDict = ["Голова": 1, "Верхняя": 2, "Под верх": 3, "Нижняя": 4, "Обувь": 5]
        viewController.isEditingModeOn = true
        viewController.editedLooksetId = 10

        // When
        viewController.updateLookset()

        // Then
        XCTAssertTrue(mockDBManager.updateLooksetCalled, "updateLookset should be called")
        XCTAssertEqual(mockDBManager.updatedLooksetId, 10, "Lookset ID should match")
        XCTAssertEqual(mockDBManager.updatedLooksetName, "TestName", "Lookset name should match")
        XCTAssertEqual(mockDBManager.updatedLooksetDescription, "TestDescription", "Lookset description should match")
        XCTAssertEqual(mockDBManager.updatedLooksetTemp, 20, "Lookset temp should match")
        XCTAssertEqual(mockDBManager.updatedHeadId, 1, "Head ID should match")
        XCTAssertEqual(mockDBManager.updatedJacketId, 2, "Jacket ID should match")
        XCTAssertEqual(mockDBManager.updatedTshirtId, 3, "T-shirt ID should match")
        XCTAssertEqual(mockDBManager.updatedTrousersId, 4, "Trousers ID should match")
        XCTAssertEqual(mockDBManager.updatedShoesId, 5, "Shoes ID should match")
    }

    func testAlert() {
        let expectation = XCTestExpectation(description: "Alert is presented")

        let mockViewController = MockAddLooksetViewController()

        mockViewController.alertClosure = { title, message in
            XCTAssertEqual(title, "Успешно!", "Title should be 'Успешно!'")
            XCTAssertEqual(message, "Test message", "Message should be 'Test message'")
            expectation.fulfill()
        }

        mockViewController.alert(message: "Test message")

        wait(for: [expectation], timeout: 1.0)
    }

    func testAlert_callsDelegate() {
        // Given
        let mockViewController = MockAddLooksetViewController()
        mockViewController.updateLooksetDelegate = mockDelegate // Set the delegate
        let expectation = XCTestExpectation(description: "Delegate method called")

        mockDelegate.expectation = expectation

        // When
        mockViewController.alert(message: "Test message")

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockDelegate.updateLooksetTableCalled, "updateLooksetTable should be called")
    }

    func testClearForm() {
        // Given
        populateTextFields(name: "InitialName", description: "InitialDescription")

        // When
        viewController.clearForm()

        // Then
        XCTAssertTrue((viewController.looksetNameTextField.text?.isEmpty)!, "looksetNameTextField should be empty")
        XCTAssertTrue((viewController.looksetDescriptionTextField.text?.isEmpty)!, "looksetDescriptionTextField should be empty")
    }

    // MARK: - Mock Classes
    class MockDBManager: DBManager {
        var insertIntoLooksetCalled = false
        var updateLooksetCalled = false

        var insertedLooksetName: String?
        var insertedLooksetDescription: String?
        var insertedLooksetTemp: Int?
        var insertedHeadId: Int?
        var insertedJacketId: Int?
        var insertedTshirtId: Int?
        var insertedTrousersId: Int?
        var insertedShoesId: Int?

        var updatedLooksetId: Int?
        var updatedLooksetName: String?
        var updatedLooksetDescription: String?
        var updatedLooksetTemp: Int?
        var updatedHeadId: Int?
        var updatedJacketId: Int?
        var updatedTshirtId: Int?
        var updatedTrousersId: Int?
        var updatedShoesId: Int?

        override func insertIntoLookset(looksetName: String, looksetDescription: String, looksetTemp: Int, headId: Int, jacketId: Int, tshirtId: Int, trousersId: Int, shoesId: Int) {
            insertIntoLooksetCalled = true
            insertedLooksetName = looksetName
            insertedLooksetDescription = looksetDescription
            insertedLooksetTemp = looksetTemp
            insertedHeadId = headId
            insertedJacketId = jacketId
            insertedTshirtId = tshirtId
            insertedTrousersId = trousersId
            insertedShoesId = shoesId
        }

        override func updateLookset(id: Int, looksetName: String, looksetDescription: String, looksetTemp: Int, headId: Int, jacketId: Int, tshirtId: Int, trousersId: Int, shoesId: Int) {
            updateLooksetCalled = true
            updatedLooksetId = id
            updatedLooksetName = looksetName
            updatedLooksetDescription = looksetDescription
            updatedLooksetTemp = looksetTemp
            updatedHeadId = headId
            updatedJacketId = jacketId
            updatedTshirtId = tshirtId
            updatedTrousersId = trousersId
            updatedShoesId = shoesId
        }
    }

    class MockUpdateLooksetDelegate: UpdateLooksetDelegate {
        var updateLooksetTableCalled = false
        var expectation: XCTestExpectation?

        func updateLooksetTable() {
            updateLooksetTableCalled = true
            expectation?.fulfill()
        }
    }

    class MockAddLooksetViewController: AddLooksetViewController {
        var alertClosure: ((String?, String?) -> Void)?

        override func alert(message: String) {
            alertClosure?("Успешно!", message)
            self.updateLooksetDelegate?.updateLooksetTable() // Simulate delegate call
        }
    }
}


//class ClothesItemInfoViewControllerTests: XCTestCase {
//
//    var viewController: ClothesItemInfoViewController!
//    var mockDelegate: MockAddNewClothesDelegate!
//    var mockDBManager: MockDBManager!
//
//    override func setUp() {
//        super.setUp()
//
//        // Instantiate the view controller from the storyboard
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        viewController = storyboard.instantiateViewController(withIdentifier: "ClothesItemInfoViewController") as? ClothesItemInfoViewController
//        viewController.loadViewIfNeeded()
//
//        // Instantiate mock objects
//        mockDelegate = MockAddNewClothesDelegate()
//        viewController.addNewClothesDelegate = mockDelegate
//
//        mockDBManager = MockDBManager()
//    }
//
//    override func tearDown() {
//        viewController = nil
//        mockDelegate = nil
//        mockDBManager = nil
//        super.tearDown()
//    }
//
//    // MARK: - Helper Functions
//    func createTestClothes() -> Clothes {
//        let imageData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=")! // Minimal valid image data
//        return Clothes(id: 123, name: "Test Clothes", description: "Test Description", category: "Test Category", tempMin: 10, tempMax: 25, image: imageData)
//    }
//
//    // MARK: - Tests
//
//    func testViewDidLoad() {
//        // Initially, labels should be empty or have default values
//        XCTAssertEqual(viewController.clothesItemNameLabel.text, "", "Name label should be empty initially")
//        XCTAssertEqual(viewController.clothesItemDescriptionLabel.text, "", "Description label should be empty initially")
//        XCTAssertEqual(viewController.clothesItemTempsLabel.text, "", "Temps label should be empty initially")
//    }
//
//    func testViewWillAppear() {
//        let navigationController = MockNavigationController(rootViewController: viewController)
//        UIApplication.shared.windows.first?.rootViewController = navigationController // Required for viewWillAppear to be called
//
//        viewController.viewWillAppear(false)
//        XCTAssertFalse(navigationController.isNavigationBarHidden, "Navigation bar should be visible")
//
//        viewController.viewWillAppear(true) // Test animated = true as well
//        XCTAssertFalse(navigationController.isNavigationBarHidden, "Navigation bar should be visible even when animated")
//
//        //Clean up after test
//        UIApplication.shared.windows.first?.rootViewController = nil
//    }
//
//    func testUploadInfo() {
//        // Given
//        let clothes = createTestClothes()
//
//        // When
//        let expectation = XCTestExpectation(description: "Upload info updates UI")
//        DispatchQueue.main.async {
//            self.viewController.uploadInfo(info: clothes)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 1.0)
//
//        // Then
//        XCTAssertEqual(viewController.clothesItemNameLabel.text, "Test Clothes", "Name label should be updated")
//        XCTAssertEqual(viewController.clothesItemDescriptionLabel.text, "Test Description", "Description label should be updated")
//        XCTAssertEqual(viewController.clothesItemTempsLabel.text, "Температура: от 10°C до 25°C", "Temps label should be updated")
//        XCTAssertNotNil(viewController.clothesItemImageView.image, "Image view should have an image")
//    }
//
//    func testUpdateAllClothesTable() {
//        // When
//        viewController.updateAllClothesTable()
//
//        // Then
//        XCTAssertTrue(mockDelegate.updateAllClothesTableCalled, "Delegate method should be called")
//    }
//
//    func testEditClothesItemButtonPressed() {
//        // Given
//        let clothes = createTestClothes()
//        viewController.info = clothes // Initialize 'info' before pressing the button
//
//        // When
//        viewController.editClothesItemButtonPressed(UIButton())
//
//        // Then
//        // Assert that AddClothesViewController is pushed onto the navigation stack
//        let navigationController = viewController.navigationController
//        XCTAssertTrue(navigationController?.viewControllers.last is AddClothesViewController, "AddClothesViewController should be pushed onto navigation stack")
//
//        // Further assertions (if needed):
//        if let addClothesVC = navigationController?.viewControllers.last as? AddClothesViewController {
//            XCTAssertEqual(addClothesVC.clothesItemNameTextField.text, "Test Clothes", "Name should be passed to AddClothesViewController")
//            XCTAssertEqual(addClothesVC.clothesItemDescriptionTextField.text, "Test Description", "Description should be passed to AddClothesViewController")
//            XCTAssertEqual(addClothesVC.minTempTextField.text, "10", "Min Temp should be passed")
//            XCTAssertEqual(addClothesVC.maxTempTextField.text, "25", "Max temp should be passed")
//        }
//
//    }
//
//    func testDeleteClothesItemButtonPressed_presentsAlert() {
//        // Given
//        let clothes = createTestClothes()
//        viewController.info = clothes
//
//        // When
//        let expectation = XCTestExpectation(description: "Alert is presented")
//        let presentingVC = MockViewController()
//        viewController.modalPresentationStyle = .fullScreen
//        presentingVC.present(viewController, animated: false) {
//                expectation.fulfill()
//        }
//
//        viewController.deleteClothesItemButtonPressed(UIButton())
//        wait(for: [expectation], timeout: 2.0)
//
//        // Then
//        XCTAssertTrue(viewController.presentedViewController is UIAlertController, "Alert should be presented")
//
//        if let alertController = viewController.presentedViewController as? UIAlertController {
//            XCTAssertEqual(alertController.title, "Удаление", "Alert title should be correct")
//            XCTAssertEqual(alertController.message, "Вы уверены, что хотите удалить данную вещь?", "Alert message should be correct")
//            XCTAssertEqual(alertController.actions.count, 2, "Alert should have two actions")
//        }
//        presentingVC.dismiss(animated: false, completion: nil)
//    }
//
//    func testDeleteClothesItem_deletesItemAndUpdatesUI() {
//        // Given
//        let clothes = createTestClothes()
//        viewController.info = clothes
//        viewController.addNewClothesDelegate = mockDelegate
//        viewController.dbConnection = mockDBManager
//
//        //Mock presenting VC
//        let presentingVC = MockViewController()
//        viewController.modalPresentationStyle = .fullScreen
//        presentingVC.present(viewController, animated: false, completion: nil)
//
//        // Create an expectation for the alert presentation and action execution
//        let alertExpectation = XCTestExpectation(description: "Alert presented and action executed")
//
//        // Mock the UIAlertController presentation to immediately trigger the 'Yes' action
//        viewController.mockAlertPresentation = { [weak viewController] (alert) in
//            // Simulate tapping the "Yes" button on the alert
//            if let action = alert.actions.first(where: { $0.title == "ОК" }) {
//                action.handler?(action) // Simulate the button press
//                alertExpectation.fulfill() // Fulfill the expectation
//                presentingVC.dismiss(animated: false, completion: nil)
//            }
//        }
//
//        // When
//        viewController.deleteClothesItem()
//
//        // Then
//        wait(for: [alertExpectation], timeout: 2.0)
//        XCTAssertTrue(mockDBManager.deleteByIDFromClothesCalled, "deleteByIDFromClothes should be called")
//        XCTAssertEqual(mockDBManager.deletedClothesId, clothes.id, "Correct clothes id should be passed to deleteByIDFromClothes")
//        XCTAssertTrue(mockDelegate.updateAllClothesTableCalled, "Delegate's updateAllClothesTable should be called")
//        XCTAssertTrue(viewController.navigationController?.popViewControllerCalled == true, "Navigation controller popViewController should be called")
//
//    }
//    //MARK: - Mocks
//
//    class MockAddNewClothesDelegate: AddNewClothesDelegate {
//        var updateAllClothesTableCalled = false
//
//        func updateAllClothesTable() {
//            updateAllClothesTableCalled = true
//        }
//    }
//
//    class MockDBManager: DBManager {
//        var deleteByIDFromClothesCalled = false
//        var deletedClothesId: Int?
//
//        override func deleteByIDFromClothes(id: Int) {
//            deleteByIDFromClothesCalled = true
//            deletedClothesId = id
//        }
//    }
//
//    class MockNavigationController: UINavigationController {
//        var isNavigationBarHidden = false
//        var popViewControllerCalled = false
//
//        override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
//            isNavigationBarHidden = hidden
//        }
//
//        override func popViewController(animated: Bool) -> UIViewController? {
//            popViewControllerCalled = true
//            return UIViewController() // Dummy return
//        }
//    }
//
//    class MockViewController: UIViewController {
//
//        var presentationExpectation: XCTestExpectation?
//
//        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
//            super.present(viewControllerToPresent, animated: flag, completion: completion)
//        }
//    }
//    // Extend the ViewController to be able to mock the alert presentation
//    extension ClothesItemInfoViewController {
//        typealias AlertPresentationBlock = (UIAlertController) -> Void
//        var mockAlertPresentation: AlertPresentationBlock? {
//            get {
//                return objc_getAssociatedObject(self, &AssociatedKeys.mockAlertPresentation) as? AlertPresentationBlock
//            }
//            set {
//                objc_setAssociatedObject(self, &AssociatedKeys.mockAlertPresentation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//
//        private struct AssociatedKeys {
//            static var mockAlertPresentation: UInt8 = 0
//        }
//
//        override func present(_ alert: UIAlertController, animated flag: Bool, completion: (() -> Void)? = nil) {
//            if let mockAlertPresentation = mockAlertPresentation {
//                mockAlertPresentation(alert)
//            } else {
//                super.present(alert, animated: flag, completion: completion)
//            }
//        }
//    }
//}
