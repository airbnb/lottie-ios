//
//  Data+Serialization.swift
//  ZIPFoundation
//
//  Copyright © 2017-2021 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation

typealias FILEPointer = UnsafeMutablePointer<FILE>

// MARK: - DataSerializable

protocol DataSerializable {
  static var size: Int { get }
  init?(data: Data, additionalDataProvider: (Int) throws -> Data)
  var data: Data { get }
}

extension Data {
  enum DataError: Error {
    case unreadableFile
    case unwritableFile
  }

  static func readStruct<T>(from file: FILEPointer, at offset: UInt64)
    -> T? where T: DataSerializable
  {
    guard offset <= .max else { return nil }
    fseeko(file, off_t(offset), SEEK_SET)
    guard let data = try? readChunk(of: T.size, from: file) else {
      return nil
    }
    let structure = T(data: data, additionalDataProvider: { additionalDataSize -> Data in
      try self.readChunk(of: additionalDataSize, from: file)
    })
    return structure
  }

  static func readChunk(of size: Int, from file: FILEPointer) throws -> Data {
    let alignment = MemoryLayout<UInt>.alignment
    #if swift(>=4.1)
    let bytes = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
    #else
    let bytes = UnsafeMutableRawPointer.allocate(bytes: size, alignedTo: alignment)
    #endif
    let bytesRead = fread(bytes, 1, size, file)
    let error = ferror(file)
    if error > 0 {
      throw DataError.unreadableFile
    }
    #if swift(>=4.1)
    return Data(bytesNoCopy: bytes, count: bytesRead, deallocator: .custom { buf, _ in buf.deallocate() })
    #else
    let deallocator = Deallocator.custom { buf, _ in buf.deallocate(bytes: size, alignedTo: 1) }
    return Data(bytesNoCopy: bytes, count: bytesRead, deallocator: deallocator)
    #endif
  }

  static func write(chunk: Data, to file: FILEPointer) throws -> Int {
    var sizeWritten = 0
    chunk.withUnsafeBytes { rawBufferPointer in
      if let baseAddress = rawBufferPointer.baseAddress, rawBufferPointer.count > 0 {
        let pointer = baseAddress.assumingMemoryBound(to: UInt8.self)
        sizeWritten = fwrite(pointer, 1, chunk.count, file)
      }
    }
    let error = ferror(file)
    if error > 0 {
      throw DataError.unwritableFile
    }
    return sizeWritten
  }

  func scanValue<T>(start: Int) -> T {
    let subdata = subdata(in: start..<start + MemoryLayout<T>.size)
    #if swift(>=5.0)
    return subdata.withUnsafeBytes { $0.load(as: T.self) }
    #else
    return subdata.withUnsafeBytes { $0.pointee }
    #endif
  }

}
