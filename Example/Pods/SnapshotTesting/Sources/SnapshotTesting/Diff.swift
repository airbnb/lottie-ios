import Foundation

struct Difference<A> {
  enum Which {
    case first
    case second
    case both
  }

  let elements: [A]
  let which: Which
}

func diff<A: Hashable>(_ fst: [A], _ snd: [A]) -> [Difference<A>] {
  var idxsOf = [A: [Int]]()
  fst.enumerated().forEach { idxsOf[$1, default: []].append($0) }

  let sub = snd.enumerated().reduce((overlap: [Int: Int](), fst: 0, snd: 0, len: 0)) { sub, sndPair in
    (idxsOf[sndPair.element] ?? [])
      .reduce((overlap: [Int: Int](), fst: sub.fst, snd: sub.snd, len: sub.len)) { innerSub, fstIdx in

        var newOverlap = innerSub.overlap
        newOverlap[fstIdx] = (sub.overlap[fstIdx - 1] ?? 0) + 1

        if let newLen = newOverlap[fstIdx], newLen > sub.len {
          return (newOverlap, fstIdx - newLen + 1, sndPair.offset - newLen + 1, newLen)
        }
        return (newOverlap, innerSub.fst, innerSub.snd, innerSub.len)
    }
  }
  let (_, fstIdx, sndIdx, len) = sub

  if len == 0 {
    let fstDiff = fst.isEmpty ? [] : [Difference(elements: fst, which: .first)]
    let sndDiff = snd.isEmpty ? [] : [Difference(elements: snd, which: .second)]
    return fstDiff + sndDiff
  } else {
    let fstDiff = diff(Array(fst.prefix(upTo: fstIdx)), Array(snd.prefix(upTo: sndIdx)))
    let midDiff = [Difference(elements: Array(fst.suffix(from: fstIdx).prefix(len)), which: .both)]
    let lstDiff = diff(Array(fst.suffix(from: fstIdx + len)), Array(snd.suffix(from: sndIdx + len)))
    return fstDiff + midDiff + lstDiff
  }
}

let minus = "−"
let plus = "+"
private let figureSpace = "\u{2007}"

struct Hunk {
  let fstIdx: Int
  let fstLen: Int
  let sndIdx: Int
  let sndLen: Int
  let lines: [String]

  var patchMark: String {
    let fstMark = "\(minus)\(fstIdx + 1),\(fstLen)"
    let sndMark = "\(plus)\(sndIdx + 1),\(sndLen)"
    return "@@ \(fstMark) \(sndMark) @@"
  }

  // Semigroup

  static func +(lhs: Hunk, rhs: Hunk) -> Hunk {
    return Hunk(
      fstIdx: lhs.fstIdx + rhs.fstIdx,
      fstLen: lhs.fstLen + rhs.fstLen,
      sndIdx: lhs.sndIdx + rhs.sndIdx,
      sndLen: lhs.sndLen + rhs.sndLen,
      lines: lhs.lines + rhs.lines
    )
  }

  // Monoid

  init(fstIdx: Int = 0, fstLen: Int = 0, sndIdx: Int = 0, sndLen: Int = 0, lines: [String] = []) {
    self.fstIdx = fstIdx
    self.fstLen = fstLen
    self.sndIdx = sndIdx
    self.sndLen = sndLen
    self.lines = lines
  }

  init(idx: Int = 0, len: Int = 0, lines: [String] = []) {
    self.init(fstIdx: idx, fstLen: len, sndIdx: idx, sndLen: len, lines: lines)
  }
}

func chunk(diff diffs: [Difference<String>], context ctx: Int = 4) -> [Hunk] {
  func prepending(_ prefix: String) -> (String) -> String {
    return { prefix + $0 + ($0.hasSuffix(" ") ? "¬" : "") }
  }
  let changed: (Hunk) -> Bool = { $0.lines.contains(where: { $0.hasPrefix(minus) || $0.hasPrefix(plus) }) }

  let (hunk, hunks) = diffs
    .reduce((current: Hunk(), hunks: [Hunk]())) { cursor, diff in
      let (current, hunks) = cursor
      let len = diff.elements.count

      switch diff.which {
      case .both where len > ctx * 2:
        let hunk = current + Hunk(len: ctx, lines: diff.elements.prefix(ctx).map(prepending(figureSpace)))
        let next = Hunk(
          fstIdx: current.fstIdx + current.fstLen + len - ctx,
          fstLen: ctx,
          sndIdx: current.sndIdx + current.sndLen + len - ctx,
          sndLen: ctx,
          lines: (diff.elements.suffix(ctx) as ArraySlice<String>).map(prepending(figureSpace))
        )
        return (next, changed(hunk) ? hunks + [hunk] : hunks)
      case .both where current.lines.isEmpty:
        let lines = (diff.elements.suffix(ctx) as ArraySlice<String>).map(prepending(figureSpace))
        let count = lines.count
        return (current + Hunk(idx: len - count, len: count, lines: lines), hunks)
      case .both:
        return (current + Hunk(len: len, lines: diff.elements.map(prepending(figureSpace))), hunks)
      case .first:
        return (current + Hunk(fstLen: len, lines: diff.elements.map(prepending(minus))), hunks)
      case .second:
        return (current + Hunk(sndLen: len, lines: diff.elements.map(prepending(plus))), hunks)
      }
  }

  return changed(hunk) ? hunks + [hunk] : hunks
}
