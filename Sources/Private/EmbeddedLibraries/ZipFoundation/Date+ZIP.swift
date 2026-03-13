//
//  Date+ZIP.swift
//  ZIPFoundation
//
//  Created by Thomas Zoechling on 20.12.22.
//

import Foundation

extension Date {

    var fileModificationDateTime: (UInt16, UInt16) {
        return (self.fileModificationDate, self.fileModificationTime)
    }

    var fileModificationDate: UInt16 {
        var time = time_t(self.timeIntervalSince1970)
        guard let unixTime = gmtime(&time) else {
            return 0
        }
        var year = unixTime.pointee.tm_year + 1900 // UNIX time structs count in "years since 1900".
        // ZIP uses the MSDOS date format which has a valid range of 1980 - 2099.
        year = year >= 1980 ? year : 1980
        year = year <= 2099 ? year : 2099
        let month = unixTime.pointee.tm_mon + 1 // UNIX time struct month entries are zero based.
        let day = unixTime.pointee.tm_mday
        return (UInt16)(day + ((month) * 32) +  ((year - 1980) * 512))
    }

    var fileModificationTime: UInt16 {
        var time = time_t(self.timeIntervalSince1970)
        guard let unixTime = gmtime(&time) else {
            return 0
        }
        let hour = unixTime.pointee.tm_hour
        let minute = unixTime.pointee.tm_min
        let second = unixTime.pointee.tm_sec
        return (UInt16)((second/2) + (minute * 32) + (hour * 2048))
    }

    init(dateTime: (UInt16, UInt16)) {
        var msdosDateTime = Int(dateTime.0)
        msdosDateTime <<= 16
        msdosDateTime |= Int(dateTime.1)
        var unixTime = tm()
        unixTime.tm_sec = Int32((msdosDateTime&31)*2)
        unixTime.tm_min = Int32((msdosDateTime>>5)&63)
        unixTime.tm_hour = Int32((Int(dateTime.1)>>11)&31)
        unixTime.tm_mday = Int32((msdosDateTime>>16)&31)
        unixTime.tm_mon = Int32((msdosDateTime>>21)&15)
        unixTime.tm_mon -= 1 // UNIX time struct month entries are zero based.
        unixTime.tm_year = Int32(1980+(msdosDateTime>>25))
        unixTime.tm_year -= 1900 // UNIX time structs count in "years since 1900".
        let time = timegm(&unixTime)
        self = Date(timeIntervalSince1970: TimeInterval(time))
    }

    init(timespec: timespec) {
        let seconds = 1.0e-9 * Double(timespec.tv_nsec)
        let timeIntervalSince1970 = TimeInterval(timespec.tv_sec)
        let absoluteTimeIntervalSince1970 = Constants.absoluteTimeIntervalSince1970
        self.init(timeIntervalSinceReferenceDate: (timeIntervalSince1970 - absoluteTimeIntervalSince1970) + seconds)
    }
}

private extension Date {

    enum Constants {
#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
        static let absoluteTimeIntervalSince1970 = kCFAbsoluteTimeIntervalSince1970
#else
        static let absoluteTimeIntervalSince1970: Double = 978307200.0
#endif
    }
}

extension stat {

    var lastAccessDate: Date {
#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
        return Date(timespec: st_atimespec)
#else
        return Date(timespec: st_atim)
#endif
    }
}

extension timeval {

    init(timeIntervalSince1970: TimeInterval) {
        let (integral, fractional) = modf(timeIntervalSince1970)
        self.init(tv_sec: time_t(integral), tv_usec: suseconds_t(1.0e6 * fractional))
    }
}
