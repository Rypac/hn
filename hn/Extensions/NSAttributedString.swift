import Foundation

func + (_ left: NSAttributedString, _ right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString(attributedString: left)
    result.append(right)
    return result
}
