#!/usr/bin/swift

import Foundation
import AppKit

struct Finding {
    let column: Int
    let wrongWord: String
    let suggestions: [String]
}

func highlightedLine(from line: String, findings: [Finding]) -> String {
    let nsLine = line as NSString
    let sortedFindings = findings.sorted(by: { $0.column < $1.column })

    var result = ""
    var cursor = 0

    for finding in sortedFindings {
        let start = finding.column - 1
        let length = (finding.wrongWord as NSString).length

        if start < cursor || start < 0 || start + length > nsLine.length {
            continue
        }

        result += nsLine.substring(with: NSRange(location: cursor, length: start - cursor))
        let word = nsLine.substring(with: NSRange(location: start, length: length))
        result += "\u{001B}[4;33m\(word)\u{001B}[0m"
        cursor = start + length
    }

    if cursor < nsLine.length {
        result += nsLine.substring(from: cursor)
    }

    return result
}

func printUsageAndExit() -> Never {
    fputs("Usage: spell-check.swift [--wordlist /path/to/wordlist] \"line of text\"\n", stderr)
    exit(1)
}

var customWordlistPath: String?
var lineInput: String?
var index = 1

while index < CommandLine.arguments.count {
    let arg = CommandLine.arguments[index]

    if arg == "--wordlist" {
        guard index + 1 < CommandLine.arguments.count else {
            fputs("Missing value for --wordlist\n", stderr)
            printUsageAndExit()
        }
        customWordlistPath = CommandLine.arguments[index + 1]
        index += 2
        continue
    }

    if lineInput == nil {
        lineInput = arg
        index += 1
        continue
    }

    printUsageAndExit()
}

guard let line = lineInput else {
    printUsageAndExit()
}

let checker = NSSpellChecker.shared
let language = "en_US"

func loadDictionary(from paths: [String]) -> Set<String> {
    var words = Set<String>()

    for path in paths {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            continue
        }

        for rawLine in content.split(whereSeparator: \.isNewline) {
            let token = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if !token.isEmpty {
                words.insert(token.lowercased())
            }
        }
    }

    return words
}

let defaultWordlists = [
    "/usr/share/dict/words",
    "/usr/share/dict/propernames"
]

let dictionary: Set<String>
if let customWordlistPath {
    let expandedPath = (customWordlistPath as NSString).expandingTildeInPath
    if (try? String(contentsOfFile: expandedPath, encoding: .utf8)) == nil {
        fputs("Could not read custom wordlist: \(expandedPath)\n", stderr)
        exit(1)
    }
    dictionary = loadDictionary(from: defaultWordlists + [expandedPath])
} else {
    dictionary = loadDictionary(from: defaultWordlists)
}

let nsLine = line as NSString
let regex = try NSRegularExpression(pattern: "[A-Za-z]+(?:'[A-Za-z]+)?")
let matches = regex.matches(in: line, range: NSRange(location: 0, length: nsLine.length))

var findings: [Finding] = []

for match in matches {
    let word = nsLine.substring(with: match.range)
    let normalized = word.lowercased()

    if normalized.count <= 1 {
        continue
    }

    let misspelled = checker.checkSpelling(
        of: word,
        startingAt: 0,
        language: language,
        wrap: false,
        inSpellDocumentWithTag: 0,
        wordCount: nil
    )

    let isMisspelled = misspelled.location != NSNotFound
    let isUnknown = !dictionary.contains(normalized)

    if !(isMisspelled || isUnknown) {
        continue
    }

    let singleWordRange = NSRange(location: 0, length: (word as NSString).length)
    let guesses = checker.guesses(
        forWordRange: singleWordRange,
        in: word,
        language: language,
        inSpellDocumentWithTag: 0
    ) ?? []

    findings.append(Finding(
        column: match.range.location + 1,
        wrongWord: word,
        suggestions: guesses
    ))
}

let sortedFindings = findings.sorted(by: { $0.column < $1.column })
print(highlightedLine(from: line, findings: sortedFindings))

if !sortedFindings.isEmpty {
    var markerChars = Array(repeating: Character(" "), count: nsLine.length)

    for finding in sortedFindings {
        let index = finding.column - 1
        if index >= 0 && index < markerChars.count {
            markerChars[index] = "|"
        }
    }

    print(String(markerChars))

    let branchFindings = sortedFindings.sorted(by: { $0.column > $1.column })

    for (index, finding) in branchFindings.enumerated() {
        var rowChars = Array(repeating: Character(" "), count: nsLine.length)
        let currentIndex = max(0, finding.column - 1)

        for pending in branchFindings[(index + 1)...] {
            let pendingIndex = pending.column - 1
            if pendingIndex >= 0 && pendingIndex < rowChars.count {
                rowChars[pendingIndex] = "|"
            }
        }

        if currentIndex >= 0 && currentIndex < rowChars.count {
            rowChars[currentIndex] = "+"
        }

        let prefix = currentIndex > 0 ? String(rowChars[0..<currentIndex]) : ""
        let correction = finding.suggestions.isEmpty
            ? "(no suggestion)"
            : finding.suggestions.joined(separator: ", ")
        print("\(prefix)+--> \(correction)")
    }
}
