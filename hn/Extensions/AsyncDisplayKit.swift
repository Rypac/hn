import AsyncDisplayKit

extension ASStackLayoutSpec {
    convenience init(
        direction: ASStackLayoutDirection,
        spacing: CGFloat,
        flex: (shrink: CGFloat, grow: CGFloat),
        children: [ASLayoutElement]
    ) {
        self.init(
            direction: direction,
            spacing: spacing,
            justifyContent: .start,
            alignItems: .stretch,
            children: children)
        style.flexShrink = flex.shrink
        style.flexGrow = flex.grow
    }
}
