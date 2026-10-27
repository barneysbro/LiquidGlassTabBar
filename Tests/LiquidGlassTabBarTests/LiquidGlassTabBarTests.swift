import UIKit
import XCTest
@testable import LiquidGlassTabBar

@MainActor
final class LiquidGlassTabBarTests: XCTestCase {
    func testVerticalOrientationStacksTabsTopToBottom() {
        let tabBar = LiquidGlassTabBar()
        tabBar.orientation = .vertical
        tabBar.frame = CGRect(x: 0, y: 0, width: 76, height: 420)
        tabBar.configure(with: sampleItems)
        tabBar.layoutIfNeeded()

        let buttons = tabBar.descendants.compactMap { $0 as? UIButton }.sorted { $0.tag < $1.tag }
        XCTAssertEqual(buttons.count, sampleItems.count)

        let frames = buttons.map { $0.convert($0.bounds, to: tabBar) }
        for pair in zip(frames, frames.dropFirst()) {
            XCTAssertLessThan(pair.0.midY, pair.1.midY)
            XCTAssertEqual(pair.0.midX, pair.1.midX, accuracy: 0.5)
        }
    }

    func testHorizontalOrientationRemainsDefaultAndLeftToRight() {
        let tabBar = LiquidGlassTabBar()
        XCTAssertEqual(tabBar.orientation, .horizontal)
        tabBar.frame = CGRect(x: 0, y: 0, width: 360, height: 64)
        tabBar.configure(with: sampleItems)
        tabBar.layoutIfNeeded()

        let buttons = tabBar.descendants.compactMap { $0 as? UIButton }.sorted { $0.tag < $1.tag }
        XCTAssertEqual(buttons.count, sampleItems.count)

        let frames = buttons.map { $0.convert($0.bounds, to: tabBar) }
        for pair in zip(frames, frames.dropFirst()) {
            XCTAssertLessThan(pair.0.midX, pair.1.midX)
            XCTAssertEqual(pair.0.midY, pair.1.midY, accuracy: 0.5)
        }
    }

    func testOrientationCanChangeAfterTabsAreConfigured() {
        let tabBar = LiquidGlassTabBar()
        tabBar.frame = CGRect(x: 0, y: 0, width: 76, height: 420)
        tabBar.configure(with: sampleItems)

        tabBar.orientation = .vertical
        tabBar.layoutIfNeeded()
        let verticalFrames = buttonFrames(in: tabBar)
        let verticalCentersX = verticalFrames.map { $0.midX }
        XCTAssertEqual(verticalCentersX.max() ?? 0,
                       verticalCentersX.min() ?? 0,
                       accuracy: 0.5)

        tabBar.orientation = .horizontal
        tabBar.frame = CGRect(x: 0, y: 0, width: 360, height: 64)
        tabBar.layoutIfNeeded()
        let frames = buttonFrames(in: tabBar)
        XCTAssertLessThan(frames[0].midX, frames[1].midX)
        XCTAssertLessThan(frames[1].midX, frames[2].midX)
    }

    private func buttonFrames(in tabBar: LiquidGlassTabBar) -> [CGRect] {
        var views: [UIView] = []
        func collectSubviews(of view: UIView) {
            for subview in view.subviews {
                views.append(subview)
                collectSubviews(of: subview)
            }
        }
        collectSubviews(of: tabBar)
        return views
            .compactMap { $0 as? UIButton }
            .sorted { $0.tag < $1.tag }
            .map { $0.convert($0.bounds, to: tabBar) }
    }

    private var sampleItems: [LiquidGlassTabItem] {
        [
            .system(id: "one", title: "One", symbol: "1.circle"),
            .system(id: "two", title: "Two", symbol: "2.circle"),
            .system(id: "three", title: "Three", symbol: "3.circle")
        ]
    }
}

private extension UIView {
    var descendants: [UIView] {
        subviews.flatMap { [$0] + $0.descendants }
    }
}
