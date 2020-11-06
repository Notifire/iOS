//
//  ConcurrentOperation.swift
//  Notifire
//
//  Created by David Bielik on 23/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// http://www.patrickm.io/blog/2017/05/28/swift-networking-operations.html
/// https://williamboles.me/building-a-networking-layer-with-operations/
class ConcurrentOperation: Operation {

    // MARK: - State
    enum State: String {
        case ready, executing, finished

        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }

    // Default initial state is ready
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }

    // MARK: - Operation Overrides
    override var isReady: Bool {
        return super.isReady && state == .ready
    }

    override var isExecuting: Bool {
        return state == .executing
    }

    override var isFinished: Bool {
        return state == .finished
    }

    override var isAsynchronous: Bool {
        return true
    }

    // MARK: - Lifecycle
    override func start() {
        guard !isCancelled else {
            finish()
            return
        }

        if !isExecuting {
            state = .executing
        }

        main()
    }

    func finish() {
        if isExecuting {
            state = .finished
        }
    }

    override func cancel() {
        super.cancel()
        finish()
    }
}

class ProtectedNetworkOperation<RequestResponse: Decodable>: ConcurrentOperation {

    // MARK: - Properties
    let apiManager: NotifireProtectedAPIManager
    var completionHandler: NotifireAPIBaseManager.Callback<RequestResponse>?
    var result: NotifireAPIBaseManager.ManagerResult<RequestResponse>?

    // MARK: - Initialization
    init(apiManager: NotifireProtectedAPIManager) {
        self.apiManager = apiManager
    }

    // MARK: - Inherited
    override func main() {
        guard !isCancelled else { return }
        super.main()
    }

    // MARK: - Functions
    func complete(result: NotifireAPIBaseManager.ManagerResult<RequestResponse>) {
        finish()

        self.result = result

        if !isCancelled {
            completionHandler?(result)
        }
    }
}
