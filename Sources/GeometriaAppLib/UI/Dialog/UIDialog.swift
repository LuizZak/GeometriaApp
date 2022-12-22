import ImagineUI

public protocol UIDialog: View {
    var dialogDelegate: UIDialogDelegate? { get set }

    /// Allows this dialog to provide a custom backdrop view that will be 
    /// constrained to fill the entire target view to disable mouse events while
    /// the dialog is opened.
    ///
    /// If `nil` is returned, a default backdrop is used, instead.
    func customBackdrop() -> View?

    /// Called to indicate this dialog view has been opened.
    func didOpen()

    /// Called to indicate this dialog view will close.
    func didClose()
}

public extension UIDialog {
    func customBackdrop() -> View? {
        return nil
    }
}
