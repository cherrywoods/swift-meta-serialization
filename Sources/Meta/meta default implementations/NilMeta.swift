//
//  NilMeta.swift
//  meta-serialization
//
//  Available at the terms of the LICENSE file included in this project.
//  If none is included, available at the terms of the unlicense, see www.unlicense.org
//
import Foundation

/**
 A Meta for representing nil.
 */
public struct NilMeta: NilMetaProtocol {
    
    public static let `nil`: NilMeta = NilMeta()
    
}
