//
//  InputBloodPressureViewModel.swift
//  Healthcare
//
//  Created by T T on 2021/06/17.
//

import Foundation
import Combine

final class InputBloodPressureViewModel: ViewModelObject {

    let input: Input
    let output: Output
    @BindableObject private(set) var binding: Binding

    // 取得した時一時保存しておく、 次に進むときに差異があれば保存する
    var bloodHcache: Double?
    var bloodLcache: Double?

    final class Input: InputObject {
        let onAppear = PassthroughSubject<Void, Never>()
        //        let getLastBlood = PassthroughSubject<Void, Never>()
        //        let saveBlood = PassthroughSubject<Void, Never>()
        let next = PassthroughSubject<Void, Never>()

    }

    final class Output: OutputObject {
    }

    final class Binding: BindingObject {
        @Published var dateString: String = ""
        @Published var bloodH: String = ""
        @Published var bloodL: String = ""
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

            self.healthDataRepository.getLastBloodPressureSystolic(min: 30)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { val in
                    self.binding.bloodH = val?.toInt().description ?? ""
                    self.bloodHcache = val
                }).store(in: &self.cancellables)

            self.healthDataRepository.getLastBloodPressureDiastolic(min: 30)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { val in
                    self.binding.bloodL = val?.toInt().description ?? ""
                    self.bloodLcache = val
                }).store(in: &self.cancellables)

        }.store(in: &cancellables)

        self.input.next.sink { [weak self] in
            guard let self = self else { return }

            guard let bloodH = Double( self.binding.bloodH ) else { return }
            guard let bloodL = Double( self.binding.bloodL ) else { return }


            if self.bloodHcache != bloodH || self.bloodLcache != bloodL {
                self.saveBlood(bloodH: bloodH, bloodL: bloodL)
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

    private func saveBlood(bloodH: Double, bloodL: Double) {
        let now = Date()

        self.healthDataRepository.save(type: .bloodPressureSystolic, value: bloodH, start: now, end: Date())
            .assertNoFailure()
            .sink(receiveValue: { _ in
            }).store(in: &self.cancellables)

        self.healthDataRepository.save(type: .bloodPressureDiastolic, value: bloodL, start: now, end: Date())
            .assertNoFailure()
            .sink(receiveValue: { _ in
            }).store(in: &self.cancellables)
    }
}
