import UIKit

extension UIFont {
    var italicVariant: UIFont? {
        return variantWith(trait: .traitItalic)
    }

    var boldVariant: UIFont? {
        return variantWith(trait: .traitBold)
    }

    var monospaceVariant: UIFont? {
        return variantWith(trait: .traitMonoSpace)
    }

    func variantWith(trait: UIFontDescriptorSymbolicTraits) -> UIFont? {
        guard let trait = fontDescriptor.withSymbolicTraits(trait) else {
            return .none
        }
        return UIFont(descriptor: trait, size: pointSize)
    }
}
