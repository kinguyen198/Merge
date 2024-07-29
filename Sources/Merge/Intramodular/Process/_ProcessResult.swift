//
// Copyright (c) Vatsal Manot
//

import FoundationX
import Swallow

/// A type that represents the result of a running a `Process`.
@Hashable
public struct _ProcessResult: Logging, @unchecked Sendable {
    #if os(macOS) || targetEnvironment(macCatalyst)
    public let process: Process
    #endif
    public let stdout: Data
    public let stderr: Data
    public let terminationError: ProcessTerminationError?
    
    /// A convenience property to get lines of the standard output, whitespace and newline trimmed.
    public var lines: [String] {
        get throws {
            let result = try stdout.toStringTrimmingWhitespacesAndNewlines().unwrap().lines().map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            
            if result.count == 1, result.first.isNilOrEmpty {
                return []
            }
            
            return result
        }
    }
    
    #if os(macOS)
    package init(
        process: Process,
        stdout: Data,
        stderr: Data,
        terminationError: Process.TerminationError?
    ) {
        self.process = process
        self.stdout = stdout
        self.stderr = stderr
        self.terminationError = terminationError
    }
    #endif
    
    public var stdoutString: String? {
        stdout.toStringTrimmingWhitespacesAndNewlines().nilIfEmpty()
    }
    
    public var stderrString: String? {
        stderr.toStringTrimmingWhitespacesAndNewlines().nilIfEmpty()
    }
    
    public func toString() throws -> String {
        try validate()
        
        return try stdoutString.unwrap()
    }
    
    @_transparent
    public func validate() throws {
        if let terminationError {
            if let stderrString = stderrString {
                logger.error(stderrString)
            }
            
            throw terminationError
        }
    }
}

#if os(macOS) || targetEnvironment(macCatalyst)
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
@available(macCatalyst, unavailable)
extension _ProcessResult {
    package init(
        process: Process,
        stdout: String,
        stderr: String,
        terminationError: Process.TerminationError?
    ) throws {
        self.init(
            process: process,
            stdout: try stdout.data(),
            stderr: try stderr.data(),
            terminationError: terminationError
        )
    }
}
#endif

#if os(macOS)
extension Process {
    @available(*, deprecated, renamed: "_ProcessResult")
    public typealias AllOutput = _ProcessResult
}
#endif
