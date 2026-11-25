import Guidelines

public enum GuidelineDiagnosticSeverity:
    Sendable,
    Hashable
{
    case warning
    case error
}

@attached(peer)
public macro GuidelineViolation(
    _ guideline: Guideline,
    reason: String? = nil,
    severity: GuidelineDiagnosticSeverity = .warning
) = #externalMacro(
    module: "GuidelinesDiagnosticsMacros",
    type: "GuidelineViolationMacro"
)
