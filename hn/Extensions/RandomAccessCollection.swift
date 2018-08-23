import Foundation

extension RandomAccessCollection {
  func concurrentMap<T>(_ transform: (Iterator.Element) -> T) -> [T] {
    let n = numericCast(count) as Int
    let p = UnsafeMutablePointer<T>.allocate(capacity: n)
    defer { p.deallocate(capacity: n) }

    DispatchQueue.concurrentPerform(iterations: n) { offset in
      (p + offset).initialize(
        to: transform(self[index(startIndex, offsetBy: numericCast(offset))])
      )
    }

    return Array(UnsafeMutableBufferPointer(start: p, count: n))
  }
}
