////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#if canImport(Combine)
import XCTest
import Combine
import RealmSwift

@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
extension Publisher {
    public func signal(_ semaphore: DispatchSemaphore) -> Combine.Publishers.HandleEvents<Self> {
        self.handleEvents(receiveOutput: { _ in semaphore.signal() })
    }
}

// XCTest doesn't care about the @available on the class and will try to run
// the tests even on older versions. Putting this check inside `defaultTestSuite`
// results in a warning about it being redundant due to the enclosing check, so
// it needs to be out of line.
func hasCombine() -> Bool {
    if #available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *) {
        return true
    }
    return false
}

@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
class CombineTestCase: TestCase {
    var realm: Realm!
    var token: AnyCancellable?
    let subscribeOnQueue = DispatchQueue(label: "subscribe on")
    let receiveOnQueue = DispatchQueue(label: "receive on")

    override class var defaultTestSuite: XCTestSuite {
        if hasCombine() {
            return super.defaultTestSuite
        }
        return XCTestSuite(name: "\(type(of: self))")
    }

    override func setUp() {
        super.setUp()
        realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "test"))
    }

    override func tearDown() {
        if let token = token {
            token.cancel()
        }
        realm.invalidate()
        realm = nil
        subscribeOnQueue.sync { }
        receiveOnQueue.sync { }
        super.tearDown()
    }
}

@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
class CombineRealmTests: CombineTestCase {
    func testWillChangeLocalWrite() {
        var called = false
        token = realm.objectWillChange.sink {
            called = true
        }
        try! realm.write {
            realm.create(SwiftIntObject.self, value: [])
        }
        XCTAssertTrue(called)
    }

    func testWillChangeRemoteWrite() {
        let exp = XCTestExpectation()
        token = realm.objectWillChange.sink {
            exp.fulfill()
        }
        subscribeOnQueue.async {
            let backgroundRealm = try! Realm(configuration: self.realm.configuration)
            try! backgroundRealm.write {
                backgroundRealm.create(SwiftIntObject.self, value: [])
            }
        }
        wait(for: [exp], timeout: 1)
    }
}

@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
class CombineObjectPublisherTests: CombineTestCase {
    var obj: SwiftIntObject!

    override func setUp() {
        super.setUp()
        obj = try! realm.write { realm.create(SwiftIntObject.self, value: []) }
    }

    func testWillChange() {
        let exp = XCTestExpectation()
        token = obj.objectWillChange.sink {
            exp.fulfill()
        }
        try! realm.write { obj.intCol = 1 }
        wait(for: [exp], timeout: 1)
    }

    func testChange() {
        let exp = XCTestExpectation()
        token = valuePublisher(obj).assertNoFailure().sink { o in
            XCTAssertEqual(self.obj, o)
            exp.fulfill()
        }

        try! realm.write { obj.intCol = 1 }
        wait(for: [exp], timeout: 1)
    }

    func testChangeSet() {
        let exp = XCTestExpectation()
        token = changesetPublisher(obj).assertNoFailure().sink { change in
            if case .change(let o, let properties) = change {
                XCTAssertEqual(self.obj, o)
                XCTAssertEqual(properties.count, 1)
                XCTAssertEqual(properties[0].name, "intCol")
                XCTAssertNil(properties[0].oldValue)
                XCTAssertEqual(properties[0].newValue as? Int, 1)
            } else {
                XCTFail("Expected .change but got \(change)")
            }
            exp.fulfill()
        }

        try! realm.write { obj.intCol = 1 }
        wait(for: [exp], timeout: 1)
    }

    func testDelete() {
        let exp = XCTestExpectation()
        token = valuePublisher(obj).sink(receiveCompletion: { _ in exp.fulfill() },
                                         receiveValue: { _ in })
        try! realm.write { realm.delete(obj) }
        wait(for: [exp], timeout: 1)
    }

