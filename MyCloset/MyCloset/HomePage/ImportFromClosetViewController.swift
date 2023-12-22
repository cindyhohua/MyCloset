//
//  ImportFromClosetViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/11.
//

import Foundation
import UIKit

protocol ClosetToPost: AnyObject {
    func closetToPost(cloth: ClothesStruct, index: Int)
}

class ImportFromClosetViewController: MyClosetPageViewController {
    var delegate: ClosetToPost?
    var indexPathRow: Int?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndexPath = tableView.indexPathForSelectedRow
        tableView.deselectRow(at: selectedIndexPath!, animated: true)
        if let row = indexPathRow {
            delegate?.closetToPost(cloth: sections[indexPath.section].items[indexPath.row], index: row)
            print(sections[indexPath.section].items[indexPath.row])
            dismiss(animated: true)
        }
    }
}
