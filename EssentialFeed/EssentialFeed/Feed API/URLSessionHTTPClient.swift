//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Galih Samodra Wicaksono on 09/05/23.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValueRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void ) {
        session.dataTask(with: url) {data, response, error in
            completion(Result {
                if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else if let error = error {
                    throw error
                } else {
                    throw UnexpectedValueRepresentation()
                }
            })
        }.resume()
    }
}