    func testSubscribeOn() {
        let sema = DispatchSemaphore(value: 0)
        var i = 1
        token = valuePublisher(obj)
            .subscribe(on: subscribeOnQueue)
            .map { obj -> SwiftIntObject in
                sema.signal()
                XCTAssertEqual(obj.intCol, i)
                i += 1
                return obj
            }
            .collect()
            .assertNoFailure()
            .sink { arr in
                XCTAssertEqual(arr.count, 10)
                sema.signal()
            }

        for _ in 0..<10 {
            try! realm.write { obj.intCol += 1 }
            // wait between each write so that the notifications can't get coalesced
            // also would deadlock if the subscription was on the main thread
            sema.wait()
        }
        try! realm.write { realm.delete(obj) }
        sema.wait()
    }

    func testReceiveOn() {
        var exp = XCTestExpectation()
        token = valuePublisher(obj)
            .receive(on: receiveOnQueue)
            .map { obj -> Int in
                exp.fulfill()
                return obj.intCol
            }
            .collect()
            .assertNoFailure()
            .sink { arr in
                XCTAssertEqual(arr.count, 10)
                for i in 1..<10 {
                    XCTAssertTrue(arr.contains(i))
                }
                exp.fulfill()
            }

        for _ in 0..<10 {
            try! realm.write { obj.intCol += 1 }
            wait(for: [exp], timeout: 10)
            exp = XCTestExpectation()
        }
        try! realm.write { realm.delete(obj) }
        wait(for: [exp], timeout: 10)
    }

    func testChangeSetSubscribeOn() {
        let sema = DispatchSemaphore(value: 0)

        var prev: SwiftIntObject?
        token = changesetPublisher(obj)
            .subscribe(on: subscribeOnQueue)
            .assertNoFailure()
            .sink(receiveCompletion: { _ in sema.signal() }, receiveValue: { change in
                if case .change(let o, let properties) = change {
                    XCTAssertNotEqual(self.obj, o)
                    XCTAssertEqual(properties.count, 1)
                    XCTAssertEqual(properties[0].name, "intCol")
                    if let prev = prev {
                        XCTAssertEqual(properties[0].oldValue as? Int, prev.intCol)
                    }
                    XCTAssertEqual(properties[0].newValue as? Int, o.intCol)
                    prev = o.freeze()
                    XCTAssertEqual(prev!.intCol, o.intCol)

                    if o.intCol == 100 {
                        sema.signal()
                    }
                } else {
                    XCTFail("Expected .change but got \(change)")
                }
            })

        for _ in 0..<100 {
            try! realm.write { obj.intCol += 1 }
        }
        sema.wait()
        try! realm.write { realm.delete(obj) }

        sema.wait()
        XCTAssertNotNil(prev)
        XCTAssertEqual(prev!.intCol, 100)
    }

    func testChangeSetReceiveOn() {
        var exp = XCTestExpectation(description: "change")

        token = changesetPublisher(obj)
            .receive(on: receiveOnQueue)
            .assertNoFailure()
            .sink(receiveCompletion: { _ in exp.fulfill() }, receiveValue: { change in
                if case .change(let o, let properties) = change {
                    XCTAssertNotEqual(self.obj, o)
                    XCTAssertEqual(properties.count, 1)
                    XCTAssertEqual(properties[0].name, "intCol")
                    // oldValue is always nil because we subscribed on the thread doing the writing
                    XCTAssertNil(properties[0].oldValue)
                    XCTAssertEqual(properties[0].newValue as? Int, o.intCol)
                } else {
                    XCTFail("Expected .change but got \(change)")
                }
                exp.fulfill()
            })

        for _ in 0..<10 {
            exp = XCTestExpectation(description: "change")
            try! realm.write { obj.intCol += 1 }
            wait(for: [exp], timeout: 1)
        }
        exp = XCTestExpectation(description: "completion")
        try! realm.write { realm.delete(obj) }
        wait(for: [exp], timeout: 1)
    }

