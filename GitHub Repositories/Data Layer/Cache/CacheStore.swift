//
//  CacheStore.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation

protocol CacheStore {
    func save<T: Codable>(_ value: T, forKey key: String)
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T?
}

final class DiskCacheStore: CacheStore {
    private let baseURL: URL
    private let queue = DispatchQueue(label: "com.trendingrepos.cache", qos: .utility)
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(baseURL: URL? = nil) {
        if let baseURL = baseURL {
            self.baseURL = baseURL
        } else {
            let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            self.baseURL = (caches ?? FileManager.default.temporaryDirectory)
                .appendingPathComponent("TrendingReposCache", isDirectory: true)
        }
        createDirectoryIfNeeded()
    }

    func save<T: Codable>(_ value: T, forKey key: String) {
        let url = fileURL(forKey: key)
        queue.async {
            do {
                let data = try self.encoder.encode(value)
                try data.write(to: url, options: [.atomic])
            } catch {
                // Best-effort cache; ignore write errors.
            }
        }
    }

    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        let url = fileURL(forKey: key)
        return queue.sync {
            guard let data = try? Data(contentsOf: url) else {
                return nil
            }
            return try? decoder.decode(T.self, from: data)
        }
    }

    private func fileURL(forKey key: String) -> URL {
        baseURL.appendingPathComponent(key).appendingPathExtension("json")
    }

    private func createDirectoryIfNeeded() {
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }
}

final class InMemoryCacheStore: CacheStore {
    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func save<T: Codable>(_ value: T, forKey key: String) {
        storage[key] = try? encoder.encode(value)
    }

    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = storage[key] else {
            return nil
        }
        return try? decoder.decode(T.self, from: data)
    }
}
