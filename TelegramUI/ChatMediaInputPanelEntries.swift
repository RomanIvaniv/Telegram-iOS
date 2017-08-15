import Postbox
import TelegramCore
import SwiftSignalKit
import Display

enum ChatMediaInputPanelAuxiliaryNamespace: Int32 {
    case recentGifs = 3
    case savedStickers = 2
    case recentStickers = 4
    case trending = 5
}

enum ChatMediaInputPanelEntryStableId: Hashable {
    case recentGifs
    case savedStickers
    case recentPacks
    case stickerPack(Int64)
    
    static func ==(lhs: ChatMediaInputPanelEntryStableId, rhs: ChatMediaInputPanelEntryStableId) -> Bool {
        switch lhs {
            case .recentGifs:
                if case .recentGifs = rhs {
                    return true
                } else {
                    return false
                }
            case .savedStickers:
                if case .savedStickers = rhs {
                    return true
                } else {
                    return false
                }
            case .recentPacks:
                if case .recentPacks = rhs {
                    return true
                } else {
                    return false
                }
            case let .stickerPack(lhsId):
                if case let .stickerPack(rhsId) = rhs, lhsId == rhsId {
                    return true
                } else {
                    return false
                }
        }
    }
    
    var hashValue: Int {
        switch self {
            case .recentGifs:
                return 0
            case .savedStickers:
                return 1
            case .recentPacks:
                return 2
            case let .stickerPack(id):
                return id.hashValue
        }
    }
}

enum ChatMediaInputPanelEntry: Comparable, Identifiable {
    case recentGifs(PresentationTheme)
    case savedStickers(PresentationTheme)
    case recentPacks(PresentationTheme)
    case stickerPack(index: Int, info: StickerPackCollectionInfo, topItem: StickerPackItem?, theme: PresentationTheme)
    
    var stableId: ChatMediaInputPanelEntryStableId {
        switch self {
            case .recentGifs:
                return .recentGifs
            case .savedStickers:
                return .savedStickers
            case .recentPacks:
                return .recentPacks
            case let .stickerPack(_, info, _, _):
                return .stickerPack(info.id.id)
        }
    }
    
    static func ==(lhs: ChatMediaInputPanelEntry, rhs: ChatMediaInputPanelEntry) -> Bool {
        switch lhs {
            case let .recentGifs(lhsTheme):
                if case let .recentGifs(rhsTheme) = rhs, lhsTheme === rhsTheme {
                    return true
                } else {
                    return false
                }
            case let .savedStickers(lhsTheme):
                if case let .savedStickers(rhsTheme) = rhs, lhsTheme === rhsTheme {
                    return true
                } else {
                    return false
                }
            case let .recentPacks(lhsTheme):
                if case let .recentPacks(rhsTheme) = rhs, lhsTheme === rhsTheme {
                    return true
                } else {
                    return false
                }
            case let .stickerPack(index, info, topItem, lhsTheme):
                if case let .stickerPack(rhsIndex, rhsInfo, rhsTopItem, rhsTheme) = rhs, index == rhsIndex, info == rhsInfo, topItem == rhsTopItem, lhsTheme === rhsTheme {
                    return true
                } else {
                    return false
                }
        }
    }
    
    static func <(lhs: ChatMediaInputPanelEntry, rhs: ChatMediaInputPanelEntry) -> Bool {
        switch lhs {
            case .recentGifs:
                switch rhs {
                    case .recentGifs:
                        return false
                    default:
                        return true
                }
            case .savedStickers:
                switch rhs {
                    case .recentGifs, savedStickers:
                        return false
                    default:
                        return true
                }
            case .recentPacks:
                switch rhs {
                    case .recentGifs, .savedStickers, recentPacks:
                        return false
                    default:
                        return true
                }
            case let .stickerPack(lhsIndex, lhsInfo, _, _):
                switch rhs {
                    case .recentGifs, .savedStickers, .recentPacks:
                        return false
                    case let .stickerPack(rhsIndex, rhsInfo, _, _):
                        if lhsIndex == rhsIndex {
                            return lhsInfo.id.id < rhsInfo.id.id
                        } else {
                            return lhsIndex <= rhsIndex
                        }
                }
        }
    }
    
    func item(account: Account, inputNodeInteraction: ChatMediaInputNodeInteraction) -> ListViewItem {
        switch self {
            case let .recentGifs(theme):
                return ChatMediaInputRecentGifsItem(inputNodeInteraction: inputNodeInteraction, theme: theme, selected: {
                    let collectionId = ItemCollectionId(namespace: ChatMediaInputPanelAuxiliaryNamespace.recentGifs.rawValue, id: 0)
                    inputNodeInteraction.navigateToCollectionId(collectionId)
                })
            case let .savedStickers(theme):
                return ChatMediaInputMetaSectionItem(inputNodeInteraction: inputNodeInteraction, type: .savedStickers, theme: theme, selected: {
                    let collectionId = ItemCollectionId(namespace: ChatMediaInputPanelAuxiliaryNamespace.savedStickers.rawValue, id: 0)
                    inputNodeInteraction.navigateToCollectionId(collectionId)
                })
            case let .recentPacks(theme):
                return ChatMediaInputMetaSectionItem(inputNodeInteraction: inputNodeInteraction, type: .recentStickers, theme: theme, selected: {
                    let collectionId = ItemCollectionId(namespace: ChatMediaInputPanelAuxiliaryNamespace.recentStickers.rawValue, id: 0)
                    inputNodeInteraction.navigateToCollectionId(collectionId)
                })
            case let .stickerPack(index, info, topItem, theme):
                return ChatMediaInputStickerPackItem(account: account, inputNodeInteraction: inputNodeInteraction, collectionId: info.id, stickerPackItem: topItem, index: index, theme: theme, selected: {
                    inputNodeInteraction.navigateToCollectionId(info.id)
                })
        }
    }
}
