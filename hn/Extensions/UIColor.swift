import UIKit

extension UIColor {
  convenience init(byteRed red: Int, green: Int, blue: Int, alpha: Float = 1.0) {
    self.init(
      red: CGFloat(red) / 255.0,
      green: CGFloat(green) / 255.0,
      blue: CGFloat(blue) / 255.0,
      alpha: CGFloat(alpha)
    )
  }

  convenience init(hex: Int, alpha: Float = 1.0) {
    self.init(
      byteRed: (hex & 0xFF0000) >> 16,
      green: (hex & 0x00FF00) >> 8,
      blue: (hex & 0x0000FF) >> 0,
      alpha: alpha
    )
  }
}

extension UIColor {
  struct Apple {
    static let red = UIColor(byteRed: 255, green: 59, blue: 48)
    static let orange = UIColor(byteRed: 255, green: 95, blue: 0)
    static let yellow = UIColor(byteRed: 255, green: 204, blue: 0)
    static let green = UIColor(byteRed: 76, green: 217, blue: 100)
    static let tealBlue = UIColor(byteRed: 90, green: 200, blue: 250)
    static let blue = UIColor(byteRed: 0, green: 122, blue: 255)
    static let purple = UIColor(byteRed: 88, green: 86, blue: 214)
    static let pink = UIColor(byteRed: 255, green: 45, blue: 85)
  }
}
