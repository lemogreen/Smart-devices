//
//  ViewController.swift
//  Smart devices
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxDataSources

final class DevicesListViewController: UIViewController {
    var viewModel: DevicesListViewModel!
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        collectionView.register(DeviceCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer()
        gestureRecognizer.minimumPressDuration = 0.5
        return gestureRecognizer
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Asset.Images.Backgrounds.deviceListBackgroundRed.image
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var refreshControl = UIRefreshControl()
    private let disposeBag = DisposeBag()
    
    private let dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfDeviceData>(
        configureCell: { _, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "cell",
                for: indexPath
            ) as? DeviceCollectionViewCell else { return UICollectionViewCell() }
            cell.configure(with: item)
            return cell
        }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
}

extension DevicesListViewController: ViewModelBindable {
    func bind() {
        let viewDidAppearSignal = rx.viewDidAppear
            .take(1)
            .asSignal(onErrorSignalWith: .never())
            .map { _ in }
        
        let refreshControlValueChanged = refreshControl.rx
            .controlEvent(.valueChanged)
            .asSignal()
        
        let deviceToUpdateIndexPath = longPressGestureRecognizer.rx.event.asSignal()
            .filter { $0.state == .began }
            .map { [weak collectionView] gestureRecognizer -> IndexPath? in
                let point = gestureRecognizer.location(in: self.collectionView)
                return collectionView?.indexPathForItem(at: point)
            }
        
        let didSelectCell = collectionView.rx.itemSelected.asSignal()
        
        let input = ViewModel.Input(
            viewWillAppearSignal: viewDidAppearSignal,
            refreshControlValueChanged: refreshControlValueChanged,
            deviceToUpdateIndexPath: deviceToUpdateIndexPath,
            didSelectCell: didSelectCell
        )
        
        let output = viewModel.transform(input)
        output.cells
            .do(onNext: { [weak refreshControl] _ in refreshControl?.endRefreshing() })
            .drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        output.deviceUpdatedSignal
            .do(onNext: { _ in
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            })
            .emit()
            .disposed(by: disposeBag)
                    
        output.pullcord.emit().disposed(by: disposeBag)
                
        NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?.handleDeviceRotation() })
            .disposed(by: disposeBag)
    }
}

private extension DevicesListViewController {
    func setupUI() {
        title = L10n.DevicesList.title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { $0.top.left.right.bottom.equalToSuperview() }
        collectionView.addSubview(refreshControl)
        collectionView.backgroundColor = .clear
        backgroundImageView.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.top.left.bottom.right.equalToSuperview() }
        
        collectionView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let deviceOrientation = DevicesListCollectionViewOrientationType(
            rawValue: UIDevice.current.orientation.rawValue
        ) ?? .portrait
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupHeight = NSCollectionLayoutDimension.fractionalHeight(
            deviceOrientation.groupSizeСoefficient
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: groupHeight
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: deviceOrientation.numberOfRows
        )
        
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 10,
            bottom: 0,
            trailing: 10
        )

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func handleDeviceRotation() {
        if UIDevice.current.orientation.isLandscape {
            collectionView.setCollectionViewLayout(
                createLayout(),
                animated: true
            )
        }
        
        if UIDevice.current.orientation.isPortrait {
            collectionView.setCollectionViewLayout(
                createLayout(),
                animated: true
            )
        }
    }
}

private enum DevicesListCollectionViewOrientationType: Int {
    case landscape
    case portrait
    
    init?(rawValue: Int) {
        switch rawValue {
        case 1:
            self = .portrait
        case 3, 4:
            self = .landscape
        default:
            return nil
        }
    }
    
    var groupSizeСoefficient: CGFloat {
        switch self {
        case .landscape:
            switch UIScreen.sizeClass {
            case .extraSmall:
                return 0.50
            case .small:
                return 0.40
            case .medium:
                return 0.35
            case .large:
                return 0.30
            case .extraLarge:
                return 0.15
            case .none:
                return 0.15
            }
        case .portrait:
            switch UIScreen.sizeClass {
            case .extraSmall:
                return 0.25
            case .small:
                return 0.22
            case .medium:
                return 0.17
            case .large:
                return 0.15
            case .extraLarge:
                return 0.12
            case .none:
                return 0.15
            }
        }
    }
    
    var numberOfRows: Int {
        switch self {
        case .landscape:
            return 4
        case .portrait:
            return 2
        }
    }
}
