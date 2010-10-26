/*
* LaTeX Editor - JavaScript to launch the CodeCogs Equation Editor 
* Copyright (C) 2009 William Bateman, 2008 Waipot Ngamsaad 

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// The following code was originally developed by Waipot Ngamsaad <waipot@ngamsaad.name> (Website: http://www.waipot.ngamsaad.name)
// It has been updated and adapted by Will Bateman for www.CodeCogs.com

function combine(a,b){
  var ary=[];
  for (var zxc0=0;zxc0<a.length;zxc0++) { ary.push(a[zxc0]); }
  for (var zxc1=0;zxc1<b.length;zxc1++) { ary.push(b[zxc1]); }
  return ary;
}

function renderlatex() {
	var eqnp = window.document.getElementsByTagName("p");
        var eqnli = window.document.getElementsByTagName("li");
        var eqnspan = window.document.getElementsByTagName("span");
        var eqntd = window.document.getElementsByTagName("td");
        var eqnh1 = window.document.getElementsByTagName("h1");
//	var eqn = window.document.getElementsByTagName("div");
	var eqn1 = combine(eqnp,eqnli);
        var eqn2 = combine(eqnspan,eqntd);
        var eqn = combine(eqn1,eqn2);
        var eqn = combine(eqn,eqnh1);

	
	for (var i=0; i<eqn.length; i++) {
		html=eqn[i].innerHTML;
    html=html.replace(/(^\$|[^\\]\$)(.*?[^\\])\$/g," <img src=\"http://latex.codecogs.com/gif.latex?\\inline $2\" alt=\"$2\" title=\"$2\" border=\"0\" class=\"latex\" /> ");

    html=html.replace(/(^\\|[^\\]\\)\[(.*?[^\\])\\\]/g," <br/><img src=\"http://latex.codecogs.com/gif.latex?$2\" alt=\"$2\" title=\"$2\" border=\"0\" /><br/> "); 
    html=html.replace(/\\\$/g,"\$"); 
    html=html.replace(/\\\\(\[|\])/g,"$1"); 
		eqn[i].innerHTML = html;
	}
}

if (window.addEventListener)
  window.addEventListener("load", renderlatex, false); 
else if (window.attachEvent)
  window.attachEvent("onload", renderlatex);  