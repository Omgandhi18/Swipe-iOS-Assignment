//
//  AddProductScreen.swift
//  Swipe iOS Assignment
//
//  Created by Om Gandhi on 29/01/2025.
//

import SwiftUI
import PhotosUI
import Foundation

struct AddProductScreen: View {
    //MARK: Environment variables and State variables
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddProductViewModel()
    @ObservedObject private var networkManager = NetworkManager.shared
    @State private var isConnected: Bool = true
    @State private var showOfflineAlert: Bool = false
    var body: some View {
        NavigationStack {
            Form{
                // Image Picker
                HStack{
                    Spacer()
                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images, photoLibrary: .shared()) {
                        VStack {
                            if let image = viewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Text("Select Image")
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(width: 120, height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    }
                    .onChange(of: viewModel.selectedItem) { newItem in
                        loadImage(from: newItem)
                    }
                    Spacer()
                }
               
                // Product Type Picker
                Section{
                    HStack{
                        Picker("Product Type", selection: $viewModel.selectedProductType) {
                            ForEach(viewModel.productTypes, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(.automatic)
                        .accentColor(.red)
                    }
                }
                Section{
                    // Product Name TextField
                    Text("Product name")
                    TextField("Enter product name", text: $viewModel.productName)
                        
                }
                Section{
                    // Selling Price TextField
                    Text("Selling Price")
                    TextField("Enter selling price", text: $viewModel.sellingPrice)
                        .keyboardType(.decimalPad)
                }
                Section{
                    // Tax Rate TextField
                    Text("Tax rate")
                    TextField("Enter tax rate (%)", text: $viewModel.taxRate)
                        .keyboardType(.decimalPad)
                      
                }
                // Submit Button
                Button(action: {
                    let product = Product(image: "", price: Double(viewModel.sellingPrice) ?? 0, product_name: viewModel.productName, product_type: viewModel.selectedProductType, tax: Double(viewModel.taxRate) ?? 0)
                    
                    if networkManager.isConnected{
                       
                        viewModel.submitProduct(product)
                        viewModel.showAlert = true
                    }
                    else{
                        viewModel.saveOfflineProduct(product)
                        showOfflineAlert = true
                    }
                    
                   
                }) {
                    HStack {
                        if viewModel.isSubmitting {
                            ProgressView()
                        }
                        Text(isConnected ? "Add Product" : "Save Product")
                    }
                    .frame(maxWidth: .infinity,minHeight: 35)
                    .foregroundColor(viewModel.isFormValid ? Color.red : Color.gray)
                }
                .disabled(!viewModel.isFormValid)
                
            }
            .tint(.red)
            .navigationTitle("Add Product")
            .scrollDismissesKeyboard(.automatic)
            //alert when product saved successfully
            .alert(viewModel.message ?? "Product added successfully", isPresented: $viewModel.showAlert){
                Button{
                    dismiss()
                }label: {
                    Text("Ok")
                }
            }
            //alert when product is saved offline
            .alert("Product saved offline and will be uploaded when Internet connection is available", isPresented: $showOfflineAlert){
                Button{
                    dismiss()
                }label: {
                    Text("Ok")
                }
            }
            .toolbar {
                //close screen
                Button{
                    dismiss()
                }label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.red)
                }
            }
        }
        .onAppear {
            //check for internet connection
            NetworkManager.shared.onStatusChange = { status in
                isConnected = status
            }
        }
        
    }
 
    // Function to Load Selected Image
    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data),
               image.size.width == image.size.height { // Ensure 1:1 ratio
                viewModel.selectedImage = image
            } else {
                viewModel.message = "Please select a square image (1:1 ratio)."
            }
        }
    }
}



#Preview {
    AddProductScreen()
}
