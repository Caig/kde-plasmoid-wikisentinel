// -*- coding: iso-8859-1 -*-
/*
 *   Author: Caig <giacomosrv@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

.pragma library

var db;

function openDB() {
    db = openDatabaseSync("WikiSentinelDB", "1.0", "The KDE WikiSentinel plasmoid database", 1000000);
    createTable();
}

function createTable() {
    // DBWiki: UserBase or TechBase
    // DBHidden: 0 == false; 1 == true
    // DBRead: 0 == false; 1 == true (item already clicked or not)
    // DBTime: timestamp (from the feed)
    // DBTitle: name of the page (from the feed)
    // DBLink: link to the page (from the feed)
    
    db.transaction( function(tx) {
        tx.executeSql('CREATE TABLE IF NOT EXISTS items(DBWiki TEXT, DBHidden INTEGER, DBRead INTEGER, DBTime INTEGER, DBTitle TEXT, DBLink TEXT)');
        }
    );
}

function readDB(DBWiki) {
    var result;
    
    db.readTransaction( function(tx) {
        result = tx.executeSql('SELECT * FROM items WHERE DBWiki=? AND DBHidden=? ORDER BY DBTime DESC', [DBWiki, 0]);
        }
    );
    
    var item;
    var allItems = new Array();
    
    for (var i=0; i<result.rows.length; i++) {
        item = result.rows.item(i);
        allItems[i] = [item.DBWiki, item.DBRead, item.DBTime, item.DBTitle, item.DBLink];
    }

    return allItems;
}

function getLatestTimeInDB(DBWiki) {
    var result;
    
    db.readTransaction( function(tx) {
        result = tx.executeSql('SELECT DBTime FROM items WHERE DBWiki=? ORDER BY DBTime DESC LIMIT 1', [DBWiki]);
        }
    );
    
    if (result.rows.length > 0) //if there is a result...
        return result.rows.item(0).DBTime;
    else
        return 0;
}

function addItemToDB(DBWiki, DBRead, DBTime, DBTitle, DBLink) {
    db.transaction( function(tx) { //the second one (value == 0) is DBHidden
        tx.executeSql('INSERT INTO items VALUES(?, ?, ?, ?, ?, ?)', [DBWiki, 0, DBRead, DBTime, DBTitle, DBLink]);
        }
    );
}

function updateItemInDB(DBWiki, DBTime, action) {
    if (action == "read") {
        //set read == true (1)
        db.transaction( function(tx) {
            tx.executeSql('UPDATE items SET DBRead=1 WHERE DBWiki=? AND DBTime=?', [DBWiki, DBTime]);
            }
        );
    }
    else if (action == "hidden") {
        //set hidden == true (1)
        db.transaction( function(tx) {
            tx.executeSql('UPDATE items SET DBHidden=1 WHERE DBWiki=? AND DBTime=?', [DBWiki, DBTime]);
            }
        );
    }
}

function countItemsInDB(DBWiki) { //return the number of just visible items
    var result;
    
    db.readTransaction( function(tx) {
        result = tx.executeSql('SELECT COUNT(DBWiki) AS count FROM items WHERE DBWiki=? AND DBHidden=?', [DBWiki, 0]);
        }
    );

    return result.rows.item(0).count;
}

function readExcessItemsInDB(DBWiki, itemsNumber) {
    var tempItems;
    db.readTransaction( function(tx) {
        tempItems = tx.executeSql('SELECT DBTime FROM items WHERE DBWiki=? AND DBHidden=? ORDER BY DBTime ASC LIMIT ?', [DBWiki, 0, itemsNumber]);
        }
    );
    
    var selectedItem = tempItems.rows.item(itemsNumber-1).DBTime
    
    var tempToDeleteItems;
    db.readTransaction( function(tx) {
        tempToDeleteItems = tx.executeSql('SELECT DBTime FROM items WHERE DBWiki=? AND DBTime<=?', [DBWiki, selectedItem]);
        }
    );

    var toDeleteItems = new Array();
    
    for (var i=0; i<tempToDeleteItems.rows.length; i++) {
        toDeleteItems[i] = tempToDeleteItems.rows.item(i).DBTime;
    }

    return toDeleteItems;
}

function readOlderItemsInDB(DBWiki, DBTime) {    
    var tempToDeleteItems;
    db.readTransaction( function(tx) {
        tempToDeleteItems = tx.executeSql('SELECT DBTime FROM items WHERE DBWiki=? AND DBTime<?', [DBWiki, DBTime]);
        }
    );

    var toDeleteItems = new Array();
    
    for (var i=0; i<tempToDeleteItems.rows.length; i++) {
        toDeleteItems[i] = tempToDeleteItems.rows.item(i).DBTime;
    }

    return toDeleteItems;
}

function deleteItemFromDB(DBWiki, DBTime) {
    db.transaction( function(tx) {
        tx.executeSql('DELETE FROM items WHERE DBWiki=? AND DBTime=?', [DBWiki, DBTime]);
        }
    );
}