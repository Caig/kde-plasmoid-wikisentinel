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

function getDiff (baseUrl, title, time, callback) {
    // MediaWiki API:
    // * http://www.mediawiki.org/wiki/API:Query
    // * http://www.mediawiki.org/wiki/API:Query_-_Properties#revisions_.2F_rv
    var url = baseUrl + "/api.php?format=xml&action=query&titles=" + title + "&prop=revisions&rvstart=" + time + "&rvend=" + time + "&rvdiffto=prev";

    var doc = new XMLHttpRequest();
    
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {           
            if (doc.responseXML != "") {
                var response = doc.responseXML;

                var diff = response.documentElement.childNodes[0].childNodes[0].childNodes[0].childNodes[0].childNodes[0].childNodes[0].childNodes[0].nodeValue;
                
                console.log("Got diff");
                
                callback(diff);
            }
        } else
            console.log("Waiting for diff...");
    }
                    
    doc.open("GET", url);
    doc.send();  
}