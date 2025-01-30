//
//  ProductViewModel.swift
//  Swipe iOS Assignment
//
//  Created by Om Gandhi on 29/01/2025.
//

import SwiftUI
class ProductViewModel: ObservableObject {
    //MARK: Published variables
    @Published var products: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var searchText: String = ""{
        didSet{filterProducts()}
    }
    init () {
        fetchProducts()
    }
//MARK: Fetch products from server
    func fetchProducts() {
        guard let url = URL(string: "https://app.getswipe.in/api/public/get") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data:", error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedProducts = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    self.products = decodedProducts
                    self.filteredProducts = decodedProducts
                    self.loadFavorites()
                   
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
    //MARK: Filter products
    private func filterProducts() {
        if searchText.isEmpty {
            filteredProducts = products
        }
        else{
            filteredProducts = products.filter{
                $0.product_name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    //MARK: Toggle favourites
    func toggleFavorite(for product: Product) {
        /*
         Comparing with names as product ID is not coming from API and
         locally assigned IDs change everytime for a product when API is called.
         */
       
        if let index = products.firstIndex(where: { $0.product_name == product.product_name }) {
               products[index].isFavorite.toggle()
           }
        if let index = filteredProducts.firstIndex(where: { $0.product_name == product.product_name }){
            filteredProducts[index].isFavorite.toggle()
        }
           saveFavorites()
       }
    
    //MARK: Save favourites
    private func saveFavorites() {
            let favorites = products.filter { $0.isFavorite }
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(favorites) {
                UserDefaults.standard.set(data, forKey: "Favorites")
                UserDefaults.standard.synchronize()
            }
        }
        
    //MARK: Load favourites from User defaults
        private func loadFavorites() {
            if let data = UserDefaults.standard.data(forKey: "Favorites"),
               let savedFavorites = try? JSONDecoder().decode([Product].self, from: data) {
                // Update the favorite status in the product list
                for savedProduct in savedFavorites {
                    if let index = products.firstIndex(where: { $0.product_name == savedProduct.product_name }) {
                        products[index].isFavorite = true
                    }
                    if let index = filteredProducts.firstIndex(where: { $0.product_name == savedProduct.product_name }) {
                        filteredProducts[index].isFavorite = true
                    }
                }
            }
        }
    //MARK: Sort products by favourites
    func sortedProducts() -> [Product] {
            // Sort products, placing favorites at the top
        return filteredProducts.sorted { $0.isFavorite && !$1.isFavorite }
        }
}
