//
//  ContentViewModel.swift
//  Healthcare
//
//  Created by T T on 2021/06/21.
//

import Foundation
import Combine
import HealthKit

final class ContentViewModel: ViewModelObject {

    let input: Input
    let output: Output
    @BindableObject private(set) var binding: Binding

    final class Input: InputObject {
        let onAppear = PassthroughSubject<Void, Never>()
        let setFirstOpen = PassthroughSubject<Void, Never>()

    }

    final class Output: OutputObject {
    }

    final class Binding: BindingObject {
        @Published var isfirstOpen: Bool = true
    }

    private var cancellables = Set<AnyCancellable>()

    init() {

        self.input = Input()
        self.output = Output()
        self.binding = Binding()

        self.bindInputs()
        self.bindOutputs()
        self.request()

        self.binding.isfirstOpen = isfirstOpen()
    }

    private func bindInputs() {
        self.input.setFirstOpen.sink { [weak self] in
            guard let self = self else { return }
            self.setFirstOpen()
            self.binding.isfirstOpen = self.isfirstOpen()
        }.store(in: &cancellables)

    }
    private func bindOutputs() {
    }
    private func request() {
    }

    deinit {

    }

    func isfirstOpen() -> Bool {
        return UserDefaults.standard.object(forKey: "firstOpen") as? Bool ?? true
    }

    func setFirstOpen() {
        UserDefaults.standard.set(false, forKey: "firstOpen")
    }
}
