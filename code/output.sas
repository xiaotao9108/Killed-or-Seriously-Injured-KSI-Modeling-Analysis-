/*** Slide 3 Graph1 four lines  general report for accidents***********************************************/
GOPTIONS reset=all Device = ActiveX;
ODS LISTING CLOSE;
ODS tagsets.HTMLpanel Path="C:\Users\stone\Desktop\FT project\coding"
BODY = "GRAPHS_ALL.html" STYLE=SASWEB;
%let embedded_titles=yes;
ODS tagsets.HTMLpanel event = panel (start);
ODS tagsets.HTMLpanel event = row_panel (start);
ODS tagsets.HTMLpanel event = column_panel (start);

goptions reset=all device=ActiveX xpixels=1050  ypixels=750  ;
axis1 offset=( 0 , 0 ) minor=NONE 
      label=( 'From 2011 to 2015' h= 1.0  f=swiss) 
      value=(h= 1.0   f=swiss );
axis2 label=( 'Number of Accidents'  h= 1.0  f=swiss1) 
      value=(h= 1.0  f=swiss)
      minor=none /**number of ticks**/
      offset=(0, 0 ) order=(10000 to 200000 by 10000);
axis3 label=( 'Number of Casualties'  h= 1.0  f=swiss) 
      value=(h= 1.0  f=swiss) offset=(0, 0 ) 
      minor=none
      order=(1000 to 220000 by 10000);
symbol1 i=j v=dot c=blue h=1.0 w=3  pointlabel=(h=0.8  c=black); 
symbol2 i=j v=dot c=yellow h=1.0 w=3 pointlabel=(h=0.8  c=black); 
symbol3 i=j v=dot c=black h=1.0 w=3 pointlabel=(h=0.8  c=black); 
symbol4 i=j v=dot c=red h=1.0 w=3 pointlabel=(h=0.8  c=black); 
legend1 label=none 
      value=(h=0.7 color=blue font=swiss 'Number of Accidents')
      position=(bottom center outside) mode=reserve cborder=white;
legend2 label=none 
      value=(h=0.7 color=blue  font=swiss 'Number of Severe Accidents')
      position=(bottom center outside) mode=reserve cborder=white;
legend3 label=none 
      value=(h=0.7 color=blue  font=swiss 'Number of Casualties')
      position=(bottom center outside) mode=reserve cborder=white;
legend4 label=none 
      value=(h=0.7 color=blue  font=swiss 'Number of Death')
      position=(bottom center outside) mode=reserve cborder=white;

proc gplot  data=kk.graph1_acc ;
title h=10pt f=swiss "UK Accident Chart from 2011 to 2015"  ;
format Number_of_Accident Number_of_Severity Number_of_Casualty Number_of_death  COMMA8.;
plot Number_of_Accident*year Number_of_Severity*year /overlay haxis=axis1 vaxis=axis2  legend=legend1 cframe=white  ;
plot2  Number_of_Casualty*year Number_of_death*year/overlay  vaxis=axis3 legend=legend3 cframe=white;
*plot Number_of_Accident*year Number_of_Severity*year/ overlay haxis=axis1 vaxis=axis2  legend=legend1 cframe=white  ;
run;
quit;

ODS tagsets.HTMLpanel event = column_panel (finish);
ODS tagsets.HTMLpanel event = row_panel (finish);
ODS tagsets.HTMLpanel event = panel (FINISH);

/***Slide 4 Graph7 general report month year*********************************************************************/
ODS tagsets.HTMLpanel event = panel (start);
ODS tagsets.HTMLpanel event = row_panel (start);
ODS tagsets.HTMLpanel event = column_panel (start);
GOPTIONS reset=all;
goptions reset=all device=ActiveX xpixels= 1250  ypixels= 1050 ;
proc sgplot data=kk.mony1 ;   
title h=10pt c=blue  f=swiss "Number of Accidents, casualties and involved vehicles for every month";
   series x= yearmon y= number_of_accident/ curvelabel  curvelabelpos=max ; /*date: numeric variable*/
   series x= yearmon y= number_of_casualties/ curvelabel curvelabelpos=max ;
   series x= yearmon y= number_of_vehicles / curvelabel curvelabelpos=max ;
   xaxis FITPOLICY=ROTATETHIN interval=month;
   YAXIS LABEL='Numbers'; 
   XAXIS LABES='Year-Month';
run;  
ODS tagsets.HTMLpanel event = column_panel (finish);
ODS tagsets.HTMLpanel event = row_panel (finish);
ODS tagsets.HTMLpanel event = panel (FINISH);

/***Slide 7left Graph3 day ageband gender for distribution *******************************************************************/
ODS tagsets.HTMLpanel event = panel (start);
ODS tagsets.HTMLpanel event = row_panel (start);
ODS tagsets.HTMLpanel event = column_panel (start);


GOPTIONS reset=all;
goptions reset=all device=ActiveX xpixels= 450  ypixels= 550 ;
legend1 label=none 
      value=(h=0.7 color=blue font=swiss 'Number of Male Death')
      position=(bottom center outside) mode=reserve cborder=white;
legend2 label=none 
      value=(h=0.7 color=red  font=swiss 'Number of Female Death')
      position=(bottom center outside) mode=reserve cborder=white;
