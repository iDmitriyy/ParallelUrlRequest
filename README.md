# ParallelUrlRequest

A group of simple methods that solves routine problem: run several api requests in parallel and then combine their results.

```swift
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
```
