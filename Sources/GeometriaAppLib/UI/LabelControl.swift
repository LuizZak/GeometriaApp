import ImagineUI

public class LabelControl: ControlView {
    private let textInset = UIEdgeInsets(left: 5, top: 2.5, right: 5, bottom: 2.5)
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

    public convenience override init() {
        let font = Fonts.defaultFont(size: 12)
        
        self.init(font: font)
    }
    
    public convenience init(text: String) {
        let font = Fonts.defaultFont(size: 12)
        
        self.init(font: font)
        
        self.text = text
    }
    
    public init(font: Font) {
        label = Label(textColor: .white, font: font)
        
        super.init()
        
        textColor = .white
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
}
