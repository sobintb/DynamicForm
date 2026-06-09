//
//  FormSchemaDecoder.swift
//  DynamicForm
//
//  Created by S O B I N on 08/06/26.
//

import Foundation

final class FormSchemaDecoder {
    
    func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }
}
