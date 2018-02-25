//
//  Errors.swift
//  meta-serialization
//
//  Created by cherrywoods on 24.10.17.
//  Licensed under Unlicense, https://unlicense.org
//  See the LICENSE file in this project
//

import Foundation

public enum MetaEncodingError: Error {
    /// thrown if the encoding process hasn't finished properly
    case encodingProcessHasNotFinishedProperly
}
