import ImagineUI

// TODO: Consider building text insetting into `Label` itself on ImagineUI upstream.

/// A label that has support for text insetting.
public class LabelControl: ControlView {
    private var label: Label
    
    public var text: String {
        get { label.text }
        set { label.text = newValue }
    }
    
    public var textColor: Color {
        get { label.textColor }
        set { label.textColor = newValue }
    }
    
    public var attributedText: AttributedText {
        get { label.attributedText }
        set { label.attributedText = newValue }
    }

    /// Specifies the inset of the label within the bounds of this label control.
    public var textInset = UIEdgeInsets(left: 5, top: 2.5, right: 5, bottom: 2.5) {
        didSet {
            guard textInset != oldValue else { return }
            
            updateConstraints()
        }
    }

    public convenience override init() {
        let font = Fonts.defaultFont(size: 12)
        
        self.init(font: font)
    }
    
    public convenience init(text: String) {
        let font = Fonts.defaultFont(size: 12)
        
        self.init(font: font)
        
        self.text = text
    }

    public convenience init(textColor: Color) {
        let font = Fonts.defaultFont(size: 12)
        
        self.init(textColor: textColor, font: font)
    }
    
    public init(font: Font) {
        label = Label(textColor: .white, font: font)
        
        super.init()

        backColor = .black.withTransparency(60)
    }

    public init(textColor: Color, font: Font) {
        label = Label(textColor: textColor, font: font)
        
        super.init()

        backColor = .black.withTransparency(60)
    }
    
    public override func setupHierarchy() {
        addSubview(label)
    }
    
    public override func setupConstraints() {
        label.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: textInset)
        }
    }

    private func updateConstraints() {
        label.layout.updateConstraints { make in
            make.edges.equalTo(self, inset: textInset)
        }
    }
}
