//
//  FormSchemaDecoderTests.swift
//  DynamicFormTests
//
//  Created by S O B I N on 08/06/26.
//

import XCTest
@testable import DynamicForm

@MainActor  // just used to hide warning
final class FormSchemaDecoderTests: XCTestCase {

   
    private var decoder: FormSchemaDecoder!

    override func setUp() {
        super.setUp()

        decoder = FormSchemaDecoder()
    }

    override func tearDown() {
        
        decoder = nil
        
        super.tearDown()
    }
    
    func testDecodeFormSchema() throws {

        let json = """
        {
          "theme": {
            "background_color": "#FF",
            "text_color": "#111827",
            "border_color": "#D1D5DB",
            "error_color": "#B91C1C"
          },
          "form_title": "Campaign Setup",
          "fields": []
        }
        """

        let data = Data(json.utf8)

        let schema = try decoder.decode(FormSchema.self, from: data)

        XCTAssertEqual(schema.formTitle, "Campaign Setup")
    }
    
    func testMalformedJSONThrowsError() {

        let json = """
        {
          "form_title": "Campaign Setup"
        """

        let data = Data(json.utf8)

        XCTAssertThrowsError(
            try decoder.decode(FormSchema.self, from: data)
        )
    }
    
    func testTextFieldCase() throws {
        
        let json = """
                {
                  "id": "campaign_name",
                  "order": 1,
                  "type": "TEXT",
                  "subtype": "PLAIN",
                  "label": "Campaign Name",
                  "placeholder": "e.g., Summer Sale",
                  "max_length": 30,
                  "error_message": "Name is required.",
                  "required": true
                }
            """
        let data = Data(json.utf8)
        
        let field = try decoder.decode(FormField.self, from: data)
        
        XCTAssertEqual(field.id, "campaign_name")
        switch field {
        case .text(let config):
            XCTAssertEqual(config.id, "campaign_name")
            XCTAssertEqual(config.order, 1)
            XCTAssertEqual(config.label, "Campaign Name")
            XCTAssertEqual(config.maxLength, 30)
            XCTAssertTrue(config.required)
            
        default:
            XCTFail("Failed Text")
        }
        
    }
    
    func testDecodeUnknownField() throws {

        let json = """
        {
          "id": "future_field",
          "order": 99,
          "type": "RADIO"
        }
        """
        let data = Data(json.utf8)

        let field = try decoder.decode(FormField.self, from: data)

        switch field {

        case .unknown(let id, let order):

            XCTAssertEqual(id, "future_field")
            XCTAssertEqual(order, 99)

        default:
            XCTFail("Expected .unknown case")
        }
    }

}
