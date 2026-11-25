import Guidelines
import GuidelinesDiagnostics

@GuidelineViolation(
    .parse_dont_validate(.strong_result),
    reason: "This API establishes a stronger invariant but still exposes a loose representation."
)
enum WarningExample {
    case hello
}

#if GUIDELINES_DIAGNOSTICS_ERROR_CONCEPT

@GuidelineViolation(
    .parse_dont_validate(.strong_result),
    reason: "This concept demonstrates a guideline violation that blocks compilation.",
    severity: .error
)
enum ErrorExample {
    case blocked
}

#endif

let value: WarningExample = .hello

print(value)

print(
    Guideline
        .parse_dont_validate(
            .strong_result
        )
        .reference
)
