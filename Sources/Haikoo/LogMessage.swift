//
//  Blab.swift
//  Haikoo
//
//  Created by Paolo Ardia on 13/10/2019.
//

import Foundation

/// A LogMessage is a detailed log entry with a name and a dictionary of associated attributes.
public protocol LogMessage {
    /// Name of this message.
    var name: String { get }

    /// Payload associated with this message.
    var payload: [String: Any] { get }
}
