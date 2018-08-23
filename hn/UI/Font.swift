import UIKit

enum Font {
  case sanFransisco
  case avenirNext
  case helveticaNue
  case menlo
  case courierNew
}

extension Font {
  var title1: UIFont {
    return defaultFont(forTextStyle: .title1)
  }

  var title2: UIFont {
    return defaultFont(forTextStyle: .title2)
  }

  var title3: UIFont {
    return defaultFont(forTextStyle: .title3)
  }

  var headline: UIFont {
    switch self {
    case .sanFransisco: return UIFont.preferredFont(forTextStyle: .headline)
    case .avenirNext: return UIFont(name: "AvenirNext-DemiBold", textStyle: .headline)!
    case .helveticaNue: return UIFont(name: "HelveticaNue-Medium", textStyle: .headline)!
    case .menlo: return UIFont(name: "Menlo-Bold", textStyle: .headline)!
    case .courierNew: return UIFont(name: "CourierNewPS-BoldMT", textStyle: .headline)!
    }
  }

  var body: UIFont {
    return defaultFont(forTextStyle: .body)
  }

  var callout: UIFont {
    return defaultFont(forTextStyle: .callout)
  }

  var subheadline: UIFont {
    return defaultFont(forTextStyle: .subheadline)
  }

  var footnote: UIFont {
    return defaultFont(forTextStyle: .footnote)
  }

  var caption1: UIFont {
    return defaultFont(forTextStyle: .caption1)
  }

  var caption2: UIFont {
    return defaultFont(forTextStyle: .caption2)
  }

  private func defaultFont(forTextStyle textStyle: UIFontTextStyle) -> UIFont {
    let system = UIFont.preferredFont(forTextStyle: textStyle)
    switch self {
    case .sanFransisco: return system
    case .avenirNext: return UIFont(name: "AvenirNext-Regular", size: system.pointSize)!
    case .helveticaNue: return UIFont(name: "HelveticaNue", size: system.pointSize)!
    case .menlo: return UIFont(name: "Menlo-Regular", size: system.pointSize - 2)!
    case .courierNew: return UIFont(name: "CourierNewPSMT", size: system.pointSize - 2)!
    }
  }
}
