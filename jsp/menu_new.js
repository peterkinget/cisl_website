
// var buttonbase = "http://www.cisl.columbia.edu/grads/yu/cislgroup/";
var buttonbase = "";
// var menulinkbase = "http://www.cisl.columbia.edu/grads/yu/cislgroup/";
var menulinkbase = "";

/* define the number of the buttons */
var button_num = 7;

var buttonscale = 0.75 ; 
// var button_width = 140*buttonscale;
// var button_height = 38*buttonscale;
var button_width = 105;
var button_height = 28;

/* define the name of the button, 
   images files of the button 
   and the linked URL of the button*/

var buttonname = new Array;
var buttonfilename = new Array;
var buttonswapfilename = new Array;
var buttonselectedfilename = new Array;
var linkedURL = new Array;

buttonname[0] = "people";
buttonfilename[0] = buttonbase + "images/button/people2.gif";
buttonswapfilename[0] = buttonbase + "images/button/people1.gif";
buttonselectedfilename[0] = buttonbase + "images/button/people2.gif";
linkedURL[0] = menulinkbase + "people.html";

buttonname[1] = "research";
buttonfilename[1] = buttonbase + "images/button/research2.gif";
buttonswapfilename[1] = buttonbase + "images/button/research1.gif";
buttonselectedfilename[1] = buttonbase + "images/button/research2.gif";
linkedURL[1] = menulinkbase + "research.html";

buttonname[2] = "publications";
buttonfilename[2] = buttonbase + "images/button/publications2.gif";
buttonswapfilename[2] = buttonbase + "images/button/publications1.gif";
buttonselectedfilename[2] = buttonbase + "images/button/publications2.gif";
linkedURL[2] = menulinkbase + "publications.html";

buttonname[3] = "seminars";
buttonfilename[3] = buttonbase + "images/button/seminars2.gif";
buttonswapfilename[3] = buttonbase + "images/button/seminars1.gif";
buttonselectedfilename[3] = buttonbase + "images/button/seminars2.gif";
linkedURL[3] = menulinkbase + "seminars/seminars.html";

buttonname[4] = "courses";
buttonfilename[4] = buttonbase + "images/button/courses2.gif";
buttonswapfilename[4] = buttonbase + "images/button/courses1.gif";
buttonselectedfilename[4] = buttonbase + "images/button/courses2.gif";
linkedURL[4] = menulinkbase + "courses.html";
//linkedURL[4] = "http://www.ee.columbia.edu/misc-pages/grad_flowcharts.html#Circuits%20&%20Electronics%20(Senior%20&%20Graduate%20Courses)";

buttonname[5] = "sponsors";
buttonfilename[5] = buttonbase + "images/button/sponsors2.gif";
buttonswapfilename[5] = buttonbase + "images/button/sponsors1.gif";
buttonselectedfilename[5] = buttonbase + "images/button/sponsors2.gif";
linkedURL[5] = menulinkbase + "sponsors.html";

buttonname[6] = "news";
buttonfilename[6] = buttonbase + "images/button/news2.gif";
buttonswapfilename[6] = buttonbase + "images/button/news1.gif";
buttonselectedfilename[6] = buttonbase + "images/button/news2.gif";
linkedURL[6] = menulinkbase + "news.html";


/* The following code  is not necessary,
   but it might help by loading all the buttons in the
   cache at the beginning, so the swapping of the button
   will not be slow if the network is slow
*/

var buttonimages = new Array;
var buttonswapimages = new Array;

for (i=0;i<button_num;i++)
 {
   buttonimages[i] = new Image();
   buttonimages[i].src = buttonfilename[i];
   buttonswapimages[i] = new Image();
   buttonswapimages[i].src = buttonswapfilename[i];
 }



/* When mouse go over the button, swap to 
the active button */

function active(i) 
{ 
 var name = buttonname[i];
 document[name].src = eval("buttonswapimages["+i+"].src"); 
} 

/* When mouse go out of the button, swap
 to the inactive button */

function inactive(i) 
{ 
 var name = buttonname[i];
 document[name].src = eval("buttonimages["+i+"].src");
} 

function writemenu(selected)
{

 var i;

 var total_width;

 total_width = button_width * button_num + 10;

 document.write("<center><table width=\"" + total_width + "\""); 
 document.write(" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n <tr><td>\n");

 for (i=0;i<button_num;i++)
  {
    writeonebutton(i,selected);
  }

 document.write(" </td></tr>\n</table></center>\n");

}



function writeonebutton(i,selected) 
{

 if (buttonname[i] != selected) /* when button is selected, no link needed for it */
  {
      /* define the linked file name  */
    document.write("<a href=\""+linkedURL[i]+"\"");

      /* write the swap image functions  */
    document.write(" onmouseover=\"active(" + i + ")\"\n");
    document.write("     onmouseout=\"inactive(" + i + ")\"");
    document.write(">");
  }

  /* write the button image */
 if (buttonname[i] == selected)
  {
    document.write("<img src=\"" + buttonselectedfilename[i] + "\" \n");
  }
 else
  {
    document.write("<img src=\"" + buttonfilename[i] + "\" \n");
  }

 document.write(" border=\"0\"");

 /* define the size of the button */
 document.write(" width=\"" + button_width + "\"");
 document.write(" height=\"" + button_height + "\"");

  /* define the name of the button variable */
 document.write(" name=\"" + buttonname[i] + "\"");

 document.write(">");
 
 if (buttonname[i] != selected)
  {
    document.write("</a>");
  }

}

