//
//  RecorderLibrary.swift
//  Alarm
//
//  Created by Hipteam on 11.05.2020.
//  Copyright © 2020 Roman Huti. All rights reserved.
//

import Foundation

protocol RecordLibrary {
    var fileManager: FileManager { get }
    
    func generateUrl(for name: String) -> URL?
}

class DocumentsRecordLibrary: RecordLibrary {
    
    // MARK: - Properties
    
    var fileManager: FileManager
    
    private let fileExtension = ".m4a"
    
    // MARK: - Initialize
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    // MARK: - Public methods

    func generateUrl(for name: String) -> URL? {
        return documentsDirectory()?.appendingPathComponent(name + fileExtension)
    }
    
    // MARK: - Private methods
    
    private func documentsDirectory() -> URL? {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
