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

function getDiffsList(baseUrl, title, time, callback) {
    var diffsListUrl = baseUrl + "/index.php?title=" + title + "&action=history";
    
    var doc = new XMLHttpRequest();
                    
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {           
            if (doc.responseText != "") {
                var response = doc.responseText;
                
                //search for the delimiters...
                var begin = response.indexOf("<ul id=\"pagehistory\">");
                var end = response.indexOf("</ul>", begin);

                var result = response.slice(begin, end);
                
                var diffUrl;
                var variableUrl = getDiffUrl(result, title, time)
                if (variableUrl != "")
                    diffUrl = baseUrl + variableUrl;
                else
                    diffUrl = variableUrl;

                console.log("Got: diffs list");
                
                callback(diffUrl)
            }
        } else
            console.log("Wait for diffs list...");
    }
                    
    doc.open("GET", diffsListUrl);
    doc.send();  
}

function getDiffUrl(diffsList, title, time) {
    var diffsListItems = diffsList.split('\n'); //from a html list to an array of items
    
    var testThisItem;
    var chosenItem;
    var result = "";
    
    for (var i=0; i<diffsListItems.length; i++) {
        if (diffsListItems[i].indexOf("(Updating to match new version of source page)") != -1) {
            testThisItem = diffsListItems[i];
            
            //search for the delimiters...
            var begin = testThisItem.lastIndexOf("title=\"" + title + "\">");
            var end = testThisItem.indexOf("</a>‎", begin);
            
            var testThisItemTime = testThisItem.slice(begin, end);
            testThisItemTime = testThisItemTime.replace("title=\"" + title + "\">", "");

            if (testThisItemTime == time) {
                chosenItem = testThisItem;

                //search for the delimiters...
                var begin2 = chosenItem.search(/cur(<\/a>)? \| <a href=\"/);
                var end2 = chosenItem.indexOf("\" title=\"" + title + "\">prev", begin2);

                result = chosenItem.slice(begin2, end2);
                result = result.replace(/cur(<\/a>)? \| <a href=\"/, "");
                result = result.replace(/&amp;/g, "&");

                break;
            }
        }
    }

    return result;
}

//=====================================================================================

function getDiff(url, callback) {
    var doc = new XMLHttpRequest();
                    
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.responseText != "") {
                var response = doc.responseText;

                //search for the delimiters...
                var begin = response.indexOf("<table class='diff diff-contentalign-left");
                var end = response.indexOf("<hr class='diff-hr' />");

                var result = response.slice(begin, end);

                //add a css style
                result = "<link rel=\"stylesheet\" href=\"" + "plasmapackage:/data/style.css" + "\" />" + result;
                    
                result = removeLinks(result);
                result = removeUselessText(result);
                    
                console.log("got diff text");
                    
                callback(result);//, url);
            }
        }
        else
            console.log("...wait for diff text...");
    }
                       
    doc.open("GET", url);
    doc.send(); 
}

function removeLinks(html) {
    //remove all end tags of links
    html = html.replace(/<\/a>/g, "")
    
    var begin = html.indexOf("<a href=");
    var end;
    
    //remove all starting tags of links
    while (begin != -1) {
        end = html.indexOf(">", begin) + 1; //+1 to get the ">" itself
                
        var link = html.slice(begin, end);
        
        //remove the extracted substring from the original one (html)
        html = html.replace(link, "");
        
        begin = html.indexOf("<a href=");
    }
    
    return html;
}

function removeUselessText(html) {
    html = html.replace(/\(view source\)/g, "");
    html = html.replace(/\(Talk \| contribs\)/g, "");
    html = html.replace(/\(Talk\)/g, "");
    html = html.replace("Newer edit →", "");
    html = html.replace("← Older edit", "");
    
    return html;
}