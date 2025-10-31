import Foundation
import UIKit
import React

@objc(CounterView)
class CounterView: UIView {
    
    // MARK: - Properties
    private var counterValue: Int = 0 {
        didSet {
            updateUI()
            if shouldSendEvent {
                sendCountChangeEvent()
            }
        }
    }
    
    private var shouldSendEvent = true
    
    @objc var count: NSNumber = 0 {
        didSet {
            // Prevent circular updates: when prop is set from JS, don't send event
            shouldSendEvent = false
            counterValue = count.intValue
            shouldSendEvent = true
        }
    }
    
    @objc var onCountChange: RCTBubblingEventBlock?
    
    // MARK: - UI Components
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 72, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let incrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Increment", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let decrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Decrement", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Add subviews
        addSubview(stackView)
        stackView.addArrangedSubview(counterLabel)
        stackView.addArrangedSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(decrementButton)
        buttonStackView.addArrangedSubview(incrementButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            counterLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
    
    private func setupActions() {
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        decrementButton.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func incrementTapped() {
        increment()
    }
    
    @objc private func decrementTapped() {
        decrement()
    }
    
    @objc func increment() {
        counterValue += 1
    }
    
    @objc func decrement() {
        counterValue -= 1
    }
    
    // MARK: - Updates
    private func updateUI() {
        counterLabel.text = "\(counterValue)"
    }
    
    private func sendCountChangeEvent() {
        guard let onCountChange = onCountChange else { return }
        onCountChange(["count": counterValue])
    }
}