    func testChangeSetSubscribeOnAndReceiveOn() {
        let sema = DispatchSemaphore(value: 0)

        var prev: SwiftIntObject?
        token = changesetPublisher(obj)
            .subscribe(on: subscribeOnQueue)
            .receive(on: receiveOnQueue)
            .assertNoFailure()
            .sink(receiveCompletion: { _ in sema.signal() }, receiveValue: { change in
                if case .change(let o, let properties) = change {
                    XCTAssertNotEqual(self.obj, o)
                    XCTAssertEqual(properties.count, 1)
                    XCTAssertEqual(properties[0].name, "intCol")
                    if let prev = prev {
                        XCTAssertEqual(properties[0].oldValue as? Int, prev.intCol)
                    }
                    XCTAssertEqual(properties[0].newValue as? Int, o.intCol)
                    prev = o.freeze()
                    XCTAssertEqual(prev!.intCol, o.intCol)

                    if o.intCol == 100 {
                        sema.signal()
                    }
                    o.realm?.invalidate()
                } else {
                    XCTFail("Expected .change but got \(change)")
                }
            })

        for _ in 0..<100 {
            try! realm.write { obj.intCol += 1 }
        }
        sema.wait()
        try! realm.write { realm.delete(obj) }

        sema.wait()
        XCTAssertNotNil(prev)
        XCTAssertEqual(prev!.intCol, 100)
    }

    func testChangeSetMakeThreadSafe() {
        var exp = XCTestExpectation(description: "change")

        token = changesetPublisher(obj)
            .map { $0 }
            .threadSafeReference()
            .receive(on: receiveOnQueue)
            .assertNoFailure()
            .sink(receiveCompletion: { _ in exp.fulfill() }, receiveValue: { change in
                if case .change(let o, let properties) = change {
                    XCTAssertNotEqual(self.obj, o)
                    XCTAssertEqual(properties.count, 1)
                    XCTAssertEqual(properties[0].name, "intCol")
                    XCTAssertNil(properties[0].oldValue)
                    XCTAssertEqual(properties[0].newValue as? Int, o.intCol)
                } else {
                    XCTFail("Expected .change but got \(change)")
                }
                exp.fulfill()
            })

        for _ in 0..<10 {
            exp = XCTestExpectation(description: "change")
            try! realm.write { obj.intCol += 1 }
            wait(for: [exp], timeout: 1)
        }
        exp = XCTestExpectation(description: "completion")
        try! realm.write { realm.delete(obj) }
        wait(for: [exp], timeout: 1)
    }

    func testFrozen() {
        let exp = XCTestExpectation()

        token = valuePublisher(obj)
            .freeze()
            .collect()
            .assertNoFailure()
            .sink { arr in
                XCTAssertEqual(arr.count, 10)
                for i in 0..<10 {
                    XCTAssertEqual(arr[i].intCol, i + 1)
                }
                exp.fulfill()
        }

        for _ in 0..<10 {
            try! realm.write { obj.intCol += 1 }
        }
        try! realm.write { realm.delete(obj) }
        wait(for: [exp], timeout: 1)
    }

    func testFrozenChangeSetSubscribeOn() {
        let sema = DispatchSemaphore(value: 0)
        token = changesetPublisher(obj)
            .subscribe(on: subscribeOnQueue)
            .freeze()
            .collect()
            .assertNoFailure()
            .sink { arr in
                var prev: SwiftIntObject?
                for change in arr {
                    guard case .change(let obj, let properties) = change else {
                        XCTFail("Expected .change, got(\(change)")
                        sema.signal()
                        return
                    }

                    XCTAssertEqual(properties.count, 1)
                    XCTAssertEqual(properties[0].name, "intCol")
                    XCTAssertEqual(properties[0].newValue as? Int, obj.intCol)
                    if let prev = prev {
                        XCTAssertEqual(properties[0].oldValue as? Int, prev.intCol)
                    }
                    prev = obj
                }
                sema.signal()
            }

        for _ in 0..<100 {
            try! realm.write { obj.intCol += 1 }
        }
        try! realm.write { realm.delete(obj) }
        sema.wait()
    }

    func testFrozenChangeSetReceiveOn() {
        let exp = XCTestExpectation(description: "sink complete")
        token = changesetPublisher(obj)
            .freeze()
            .receive(on: receiveOnQueue)
            .collect()
            .assertNoFailure()
            .sink { arr in
                for change in arr {
                    guard case .change(let obj, let properties) = change else {
                        XCTFail("Expected .change, got(\(change)")
                        exp.fulfill()
                        return
                    }

                    XCTAssertEqual(properties.count, 1)
                    XCTAssertEqual(properties[0].name, "intCol")
                    XCTAssertEqual(properties[0].newValue as? Int, obj.intCol)
                    // subscribing on the thread making writes means that oldValue
                    // is always nil
                    XCTAssertNil(properties[0].oldValue)
                }
                exp.fulfill()
        }

        for _ in 0..<100 {
            try! realm.write { obj.intCol += 1 }
        }
        try! realm.write { realm.delete(obj) }
        wait(for: [exp], timeout: 1)
    }

