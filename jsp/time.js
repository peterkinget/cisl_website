
var counterimage = new Array;

counterimage[0]="images/digits/0led.gif"
counterimage[1]="images/digits/1led.gif"
counterimage[2]="images/digits/2led.gif"
counterimage[3]="images/digits/3led.gif"
counterimage[4]="images/digits/4led.gif"
counterimage[5]="images/digits/5led.gif"
counterimage[6]="images/digits/6led.gif"
counterimage[7]="images/digits/7led.gif"
counterimage[8]="images/digits/8led.gif"
counterimage[9]="images/digits/9led.gif"

var commaimage = new Array;

commaimage[0]="images/digits/comma.gif";
commaimage[1]="images/digits/blackcomma.gif";

var backgroundcolor = "#000000";


function first_digit(number)
 {
   return Math.floor(number/10);
 }

function second_digit(number)
 {
   return (number - first_digit(number)*10);
 }

function showTheTime() 
 { 	
   now = new Date;

   var hour = now.getHours();
   var minute = now.getMinutes();
   var second = now.getSeconds();
  
   var hour1 = first_digit(hour);
   var hour2 = second_digit(hour);
   var minute1 = first_digit(minute);
   var minute2 = second_digit(minute);
   var second1 = first_digit(second);
   var second2 = second_digit(second);

   document["hour1"].src = counterimage[hour1];
   document["hour2"].src = counterimage[hour2];

   document["minute1"].src = counterimage[minute1];
   document["minute2"].src = counterimage[minute2];

   document["second1"].src = counterimage[second1];
   document["second2"].src = counterimage[second2];

   setTimeout("showTheTime()",500)

}  	


function writewatch()
 {

    document.write("<table bgcolor=\"" + backgroundcolor + "\" ");
    document.write(" border=\"0\" cellspacing=\"0\" cellpadding=\"0\"> <tr>");

    writeonedigit("hour1");
    writeonedigit("hour2");
    writeonedigit("comma");
    writeonedigit("minute1");
    writeonedigit("minute2");
    writeonedigit("comma");
    writeonedigit("second1");
    writeonedigit("second2");
    document.write("</tr></table>");
 }

function writeonedigit(name)
 {
   document.write("<td><img src=\"" + commaimage[0] + "\"");
   document.write(" name=\"" + name + "\"></td>");
 }
 
