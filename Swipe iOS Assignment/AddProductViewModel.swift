import SwiftUI
import Foundation
import PhotosUI


class AddProductViewModel: ObservableObject {
    //MARK: Published variables
    @Published var productName: String = ""
    @Published var sellingPrice: String = ""
    @Published var taxRate: String = ""
    @Published var selectedProductType: String = "Computer"
    @Published var selectedImage: UIImage?
    @Published var message: String?
    @Published var isSubmitting: Bool = false
    @Published var selectedItem: PhotosPickerItem?
    @Published var showAlert: Bool = false
    
    //Product types
    let productTypes = ["Computer","Laptop","Phone","Accessories", "Other"]

    // MARK: - Form Validation
    var isFormValid: Bool {
        !productName.isEmpty && !sellingPrice.isEmpty && !taxRate.isEmpty &&
        Double(sellingPrice) != nil && Double(taxRate) != nil
    }
    

    // MARK: - Submit Product
    func submitProduct(_ product: Product) {
        guard isFormValid else {
            message = "Please fill in all fields correctly."
            return
        }


        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "https://app.getswipe.in/api/public/add")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Append text fields (product_name, product_type, price, tax)
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"product_name\"\r\n\r\n")
        body.append("\(product.product_name)\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"product_type\"\r\n\r\n")
        body.append("\(product.product_type)\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"price\"\r\n\r\n")
        body.append("\(product.price)\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"tax\"\r\n\r\n")
        body.append("\(product.tax)\r\n")

        // Append image if available (files[])
        if let selectedImage = selectedImage, let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"image.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")

        request.httpBody = body

        isSubmitting = true
        message = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isSubmitting = false
                if let error = error {
                    self.message = "Failed to submit: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.message = "Product added successfully!"
                    self.showAlert = true
                } else {
                    self.message = "Error: Unable to add product."
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    //MARK: - Store Products Offline
    func saveOfflineProduct(_ product: Product) {
            var products = fetchOfflineProducts()
            products.append(product)
            
            if let encoded = try? JSONEncoder().encode(products) {
                UserDefaults.standard.set(encoded, forKey: "offline_products")
            }
        }

        // Retrieve all offline products
    func fetchOfflineProducts() -> [Product] {
            if let data = UserDefaults.standard.data(forKey: "offline_products"),
               let products = try? JSONDecoder().decode([Product].self, from: data) {
                return products
            }
            return []
        }

        // Remove all offline products after syncing
        func clearOfflineProducts() {
            UserDefaults.standard.removeObject(forKey: "offline_products")
        }
    
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }

    mutating func append(_ data: Data) {
        self.append(contentsOf: data)
    }
}
