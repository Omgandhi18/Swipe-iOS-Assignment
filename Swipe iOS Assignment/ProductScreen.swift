//
//  ProductScreen.swift
//  Swipe iOS Assignment
//
//  Created by Om Gandhi on 29/01/2025.
//

import SwiftUI

struct ProductScreen: View {
    //MARK: State variables
    @StateObject private var viewModel = ProductViewModel()
    @StateObject private var addViewModel = AddProductViewModel()
    @ObservedObject private var networkManager = NetworkManager.shared
    @State private var showAddProductSheet: Bool = false
    @State private var offlineProductAddAlert: Bool = false
    
    //Define columns for Gris
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        
    ]
    var body: some View {
        NavigationView {
            //Check for network conditions
            if networkManager.isConnected {
                ScrollView{
                    LazyVGrid(columns: columns,spacing: 20){
                        //Display products
                        ForEach(viewModel.sortedProducts()){product in
                            ProductCard(viewModel: viewModel,product: product)
                        }
                    }
                }
                //Enable search in Grid
                .searchable(text: $viewModel.searchText)
                //Pull to refresh
                .refreshable {
                    viewModel.fetchProducts()
                }
                .padding(.horizontal, 16)
                .navigationTitle("Products")
                .toolbar{
                    //MARK: Button to add products
                    Button{
                        showAddProductSheet = true
                    }label: {
                        Image(systemName: "plus")
                            .foregroundColor(.red)
                            .font(.system(size: 24))
                    }

                }
                
            }
            else{
                //MARK: Display when no internet connection
                VStack{
                    Text("No internet connection!")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Please check your internet settings.")
                }
               
            }
            
            
        }
        .fullScreenCover(isPresented: $showAddProductSheet){
            AddProductScreen()
        }
        .alert("Refresh to get newly added products",isPresented: $offlineProductAddAlert){
           
        }
        .onAppear{
            NetworkManager.shared.onStatusChange = {isConnected in
                //MARK: Add the products to server that are saved offline when there is no internet
                if isConnected{
                    let products = addViewModel.fetchOfflineProducts()
                    if !products.isEmpty{
                        for product in products{
                            addViewModel.productName = product.product_name
                            addViewModel.sellingPrice = String(product.price.description)
                            addViewModel.taxRate = String(product.tax.description)
                            addViewModel.submitProduct(product)
                        }
                        addViewModel.clearOfflineProducts()
                        offlineProductAddAlert = true
                    }
                    viewModel.fetchProducts()
                }
            }
        }
    }
}

#Preview {
    ProductScreen() 
}
