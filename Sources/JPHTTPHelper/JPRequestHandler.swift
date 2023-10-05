//
//  JPRequest.swift
//  JHTTPHelper
//
//  Created by Jatin Patel on 10/4/23.
//

import Foundation

protocol JPRequestHandlerProtocol {
    var url:URL {get set}
    var httpMethod :JPHttpMethods {get set}
}

public struct JPRequest:JPRequestHandlerProtocol {
    var url: URL
    var httpMethod: JPHttpMethods
    var requestBody: Data?
    
    init(url: URL, httpMethod: JPHttpMethods, requestBody: Data? = nil) {
        self.url = url
        self.httpMethod = httpMethod
        self.requestBody = requestBody ?? nil
    }
}
