//
//  Data+Compression.swift
//  ZIPFoundation
//
//  Copyright © 2017-2021 Thomas Zoechling, https://www.peakstep.com and the ZIP Foundation project authors.
//  Released under the MIT License.
//
//  See https://github.com/weichsel/ZIPFoundation/blob/master/LICENSE for license information.
//

import Foundation

#if canImport(zlib)
import zlib
#endif

/// A custom handler that consumes a `Data` object containing partial entry data.
/// - Parameters:
///   - data: A chunk of `Data` to consume.
/// - Throws: Can throw to indicate errors during data consumption.
typealias ZipDataCallback = (_ data: Data) throws -> Void
/// A custom handler that receives a position and a size that can be used to provide data from an arbitrary source.
/// - Parameters:
///   - position: The current read position.
///   - size: The size of the chunk to provide.
/// - Returns: A chunk of `Data`.
/// - Throws: Can throw to indicate errors in the data source.
typealias ZipDataProvider = (_ position: Int64, _ size: Int) throws -> Data

extension Data {
  enum CompressionError: Error {
    case invalidStream
    case corruptedData
  }

  /// Decompress the output of `provider` and pass it to `consumer`.
  /// - Parameters:
  ///   - size: The compressed size of the data to be decompressed.
  ///   - bufferSize: The maximum size of the decompression buffer.
  ///   - provider: A closure that accepts a position and a chunk size. Returns a `Data` chunk.
  ///   - consumer: A closure that processes the result of the decompress operation.
  /// - Returns: The checksum of the processed content.
  static func decompress(size: Int64, bufferSize: Int, provider: ZipDataProvider, consumer: ZipDataCallback) throws -> UInt32 {
    try process(
      operation: COMPRESSION_STREAM_DECODE,
      size: size,
      bufferSize: bufferSize,
      provider: provider,
      consumer: consumer)
  }

  /// Calculate the `CRC32` checksum of the receiver.
  ///
  /// - Parameter checksum: The starting seed.
  /// - Returns: The checksum calculated from the bytes of the receiver and the starting seed.
  func crc32(checksum: UInt32) -> UInt32 {
    #if canImport(zlib)
    return withUnsafeBytes { bufferPointer in
      let length = UInt32(count)
      return UInt32(zlib.crc32(UInt(checksum), bufferPointer.bindMemory(to: UInt8.self).baseAddress, length))
    }
    #else
    return builtInCRC32(checksum: checksum)
    #endif
  }

}

import Compression

extension Data {
  static func process(
    operation: compression_stream_operation,
    size: Int64,
    bufferSize: Int,
    provider: ZipDataProvider,
    consumer: ZipDataCallback)
    throws -> UInt32
  {
    var crc32 = UInt32(0)
    let destPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { destPointer.deallocate() }
    let streamPointer = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
    defer { streamPointer.deallocate() }
    var stream = streamPointer.pointee
    var status = compression_stream_init(&stream, operation, COMPRESSION_ZLIB)
    guard status != COMPRESSION_STATUS_ERROR else { throw CompressionError.invalidStream }
    defer { compression_stream_destroy(&stream) }
    stream.src_size = 0
    stream.dst_ptr = destPointer
    stream.dst_size = bufferSize
    var position: Int64 = 0
    var sourceData: Data?
    repeat {
      let isExhausted = stream.src_size == 0
      if isExhausted {
        do {
          sourceData = try provider(position, Int(Swift.min(size - position, Int64(bufferSize))))
          position += Int64(stream.prepare(for: sourceData))
        } catch { throw error }
      }
      if let sourceData = sourceData {
        sourceData.withUnsafeBytes { rawBufferPointer in
          if let baseAddress = rawBufferPointer.baseAddress {
            let pointer = baseAddress.assumingMemoryBound(to: UInt8.self)
            stream.src_ptr = pointer.advanced(by: sourceData.count - stream.src_size)
            let flags = sourceData.count < bufferSize ? Int32(COMPRESSION_STREAM_FINALIZE.rawValue) : 0
            status = compression_stream_process(&stream, flags)
          }
        }
        if operation == COMPRESSION_STREAM_ENCODE, isExhausted { crc32 = sourceData.crc32(checksum: crc32) }
      }
      switch status {
      case COMPRESSION_STATUS_OK, COMPRESSION_STATUS_END:
        let outputData = Data(bytesNoCopy: destPointer, count: bufferSize - stream.dst_size, deallocator: .none)
        try consumer(outputData)
        if operation == COMPRESSION_STREAM_DECODE { crc32 = outputData.crc32(checksum: crc32) }
        stream.dst_ptr = destPointer
        stream.dst_size = bufferSize
      default: throw CompressionError.corruptedData
      }
    } while status == COMPRESSION_STATUS_OK
    return crc32
  }
}

extension compression_stream {
  fileprivate mutating func prepare(for sourceData: Data?) -> Int {
    guard let sourceData = sourceData else { return 0 }

    src_size = sourceData.count
    return sourceData.count
  }
}
