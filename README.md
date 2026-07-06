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
let tabBar = LiquidGlassTabBar()
tabBar.translatesAutoresizingMaskIntoConstraints = false

view.addSubview(tabBar)
NSLayoutConstraint.activate([
    tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 22),
    tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -22),
    tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
    tabBar.heightAnchor.constraint(equalToConstant: 58)
])

tabBar.configure(with: [
    LiquidGlassTabItem(id: "home", title: "Home", systemImage: "house", selectedSystemImage: "house.fill"),
    LiquidGlassTabItem(id: "search", title: "Search", systemImage: "magnifyingglass"),
    LiquidGlassTabItem(id: "profile", title: "Profile", systemImage: "person", selectedSystemImage: "person.fill")
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

Hide the native tab bar, add `LiquidGlassTabBar` as an overlay, then sync selection:

```swift
tabBar.onSelect = { [weak self] index, _ in
    self?.selectedIndex = index
}

override var selectedIndex: Int {
    didSet { tabBar.setSelectedIndex(selectedIndex) }
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
let tabBar = LiquidGlassTabBar()
tabBar.translatesAutoresizingMaskIntoConstraints = false

view.addSubview(tabBar)
NSLayoutConstraint.activate([
    tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 22),
    tabBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -22),
    tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
    tabBar.heightAnchor.constraint(equalToConstant: 58)
])

tabBar.configure(with: [
    LiquidGlassTabItem(id: "home", title: "首頁", systemImage: "house", selectedSystemImage: "house.fill"),
    LiquidGlassTabItem(id: "search", title: "搜尋", systemImage: "magnifyingglass"),
    LiquidGlassTabItem(id: "profile", title: "我的", systemImage: "person", selectedSystemImage: "person.fill")
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

把原生 tab bar 隱藏，然後把 `LiquidGlassTabBar` 加成 overlay，再同步 selected index：

```swift
tabBar.onSelect = { [weak self] index, _ in
    self?.selectedIndex = index
}

override var selectedIndex: Int {
    didSet { tabBar.setSelectedIndex(selectedIndex) }
}
```

## License

MIT
