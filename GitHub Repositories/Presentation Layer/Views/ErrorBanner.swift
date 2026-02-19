//
//  ErrorBanner.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import SwiftUI

struct ErrorBanner: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.9))
    }
}
