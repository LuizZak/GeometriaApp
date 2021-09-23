import WinSDK

/// A Win32 window.
class Window {
    private let minSize: Size = Size(width: 200, height: 150)
    private var hwnd: HWND?
    private var size: Size

    init(size: Size) {
        self.size = size

        initialize()
    }

    deinit {
        // TODO: Free handle?
    }

    private func initialize() {
        let handle = GetModuleHandleW(nil)
        
        let IDC_ARROW: UnsafePointer<WCHAR> =
            UnsafePointer<WCHAR>(bitPattern: 32512)!

        // Register the window class.
        let CLASS_NAME = "Sample Window Class"
        
        let wc: WNDCLASSW = CLASS_NAME.withUnsafeWideBuffer { p in
            var wc = WNDCLASSW()

            wc.style         = UINT(CS_HREDRAW | CS_VREDRAW)
            wc.hCursor       = LoadCursorW(nil, IDC_ARROW)
            wc.lpfnWndProc   = windowProc
            wc.hInstance     = handle
            wc.lpszClassName = p.baseAddress!

            RegisterClassW(&wc)
            
            return wc
        }
        
        // Create the window.
        hwnd = CreateWindowExW(
            0,                               // Optional window styles.
            wc.lpszClassName,                // Window class
            "Learn to Program Windows".wide, // Window text
            WS_OVERLAPPEDWINDOW,             // Window style
            
            // Size and position
            CW_USEDEFAULT, CW_USEDEFAULT, Int32(size.width), Int32(size.height),

            nil,     // Parent window    
            nil,     // Menu
            handle,  // Instance handle
            nil      // Additional application data
        )

        if (hwnd == nil) {
            fatalError("Failed to create window.")
        }
    }

    func show() {
        ShowWindow(hwnd, SW_RESTORE)
    }
}

func windowProc(_ hwnd: HWND?, _ uMsg: UINT, _ wParam: WPARAM, _ lParam: LPARAM) -> LRESULT {
    switch (uMsg) {
    case UINT(WM_DESTROY):
        PostQuitMessage(0)
        return 0

    case UINT(WM_PAINT):
        var ps = PAINTSTRUCT()
        let hdc: HDC = BeginPaint(hwnd, &ps)
        defer { EndPaint(hwnd, &ps) }
        
        // All painting occurs here, between BeginPaint and EndPaint.
        FillRect(hdc, &ps.rcPaint, GetSysColorBrush(COLOR_WINDOW))
        
        return 0

    case UINT(WM_GETMINMAXINFO):
        func ClientSizeToWindowSize(_ size: Size) -> Size {
            var rc: RECT = RECT(from: Rect(origin: .zero, size: size))

            let gwlStyle: LONG = WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SIZEBOX
            let gwlExStyle: LONG = WS_EX_CLIENTEDGE

            if !AdjustWindowRectExForDpi(&rc,
                                        DWORD(gwlStyle),
                                        false,
                                        DWORD(gwlExStyle),
                                        GetDpiForWindow(hwnd)) {
                // log.warning("AdjustWindowRetExForDpi: \(Error(win32: GetLastError()))")
            }

            return Rect(from: rc).size
        }
        
        let lpInfo: UnsafeMutablePointer<MINMAXINFO> = .init(bitPattern: UInt(lParam))!
        
        // Adjust the minimum and maximum tracking size for the window.
        lpInfo.pointee.ptMinTrackSize =
            POINT(from: ClientSizeToWindowSize(minSize))

        return LRESULT(0)

    default:
        return DefWindowProcW(hwnd, uMsg, wParam, lParam)
    }
}
