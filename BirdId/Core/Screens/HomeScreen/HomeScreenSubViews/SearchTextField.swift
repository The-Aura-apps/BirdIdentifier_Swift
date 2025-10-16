//
//  SearchTextField.swift
//  BirdId
//
//  Created by ali bakhsha on 7/22/1404 AP.
//

import SwiftUI

struct SearchTextField: View {
    
    @Binding var searchText: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack{
            Image(.search)
                .foregroundStyle(.text)
            TextField("",text: $searchText,prompt: Text("Search").font(.app(.Sub1)).foregroundStyle(.text))
                .font(.app(.Sub1))
                .foregroundStyle(Color.white)
                .submitLabel(.done)
                .focused($isFocused)
                .onSubmit {
                    isFocused = false
                }
                .overlay (
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 10)
                        .foregroundStyle(Color.text)
                        .opacity(isFocused ? 1.0 : 0.0)
                        .onTapGesture {
                            searchText = ""
                            isFocused = false
                        }
                    ,alignment: .trailing
                )
        }
        .padding(.horizontal)
        .frame(width: UIScreen.screenWidth - 48,height: 52)
        .adaptiveGlassEffect(style: .clear,cornerRadius: 99)
    }
}

#Preview {
    SearchTextField(searchText: .constant(""))
}
