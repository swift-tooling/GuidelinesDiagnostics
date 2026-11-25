import Guidelines
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct GuidelineViolationMacro:
    PeerMacro
{
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let arguments = node.arguments?.as(
                LabeledExprListSyntax.self
            ),
            let guidelineArgument = arguments.first
        else {
            return []
        }

        guard let guideline = resolveGuideline(
            from: guidelineArgument.expression
        ) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(
                        guidelineArgument.expression
                    ),
                    message: UnsupportedGuidelineDiagnostic()
                )
            )

            return []
        }

        let severity = diagnosticSeverity(
            from: arguments
        )

        let reason = diagnosticReason(
            from: arguments
        )

        context.diagnose(
            Diagnostic(
                node: Syntax(node),
                message: ViolationDiagnostic(
                    reference: guideline.reference,
                    summary: guideline.summary,
                    reason: reason,
                    severity: severity
                )
            )
        )

        return []
    }

    private static func resolveGuideline(
        from expression: ExprSyntax
    ) -> Guideline? {
        guard
            let call = expression.as(
                FunctionCallExprSyntax.self
            ),
            call.arguments.count == 1,
            let family = call.calledExpression.as(
                MemberAccessExprSyntax.self
            ),
            let childArgument = call.arguments.first,
            let child = childArgument.expression.as(
                MemberAccessExprSyntax.self
            )
        else {
            return nil
        }

        let familyName =
            family.declName.baseName.text

        let guidelineName =
            child.declName.baseName.text

        let suffix =
            ".\(familyName).\(guidelineName)"

        return Guideline.all.first {
            $0.reference.hasSuffix(
                suffix
            )
        }
    }

    private static func diagnosticReason(
        from arguments: LabeledExprListSyntax
    ) -> String? {
        guard
            let argument = arguments.first(
                where: {
                    $0.label?.text == "reason"
                }
            ),
            let literal = argument.expression.as(
                StringLiteralExprSyntax.self
            )
        else {
            return nil
        }

        var value = ""

        for segment in literal.segments {
            guard
                let string = segment.as(
                    StringSegmentSyntax.self
                )
            else {
                return nil
            }

            value += string.content.text
        }

        let normalized = value
            .split(
                whereSeparator: {
                    $0.isWhitespace
                }
            )
            .joined(
                separator: " "
            )

        return normalized.isEmpty
            ? nil
            : normalized
    }

    private static func diagnosticSeverity(
        from arguments: LabeledExprListSyntax
    ) -> DiagnosticSeverity {
        guard
            let argument = arguments.first(
                where: {
                    $0.label?.text == "severity"
                }
            )
        else {
            return .warning
        }

        guard
            let member = argument.expression.as(
                MemberAccessExprSyntax.self
            )
        else {
            return .warning
        }

        switch member.declName.baseName.text {
        case "error":
            return .error

        default:
            return .warning
        }
    }
}

private struct ViolationDiagnostic:
    DiagnosticMessage
{
    let reference: String
    let summary: String
    let reason: String?
    let severity: DiagnosticSeverity

    var message: String {
        var value = """
        Guideline violation: \(reference)

        \(summary)
        """

        if let reason {
            value += """

            Reason: \(reason)
            """
        }

        return value
    }

    var diagnosticID: MessageID {
        .init(
            domain: "GuidelinesDiagnostics",
            id: reference
        )
    }
}

private struct UnsupportedGuidelineDiagnostic:
    DiagnosticMessage
{
    let severity: DiagnosticSeverity = .error

    var message: String {
        """
        GuidelineViolation requires a direct guideline case expression such as .parse_dont_validate(.strong_result).
        """
    }

    var diagnosticID: MessageID {
        .init(
            domain: "GuidelinesDiagnostics",
            id: "unsupported-guideline-expression"
        )
    }
}

@main
struct GuidelinesDiagnosticsPlugin:
    CompilerPlugin
{
    let providingMacros: [Macro.Type] = [
        GuidelineViolationMacro.self,
    ]
}
