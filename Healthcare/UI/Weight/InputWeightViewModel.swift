//
//  InputWeightViewModel.swift
//  Healthcare
//
//  Created by T T on 2021/06/17.
//

import Foundation
import Combine

final class InputWeightViewModel: ViewModelObject {

    let input: Input
    let output: Output
    @BindableObject private(set) var binding: Binding

    // 取得した時一時保存しておく、 次に進むときに差異があれば保存する
    var weightcache: Double?

    final class Input: InputObject {
        let onAppear = PassthroughSubject<Void, Never>()
        let next = PassthroughSubject<Void, Never>()
    }

    final class Output: OutputObject {
    }

    final class Binding: BindingObject {
        @Published var weight: String = ""
        @Published var next: Bool = false

    }

    private var cancellables = Set<AnyCancellable>()

    let healthDataRepository: IHealthDataRepository

    init(healthDataRepository: IHealthDataRepository = HealthDataRepositoryImpl()) {

        self.healthDataRepository = healthDataRepository
        self.input = Input()
        self.output = Output()
        self.binding = Binding()

        self.bindInputs()
        self.bindOutputs()
        self.request()
    }

    private func bindInputs() {
        self.input.onAppear.sink { [weak self] in
            guard let self = self else { return }

            self.healthDataRepository.getLastBodyMass(min: 3600)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { val in
                    self.binding.weight = val?.toInt().description ?? ""
                    self.weightcache = val
                }).store(in: &self.cancellables)
        }.store(in: &cancellables)

        self.input.next.sink { [weak self] in
            guard let self = self else { return }

            guard let weight = Double( self.binding.weight ) else { return }


            if self.weightcache != weight {
                self.saveWeight(weight: weight)
            }

            self.binding.next = true

        }.store(in: &cancellables)
    }
    private func bindOutputs() {
    }
    private func request() {
    }

    enum DataSource {
        case camera
        case custom
        case visionpose
    }

    deinit {

    }

    private func saveWeight(weight: Double) {
        let now = Date()
        
        self.healthDataRepository.save(type: .bodyMass, value: weight, start: now, end: Date())
            .assertNoFailure()
            .sink(receiveValue: { _ in
                print("保存成功")
            }).store(in: &self.cancellables)
    }
}
