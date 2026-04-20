//
//  Extensions.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//


import SwiftUI

extension Color {
    static let appBackground = Color(red: 0.07, green: 0.07, blue: 0.09)
    static let appGreen = Color(red: 0.11, green: 0.84, blue: 0.42)
    static let appCardBackground = Color(red: 0.12, green: 0.12, blue: 0.14)
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.appCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
