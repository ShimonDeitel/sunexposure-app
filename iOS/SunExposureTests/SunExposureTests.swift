import XCTest
@testable import SunExposure

@MainActor
final class SunExposureTests: XCTestCase {

    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeTierLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(SessionEntry(note: "test"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddWithinFreeLimit() {
        let store = Store()
        XCTAssertTrue(store.canAdd(isPro: false))
    }

    func testCanAddBlockedAtLimitWhenNotPro() {
        let store = Store()
        store.entries = (0..<Store.freeTierLimit).map { _ in SessionEntry() }
        XCTAssertFalse(store.canAdd(isPro: false))
    }

    func testCanAddAlwaysAllowedWhenPro() {
        let store = Store()
        store.entries = (0..<(Store.freeTierLimit + 5)).map { _ in SessionEntry() }
        XCTAssertTrue(store.canAdd(isPro: true))
    }

    func testDeleteEntryRemovesIt() {
        let store = Store()
        let entry = SessionEntry(note: "to delete")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntryPersistsChange() {
        let store = Store()
        var entry = SessionEntry(note: "original")
        store.add(entry)
        entry.note = "updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.note, "updated")
    }

    func testDeleteAtOffsets() {
        let store = Store()
        let countBefore = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, countBefore - 1)
    }
}
