// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Moya

enum TrustService {
    case prices(TokensPrice)
    case getTransactions(address: String, startBlock: Int, page: Int)
    case getTokens(address: String, showBalance: Bool)
    case getTransaction(ID: String)
    case register(device: PushDevice)
    case unregister(device: PushDevice)
    case marketplace(chainID: Int)
    case assets(address: String)
}

struct TokensPrice: Encodable {
    let currency: String
    let tokens: [TokenPrice]
}

struct TokenPrice: Encodable {
    let contract: String
    let symbol: String
}

extension TrustService: TargetType {

    var baseURL: URL { return Config().remoteURL }

    var path: String {
        switch self {
        case .getTransactions:
            return "/transactions"
        case .getTokens:
            return "/tokens"
        case .getTransaction(let ID):
            return "/transactions/\(ID)"
        case .register:
            return "/push/register"
        case .unregister:
            return "/push/unregister"
        case .prices:
            return "/tokenPrices"
        case .marketplace:
            return "/marketplace"
        case .assets:
            return "/assets"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getTransactions: return .get
        case .getTokens: return .get
        case .getTransaction: return .get
        case .register: return .post
        case .unregister: return .delete
        case .prices: return .post
        case .marketplace: return .get
        case .assets: return .get
        }
    }

    var task: Task {
        switch self {
        case .getTransactions(let address, let startBlock, let page):
            return .requestParameters(parameters: [
                "address": address,
                "startBlock": startBlock,
                "page": page,
            ], encoding: URLEncoding())
        case .getTokens(let address, let showBalance):
            return .requestParameters(parameters: [
                "address": address,
                "showBalance": showBalance,
            ], encoding: URLEncoding())
        case .getTransaction:
            return .requestPlain
        case .register(let device):
            return .requestJSONEncodable(device)
        case .unregister(let device):
            return .requestJSONEncodable(device)
        case .prices(let tokensPrice):
            return .requestJSONEncodable(tokensPrice)
        case .marketplace(let chainID):
            return .requestParameters(parameters: ["chainID": chainID], encoding: URLEncoding())
        case .assets(let address):
            return .requestParameters(parameters: ["address": address], encoding: URLEncoding())
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return [
            "Content-type": "application/json",
            "client": Bundle.main.bundleIdentifier ?? "",
            "client-build": Bundle.main.buildNumber ?? "",
        ]
    }
}