    func testFrozenChangeSetSubscribeOnAndReceiveOn() {
        let sema = DispatchSemaphore(value: 0)
        token = changesetPublisher(obj)
            .subscribe(on: subscribeOnQueue)
            .freeze()
            .receive(on: receiveOnQueue)
            .collect()
            .assertNoFailure()
            .sink { arr in
                var prev: SwiftIntObject?
                for change in arr {
                    guard case .change(let obj, let properties) = change else {
                        XCTFail("Expected .change, got(\(change)")
                        sema.signal()
                        return
                    }

                    XCTAssertEqual(properties.count, 1)
                    XCTAssertEqual(properties[0].name, "intCol")
                    XCTAssertEqual(properties[0].newValue as? Int, obj.intCol)
                    if let prev = prev {
                        XCTAssertEqual(properties[0].oldValue as? Int, prev.intCol)
                    }
                    prev = obj
                }
                sema.signal()
        }

        for _ in 0..<100 {
            try! realm.write { obj.intCol += 1 }
        }
        try! realm.write { realm.delete(obj) }
        sema.wait()
    }

    func testReceiveOnAfterMap() {
        var exp = XCTestExpectation()
        token = valuePublisher(obj)
            .map { $0 }
            .threadSafeReference()
            .receive(on: receiveOnQueue)
            .map { obj -> Int in
                exp.fulfill()
                return obj.intCol
            }
            .collect()
            .assertNoFailure()
            .sink { arr in
                XCTAssertEqual(arr.count, 10)
                for i in 1..<10 {
                    XCTAssertTrue(arr.contains(i))
                }
                exp.fulfill()
            }

        for _ in 0..<10 {
            try! realm.write { obj.intCol += 1 }
            wait(for: [exp], timeout: 1)
            exp = XCTestExpectation()
        }
        try! realm.write { realm.delete(obj) }
        wait(for: [exp], timeout: 1)
    }

