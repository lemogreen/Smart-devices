//
//  AppCoordinator.swift
//  Smart devices
//

import UIKit
import Foundation
import Moya

final class AppCoordinator: CoordinatorType {
    private let window: UIWindow?
    private let navigationController = UINavigationController()
    private var childCoordinators: [CoordinatorType] = []
    private let context: Context

    init(window: UIWindow?) {
        self.window = window
        
        let moduloAPIProvider = MoyaProvider<ModuloAPI>()
        let devicesManager = DevicesManager(moduloAPIProvider: moduloAPIProvider)
        let context = Context(devicesManager: devicesManager)
        self.context = context
    }

    func start() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        let repositoryListCoordinator = DeviceFlowCoordinator(
            context: context,
            navigationController: navigationController
        )
        childCoordinators.append(repositoryListCoordinator)
        repositoryListCoordinator.start()
    }
}