proc sgplot data=kk.graph3_vehacc;
title h=10pt f=swiss "Number of Accidents by the gender and age band of driver";
styleattrs datacolors=(blue red);
options fmtsearch=(kk.formats);
format Number_of_Accident Number_of_Severity COMMA8.;
format sex_driver $gender.;
format ageband_driver ageband.;
vbar Ageband_driver /group=sex_driver groupdisplay=cluster response=number_of_accident datalabel= number_of_accident ;
vline ageband_driver/group=sex_driver response= number_of_severity  ;
*keylegend/noborder position=bottomright;
run;

ODS tagsets.HTMLpanel event = column_panel (finish);

/***Slide7-right Graph4 Road type and casualty distribution**********************************************************************/
ODS tagsets.HTMLpanel event = column_panel (start);

goptions reset=all device=ActiveX xpixels= 850  ypixels= 850 ;
title h=10pt f=swiss "Road Type and Casualty type for the number of Casualties"  ;
proc sgplot data=kk.graph4_rtcas;
styleattrs datacolors=(green yellow red);
options fmtsearch=(kk.formats);
format cas_class $casclass.;
format road_type $roadtype.;
vbar road_type /group=cas_class groupdisplay=stack response=number_of_casualty datalabel= number_of_casualty ;
vline road_type /group=cas_class response= number_of_death y2axis;
run;
quit;
ODS tagsets.HTMLpanel event = column_panel (finish);
ODS tagsets.HTMLpanel event = row_panel (finish);
ODS tagsets.HTMLpanel event = panel (FINISH);

/***Slide 8 graph2 proc tabulate ****************************************************************/
ODS tagsets.HTMLpanel event = panel (start);
ODS tagsets.HTMLpanel event = row_panel (start);
ODS tagsets.HTMLpanel event = column_panel (start);

goptions reset=all device=ActiveX xpixels= 1000  ypixels= 450 ;
title h=10pt f=swiss "Weekday and hour for Accidents"  ;
proc tabulate data=kk.acc_year2 ;
class hour weekday;
options fmtsearch=(kk.formats);
table weekday ='',
hour='0-24 Hours'*(n=''*([style=[background=red.]])) (all = 'Overall'*n='') / misstext="0" box="Weekday\Time";
format weekday weekd.;
title ; title2 j=c c=red h=12pt 'Accidents Analysis-Weekday and Hours'; 
footnote1 "Created by %sysfunc(getoption(sysin)) on" " &sysdate9.."; 
run;

ODS tagsets.HTMLpanel event = column_panel (finish);
ODS tagsets.HTMLpanel event = row_panel (finish);
ODS tagsets.HTMLpanel event = panel (FINISH);
/***********Slide 5 weather condition heat map*******************************/



PROC SQL   ;
CREATE TABLE acc_road_weather AS 
SELECT A_Index,Road_Scdt,Weather_Cdt
FROM accident_in;
QUIT ;


/*
proc freq data= acc_road_weather;
table Road_Scdt Weather_Cdt/list missing;
run;
*/

data acc_road_weather2;
set acc_road_weather;
if Road_Scdt=-1 or Weather_Cdt=-1 then delete;
run;


/*
proc freq data= acc_road_weather2;
table Road_Scdt Weather_Cdt/list missing;
run;
*/

GOPTIONS reset=all Device = ActiveX;
ODS LISTING CLOSE;
ODS tagsets.HTMLpanel Path="C:\SASProject2021\SASgroupproject202201\REPORT\OUTPUT"
BODY = "GRAPHS_Ashen.html" STYLE=SASWEB;
%let embedded_titles=yes;
ODS tagsets.HTMLpanel event = panel (start);
ODS tagsets.HTMLpanel event = row_panel (start);
ODS tagsets.HTMLpanel event = column_panel (start);

proc tabulate data=acc_road_weather2 ;
class Road_Scdt Weather_Cdt;
options fmtsearch=(a.formats);
table Road_Scdt ='',
Weather_Cdt='Road Surface Conditions'*(n=''*([style=[background=road_heat_map.]])) (all = 'Overall'*n='') / misstext="0" box="Weather Conditions
";
format Road_Scdt Road_Surf_Cond.;
format Weather_Cdt Weather_cond.;
title ; title2 j=c c=red h=12pt 'Accidents Analysis-Road Surface Conditions and Weather Conditions'; 
/*footnote1 "Created by %sysfunc(getoption(sysin)) on" " &sysdate9.."; */
run;


/*********************************************************************************/



/***Graph5 5 most accident locations for each year proc report****************************************************************/
/***ODS tagsets.HTMLpanel event = panel (start);
ODS tagsets.HTMLpanel event = row_panel (start);
ODS tagsets.HTMLpanel event = column_panel (start);

goptions reset=all device=ActiveX xpixels= 850  ypixels= 650 ;
title h=10pt f=swiss "Top 5 Cities for Accidents"  ;

proc report data=kk.graph5_f nowd split="/";
column year city number_of_accident number_of_severity number_of_casualty number_of_death;
define year/"Year" left ;
define number_of_accident/"Number of Accidents" center ;
define number_of_severity/"Number of Severe Accidents" center ;
define number_of_casualty/"Number of Casualties" right ;
define number_of_death/"Number of Death" right ;
run;
ODS tagsets.HTMLpanel event = column_panel (finish);
ODS tagsets.HTMLpanel event = row_panel (finish);
ODS TAGSETS.HTMLPANEL EVENT=PANEL(FINISH);
ODS TAGSETS.HTMLPANEL CLOSE;*************************************************/

