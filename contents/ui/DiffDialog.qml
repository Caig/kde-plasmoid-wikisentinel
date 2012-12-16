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
import QtWebKit 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.components 0.1 as PlasmaComponents
import "plasmapackage:/code/getdatafromwiki.js" as GetDataFromWiki

PlasmaCore.Dialog {
    id: dialog
    
    property alias title: dialogLabel.text
    property alias html: dialogWebView.html
    property string url
    property bool loading
    
    Keys.onEscapePressed: {   
        dialog.visible = false;
    } //doesn't work...focus issue?
    
    /*
    onDiffUrlChanged: {
        //print("diffurl: " + diffUrl);
        
        if (diffUrl == "Error") {
            //errorImage.visible = true;
            errorLabel.visible = true;
            dialogOpenUrl.visible = false;
        }
        else {
            scroll.visible = true;
            
            console.log("Get diff text:");
            
            GetDataFromWiki.getDiff(diffUrl,
                function(diff) {
                    // use the better text color according to Plasma theme
                    diff = "<style type=\"text/css\">td.diff-otitle,td.diff-ntitle,td.diff-lineno,td.diff-marker,td.diff-context{color:" + theme.textColor + ";}</style>" + diff;
                                    
                    dialogWebView.html = diff;
                } );
        }
        
        loading = false;
    }
    */
    
    mainItem: Item {
        id: baseItem
        
        width: 520
        height: 300
        
        PlasmaCore.SvgItem {
            id: dialogOpenUrl
            
            anchors {
                verticalCenter: dialogLabel.verticalCenter
                left: parent.left
            }
            width: dialogLabel.height
            height: dialogLabel.height
            
            opacity: 0.7
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad; } }
            
            svg: PlasmaCore.Svg { imagePath: "widgets/configuration-icons" }
            elementId: "maximize"
                        
            MouseArea {
                anchors.fill: parent
                
                hoverEnabled: true
                
                onEntered: { dialogOpenUrl.opacity=1; }
                onExited: { dialogOpenUrl.opacity=0.7; }
                onClicked: {
                    plasmoid.openUrl(url);              
                    dialog.visible = false;
                }
            }
        }
        
        PlasmaComponents.Label {
            id: dialogLabel
            
            anchors {
                top: parent.top
                topMargin: 3
                left: dialogOpenUrl.right
                right: dialogDelete.left
            }
            
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
        
        PlasmaCore.SvgItem {
            id: dialogDelete
            
            anchors {
                verticalCenter: dialogLabel.verticalCenter
                right: parent.right
            }
            width: dialogLabel.height
            height: dialogLabel.height
            
            opacity: 0.7
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad; } }
            
            svg: PlasmaCore.Svg { imagePath: "widgets/configuration-icons" }
            elementId: "close"
                        
            MouseArea {
                anchors.fill: parent
                
                hoverEnabled: true
                
                onEntered: { dialogDelete.opacity=1; }
                onExited: { dialogDelete.opacity=0.7; }
                onClicked: {
                    dialog.visible = false;                    
                }
            }
        }
                    
        PlasmaCore.SvgItem {
            id: dialogLine
            
            anchors {
                top: dialogLabel.bottom
                left: parent.left
                right: parent.right
                topMargin: 3
            }
            height: dialogsvgLine.elementSize("horizontal-line").height
            
            svg: PlasmaCore.Svg {
                id: dialogsvgLine
                imagePath: "widgets/line"
            }
            elementId: "horizontal-line"
        }
        
        PlasmaExtras.ScrollArea {
            id: scroll
            
            anchors {
                top: dialogLine.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            
            visible: true //false
            
            Flickable {
            id: scrollable
            
            anchors.fill: scroll
                  
            contentHeight: dialogWebView.height
            
            flickableDirection: Flickable.VerticalFlick
            clip: true
                
                WebView {
                    id: dialogWebView
                    
                    //anchors.fill: parent //no per evitare problemi disegno barra
                    
                    preferredHeight: 300
                    preferredWidth: baseItem.width

                    backgroundColor: "transparent"
                    settings.standardFontFamily: theme.desktopFont.family
                    settings.defaultFontSize: 11 // theme.desktopFont.pointSize
                    
                    //onLoadStarted: { busy.visible = loading; busy.running = loading; }
                    
                    onLoadFinished: {
                        //loading = false;
                        scrollable.contentY = 0; //to ensure the page is always visible from the top
                    }
                    onLoadFailed:{
                        //loading = false;
                        scrollable.contentY = 0;
                    }
                }
            }
        }
        
        PlasmaComponents.BusyIndicator {
            id: busy
            
            anchors.centerIn: mainItem
            
            visible: loading
            running: loading
        }
        
        /*
        Image {
            id:errorImage

            anchors.centerIn: parent
            
            visible: false
            //source: "dialog-error.png"
        }
        */
        
        PlasmaComponents.Label {
            id: errorLabel
            
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            
            visible: false
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Sorry, an error occurred. Try to open the page in your browser.")
        }
        //pulsante per aprire pagina base?
    }
}