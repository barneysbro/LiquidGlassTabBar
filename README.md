# LiquidGlassTabBar

A small UIKit floating tab bar for iOS. It gives you a blurred pill background, draggable selection, tap animation, and a tiny API.

> 中文版本在下方。

## Requirements

- iOS 13+
- Swift Package Manager
- UIKit

## Installation

In Xcode:

1. File → Add Package Dependencies
2. Enter your GitHub URL, for example:
   `https://github.com/<your-name>/LiquidGlassTabBar.git`
3. Import it:

```swift
import LiquidGlassTabBar
```

## Quick start

```swift
let layout = LiquidGlassTabBarLayout.default
let tabBar = LiquidGlassTabBar()
tabBar.translatesAutoresizingMaskIntoConstraints = false

view.addSubview(tabBar)
NSLayoutConstraint.activate([
    tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: layout.expandedHorizontalInset),
    tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -layout.expandedHorizontalInset),
    tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -layout.expandedBottomSpacing),
    tabBar.heightAnchor.constraint(equalToConstant: layout.expandedHeight),
    tabBar.widthAnchor.constraint(lessThanOrEqualToConstant: layout.maxWidth)
])

tabBar.configure(with: [
    .system(id: "home", title: "Home", symbol: "house", selectedSymbol: "house.fill"),
    .system(id: "search", title: "Search", symbol: "magnifyingglass"),
    .system(id: "profile", title: "Profile", symbol: "person", selectedSymbol: "person.fill")
])

tabBar.onSelect = { index, item in
    print("Selected", index, item.id)
}
```

## Styling

```swift
tabBar.style = LiquidGlassTabBarStyle(
    backgroundTint: UIColor.black.withAlphaComponent(0.22),
    selectionColor: UIColor.white.withAlphaComponent(0.22),
    iconColor: .white,
    shadowOpacity: 0.2
)
```

## Useful methods

```swift
tabBar.setSelectedIndex(1, animated: true)
tabBar.setCompact(true, animated: true)
tabBar.updateShapeForCurrentBounds()
```

## UITabBarController integration

Hide the native tab bar, add `LiquidGlassTabBar` as an overlay, then sync selection. Call `hideNativeTabBarForLiquidGlass()` in layout callbacks so UIKit cannot put the native tab bar back on top.

```swift
final class RootTabController: UITabBarController {
    private let glassTabBar = LiquidGlassTabBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNativeTabBarForLiquidGlass()
        view.addSubview(glassTabBar)
        // Add constraints with LiquidGlassTabBarLayout.default.

        glassTabBar.onSelect = { [weak self] index, _ in
            self?.selectedIndex = index
        }
    }

    override var selectedIndex: Int {
        didSet { glassTabBar.setSelectedIndex(selectedIndex) }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideNativeTabBarForLiquidGlass()
        view.bringSubviewToFront(glassTabBar)
    }
}
```

---

# LiquidGlassTabBar 中文說明

一個小型 UIKit 浮動 Tab Bar。支援毛玻璃膠囊背景、拖曳選取、點擊動畫，API 簡單，容易放進現有 `UITabBarController`。

## 需求

- iOS 13+
- Swift Package Manager
- UIKit

## 安裝

在 Xcode：

1. File → Add Package Dependencies
2. 輸入你的 GitHub URL，例如：
   `https://github.com/<your-name>/LiquidGlassTabBar.git`
3. 使用：

```swift
import LiquidGlassTabBar
```

## 快速開始

```swift
let layout = LiquidGlassTabBarLayout.default
let tabBar = LiquidGlassTabBar()
tabBar.translatesAutoresizingMaskIntoConstraints = false

view.addSubview(tabBar)
NSLayoutConstraint.activate([
    tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: layout.expandedHorizontalInset),
    tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -layout.expandedHorizontalInset),
    tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -layout.expandedBottomSpacing),
    tabBar.heightAnchor.constraint(equalToConstant: layout.expandedHeight),
    tabBar.widthAnchor.constraint(lessThanOrEqualToConstant: layout.maxWidth)
])

tabBar.configure(with: [
    .system(id: "home", title: "首頁", symbol: "house", selectedSymbol: "house.fill"),
    .system(id: "search", title: "搜尋", symbol: "magnifyingglass"),
    .system(id: "profile", title: "我的", symbol: "person", selectedSymbol: "person.fill")
])

tabBar.onSelect = { index, item in
    print("選中了", index, item.id)
}
```

## 自訂樣式

```swift
tabBar.style = LiquidGlassTabBarStyle(
    backgroundTint: UIColor.black.withAlphaComponent(0.22),
    selectionColor: UIColor.white.withAlphaComponent(0.22),
    iconColor: .white,
    shadowOpacity: 0.2
)
```

## 常用方法

```swift
tabBar.setSelectedIndex(1, animated: true)
tabBar.setCompact(true, animated: true)
tabBar.updateShapeForCurrentBounds()
```

## 放進 UITabBarController

把原生 tab bar 隱藏，然後把 `LiquidGlassTabBar` 加成 overlay，再同步 selected index。要在 layout callbacks 再呼叫 `hideNativeTabBarForLiquidGlass()`，避免 UIKit 把原生 tab bar 蓋回來。

```swift
final class RootTabController: UITabBarController {
    private let glassTabBar = LiquidGlassTabBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNativeTabBarForLiquidGlass()
        view.addSubview(glassTabBar)
        // 用 LiquidGlassTabBarLayout.default 加 constraints。

        glassTabBar.onSelect = { [weak self] index, _ in
            self?.selectedIndex = index
        }
    }

    override var selectedIndex: Int {
        didSet { glassTabBar.setSelectedIndex(selectedIndex) }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideNativeTabBarForLiquidGlass()
        view.bringSubviewToFront(glassTabBar)
    }
}
```

## License

MIT
