import ImagineUI

protocol UIDialog: View {
    var dialogDelegate: UIDialogDelegate? { get set }

    /// Called to indicate this dialog view has been opened.
    func opened()
}
