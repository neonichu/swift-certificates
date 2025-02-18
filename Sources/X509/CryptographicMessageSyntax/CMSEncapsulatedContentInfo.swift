//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftCertificates open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftCertificates project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftCertificates project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import SwiftASN1

/// ``CMSEncapsulatedContentInfo`` is defined in ASN.1 as:
/// ```
/// EncapsulatedContentInfo ::= SEQUENCE {
///   eContentType ContentType,
///   eContent [0] EXPLICIT OCTET STRING OPTIONAL }
/// ContentType ::= OBJECT IDENTIFIER
/// ```
struct CMSEncapsulatedContentInfo: DERImplicitlyTaggable, Hashable {
    static var defaultIdentifier: ASN1Identifier {
        .sequence
    }
    
    var eContentType: ASN1ObjectIdentifier
    var eContent: ASN1OctetString?
    
    init(eContentType: ASN1ObjectIdentifier, eContent: ASN1OctetString? = nil) {
        self.eContentType = eContentType
        self.eContent = eContent
    }
    
    init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(rootNode, identifier: identifier) { nodes in
            let eContentType = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let eContent = try DER.optionalExplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in
                try ASN1OctetString(derEncoded: node)
            }
            
            return .init(eContentType: eContentType, eContent: eContent)
        }
    }
    
    func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier, { coder in
            try coder.serialize(eContentType)
            if let eContent {
                try coder.serialize(explicitlyTaggedWithTagNumber: 0, tagClass: .contextSpecific) { coder in
                    try coder.serialize(eContent)
                }
            }
        })
    }
}
