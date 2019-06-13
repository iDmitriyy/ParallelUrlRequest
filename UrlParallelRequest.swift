//
//  UrlParallelRequest.swift
//  
//
//  Created by Dmitriy Ignatyev on 07/06/2019.
//

import Foundation

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

/** Switches all results one by one and combines 'success' values.
 If all results succeded then .success will be returned.
 If at least one result failed, then .failure will be returned. */
func combinedSuccess<A, B, C, Error>(of a: Result<A, Error>,
                                     _ b: Result<B, Error>,
                                     _ c: Result<C, Error>) -> Result<(A, B, C), Error> where Error: Swift.Error {
    switch a {
    case .success(let aValue):
        switch b {
        case .success(let bValue):
            switch c {
            case .success(let cValue): return .success((aValue, bValue, cValue))
            case .failure(let error): return .failure(error)
            }
        case .failure(let error): return .failure(error)
        }
    case .failure(let error): return .failure(error)
    }
}

/** Switches all results one by one and combines 'success' values.
 If all results succeded then .success will be returned.
 If at least one result failed, then .failure will be returned. */
func combinedSuccessOf<A, B, C, D, Error>(_ a: Result<A, Error>,
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
    
    /// All actions are nonEscaping and does not reatin objects.
    static func combine<A, B, C>(_ aAction: (_ completion: @escaping (A) -> Void) -> Void,
                                 _ bAction: (_ completion: @escaping (B) -> Void) -> Void,
                                 _ cAction: (_ completion: @escaping (C) -> Void) -> Void,
                                 completeOnQueue completionQueue: DispatchQueue = defaultCompletionQueue,
                                 completion: @escaping (A, B, C) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var maybeA: A?
        var maybeB: B?
        var maybeC: C?
        
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
        
        dispatchGroup.notify(queue: completionQueue) {
            guard let aValue = maybeA, let bValue = maybeB, let cValue = maybeC else { return }
            
            completion(aValue, bValue, cValue)
        }
    }
    
    /// All actions are nonEscaping and does not reatin objects.
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
