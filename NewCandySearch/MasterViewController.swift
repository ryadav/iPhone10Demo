/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class MasterViewController: UITableViewController {

  var detailViewController: DetailViewController? = nil
  var candies: [Candy] = []
  var filteredCandies = [Candy]()
  let searchController = UISearchController(searchResultsController: nil)

  override func viewDidLoad() {
    super.viewDidLoad()

    setupSearchController()
    loadCandies()
    
    if let split = splitViewController {
        let controllers = split.viewControllers
        detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }
  
  // MARK: - Private instance methods

  func setupSearchController() {
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true

    searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
    searchController.searchBar.delegate = self

    // In iOS 11, integrate search controller into nav bar
    if #available(iOS 11.0, *) {
      self.navigationItem.searchController = searchController
      // Search bar is always visible
      self.navigationItem.hidesSearchBarWhenScrolling = false
    } else {
      tableView.tableHeaderView = searchController.searchBar
    }
  }
  
  func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }

  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    filteredCandies = candies.filter({( candy : Candy) -> Bool in
      let doesCategoryMatch = (scope == "All") || (candy.category == scope)
      
      if searchBarIsEmpty() {
        return doesCategoryMatch
      } else {
        return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
      }
    })
    tableView.reloadData()
  }

  func isFiltering() -> Bool {
    let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
    return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
  }

  func loadCandies() {
    candies = [
      Candy(category:"Chocolate", name:"Chocolate Bar"),
      Candy(category:"Chocolate", name:"Chocolate Chip"),
      Candy(category:"Chocolate", name:"Dark Chocolate"),
      Candy(category:"Hard", name:"Lollipop"),
      Candy(category:"Hard", name:"Candy Cane"),
      Candy(category:"Hard", name:"Jaw Breaker"),
      Candy(category:"Other", name:"Caramel"),
      Candy(category:"Other", name:"Sour Chew"),
      Candy(category:"Other", name:"Gummi Bear"),
      Candy(category:"Other", name:"Candy Floss"),
      Candy(category:"Chocolate", name:"Chocolate Coin"),
      Candy(category:"Chocolate", name:"Chocolate Egg"),
      Candy(category:"Other", name:"Jelly Beans"),
      Candy(category:"Other", name:"Liquorice"),
      Candy(category:"Hard", name:"Toffee Apple")
    ]
  }


  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let candy: Candy
        if isFiltering() {
          candy = filteredCandies[indexPath.row]
        } else {
          candy = candies[indexPath.row]
        }
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        controller.detailItem = candy
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }

  // MARK: - Table View

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering() {
      return filteredCandies.count
    }
    
    return candies.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let candy: Candy
    if isFiltering() {
      candy = filteredCandies[indexPath.row]
    } else {
      candy = candies[indexPath.row]
    }
    cell.textLabel!.text = candy.name
    cell.detailTextLabel!.text = candy.category
    return cell
  }

}

extension MasterViewController: UISearchBarDelegate {
  // MARK: - UISearchBar Delegate
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
  }
}

extension MasterViewController: UISearchResultsUpdating {
  // MARK: - UISearchResultsUpdating Delegate
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
    filterContentForSearchText(searchController.searchBar.text!, scope: scope)
  }
}

