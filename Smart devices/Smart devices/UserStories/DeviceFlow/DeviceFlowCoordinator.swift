//
//  DeviceFlowCoordinator.swift
//  Smart devices
//

import Foundation
import UIKit

protocol DeviceControlRouter: AnyObject {
    func closeModal()
}

final class DeviceFlowCoordinator: CoordinatorType {
    let navigationController: UINavigationController
    let context: Context
    
    init(context: Context, navigationController: UINavigationController) {
        self.context = context
        self.navigationController = navigationController
    }
    
    func start() {
        let devicesListViewController = DevicesListViewController()
        let devicesListViewModel = DevicesListViewModel(context: context)
        devicesListViewModel.coordinatorRouter = self
        devicesListViewController.viewModel = devicesListViewModel
        navigationController.viewControllers = [devicesListViewController]
    }
}

extension DeviceFlowCoordinator: DevicesListCoordinatorRouter {
    func openDeviceDetailsPage(device: Device) {
        switch device.deviceType {
        case .light:
            let viewController = LightControlViewController()
            let configuration = LightControlViewModel.Configuration(selectedDevice: device)
            let viewModel = LightControlViewModel(
                context: context,
                configuration: configuration
            )
            viewModel.coordinatorRouter = self
            viewController.viewModel = viewModel
            viewController.modalPresentationStyle = .formSheet
            viewController.isModalInPresentation = true
            navigationController.present(viewController, animated: true)
        case .heater:
            let viewController = HeaterControlViewController()
            let configuration = HeaterControlViewModel.Configuration(selectedDevice: device)
            let viewModel = HeaterControlViewModel(
                context: context,
                configuration: configuration
            )
            viewModel.coordinatorRouter = self
            viewController.viewModel = viewModel
            viewController.modalPresentationStyle = .formSheet
            viewController.isModalInPresentation = true
            navigationController.present(viewController, animated: true)
        case .rollerShutter:
            let viewController = RollerShuttersViewController()
            let configuration = RollerShuttersViewModel.Configuration(selectedDevice: device)
            let viewModel = RollerShuttersViewModel(
                context: context,
                configuration: configuration
            )
            viewModel.coordinatorRouter = self
            viewController.viewModel = viewModel
            viewController.modalPresentationStyle = .formSheet
            viewController.isModalInPresentation = true
            navigationController.present(viewController, animated: true)
        }
    }
}

extension DeviceFlowCoordinator: DeviceControlRouter {
    func closeModal() {
        navigationController.dismiss(animated: true)
    }
}
