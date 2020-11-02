//
//  CreateTemplatesTask.swift
//  ios-l10n-tools
//
//  Created by Jeff Boek on 11/2/20.
//

import Foundation

struct CreateTemplatesTask {
    let l10nRepoPath: String
    
    private func copyEnLocaleToTemplates() {
        let source = URL(fileURLWithPath: "\(l10nRepoPath)/en-US/firefox-ios.xliff")
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("temp.xliff")
        let destination = URL(fileURLWithPath: "\(l10nRepoPath)/templates/firefox-ios.xliff")
        try! FileManager.default.copyItem(at: source, to: tmp)
        try! FileManager.default.replaceItemAt(destination, withItemAt: tmp)
    }
    
    private func handleXML() throws {
        let url = URL(fileURLWithPath: "\(l10nRepoPath)/templates/firefox-ios.xliff")
        let xml = try! XMLDocument(contentsOf: url, options: .nodePreserveWhitespace)
        
        guard let root = xml.rootElement() else { return }
    
        try root.nodes(forXPath: "file").forEach { node in
            guard let node = node as? XMLElement else { return }
            node.removeAttribute(forName: "target-language")
        }
        
        try root.nodes(forXPath: "file/body/trans-unit/target").forEach { $0.detach() }
        try xml.xmlString.write(to: url, atomically: true, encoding: .utf16)
    }
    
    func run() {
        copyEnLocaleToTemplates()
        try! handleXML()
    }
}
