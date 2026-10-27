import UIKit

public struct LiquidGlassTabItem: Identifiable {
    public let id: String
    public let title: String
    public let image: UIImage?
    public let selectedImage: UIImage?

    private static let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)

    public init(
        id: String,
        title: String,
        image: UIImage? = nil,
        selectedImage: UIImage? = nil,
        systemImage: String? = nil,
        selectedSystemImage: String? = nil
    ) {
        self.id = id
        self.title = title
        self.image = image ?? systemImage.flatMap { UIImage(systemName: $0, withConfiguration: Self.symbolConfiguration) }
        self.selectedImage = selectedImage
            ?? selectedSystemImage.flatMap { UIImage(systemName: $0, withConfiguration: Self.symbolConfiguration) }
            ?? self.image
    }

    public static func system(
        id: String,
        title: String,
        symbol: String,
        selectedSymbol: String? = nil
    ) -> LiquidGlassTabItem {
        LiquidGlassTabItem(
            id: id,
            title: title,
            systemImage: symbol,
            selectedSystemImage: selectedSymbol ?? symbol
        )
    }
}

public enum LiquidGlassTabBarOrientation {
    case horizontal
    case vertical
}

public struct LiquidGlassTabBarLayout {
    public var expandedHorizontalInset: CGFloat
    public var compactHorizontalInset: CGFloat
    public var expandedHeight: CGFloat
    public var compactHeight: CGFloat
    public var expandedBottomSpacing: CGFloat
    public var compactBottomSpacing: CGFloat
    public var maxWidth: CGFloat
    public var verticalWidth: CGFloat
    public var compactVerticalWidth: CGFloat
    public var verticalTrailingSpacing: CGFloat
    public var verticalTopInset: CGFloat
    public var verticalBottomInset: CGFloat
    public var maxVerticalHeight: CGFloat

    public init(
        expandedHorizontalInset: CGFloat = 22,
        compactHorizontalInset: CGFloat = 50,
        expandedHeight: CGFloat = 58,
        compactHeight: CGFloat = 52,
        expandedBottomSpacing: CGFloat = 30,
        compactBottomSpacing: CGFloat? = nil,
        maxWidth: CGFloat = 520,
        verticalWidth: CGFloat = 70,
        compactVerticalWidth: CGFloat = 58,
        verticalTrailingSpacing: CGFloat = 16,
        verticalTopInset: CGFloat = 112,
        verticalBottomInset: CGFloat = 24,
        maxVerticalHeight: CGFloat = 420
    ) {
        self.expandedHorizontalInset = expandedHorizontalInset
        self.compactHorizontalInset = compactHorizontalInset
        self.expandedHeight = expandedHeight
        self.compactHeight = compactHeight
        self.expandedBottomSpacing = expandedBottomSpacing
        self.compactBottomSpacing = compactBottomSpacing ?? expandedBottomSpacing + expandedHeight - compactHeight
        self.maxWidth = maxWidth
        self.verticalWidth = verticalWidth
        self.compactVerticalWidth = compactVerticalWidth
        self.verticalTrailingSpacing = verticalTrailingSpacing
        self.verticalTopInset = verticalTopInset
        self.verticalBottomInset = verticalBottomInset
        self.maxVerticalHeight = maxVerticalHeight
    }

    public static let `default` = LiquidGlassTabBarLayout()
}

public struct LiquidGlassTabBarStyle {
    public var backgroundTint: UIColor
    public var fallbackBlurStyle: UIBlurEffect.Style
    public var fallbackDimmingColor: UIColor
    public var selectionColor: UIColor
    public var iconColor: UIColor
    public var shadowColor: UIColor
    public var shadowOpacity: Float
    public var shadowRadius: CGFloat
    public var shadowOffset: CGSize
    public var buttonInset: CGFloat

    public init(
        backgroundTint: UIColor = UIColor.black.withAlphaComponent(0.18),
        fallbackBlurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark,
        fallbackDimmingColor: UIColor = UIColor.black.withAlphaComponent(0.26),
        selectionColor: UIColor = UIColor(white: 0.39, alpha: 0.88),
        iconColor: UIColor = .white,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.18,
        shadowRadius: CGFloat = 14,
        shadowOffset: CGSize = CGSize(width: 0, height: 6),
        buttonInset: CGFloat = 10
    ) {
        self.backgroundTint = backgroundTint
        self.fallbackBlurStyle = fallbackBlurStyle
        self.fallbackDimmingColor = fallbackDimmingColor
        self.selectionColor = selectionColor
        self.iconColor = iconColor
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.buttonInset = buttonInset
    }

    public static let `default` = LiquidGlassTabBarStyle()
}

