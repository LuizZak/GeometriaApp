
import Foundation
import WinSDK
import SwiftCOM

let startSize = Size(width: 400, height: 300)

public func winMain() -> Int32 {
    // Initialize COM
    do {
        try CoInitializeEx(COINIT_MULTITHREADED)
    } catch {
        //log.error("CoInitializeEx: \(error)")
        return EXIT_FAILURE
    }

    // Enable Per Monitor DPI Awareness
    if !SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2) {
        //log.error("SetProcessDpiAwarenessContext: \(Error(win32: GetLastError()))")
    }

    let dwICC: DWORD = DWORD(ICC_BAR_CLASSES)
        | DWORD(ICC_DATE_CLASSES)
        | DWORD(ICC_LISTVIEW_CLASSES)
        | DWORD(ICC_NATIVEFNTCTL_CLASS)
        | DWORD(ICC_PROGRESS_CLASS)
        | DWORD(ICC_STANDARD_CLASSES)
    
    var ICCE: INITCOMMONCONTROLSEX =
        INITCOMMONCONTROLSEX(dwSize: DWORD(MemoryLayout<INITCOMMONCONTROLSEX>.size),
                             dwICC: dwICC)
    if !InitCommonControlsEx(&ICCE) {
        //log.error("InitCommonControlsEx: \(Error(win32: GetLastError()))")
    }

    var pAppRegistration: PAPPSTATE_REGISTRATION?
    let ulStatus =
        RegisterAppStateChangeNotification(pApplicationStateChangeRoutine, nil,
                                            &pAppRegistration)
    if ulStatus != ERROR_SUCCESS {
        //log.error("RegisterAppStateChangeNotification: \(Error(win32: GetLastError()))")
    }

    showMainWindow(size: startSize)
    
    var msg: MSG = MSG()
    var nExitCode: Int32 = EXIT_SUCCESS

    mainLoop: while true {
        // Process all messages in thread's message queue; for GUI applications UI
        // events must have high priority.
        while PeekMessageW(&msg, nil, 0, 0, UINT(PM_REMOVE)) {
            if msg.message == UINT(WM_QUIT) {
                nExitCode = Int32(msg.wParam)
                break mainLoop
            }

            TranslateMessage(&msg)
            DispatchMessageW(&msg)
        }

        var limitDate: Date? = nil
        repeat {
            // Execute Foundation.RunLoop once and determine the next time the timer
            // fires. At this point handle all Foundation.RunLoop timers, sources and
            // Dispatch.DispatchQueue.main tasks
            limitDate = RunLoop.main.limitDate(forMode: .default)

            // If Foundation.RunLoop doesn't contain any timers or the timers should
            // not be running right now, we interrupt the current loop or otherwise
            // continue to the next iteration.
        } while (limitDate?.timeIntervalSinceNow ?? -1) <= 0

        // Yield control to other threads.  If Foundation.RunLoop contains a timer
        // to execute, we wait until a new message is placed in the thread's message
        // queue or the timer must fire, otherwise we proceed to the next iteration
        // of mainLoop, using 0 as the wait timeout.
        _ = WaitMessage(DWORD(exactly: limitDate?.timeIntervalSinceNow ?? 0 * 1000) ?? DWORD.max)
    }

    return nExitCode
}

// Waits for a message on the message queue, returning when either a message has
// arrived or the timeout specified has expired.
private func WaitMessage(_ dwMilliseconds: UINT) -> Bool {
    let uIDEvent = WinSDK.SetTimer(nil, 0, dwMilliseconds, nil)
    defer { WinSDK.KillTimer(nil, uIDEvent) }

    return WinSDK.WaitMessage()
}

private let pApplicationStateChangeRoutine: PAPPSTATE_CHANGE_ROUTINE = { (quiesced: UInt8, context: PVOID?) in
    let foregrounding: Bool = quiesced == 0
    if foregrounding {
        // TODO: Handle moving-to-foreground event
    } else {
        // TODO: Handle moving-to-background event
    }
}