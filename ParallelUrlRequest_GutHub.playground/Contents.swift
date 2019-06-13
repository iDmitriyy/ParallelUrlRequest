//  Created by Dmitriy Ignatyev on 07/05/2019.
//  Copyright © 2019 Dmitriy Ignatyev. All rights reserved.

import Dispatch

// All examples are at the end of the file. Tap 'play' button and scroll down:)

enum ApiError: Error {
    case errorStub
}

/** A group of simple methods that solves routine problem: run several api requests in parallel and then combine their results */
enum ParrallelActions {
    static var defaultCompletionQueue: DispatchQueue { return .global(qos: .userInitiated) }
    
    /// All actions are nonEscaping and does not reatin objects.
    static func combine<A, B>(_ aAction: (_ completion: @escaping (A) -> Void) -> Void,
                              _ bAction: (_ completion: @escaping (B) -> Void) -> Void,
                              completeOnQueue completionQueue: DispatchQueue = defaultCompletionQueue,
                              completion: @escaping (A, B) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var maybeA: A?
        var maybeB: B?
        
        dispatchGroup.enter()
        let completionA: (A) -> Void = { value in
            maybeA = value
            dispatchGroup.leave()
        }
        aAction(completionA)
        
        
        dispatchGroup.enter()
        let completionB: (B) -> Void = { value in
            maybeB = value
            dispatchGroup.leave()
        }
        bAction(completionB)
        
        dispatchGroup.notify(queue: completionQueue) {
            guard let aValue = maybeA, let bValue = maybeB else { return }
            
            completion(aValue, bValue)
        }
    }
    
    static func combine<A, B, C, D>(_ aAction: (_ completion: @escaping (A) -> Void) -> Void,
                                    _ bAction: (_ completion: @escaping (B) -> Void) -> Void,
                                    _ cAction: (_ completion: @escaping (C) -> Void) -> Void,
                                    _ dAction: (_ completion: @escaping (D) -> Void) -> Void,
                                    completeOnQueue completionQueue: DispatchQueue = defaultCompletionQueue,
                                    completion: @escaping (A, B, C, D) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var maybeA: A?
        var maybeB: B?
        var maybeC: C?
        var maybeD: D?
        
        dispatchGroup.enter()
        let completionA: (A) -> Void = { value in
            maybeA = value
            dispatchGroup.leave()
        }
        aAction(completionA)
        
        
        dispatchGroup.enter()
        let completionB: (B) -> Void = { value in
            maybeB = value
            dispatchGroup.leave()
        }
        bAction(completionB)
        
        dispatchGroup.enter()
        let completionC: (C) -> Void = { value in
            maybeC = value
            dispatchGroup.leave()
        }
        cAction(completionC)
        
        dispatchGroup.enter()
        let completionD: (D) -> Void = { value in
            maybeD = value
            dispatchGroup.leave()
        }
        dAction(completionD)
        
        dispatchGroup.notify(queue: completionQueue) {
            guard let aValue = maybeA, let bValue = maybeB, let cValue = maybeC, let dValue = maybeD else { return }
            
            completion(aValue, bValue, cValue, dValue)
        }
    }
}

// MARK: Flatmap Success

/** Switches all results one by one and combines 'success' values.
 If all results succeded then .success will be returned.
 If at least one result failed, then .failure will be returned. */
func combinedSuccess<A, B, Error>(of a: Result<A, Error>,
                                  _ b: Result<B, Error>) -> Result<(A, B), Error> where Error: Swift.Error {
    switch a {
    case .success(let aValue):
        switch b {
        case .success(let bValue): return .success((aValue, bValue))
        case .failure(let error): return .failure(error)
        }
    case .failure(let error): return .failure(error)
    }
}