    func testUnmanagedMakeThreadSafe() {
        let objects = [SwiftIntObject(value: [1]), SwiftIntObject(value: [2]), SwiftIntObject(value: [3])]

        let exp = XCTestExpectation()
        token = objects.publisher
            .threadSafeReference()
            .receive(on: receiveOnQueue)
            .map { $0.intCol }
            .collect()
            .sink { (arr: [Int]) in
                XCTAssertEqual(arr, [1, 2, 3])
                exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testManagedMakeThreadSafe() {
        let objects = try! realm.write {
            return [
                realm.create(SwiftIntObject.self, value: [1]),
                realm.create(SwiftIntObject.self, value: [2]),
                realm.create(SwiftIntObject.self, value: [3])
            ]
        }

        let exp = XCTestExpectation()
        token = objects.publisher
            .threadSafeReference()
            .receive(on: receiveOnQueue)
            .map { $0.intCol }
            .collect()
            .sink { (arr: [Int]) in
                XCTAssertEqual(arr, [1, 2, 3])
                exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func testFrozenMakeThreadSafe() {
        var exp = XCTestExpectation()
        token = valuePublisher(obj)
            .freeze()
            .map { $0 }
            .threadSafeReference()
            .receive(on: receiveOnQueue)
            .assertNoFailure()
            .sink { obj in
                XCTAssertTrue(obj.isFrozen)
                exp.fulfill()
            }

        for _ in 0..<10 {
            try! realm.write { obj.intCol += 1 }
            wait(for: [exp], timeout: 1)
            exp = XCTestExpectation()
        }
    }

    func testMixedMakeThreadSafe() {
        let realm2 = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "test2"))
        var objects = try! realm.write {
            try! realm2.write {
                return [
                    realm.create(SwiftIntObject.self, value: [1]),
                    realm2.create(SwiftIntObject.self, value: [2]),
                    SwiftIntObject(value: [3]),
                    realm.create(SwiftIntObject.self, value: [4]),
                    realm2.create(SwiftIntObject.self, value: [5])
                ]
            }
        }
        objects[3] = objects[3].freeze()
        objects[4] = objects[4].freeze()
        let exp = XCTestExpectation()
        token = objects.publisher
            .threadSafeReference()
            .receive(on: receiveOnQueue)
            .map { $0.intCol }
            .collect()
            .sink { (arr: [Int]) in
                XCTAssertEqual(arr, [1, 2, 3, 4, 5])
                exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}

private protocol CombineTestCollection {
    static func getCollection(_ realm: Realm) -> Self
    func appendObject()
}

@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
private class CombineCollectionPublisherTests<Collection: RealmCollection>: CombineTestCase
        where Collection: CombineTestCollection, Collection: RealmSubscribable {
    var collection: Collection!

    class func testSuite(_ name: String) -> XCTestSuite {
        if hasCombine() {
            // By default this test suite's name will be the generic type's
            // mangled name, which is an unreadable mess. It appears that the
            // way to override it is with a subclass with an explicit name, which
            // can't be done in pure Swift.
            let cls: AnyClass = objc_allocateClassPair(CombineCollectionPublisherTests<Collection>.self, "CombinePublisherTests<\(name)>", 0)!
            objc_registerClassPair(cls)
            return cls.defaultTestSuite
        }
        return XCTestSuite(name: "CombinePublisherTests<\(name)>")
    }

    override func setUp() {
        super.setUp()
        collection = Collection.getCollection(realm)
    }

    func testWillChange() {
        let exp = XCTestExpectation()
        token = collection.objectWillChange.sink {
            exp.fulfill()
        }
        try! realm.write { collection.appendObject() }
        wait(for: [exp], timeout: 1)
    }

    func testBasic() {
        var exp = XCTestExpectation()
        var calls = 0
        token = collection.collectionPublisher
            .assertNoFailure()
            .sink { c in
                XCTAssertEqual(c.count, calls)
                calls += 1
                exp.fulfill()
        }

        for _ in 0..<10 {
            try! realm.write { collection.appendObject() }
            wait(for: [exp], timeout: 10)
            exp = XCTestExpectation()
        }
    }

    func checkChangeset(_ change: RealmCollectionChange<Collection>, calls: Int, frozen: Bool = false) {
        switch change {
        case .initial(let collection):
            XCTAssertEqual(collection.isFrozen, frozen)
            XCTAssertEqual(calls, 0)
            XCTAssertEqual(collection.count, 0)
        case .update(let collection, deletions: let deletions, insertions: let insertions,
                     modifications: let modifications):
            XCTAssertEqual(collection.isFrozen, frozen)
            XCTAssertEqual(collection.count, calls)
            XCTAssertEqual(insertions, [calls - 1])
            XCTAssertEqual(deletions, [])
            XCTAssertEqual(modifications, [])
        case .error(let error):
            XCTFail("Unexpected error \(error)")
        }
    }

    func testChangeSet() {
        var exp = XCTestExpectation(description: "initial")
        var calls = 0
        token = collection.changesetPublisher
            .sink { change in
                self.checkChangeset(change, calls: calls)
                calls += 1
                exp.fulfill()
        }
        wait(for: [exp], timeout: 10)

        for _ in 0..<10 {
            exp = XCTestExpectation(description: "change")
            try! realm.write { collection.appendObject() }
            wait(for: [exp], timeout: 10)
        }
    }

    func testSubscribeOn() {
        let sema = DispatchSemaphore(value: 0)
        var calls = 0
        token = collection.collectionPublisher
            .subscribe(on: subscribeOnQueue)
            .assertNoFailure()
            .sink { r in
                XCTAssertEqual(r.count, calls)
                calls += 1
                sema.signal()
        }
        sema.wait()

        for _ in 0..<10 {
            try! realm.write { collection.appendObject() }
            sema.wait()
        }
    }

    func testReceiveOn() {
        var calls = 0
        var exp = XCTestExpectation(description: "initial")
        token = collection.collectionPublisher
            .receive(on: receiveOnQueue)
            .assertNoFailure()
            .sink { r in
                XCTAssertEqual(r.count, calls)
                calls += 1
                exp.fulfill()
        }
        wait(for: [exp], timeout: 10)

        for _ in 0..<10 {
            exp = XCTestExpectation(description: "change")
            try! realm.write { collection.appendObject() }
            wait(for: [exp], timeout: 10)
        }
    }

    func testChangeSetSubscribeOn() {
        var calls = 0
        let sema = DispatchSemaphore(value: 0)
        token = collection.changesetPublisher
            .subscribe(on: subscribeOnQueue)
            .sink { change in
                self.checkChangeset(change, calls: calls)
                calls += 1
                sema.signal()
        }
        sema.wait()

        for _ in 0..<10 {
            try! realm.write { collection.appendObject() }
            sema.wait()
        }
    }

    func testChangeSetReceiveOn() {
        var exp = XCTestExpectation(description: "initial")
        var calls = 0
        token = collection.changesetPublisher
            .receive(on: receiveOnQueue)
            .sink { change in
                self.checkChangeset(change, calls: calls)
                calls += 1
                exp.fulfill()
        }
        wait(for: [exp], timeout: 10)

        for _ in 0..<10 {
            exp = XCTestExpectation(description: "change")
            try! realm.write { collection.appendObject() }
            wait(for: [exp], timeout: 10)
        }
    }

    func testMakeThreadSafe() {
        var calls = 0
        var exp = XCTestExpectation(description: "initial")
        token = collection.collectionPublisher
            .map { $0 }
            .threadSafeReference()
            .receive(on: receiveOnQueue)
            .assertNoFailure()
            .sink { r in
                XCTAssertEqual(r.count, calls)
                calls += 1
                exp.fulfill()
            }
        wait(for: [exp], timeout: 10)

        for _ in 0..<10 {
            exp = XCTestExpectation(description: "change")
            try! realm.write { collection.appendObject() }
            wait(for: [exp], timeout: 10)
        }
    }

    func testMakeThreadSafeChangeset() {
        var exp = XCTestExpectation(description: "initial")
        var calls = 0
        token = collection.changesetPublisher
            .map { $0 }
            .threadSafeReference()
            .receive(on: receiveOnQueue)
            .sink { change in
                self.checkChangeset(change, calls: calls)
                calls += 1
                exp.fulfill()
        }
        wait(for: [exp], timeout: 10)

        for _ in 0..<10 {
            exp = XCTestExpectation(description: "change")
            try! realm.write { collection.appendObject() }
            wait(for: [exp], timeout: 10)
        }
    }

    func testFrozen() {
        let exp = XCTestExpectation()
        token = collection.collectionPublisher
            .freeze()
            .prefix(10)
            .collect()
            .assertNoFailure()
            .sink { arr in
                for (i, collection) in arr.enumerated() {
                    XCTAssertTrue(collection.isFrozen)
                    XCTAssertEqual(collection.count, i)
                }
                exp.fulfill()
        }

        for _ in 0..<10 {
            try! realm.write { collection.appendObject() }
        }
        wait(for: [exp], timeout: 10)
    }

    func testFrozenChangeSetSubscribeOn() {
        let sema = DispatchSemaphore(value: 0)
        token = collection.changesetPublisher
            .subscribe(on: subscribeOnQueue)
            .freeze()
            .assertNoFailure()
            .signal(sema)
            .prefix(10)
            .collect()
            .sink { arr in
                for (i, change) in arr.enumerated() {
                    self.checkChangeset(change, calls: i, frozen: true)
                }
                sema.signal()
            }

        for _ in 0..<10 {
            sema.wait()
            try! realm.write { collection.appendObject() }
        }
        sema.wait()
    }

    func testFrozenChangeSetReceiveOn() {
        let exp = XCTestExpectation()
        token = collection.changesetPublisher
            .freeze()
            .receive(on: receiveOnQueue)
            .prefix(10)
            .collect()
            .assertNoFailure()
            .sink { arr in
                for (i, change) in arr.enumerated() {
                    self.checkChangeset(change, calls: i, frozen: true)
                }
                exp.fulfill()
        }

        for _ in 0..<10 {
            try! realm.write { collection.appendObject() }
        }
        wait(for: [exp], timeout: 10)
    }

    func testFrozenChangeSetSubscribeOnAndReceiveOn() {
        let sema = DispatchSemaphore(value: 0)
        token = collection.changesetPublisher
            .subscribe(on: subscribeOnQueue)
            .freeze()
            .receive(on: receiveOnQueue)
            .signal(sema)
            .prefix(10)
            .collect()
            .assertNoFailure()
            .sink { arr in
                for (i, change) in arr.enumerated() {
                    self.checkChangeset(change, calls: i, frozen: true)
                }
                sema.signal()
        }

        for _ in 0..<10 {
            sema.wait()
            try! realm.write { collection.appendObject() }
        }
        sema.wait()
    }

    func testFrozenMakeThreadSafe() {
        let sema = DispatchSemaphore(value: 0)
        token = collection.collectionPublisher
            .freeze()
            .threadSafeReference()
            .receive(on: receiveOnQueue)
            .prefix(10)
            .collect()
            .assertNoFailure()
            .sink { arr in
                for (i, collection) in arr.enumerated() {
                    XCTAssertTrue(collection.isFrozen)
                    XCTAssertEqual(collection.count, i)
                }
                sema.signal()
            }

        for _ in 0..<10 {
            try! realm.write { collection.appendObject() }
        }
        sema.wait()
    }

    func testFrozenMakeThreadSafeChangeset() {
        let exp = XCTestExpectation()
        token = collection.changesetPublisher
            .freeze()
            .threadSafeReference()
            .receive(on: receiveOnQueue)
            .prefix(10)
            .collect()
            .assertNoFailure()
            .sink { arr in
                for (i, change) in arr.enumerated() {
                    self.checkChangeset(change, calls: i, frozen: true)
                }
                exp.fulfill()
        }

        for _ in 0..<10 {
            try! realm.write { collection.appendObject() }
        }
        wait(for: [exp], timeout: 10)
    }
}

extension Results: CombineTestCollection where Element: Object {
    static func getCollection(_ realm: Realm) -> Results<Element> {
        return realm.objects(Element.self)
    }

    func appendObject() {
        realm?.create(Element.self, value: [])
    }
}

@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
class ResultsPublisherTests: TestCase {
    override class var defaultTestSuite: XCTestSuite {
        return CombineCollectionPublisherTests<Results<SwiftIntObject>>.testSuite("Results")
    }
}

extension List: CombineTestCollection where Element == SwiftIntObject {
    static func getCollection(_ realm: Realm) -> List<Element> {
        return try! realm.write { realm.create(SwiftArrayPropertyObject.self, value: []).intArray }
    }

    func appendObject() {
        append(realm!.create(Element.self, value: []))
    }
}

@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
class ManagedListPublisherTests: TestCase {
    override class var defaultTestSuite: XCTestSuite {
        return CombineCollectionPublisherTests<List<SwiftIntObject>>.testSuite("List")
    }
}

extension LinkingObjects: CombineTestCollection where Element == SwiftOwnerObject {
    static func getCollection(_ realm: Realm) -> LinkingObjects<Element> {
        return try! realm.write { realm.create(SwiftDogObject.self, value: []).owners }
    }

    func appendObject() {
        realm!.create(SwiftOwnerObject.self, value: ["", realm!.objects(SwiftDogObject.self).first!])
    }
}

@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
class LinkingObjectsPublisherTests: TestCase {
    override class var defaultTestSuite: XCTestSuite {
        return CombineCollectionPublisherTests<LinkingObjects<SwiftOwnerObject>>.testSuite("LinkingObjects")
    }
}

extension AnyRealmCollection: CombineTestCollection where Element == SwiftIntObject {
    static func getCollection(_ realm: Realm) -> AnyRealmCollection<Element> {
        return AnyRealmCollection(realm.objects(Element.self))
    }

    func appendObject() {
        realm?.create(Element.self, value: [])
    }
}

@available(OSX 10.15, watchOS 6.0, iOS 13.0, iOSApplicationExtension 13.0, OSXApplicationExtension 10.15, tvOS 13.0, *)
class AnyRealmCollectionPublisherTests: TestCase {
    override class var defaultTestSuite: XCTestSuite {
        return CombineCollectionPublisherTests<AnyRealmCollection<SwiftIntObject>>.testSuite("AnyRealmCollection")
    }
}

#endif // canImport(Combine)
