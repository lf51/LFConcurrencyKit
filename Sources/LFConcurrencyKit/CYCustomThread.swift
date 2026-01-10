// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// A dedicated run-loop–backed thread for executing serialized work.
///
/// `CYCustomThread` manages a long-lived `Thread` with an active `RunLoop`,
/// allowing arbitrary blocks to be scheduled and executed on that thread.
///
/// This is useful for scenarios that require:
/// - A stable execution context
/// - Stream or socket handling
/// - Precise control over the lifetime of a background thread
///
/// The thread is started at initialization time and remains alive until
/// `stop()` is explicitly called.
final public class CYCustomThread: NSObject {

    /// A lightweight container used to bridge Swift closures
    /// through Objective-C selector-based APIs.
    private final class BlockBox: NSObject {
        let block: () -> Void

        init(_ block: @escaping () -> Void) {
            self.block = block
        }
    }

    /// The human-readable name assigned to the underlying thread.
    private let threadName: String

    /// The managed background thread.
    private var thread: Thread!

    /// The run loop associated with the managed thread.
    private var runLoop: RunLoop?

    /// Indicates whether the thread has been stopped.
    private var isStopped = false

    /// Creates and starts a new custom thread with an active run loop.
    ///
    /// - Parameter name: A descriptive name used to identify the thread.
    public init(name: String) {
        
        self.threadName = name
        super.init()

        thread = Thread(
            target: self,
            selector: #selector(threadEntryPoint),
            object: nil
        )
        
        thread.name = name
        thread.start()
    }

    /// Entry point for the managed thread.
    ///
    /// This method installs a run loop and a dummy input source to keep
    /// the thread alive and able to process scheduled work.
    @objc private func threadEntryPoint() {
        
        let currentRunLoop = RunLoop.current
        runLoop = currentRunLoop

        let keepAlivePort = Port()
        currentRunLoop.add(keepAlivePort, forMode: .default)

        currentRunLoop.run()
    }

    /// Schedules a block for asynchronous execution on the custom thread.
    ///
    /// If the thread has been stopped, the block is silently ignored.
    ///
    /// - Parameter block: The work to be executed on the custom thread.
    public func perform(_ block: @escaping () -> Void) {
        
        guard !isStopped else { return }

        let box = BlockBox(block)
        perform(
            #selector(executeBlockBox(_:)),
            on: thread,
            with: box,
            waitUntilDone: false
        )
    }

    /// Executes a boxed block on the custom thread.
    ///
    /// - Parameter box: A container holding the block to execute.
    @objc private func executeBlockBox(_ box: BlockBox) {
        box.block()
    }

    /// Stops the custom thread and terminates its run loop.
    ///
    /// Once stopped, the thread cannot be restarted and any further
    /// scheduled work will be ignored.
    public func stop() {
        
        guard !isStopped else { return }

        isStopped = true
        thread.cancel()

        if let runLoop {
            CFRunLoopStop(runLoop.getCFRunLoop())
        }
    }
}
