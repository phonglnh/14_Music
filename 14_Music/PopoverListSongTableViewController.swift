//
//  PopoverListSongTableViewController.swift
//  14_Music
//
//  Created by PhongLe on 9/20/16.
//  Copyright © 2016 PhongLe. All rights reserved.
//

import UIKit

protocol popoverSongDelegate: class {
    func getIndexOfSelectedSongFromPopover(index: Int)
}

class PopoverListSongTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tbvSong: UITableView!
    weak var mDelegate: popoverSongDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvSong.dataSource = self
        tbvSong.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSongTiTle.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = arrSongTiTle[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mDelegate?.getIndexOfSelectedSongFromPopover(index: indexPath.row)

    }
 
}
