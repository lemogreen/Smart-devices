//
//  ViewModelBindable.swift
//  Smart devices
//

protocol ViewModelBindable {
    associatedtype ViewModel: ViewModelType
    var viewModel: ViewModel! { get }

    func bind()
}

extension ViewModelBindable {
    func bindViewModel() {
        guard viewModel != nil else { return }
        bind()
    }
}
