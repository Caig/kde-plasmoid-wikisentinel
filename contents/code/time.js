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

function toDate(timestamp) {
    var date = new Date(timestamp * 1000); // * 1000 because milliseconds needed
    var hours = date.getHours().toString();
    var minutes = date.getMinutes().toString();
    
    //to convert time values like '1:0' to '01:00'...
    if (hours.length == 1)
        hours = "0" + hours;
    
    if (minutes.length == 1)
        minutes = "0" + minutes;
    
    return date.toLocaleDateString() + ' - ' + hours + ':' + minutes;
}