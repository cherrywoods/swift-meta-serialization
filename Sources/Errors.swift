//
//  Errors.swift
//  meta-serialization
//
//  Created by cherrywoods on 24.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

public enum MetaEncodingError: Error {
    /// thrown if the encoding process hasn't finished properly
    case encodingProcessHasNotFinishedProperly
}

// MARK: - translator errors

enum TranslatorError: Error {
    
    /// throw this error during unwrap(meta:), if the encoded type does not match the requested type. MetaSerialization will convert this error to a DecodingError.
    case typeMismatch
    
}
