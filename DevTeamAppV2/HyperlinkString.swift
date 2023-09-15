//
//  HyperlinkString.swift
//  DevTeamAppV2
//
//  Created by Andrew Sauerbrei on 9/7/23.
//

import Foundation

extension NSAttributedString {
    static func makeHyperlink(for path: String, in string: String, as substring: String) -> NSAttributedString {
        let ns = NSString(string: string)
        let sub = ns.range(of: substring)
        let hyperlink = NSMutableAttributedString(string: string)
            hyperlink.addAttribute(.link, value: path, range: sub)
        return hyperlink
    }
}