func combinedSuccess<A, B, C, D, Error>(of a: Result<A, Error>,
                                        _ b: Result<B, Error>,
                                        _ c: Result<C, Error>,
                                        _ d: Result<D, Error>) -> Result<(A, B, C, D), Error> where Error: Swift.Error {
    switch a {
    case .success(let aValue):
        switch b {
        case .success(let bValue):
            switch c {
            case .success(let cValue):
                switch d {
                case .success(let dValue): return .success((aValue, bValue, cValue, dValue))
                case .failure(let error): return .failure(error)
                }
            case .failure(let error): return .failure(error)
            }
        case .failure(let error): return .failure(error)
        }
    case .failure(let error): return .failure(error)
    }
}

// MARK: - Examples

// Imitation of ApiManager (Moya / Alamofire / ...)
final class ApiManager {
    func loadProfile(completion: @escaping (Result<String, ApiError>) -> Void) {
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + Double.random(in: 0...3)) {
            completion(.success("UserProfile_\(Int.random(in: 10...99))"))
        }
    }
    
    func loadBalance(completion: @escaping (Result<String, ApiError>) -> Void) {
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + Double.random(in: 0...3)) {
            completion(.success("Balance_\(Int.random(in: 10...99))"))
        }
    }
    
    func loadTariff(completion: @escaping (Result<String, ApiError>) -> Void) {
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + Double.random(in: 0...3)) {
            completion(.success("Tariff_\(Int.random(in: 10...99))"))
        }
    }
    
    func obtainSpecialOffers(completion: @escaping (Result<String, ApiError>) -> Void) {
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + Double.random(in: 0...3)) {
            completion(.success("Offer_\(Int.random(in: 10...99))"))
        }
    }
}

let apiManager = ApiManager()

// Wrap every Api-request with a non-escaping closure:

let profileRequest: (@escaping (Result<String, ApiError>) -> Void) -> Void = {
    apiManager.loadProfile(completion: $0)
}

let balanceRequest: (@escaping (Result<String, ApiError>) -> Void) -> Void = {
    apiManager.loadBalance(completion: $0)
}

let tariffRequest: (@escaping (Result<String, ApiError>) -> Void) -> Void = {
    apiManager.loadTariff(completion: $0)
}

let offersRequest: (@escaping (Result<String, ApiError>) -> Void) -> Void = {
    apiManager.obtainSpecialOffers(completion: $0)
}

do {
    // MARK: - Simple example. Combine 4 Api requests:
    
    ParrallelActions
        .combine(profileRequest, balanceRequest, tariffRequest, offersRequest) { profile, balance, tariff, offers in
        let finalResult = combinedSuccess(of: profile, balance, tariff, offers)
        
        switch finalResult {
        case .failure(let error):
            print(error)
        case let .success(profile, balance, tariff, offers):
            print("Simple combine: \(profile), \(balance), \(tariff), \(offers)")
        }
    }
}

do {
    // MARK: - Example of complex combine: 8 Api requests
    
    let combinedRequest1: (@escaping (Result<(String, String, String, String), ApiError>) -> Void) -> Void = { completion in
        ParrallelActions
            .combine(profileRequest, balanceRequest, tariffRequest, offersRequest) { profile, balance, tariff, offers in
            let finalResult = combinedSuccess(of: profile, balance, tariff, offers)
            completion(finalResult)
        }
    }
    
    let combinedRequest2: (@escaping (Result<(String, String, String, String), ApiError>) -> Void) -> Void = { completion in
        ParrallelActions
            .combine(profileRequest, balanceRequest, tariffRequest, offersRequest) { profile, balance, tariff, offers in
                let finalResult = combinedSuccess(of: profile, balance, tariff, offers)
                completion(finalResult)
        }
    }
    
    // and even more: combinedRequest3, combinedRequest4...
    
    ParrallelActions.combine(combinedRequest1, combinedRequest2, completeOnQueue: .main) { resul1, resul2 in
        let finalResult = combinedSuccess(of: resul1, resul2)
        
        switch finalResult {
        case .failure(let error):
            print(error)
        case let .success(first, second):
            
            let (profile, balance, tariff, offers) = first
            let (profile2, balance2, tariff2, offers2) = second
            
            print("Complex combine: \(profile), \(balance), \(tariff), \(offers) | \(profile2), \(balance2), \(tariff2), \(offers2)")
        }
    }
}
