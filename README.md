# ParallelUrlRequest

A group of simple methods that solves routine problem: run several api requests in parallel and then combine their results.

```swift
let tariffRequest: (@escaping (Result<String, ApiError>) -> Void) -> Void = {
    moyaProvider.loadTariff(completion: $0)
}

let profileRequest: (@escaping (Result<String, ApiError>) -> Void) -> Void = {
    moyaProvider.loadProfile(completion: $0)
}

let authInfoRequest: (@escaping (Result<String, ApiError>) -> Void) -> Void = {
    moyaProvider.obtainAuthInfo(completion: $0)
}

ParrallelActions.combine(tariffRequest, profileRequest, authInfoRequest) { tariff, profile, authInfo in
        let finalResult = combinedSuccess(of: tariff, profile, authInfo)
        
        switch finalResult {
        case .failure(let error):
            print(error)
        case let .success(tariff, profile, authInfo):
            print("Simple combine: \(tariff), \(profile), \(authInfo)")
        }
    }
```