public final class LiquidGlassTabBar: UIView, UIGestureRecognizerDelegate {
    public var onSelect: ((Int, LiquidGlassTabItem) -> Void)?
    public var onInteractionBegan: (() -> Void)?
    public var onCompactChanged: ((Bool, Bool) -> Void)?

    public private(set) var items: [LiquidGlassTabItem] = []
    public private(set) var selectedIndex = 0
    public var style: LiquidGlassTabBarStyle { didSet { applyStyle() } }
    public var orientation: LiquidGlassTabBarOrientation = .horizontal {
        didSet {
            guard oldValue != orientation else { return }
            isDraggingSelection = false
            draggedSelectionCenter = nil
            resetEdgeStretch()
            applyOrientation()
            setNeedsLayout()
            layoutIfNeeded()
            updateButtonAppearance(animated: false)
        }
    }

    private let blurView = UIVisualEffectView()
    private let dimmingView = UIView()
    private let selectionView = UIView()
    private let buttonStack = UIStackView()
    private var buttonStackLeadingConstraint: NSLayoutConstraint?
    private var buttonStackTrailingConstraint: NSLayoutConstraint?
    private var buttonStackTopConstraint: NSLayoutConstraint?
    private var buttonStackBottomConstraint: NSLayoutConstraint?
    private var buttons: [UIButton] = []
    private var previewIndex = 0
    private var isCompact = false
    private var isDraggingSelection = false
    private var draggedSelectionCenter: CGFloat?

    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))

    public init(style: LiquidGlassTabBarStyle = .default) {
        self.style = style
        super.init(frame: .zero)
        configureView()
    }

    public override init(frame: CGRect) {
        self.style = .default
        super.init(frame: frame)
        configureView()
    }

    public required init?(coder: NSCoder) {
        self.style = .default
        super.init(coder: coder)
        configureView()
    }

    public func configure(with items: [LiquidGlassTabItem], selectedIndex: Int = 0) {
        self.items = items
        buttons.forEach {
            buttonStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        buttons = items.enumerated().map { index, item in
            let button = makeButton(for: item, index: index)
            buttonStack.addArrangedSubview(button)
            return button
        }

        self.selectedIndex = clampedIndex(selectedIndex)
        previewIndex = self.selectedIndex
        setNeedsLayout()
        layoutIfNeeded()
        updateButtonAppearance(animated: false)
    }

    public func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard !buttons.isEmpty else { return }
        let newIndex = clampedIndex(index)
        guard newIndex != selectedIndex else {
            updateButtonAppearance(animated: false)
            return
        }
        selectedIndex = newIndex
        previewIndex = newIndex
        updateButtonAppearance(animated: animated)
    }

    public func setCompact(_ compact: Bool, animated: Bool = true) {
        guard compact != isCompact else { return }
        isCompact = compact
        onCompactChanged?(compact, animated)
    }

    public func updateShapeForCurrentBounds() {
        let cornerRadius = (orientation == .horizontal ? bounds.height : bounds.width) / 2
        layer.cornerRadius = cornerRadius
        blurView.layer.cornerRadius = cornerRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    private func configureView() {
        clipsToBounds = false
        layer.cornerCurve = .continuous
        blurView.isUserInteractionEnabled = false
        blurView.clipsToBounds = true
        blurView.layer.cornerCurve = .continuous
        dimmingView.isUserInteractionEnabled = false
        selectionView.isUserInteractionEnabled = false
        selectionView.layer.cornerCurve = .continuous

        buttonStack.axis = orientation == .horizontal ? .horizontal : .vertical
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually

        addSubview(blurView)
        blurView.contentView.addSubview(dimmingView)
        addSubview(selectionView)
        addSubview(buttonStack)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        buttonStackLeadingConstraint = buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: style.buttonInset)
        buttonStackTrailingConstraint = buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -style.buttonInset)
        buttonStackTopConstraint = buttonStack.topAnchor.constraint(equalTo: topAnchor)
        buttonStackBottomConstraint = buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmingView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),
            buttonStackTopConstraint!,
            buttonStackLeadingConstraint!,
            buttonStackTrailingConstraint!,
            buttonStackBottomConstraint!
        ])

        tapGesture.require(toFail: panGesture)
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(panGesture)
        isAccessibilityElement = false
        applyStyle()
    }

    private func applyStyle() {
        applyOrientation()
        layer.shadowColor = style.shadowColor.cgColor
        layer.shadowOpacity = style.shadowOpacity
        layer.shadowRadius = style.shadowRadius
        layer.shadowOffset = style.shadowOffset
        selectionView.backgroundColor = style.selectionColor
        buttons.forEach { $0.tintColor = style.iconColor }

        if #available(iOS 26.0, *) {
            let glassEffect = UIGlassEffect(style: .regular)
            glassEffect.isInteractive = true
            glassEffect.tintColor = style.backgroundTint
            blurView.effect = glassEffect
            dimmingView.backgroundColor = .clear
        } else {
            blurView.effect = UIBlurEffect(style: style.fallbackBlurStyle)
            dimmingView.backgroundColor = style.fallbackDimmingColor
        }
    }

    private func applyOrientation() {
        let isHorizontal = orientation == .horizontal
        buttonStack.axis = isHorizontal ? .horizontal : .vertical
        buttonStackLeadingConstraint?.constant = isHorizontal ? style.buttonInset : 0
        buttonStackTrailingConstraint?.constant = isHorizontal ? -style.buttonInset : 0
        buttonStackTopConstraint?.constant = isHorizontal ? 0 : style.buttonInset
        buttonStackBottomConstraint?.constant = isHorizontal ? 0 : -style.buttonInset
    }

    private func makeButton(for item: LiquidGlassTabItem, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = index
        button.tintColor = style.iconColor
        button.accessibilityLabel = item.title
        button.accessibilityIdentifier = "liquidGlassTabBar.\(item.id)"
        button.accessibilityTraits = .button
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(item.image, for: .normal)
        button.setImage(item.selectedImage, for: .selected)
        button.addTarget(self, action: #selector(handleButtonTap(_:)), for: .touchUpInside)
        return button
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        select(nearestIndex(to: mainAxisLocation(of: gesture.location(in: self))), animated: true)
    }

    @objc private func handleButtonTap(_ sender: UIButton) { select(sender.tag, animated: true) }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        gestureRecognizer !== tapGesture || !(touch.view is UIControl)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !buttons.isEmpty else { return }
        let location = mainAxisLocation(of: gesture.location(in: self))

        switch gesture.state {
        case .began:
            isDraggingSelection = true
            beginInteraction()
            previewIndex = nearestIndex(to: location)
            updatePreviewAppearance()
            updateDraggedSelection(at: location)
        case .changed:
            let newPreviewIndex = nearestIndex(to: location)
            if newPreviewIndex != previewIndex {
                previewIndex = newPreviewIndex
                updatePreviewAppearance()
                UISelectionFeedbackGenerator().selectionChanged()
            }
            updateDraggedSelection(at: location)
        case .ended:
            resetEdgeStretch()
            isDraggingSelection = false
            draggedSelectionCenter = nil
            select(nearestIndex(to: location), animated: true, alreadyInteracting: true)
        case .cancelled, .failed:
            resetEdgeStretch()
            isDraggingSelection = false
            draggedSelectionCenter = nil
            previewIndex = selectedIndex
            updateButtonAppearance(animated: true)
        default:
            break
        }
    }

    private func select(_ index: Int, animated: Bool, alreadyInteracting: Bool = false) {
        guard buttons.indices.contains(index) else { return }
        if !alreadyInteracting { beginInteraction() }
        selectedIndex = index
        previewIndex = index
        updateButtonAppearance(animated: animated)
        if !alreadyInteracting {
            animateButtonTap(buttons[index])
        }
        onSelect?(index, items[index])
    }

    private func beginInteraction() {
        onInteractionBegan?()
        setCompact(false, animated: true)
    }

    private var isHorizontal: Bool { orientation == .horizontal }

    private func mainAxisLocation(of point: CGPoint) -> CGFloat {
        isHorizontal ? point.x : point.y
    }

    private func nearestIndex(to location: CGFloat) -> Int {
        guard !buttons.isEmpty else { return selectedIndex }
        let firstCenter = center(for: 0)
        let lastCenter = center(for: buttons.count - 1)
        let itemLength = max((mainAxisLength - style.buttonInset * 2) / CGFloat(buttons.count), 1)
        let minimum = firstCenter - itemLength / 2
        let maximum = lastCenter + itemLength / 2
        if location <= minimum { return 0 }
        if location >= maximum { return buttons.count - 1 }
        let normalizedPosition = (location - minimum) / max(maximum - minimum, 1)
        return min(max(Int(normalizedPosition * CGFloat(buttons.count)), 0), buttons.count - 1)
    }

    private var mainAxisLength: CGFloat {
        isHorizontal ? bounds.width : bounds.height
    }

    private func center(for index: Int) -> CGFloat {
        let itemLength = max((mainAxisLength - style.buttonInset * 2) / CGFloat(max(buttons.count, 1)), 1)
        return style.buttonInset + itemLength * (CGFloat(index) + 0.5)
    }

    private func updateDraggedSelection(at location: CGFloat) {
        let firstCenter = center(for: 0)
        let lastCenter = center(for: buttons.count - 1)
        let clampedLocation = min(max(location, firstCenter), lastCenter)
        let overshoot = location - clampedLocation
        draggedSelectionCenter = clampedLocation + rubberBandDistance(overshoot)
        positionSelectionView(center: draggedSelectionCenter!)
        applyEdgeStretch(overshoot: overshoot)
    }

    private func rubberBandDistance(_ distance: CGFloat) -> CGFloat {
        let magnitude = abs(distance)
        let damped = (1 - (1 / ((magnitude * 0.025) + 1))) * 18
        return distance < 0 ? -damped : damped
    }

    private func applyEdgeStretch(overshoot: CGFloat) {
        guard abs(overshoot) > 0.5 else { resetEdgeStretch(); return }
        let stretch = min(abs(rubberBandDistance(overshoot)), 12)
        let direction: CGFloat = overshoot < 0 ? -1 : 1
        let scale = 1 + (stretch / max(mainAxisLength, 1))
        blurView.transform = isHorizontal
            ? CGAffineTransform(translationX: direction * stretch / 2, y: 0).scaledBy(x: scale, y: 1)
            : CGAffineTransform(translationX: 0, y: direction * stretch / 2).scaledBy(x: 1, y: scale)
    }

    private func resetEdgeStretch() {
        UIView.animate(withDuration: 0.34, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.blurView.transform = .identity
        }
    }

    private func updatePreviewAppearance() {
        buttons.enumerated().forEach { index, button in
            button.isSelected = index == previewIndex
            button.alpha = index == previewIndex ? 1 : 0.92
            button.accessibilityTraits = index == previewIndex ? [.button, .selected] : .button
        }
    }

    private func updateButtonAppearance(animated: Bool) {
        guard buttons.indices.contains(selectedIndex) else { selectionView.isHidden = true; return }
        selectionView.isHidden = false
        previewIndex = selectedIndex
        buttons.enumerated().forEach { index, button in
            button.isSelected = index == selectedIndex
            button.accessibilityTraits = index == selectedIndex ? [.button, .selected] : .button
        }

        let updates = {
            self.layoutSelectionView()
            self.buttons.enumerated().forEach { index, button in
                button.alpha = index == self.selectedIndex ? 1 : 0.92
                button.transform = .identity
            }
        }
        guard animated else { updates(); return }
        UIView.animate(withDuration: 0.42, delay: 0, usingSpringWithDamping: 0.78, initialSpringVelocity: 0.35, options: [.allowUserInteraction, .beginFromCurrentState], animations: updates)
    }

    private func animateButtonTap(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.62, initialSpringVelocity: 0.4, options: [.allowUserInteraction]) {
                button.transform = .identity
            }
        })
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateShapeForCurrentBounds()
        layoutSelectionView()
    }

    private func layoutSelectionView() {
        if isDraggingSelection, let draggedSelectionCenter {
            positionSelectionView(center: draggedSelectionCenter)
            return
        }
        guard buttons.indices.contains(selectedIndex) else { return }
        positionSelectionView(center: center(for: selectedIndex))
    }

    private func positionSelectionView(center: CGFloat) {
        let crossAxisLength = max((isHorizontal ? bounds.height : bounds.width) - 10, 1)
        let itemLength = max((mainAxisLength - style.buttonInset * 2) / CGFloat(max(buttons.count, 1)), 1)
        let selectionMainLength = max(itemLength + 8, crossAxisLength)
        let minimumCenter = 2 + selectionMainLength / 2
        let maximumCenter = max(mainAxisLength - minimumCenter, minimumCenter)
        let clampedCenter = min(max(center, minimumCenter), maximumCenter)

        if isHorizontal {
            selectionView.frame = CGRect(
                x: clampedCenter - selectionMainLength / 2,
                y: bounds.midY - crossAxisLength / 2,
                width: selectionMainLength,
                height: crossAxisLength
            )
        } else {
            selectionView.frame = CGRect(
                x: bounds.midX - crossAxisLength / 2,
                y: clampedCenter - selectionMainLength / 2,
                width: crossAxisLength,
                height: selectionMainLength
            )
        }
        selectionView.layer.cornerRadius = crossAxisLength / 2
    }

    private func clampedIndex(_ index: Int) -> Int {
        guard !buttons.isEmpty else { return 0 }
        return min(max(index, 0), buttons.count - 1)
    }
}

public extension UITabBarController {
    func hideNativeTabBarForLiquidGlass() {
        tabBar.layer.removeAllAnimations()
        tabBar.alpha = 0
        tabBar.layer.opacity = 0
        tabBar.isHidden = true
        tabBar.isUserInteractionEnabled = false
        tabBar.subviews.forEach {
            $0.alpha = 0
            $0.isHidden = true
        }
    }
}
