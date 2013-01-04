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
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.plasma.components 0.1 as PlasmaComponents
import "plasmapackage:/code/getdatafromwiki.js" as GetDataFromWiki

PlasmaCore.Dialog {
    id: dialog
    
    property alias title: dialogLabel.text
    property alias html: htmlText.text
    property string url
    property bool loading
    property bool error
    
    Keys.onEscapePressed: {   
        dialog.visible = false;
        //event.accepted = true;
    } //doesn't work...focus issue?
    
    onHtmlChanged: {
        scrollable.contentY = 0; // to ensure the text is always visible from the beginning
        loading = false; // because received something
    }
    
    mainItem: Item {
        id: baseItem
        
        width: 520
        height: 300
        
        focus: true
        
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
                    html = "";
                    error = false;
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
                    html = "";
                    error = false;
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
            
            visible: true
            
            Flickable {
                id: scrollable
                
                anchors.fill: parent
                
                //contentWidth: htmlText.width
                contentHeight: htmlText.height
                
                flickableDirection: Flickable.VerticalFlick
                
                clip: true
                
                Text {
                    id: htmlText
                    
                    anchors.left: parent.left
                    anchors.right: parent.right
                    
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
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
            
            visible: error
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Sorry, an error occurred. Try to open the page in your browser.")
        }
        //button to open diff page?
    }
}