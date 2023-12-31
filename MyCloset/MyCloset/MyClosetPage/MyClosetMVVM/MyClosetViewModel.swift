//
//  MyClosetViewModel.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/30.
//

class MyClosetPageViewModel {
    var clothes: [String: [String]] = [:]
    var sectionAll: [[Section]] = []
    var sections: [Section] = []

    private let coreDataManager = CoreDataManager.shared

    func fetchAllCategoriesAndSubcategories() {
        clothes = coreDataManager.fetchAllCategoriesAndSubcategories()
    }

    func makeSectionArray(for segmentIndex: Int) {
        sectionAll = [] // Reset
        for title in ["Tops", "Bottoms", "Accessories"] {
            if let subcategories = clothes[title] {
                var sectionsForCategory: [Section] = []
                for subcategory in subcategories {
                    let items = coreDataManager.fetchClothesFor(category: title, subcategory: subcategory)
                    let section = Section(title: subcategory, isExpanded: true, items: items)
                    sectionsForCategory.append(section)
                }
                sectionAll.append(sectionsForCategory)
            } else {
                sectionAll.append([])
            }
        }
        sections = !sectionAll.isEmpty ? sectionAll[segmentIndex] : []
    }
}
