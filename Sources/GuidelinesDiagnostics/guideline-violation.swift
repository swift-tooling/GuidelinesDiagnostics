import Guidelines

@attached(peer)
public macro GuidelineViolation(
    _ guideline: Guideline
) = #externalMacro(
    module: "GuidelinesDiagnosticsMacros",
    type: "GuidelineViolationMacro"
)
