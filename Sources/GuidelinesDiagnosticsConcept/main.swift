import Guidelines
import GuidelinesDiagnostics

@GuidelineViolation(
    .structure.parse_dont_validate.strong_result
)
enum TypoType {
    case hello
}

let value: TypoType = .hello

print(value)
print(
    Guideline
        .structure
        .parse_dont_validate
        .strong_result
        .reference
)
