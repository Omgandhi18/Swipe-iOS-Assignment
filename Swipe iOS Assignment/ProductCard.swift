//
//  ProductCard.swift
//  Swipe iOS Assignment
//
//  Created by Om Gandhi on 29/01/2025.
//

import SwiftUI

struct ProductCard: View {
    //MARK: State and Observed Variables
    @ObservedObject var viewModel: ProductViewModel
    let product: Product

    var body: some View {
        VStack {
            HStack{
                Spacer()
                //Button to toggle favourites
                Button{
                    viewModel.toggleFavorite(for: product)
                }label: {
                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(.red)
                }
            }
            //Load images asynchronously
            AsyncImage(url: URL(string: product.image)) { image in
                image.resizable()
            } placeholder: {
                Image("defaultProduct")
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack {
                //Product type
                Text(product.product_type)
                    .multilineTextAlignment(.leading)
                    .font(.caption)
                    .foregroundStyle(.gray)
                Spacer()
              
            }
            HStack{
                //Product Name
                Text(product.product_name)
                    .font(.headline)
                Spacer()
            }
          
            HStack{
                //Product Price
                Text("₹\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
               
            }
            HStack{
                //Product tax
                Text("+ \(product.tax, specifier: "%.0f")% tax")
                    .font(.caption)
                    .foregroundStyle(.gray)
                Spacer()
            }
           
        }
        .padding()
        .frame(width: 160, height: 240)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
#Preview {
    ProductCard(viewModel: ProductViewModel(),product: Product(image: "", price: 10, product_name: "Test", product_type: "TestType", tax: 10))
}
