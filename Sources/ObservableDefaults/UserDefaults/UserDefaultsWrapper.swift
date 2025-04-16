// This portion of code is derived from UserDefaultsObservation
// Source: https://github.com/tgeisse/UserDefaultsObservation
// The original code is licensed under the MIT License.

/*
 Copyright (c) 2024 Taylor Geisse

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation

public struct UserDefaultsWrapper<Value> {
  private init() {}

  // MARK: - Get Values
  public nonisolated static func getValue(
    _ key: String, _ defaultValue: Value, _ store: UserDefaults
  ) -> Value where Value: Codable {
    if isNativeType(Value.self) {
      return store.value(forKey: key) as? Value ?? defaultValue
    }

    guard let data = store.data(forKey: key) else { return defaultValue }
    do {
      return try JSONDecoder().decode(Value.self, from: data)
    } catch {
      fatalError(
        "Unable to decode Value from data: \(String(data: data, encoding: .utf8) ?? "<undecodable data>")"
      )
    }
  }

	private static func isNativeType(_ type: Any.Type) -> Bool {
			switch type {
			case is String.Type, is Bool.Type, is Int.Type, is Float.Type, is Double.Type, is Date.Type:
					return true
			default:
					return false
			}
	}

  public nonisolated static func setValue(
    _ key: String, _ newValue: Value, _ store: UserDefaults
  ) where Value: Codable {
    store.set(encode(newValue), forKey: key)
  }

  private static func encode<R>(_ value: R) -> Any where R: Codable {
    if isNativeType(R.self) {
      return value
    }

    do {
      return try JSONEncoder().encode(value)
    } catch {
      fatalError("Failed to encode value: \(value)")
    }
  }
}
