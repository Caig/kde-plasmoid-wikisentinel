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

import QtQuick 1.1
import org.kde.locale 0.1 as Locale
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.components 0.1 as PlasmaComponents
import "plasmapackage:/code/utils.js" as Utils
import "plasmapackage:/code/database.js" as Database
import "plasmapackage:/code/getdatafromwiki.js" as GetDataFromWiki

Item {
    id: root
    
    property int minimumWidth: 300
    property int minimumHeight: 200
    
    property string sourceWiki
    property string sourceWikiBaseUrl
    property string languageCode
    property string updateInterval
    property int latestTimeInDB // to understand if an item in the feed is new
    
    // settings for the archive management
    property bool keepMaxItems
    property int keepMaxItemsNumber
    property bool keepForDays
    property int keepForDaysNumber
    
    ListModel { id:dataList }
    
    PlasmaCore.DataSource {
        id: wikiSource
        
        engine: "rss"
        interval: updateInterval * 3600000 // in hours
        //connectedSources: [sourceWikiBaseUrl + "/api.php?action=feedcontributions&user=FuzzyBot&feedformat=atom"]
        
        onDataChanged: {
            print("Data changed");
            print("--------------------------------");
            updateDataList();
            plasmoid.busy = false;
        }
        
        onNewData: {
            print("New data: " + wikiSource.connectedSources[0]);
            print("--------------------------------");
            
            var DBTime;
            var DBTitle;
            var DBLink;
            var DBWiki = sourceWiki;
            var DBRead = 0;
            
            var updatatedDB = false; //to know if we need to update the dataList (and so the pages list)

            latestTimeInDB = Database.getLatestTimeInDB(sourceWiki);

            for (var i=0; i<data["items"].length; i++) {
                DBTime = data["items"][i]["time"];
                DBTitle = data["items"][i]["title"];
                DBLink = data["items"][i]["link"];
                    
                var lang = DBTitle.slice(DBTitle.lastIndexOf('/') - DBTitle.length);
                
                if (lang == '/' + languageCode) { // if the item is in the wanted language...
                    if (DBTime > latestTimeInDB) { //if is a new item not in database...
                        console.log("Added: " + DBWiki + " - " + DBRead + " - " + DBTime + " - " + DBTitle + " - " + DBLink);
                        Database.addItemToDB(DBWiki, DBRead, DBTime, DBTitle, DBLink);
                        updatatedDB = true;
                        sendNotification("KDE " + DBWiki + " " + i18n("needs you to update:"), DBTitle);
                    }
                    else {
                        console.log("No new translation to update.");
                        break;
                    }
                }
            }
            
            if (keepMaxItems == true)
            {
                var numberItemsToDelete = Database.countItemsInDB(sourceWiki) - keepMaxItemsNumber;
                
                if (numberItemsToDelete > 0)
                {
                    console.log("There are " + numberItemsToDelete + " excess items to delete...");
                    
                    var db = Database.readExcessItemsInDB(sourceWiki, numberItemsToDelete);
                    
                    for (var i=0; i<db.length; i++) {
                        Database.deleteItemFromDB(sourceWiki, db[i]);
                        updatatedDB = true;
                    }
                    
                    console.log("...deletion done.");
                }
            }
            
            if (keepForDays == true)
            {                
                var previousDay = new Date();
                previousDay.setDate(previousDay.getDate() - keepForDaysNumber); // go in the past...javascript does all the dirty things (it changes month or year if needed)
                
                var db = Database.readOlderItemsInDB(sourceWiki, previousDay.getTime()/1000);
                //previousDay.getTime()/1000 is the timestamp (in the same format the atom feed provides)
                
                if (db.length > 0)
                {
                    console.log("There are " + db.length + " old items to delete...");
                    
                    for (var i=0; i<db.length; i++) {
                        Database.deleteItemFromDB(sourceWiki, db[i]);
                        updatatedDB = true;
                    }
                    
                    console.log("...deletion done.");               
                }    
            }
            
            if (updatatedDB == true) {
                updateDataList();
            }
                        
            plasmoid.busy = false;
        }
        
        onSourceConnected: {
            print("Source connected: " + wikiSource.connectedSources[0]);
            print("--------------------------------");
            plasmoid.busy = true;
        }
    }
    
    PlasmaCore.DataSource {
        id: notifyService
        
        dataEngine: "notifications"
    }
    
    function configChanged() {
        //problema se più di un plasmoide x accesso a database?!
        
        sourceWiki = plasmoid.readConfig("wiki");
        if (sourceWiki == 0) {
            sourceWiki = "UserBase";
            sourceWikiBaseUrl = "http://userbase.kde.org";
        } else if (sourceWiki == 1) {
            sourceWiki = "TechBase";
            sourceWikiBaseUrl = "http://techbase.kde.org";
        } else { //to avoid problems with wrong settings (manual change of the file, ecc)
            sourceWiki = "UserBase";
            sourceWikiBaseUrl = "http://userbase.kde.org";
        }
        wikiSource.connectedSources = [sourceWikiBaseUrl + "/api.php?action=feedcontributions&user=FuzzyBot&feedformat=atom"]
        
        languageCode = plasmoid.readConfig("language");
        if (languageCode == "") { // if it's the first execution (or an issue to fix)
            var lang = locale.language;
            if (lang.length > 2) { // to adapt to the UserBase/TechBase language codes
                lang = lang.toLowerCase();
                lang = lang.replace("_", "-");
            }
            
            languageCode = lang;
            plasmoid.writeConfig("language", languageCode);
        }

        updateInterval = plasmoid.readConfig("updateInterval");
        
        keepMaxItems = plasmoid.readConfig("keepMaxItems");
        keepMaxItemsNumber = plasmoid.readConfig("keepMaxItemsNumber");
        
        keepForDays = plasmoid.readConfig("keepForDays");
        keepForDaysNumber = plasmoid.readConfig("keepForDaysNumber");
    }
    
    function updateDataList() {
        dataList.clear(); // clear the list to update it
        
        var db = Database.readDB(sourceWiki);

        for (var i=0; i<db.length; i++) {
            dataList.append({"wiki": db[i][0], "read": db[i][1], "time": db[i][2], "title": db[i][3], "link": db[i][4]});
            console.log("Read from DB: " + db[i][0] + " - " + db[i][2] + " - " + db[i][3]);
        }
        
        if (dataList.count == 0)
            messageLabel.visible = true;
        else
            messageLabel.visible = false;
    }
    
    function sendNotification(summary, body) {        
        var service = notifyService.serviceForSource("notification");
        var operation = service.operationDescription("createNotification");
        operation.appName = "WikiSentinel";
        operation.appIcon = plasmoid.file("images", "icon.png"); // "plasmapackage:/images/icon.png" doesn't work
        operation.summary = summary;
        operation.body = body;
        operation.timeout = 5000;
 
        var job = service.startOperationCall(operation);
    }
    
    Locale.Locale { id:locale }
    
    DiffDialog { id:diffDialog }
        
    PlasmaComponents.Label {
        id: titleLabel
        
        anchors {
            top: parent.top
            topMargin: 3
            left: parent.left
            right: parent.right
        }
        
        horizontalAlignment: Text.AlignHCenter
        text: "KDE " + sourceWiki
    }
                    
    PlasmaCore.SvgItem {
        id: titleLine
        
        anchors {
            top: titleLabel.bottom
            topMargin: 3
            left: parent.left
            right: parent.right
        }
        height: svgLine.elementSize("horizontal-line").height
        
        svg: PlasmaCore.Svg {
            id: svgLine
            imagePath: "widgets/line"
        }
        elementId: "horizontal-line"
        
    }
                
    PlasmaExtras.ScrollArea {
        id: scroll

        anchors {
            top: titleLine.bottom
            topMargin: 3
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        
        ListView {
            id: itemList
            
            anchors.fill: parent
            
            model: dataList
            delegate: singleItemComponent
            //highlight: PlasmaComponents.Highlight {}
        }
    }
    
    PlasmaComponents.Label {
        id: messageLabel
        
        anchors {
            top: titleLine.bottom
            topMargin: 3
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        
        visible: false
        
        horizontalAlignment: Text.AlignHCenter
        text: i18n("No pages to update.");
    }
    
    Component {
        id: singleItemComponent
        
        PlasmaComponents.ListItem {
            id: singleItem

            PlasmaComponents.Label {
                id: itemName
                
                anchors.left: parent.left
                //right or width to set
                
                elide: Text.ElideRight
                // bold if read==0 (not already clicked item)
                text: (read==1)? Utils.toShortName(title) : "<b>" + Utils.toShortName(title) + "</b>"
            }
                
            PlasmaComponents.Label {
                id: itemTime
                
                anchors {
                    right: itemDelete.left
                    rightMargin: 5
                    left: itemName.right
                    leftMargin: 5
                }
                
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
                font.pointSize: theme.smallestFont.pointSize
                //color: "#99"+(theme.textColor.toString().substr(1))              
                text: Utils.toDate(time)
            }

            MouseArea {
                anchors.fill: parent
                
                hoverEnabled: true
                
                onEntered: { itemDelete.opacity=0.7; }
                
                onExited: { itemDelete.opacity=0.1; }
                
                onClicked: {
                    Database.updateItemInDB(sourceWiki, time, "read"); //mark item as read
                    itemName.text = Utils.toShortName(title); //no more bold page name because it's read
                    
                    diffDialog.title = Utils.toShortName(title) + " - " + i18n("Difference between revisions");
                    
                    diffDialog.url = sourceWikiBaseUrl + "/index.php?title=Special:UserLogin&returnto=Special:Translate&returntoquery=group=page-" + Utils.toShortName(title) + "&task=view&language=" + languageCode;
                    
                    diffDialog.windowFlags = Qt.Popup;

                    var pos = diffDialog.popupPosition(singleItem);
                    diffDialog.x = pos.x;
                    diffDialog.y = pos.y;
                    
                    diffDialog.visible = true;
                    //diffDialog.loading = true; //to activate the BusyIndicator

                    GetDataFromWiki.getDiff(
                        sourceWikiBaseUrl,
                        title,
                        time,
                        function(data) {
                            //if (data == "")
                            //    data = "Error";
                            
                            // use the better text color according to Plasma theme and other fixes
                            // can't use an external css stylesheet
                            
                            var style = "<style type=\"text/css\">td.diff-lineno,td.diff-marker,td.diff-context{color:" + theme.textColor + ";}td.diff-lineno{font-weight:bold}td.diff-addedline{background-color:#CCFFCC;}td.diff-deletedline{background-color:#ffa;}.diffchange{color:red;font-weight:bold;text-decoration:none}</style>";
                            
                            data = "<html>" + style + "<table class=\"diff\">" + data + "</table></html>";

                            diffDialog.html = data;
                        }
                    );
                }
            }
            
            PlasmaCore.SvgItem {
                id: itemDelete
                
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }
                width: parent.height
                height: parent.height
                
                opacity: 0.1
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad; } }
                
                svg: PlasmaCore.Svg { imagePath: "widgets/configuration-icons" }
                elementId: "close"
                  
                MouseArea {
                    anchors.fill: parent
                    
                    hoverEnabled: true
                    
                    onEntered: { itemDelete.opacity=1; }
                    
                    onExited: { itemDelete.opacity=0.1; }
                    
                    onClicked: {
                        console.log("Delete: " + title);
                        Database.updateItemInDB(sourceWiki, time, "hidden"); //the item isn't deleted because its time can be useful to know what pages from the feed are new...
                        dataList.remove(index);
                    }
                }
            }
            
            ListView.onRemove:
            SequentialAnimation {
                PropertyAction { target: singleItem; property: "ListView.delayRemove"; value: true; }
                //PlasmaExtras.DisappearAnimation{ targetItem: singleItemComponent; } //seems not working...
                PropertyAnimation { target: singleItem; property: "opacity"; to: 0; duration: 250; easing.type: Easing.OutExpo; }
                PropertyAction { target: singleItem; property: "ListView.delayRemove"; value: false; }
            }
        }
    }
    
    Component.onCompleted: {      
        plasmoid.aspectRatioMode = IgnoreAspectRatio; //to avoid fixed ratio on resizing
        
        //maybe...if in the panel...use compact form...
        
        plasmoid.popupIcon = "plasmapackage:/images/icon.png";
        
        plasmoid.passivePopup = true; //other windows can gain focus and the popup won't close
        
        /* doesn't work...
        if (plasmoid.formFactor == Horizontal || plasmoid.formFactor == Vertical) {
            var toolTipData = new Object;
            //toolTipData["image"] = "icon.png";
            toolTipData["mainText"] = i18n("ToolTip title");
            toolTipData["subText"] = i18n("ToolTip descriptive sub text");
            plasmoid.popupIconToolTip = toolTipData;
        }
        */
        
        plasmoid.addEventListener('ConfigChanged', configChanged);
        
        plasmoid.busy = true;
        
        Database.openDB();
        
        //updateDataList(); //senza però non carica subito le voci
    }
}
