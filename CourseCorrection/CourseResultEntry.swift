import Foundation
import SwiftUI

struct CourseResultEntry: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var classID: UUID
    var courseResult: CourseResult?
}

/// Represents a letter grade with optional plus/minus.
enum LetterGrade: String, CaseIterable, Codable, Comparable {
    case aPlus   = "A+"
    case a       = "A"
    case aMinus  = "A-"
    case bPlus   = "B+"
    case b       = "B"
    case bMinus  = "B-"
    case cPlus   = "C+"
    case c       = "C"
    case cMinus  = "C-"
    case dPlus   = "D+"
    case d       = "D"
    case dMinus  = "D-"
    case f       = "F"
    
    /// Order from highest to lowest
    static let orderedCases: [LetterGrade] = [
        .aPlus, .a, .aMinus,
        .bPlus, .b, .bMinus,
        .cPlus, .c, .cMinus,
        .dPlus, .d, .dMinus,
        .f
    ]
    
    /// Numeric value for GPA calculation (optional to adjust for your institution).
    var numericValue: Double {
        switch self {
        case .aPlus:   return 4.0  // or 4.3 if your scale uses that
        case .a:       return 4.0
        case .aMinus:  return 3.7
        case .bPlus:   return 3.3
        case .b:       return 3.0
        case .bMinus:  return 2.7
        case .cPlus:   return 2.3
        case .c:       return 2.0
        case .cMinus:  return 1.7
        case .dPlus:   return 1.3
        case .d:       return 1.0
        case .dMinus:  return 0.7
        case .f:       return 0.0
        }
    }
    
    var description: String { rawValue }
    
    static func < (lhs: LetterGrade, rhs: LetterGrade) -> Bool {
        guard let lhsIndex = orderedCases.firstIndex(of: lhs),
              let rhsIndex = orderedCases.firstIndex(of: rhs) else {
            return lhs.rawValue < rhs.rawValue
        }
        // higher grade has smaller index; so lhs < rhs if lhsIndex > rhsIndex
        return lhsIndex > rhsIndex
    }
    
    /// Initialize from a string like "B+" or "c-"
    init?(letter: String) {
        let trimmed = letter.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if let match = LetterGrade.allCases.first(where: { $0.rawValue == trimmed }) {
            self = match
        } else {
            return nil
        }
    }
}

/// Represents the overall course result/status: either a letter grade or a non-graded status.
enum CourseResult: Codable, Equatable, Hashable {
    case grade(LetterGrade)
    case withdrawn     // "W"
    case incomplete    // "I"
    case audit         // "AU" or "Audit"
    case pass          // "P" (if using pass/fail)
    case noPass        // "NP" or "F" depending on how your institution denotes
    // You can add more statuses if needed, e.g.:
    // case transferCredit  // "TC"
    // case creditReceived  // etc.
    
    /// Raw string representation, for display or encoding if needed.
    var rawValue: String {
        switch self {
        case .grade(let lg):    return lg.rawValue
        case .withdrawn:        return "W"
        case .incomplete:       return "I"
        case .audit:            return "AU"
        case .pass:             return "P"
        case .noPass:           return "NP"
        }
    }
    
    /// Optional numeric value: only letter grades have a numericValue; others return nil.
    var numericValue: Double? {
        switch self {
        case .grade(let lg):    return lg.numericValue
        default:                return nil
        }
    }
    
    /// A human-friendly description.
    var description: String {
        switch self {
        case .grade(let lg):    return lg.description
        case .withdrawn:        return "Withdrawn"
        case .incomplete:       return "Incomplete"
        case .audit:            return "Audit"
        case .pass:             return "Pass"
        case .noPass:           return "No Pass"
        }
    }

    /// All standard course result options including letter grades.
    static var allOptions: [CourseResult] {
        LetterGrade.orderedCases.map { .grade($0) } + [.withdrawn, .incomplete, .audit, .pass, .noPass]
    }
    
    /// Initialize from a string code, e.g. "B+", "W", "I", etc.
    init?(code: String) {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        // Check letter grade first:
        if let lg = LetterGrade(letter: trimmed) {
            self = .grade(lg)
            return
        }
        switch trimmed {
        case "W":
            self = .withdrawn
        case "I":
            self = .incomplete
        case "AU", "AUDIT":
            self = .audit
        case "P":
            self = .pass
        case "NP", "NO PASS", "NO-PASS":
            self = .noPass
        default:
            return nil
        }
    }
    
    /// Codable conformance using a single-string representation.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        if let v = CourseResult(code: str) {
            self = v
        } else {
            // Unknown code: fail decoding
            throw DecodingError.dataCorruptedError(in: container,
                debugDescription: "Invalid CourseResult code: \(str)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
