libname x "D:\financial_tele_pro";
options fmtsearch=(x) ;

data x.accidents;
infile "D:\financial_tele_pro\Accidents0515.csv" dsd dlm=',' missover lrecl=2000 firstobs=2;
input Accident_Index: $20. Location_Easting_OSGR : 8.0  Location_Northing_OSGR : 8.0
Longitude: 11.8 Latitude: 11.8 Police_Force: $5. 
Accident_Severity: $2. Number_Vehicles: 3.0
Number_Casualties:4.0
Date: ddmmyy10. Weekd: 2.0 Time: time5. 
Local_Authority_District: $5. Local_Authority_Highway: $20. 
_1st_Road_Class: $3. _1st_Road_Number: $10. Road_Type: $3. 
Speed_limit: 4.0 Junction_Detail :$2.Junction_Control: $2.
_2nd_Road_Class: $2. _2nd_Road_Number: $2.
Ped_Cross_Human_Control: $2. Ped_Cross_Physical_Facilities: $2.
Light_Conditions: $2. Weather_Conditions:$2. Road_Surface_Conditions: $2. 
Special_Conditions_at_Site: $6. Carriageway_Hazards:$10.
Urban_or_Rural_Area: $3. 
Police_Attend_Scene: $3.
LSOA_of_Accident_Location: $20.;
format Date ddmmyy10.  Time time5.  ;
run;

data x.casualties;
infile "D:\financial_tele_pro\Casualties0515.csv" dsd dlm=',' missover lrecl=2000 firstobs=2;
input Accident_Index: $20. Vehicle_Reference: 3.0
Casualty_Reference: 3.0 Casualty_Class: $3.
Sex_Casualty: $2. Age_Casualty :3.0 Age_Band_Casualty: $2. 
Casualty_Severity: $1. Ped_Location:$3. Ped_Movement: $3.
Car_Passenger:$2. Bus_or_Coach_Passenger:$3.
Ped_Road_Maintenance_Worker:$3. Casualty_Type:$3. 
Casualty_Home_Area_Type:$3.;
run;
data x.Vehicles;
infile "D:\financial_tele_pro\Vehicles0515.csv" dsd dlm=',' missover lrecl=2000 firstobs=2;
input Accident_Index: $20. Vehicle_Reference: 3.0
Vehicle_Type: 3.0 Towing_Articulation:$3. Vehicle_Manoeuvre:$3.
Vehicle_Location_Restricted_Lane:$3.
Junction_Location:$3. Skidding_Overturning:$3.
Hit_Object_in_Carriageway:$3.
Vehicle_Leaving_Carriageway:$3.
Hit_Object_off_Carriageway:$3.
Point_Impact:$3.
Vehicle_Left_Hand_Drive:$3.
Journey_Purpose:$3.
Sex_Driver :$3. Age_Driver Age_Band_Driver: $2. 
Engine_Capacity:$10. Propulsion_Code:$3.
Age_Vehicle: 3.0
Driver_IMD_Decile:$3. Driver_Home_Area_Type:$3.;
run;
data x.accidents_5y;
set x.accidents;
where date ge "01jan2011"d;
year =year (date);
mon= month(date);
month=put(date, monname.);
week_day=put(date, weekdate9.);
mon_yr=put(date, monyy7.);
run;	

data x.casualties_5y;
set x.casualties;
where substr(accident_index,1,4) ge '2011';
run;

data x.Vehicles_5y;
set x.Vehicles;
where substr(accident_index,1,4) ge '2011';
run;

proc freq data=x.accidents_5y order=freq ;
tables Local_Authority_District Local_Authority_Highway Police_Force LSOA_of_Accident_Location ;
run;
proc freq data=x.accidents_5y order=freq ;
tables LSOA_of_Accident_Location/missing ;
run;

data x.loc_authority_dist;
infile "D:\financial_tele_pro\Local_Authority_District.csv" dsd dlm=',' missover lrecl=2000 firstobs=2;
input Local_Authority_District: $5. location: $60.;
run;
data x.veh_manoeuvre;
infile "D:\financial_tele_pro\Vehicle_Manoeuvre.csv" dsd dlm=',' missover lrecl=2000 firstobs=2;
input Vehicle_Manoeuvre:$3. Veh_Movement: $60.;
run;
data x.veh_type;
infile "D:\financial_tele_pro\Vehicle_Type.csv" dsd dlm=',' missover lrecl=2000 firstobs=2;
input Vehicle_Type: 3.0 Veh_type: $60.;
run;

/*for table-month vs weekday*/
proc sort data=x.accidents_5y out=x.acc;
by mon;
run;

proc format lib=x;
value colorfmt 
low-400='#FFCCCC'
401-600='#FF9999'
601-1600='#FF6666'
1601-4300='#FF3333'
4301-6000='#FF0000'
6001-8700='#CC0000'
8701-10000='#990000'
10001-30000='#660000';
value weight low -7.4= 'yellow'
             66049-high = 'red';
value wt     low -78182= 'yellow'
             117837-high = 'red';
value wkday   1= 'Sunday'
              2= 'Monday'
		      3='Tuesday'
			  4='Wednesday'
			  5='Thursday'
			  6='Friday'
			  7='Saturday';

value $cas_class    1='Driver or Rider'
                    2='Passenger'
					3='Pedestrian';

value  $Cas_Severity  1='Fatal'
	                 2='Serious'
                     3='Slight';
value  $Cas_Type   
0='Pedestrian'
1='Cyclist'
2='Motorcycle 50cc and under rider or passenger'
3='Motorcycle 125cc and under rider or passenger'
4='Motorcycle over 125cc and up to 500cc rider or passenger'
5='Motorcycle over 500cc rider or passenger'
8='Taxi/Private hire car occupant'
9='Car occupant'
10='Minibus (8 - 16 passenger seats) occupant'
11='Bus or coach occupant (17 or more pass seats)'
16='Horse rider'
17='Agricultural vehicle occupant'
18='Tram occupant'
19='Van / Goods vehicle (3.5 tonnes mgw or under) occupant'
20='Goods vehicle (over 3.5t. and under 7.5t.) occupant'
21='Goods vehicle (7.5 tonnes mgw and over) occupant'
22='Mobility scooter rider'
23='Electric motorcycle rider or passenger'
90='Other vehicle occupant'
97='Motorcycle - unknown cc rider or passenger'
98='Goods vehicle (unknown weight) occupant';

value $rcfmt 1='Motorway'
             2='A(M)'
             3='A'
             4="B" 
             5='C' 
             6="Unclassified";
run;

/*for plot*/
proc sql;
create table acc_veh_cas1 as
select  date, mon_yr,count(*) as num_acc, sum(number_Vehicles) as num_Veh, sum (number_Casualties) as num_Cas, year, mon
from x.accidents_5y 
group by mon_yr
order by year, mon;
quit;
proc sort data=acc_veh_cas1 out=x.acc_monyr nodupkey;
by year mon;
run;

/*for a drill down report*/
proc sql;
create table cas_veh as
select a.Accident_Index, a.Vehicle_Reference, Casualty_Reference, Casualty_Severity format=$Cas_Severity.,
Casualty_Class format=$cas_class., Age_Casualty,Casualty_Type format=$Cas_Type.,
Vehicle_Type, Vehicle_Manoeuvre
from x.casualties_5y as a left join x.vehicles_5y as b 
on a.Accident_Index= b.Accident_Index and a.Vehicle_Reference= b.Vehicle_Reference;
quit;
proc sql;
create table x.all as
select a.* , year, date, Number_Vehicles, Number_Casualties, Local_Authority_District,
case when Casualty_Severity='1' then 1
else 0
end as num_death
from cas_veh as a left join x.accidents_5y as b
on a.Accident_Index= b.Accident_Index;
quit;

Data x.all;
length location $60 Veh_type $60 Veh_Movement $60;
If _N_ = 1 Then  Do;
if 0 then ;
Declare Hash MyLkup(HashExp:8,Dataset:'x.loc_authority_dist');
MyLkup.DefineKey('Local_Authority_District');
MyLkup.DefineData('location');
MyLkup.DefineDone();

Declare Hash t(HashExp:8,Dataset:'x.Veh_type');
T.DefineKey('Vehicle_Type');
T.DefineData('Veh_type');
T.DefineDone();

Declare Hash M(HashExp:8,Dataset:'x.Veh_manoeuvre');
M.DefineKey('Vehicle_Manoeuvre');
M.DefineData('Veh_Movement');
M.DefineDone();
End;
call missing(location, Veh_type,Veh_Movement );
Set X.all ;
Rc = MyLkup.Find(); 
RC1=T.FIND(); 
RC2=M.FIND();
DROP RC RC1 RC2;
run; 

data all_1;
set x.all;
by Accident_Index;
if first.Accident_Index then n_death= 0; 
n_death + num_death;
if last.Accident_Index;
run;

proc print data=all_1;
where num_death ne n_death;
run;
proc sort data=all_1 out=all_sort;
by year descending Number_Casualties;
run;

data all_2 (keep=Accident_Index year Location Number_Vehicles n_death Number_Casualties );
set all_sort;
by year;
if first.year then count=0;
count+1;
if count le 10 then output;
run;
%macro linkreprt;
data x.all_3;
set x.all_2;
loops=_n_;
run;

proc sql;
select max(loops) into: loops
from x.all_3;
quit;

%put &loops;

%do i=1 %to &loops;
proc sql;
select Accident_Index  into :Acc_Index
from X.ALL_3
where loops=&i;
quit;

	data temp_&i ;
	set x.all (drop= Vehicle_type Vehicle_Manoeuvre year Local_Authority_District);
	where Accident_Index="&Acc_Index";
	run ;

	ods listing close;

	ods html
	file="D:\financial_tele_pro\report_2022\%trim(&Acc_Index).html"
	style=sasweb;
	proc print data=temp_&i;
	title "The Detail Data of Accidents &Acc_Index ";
	title2 "Run as of %qsysfunc(today(),worddate.)";
	run;
	ods html close;
	ods listing ;
%end;
%mend;
%linkreprt;
/*for table weekday vs time*/
data x.acc_5y;
set x.accidents_5y;
time_range= substr(put(time, time5.),1,2);
run;
proc sort data=x.acc_5y;
by time_range;
where time_range is not null;
run;


GOPTIONS reset=all Device = ActiveX ;

ODS LISTING CLOSE;
ODS html BODY = "D:\financial_tele_pro\report_2022\GRAPHS_ALL_20220206.html" STYLE=SASWEB;
%let embedded_titles=yes;

proc sgplot data=x.acc_monyr ;   
   series x= date y= num_acc/ curvelabel='Accidents'  curvelabelpos=max; /*date: numeric variable*/
   series x= date y= num_cas/ curvelabel='Casualties'  curvelabelpos=max;
   series x= date y= num_veh / curvelabel='Vehicles'  curvelabelpos=max;
   xaxis interval=month;
   YAXIS LABEL='Numbers'; 
   title j=c c=red h=12pt 'Accidents Analysis- Year  vs Month'; 
footnote1 "Created by %sysfunc(getoption(sysin)) on" " &sysdate9.."; 
run; 
quit; 

proc tabulate data=x.acc;
class month/order=data;
class weekd;
table month =''*(n='n' * f = 7. colpctn = '%' * f = 4.2) all*[style=[background=wt.]],
weekd= ''(all = 'Overall'*[s=[background=weight.]]) / misstext="0" box="Month\Weekday";
format weekd wkday.;
title j=c c=red h=12pt 'Accidents Analysis - Month vs Weekday '; 
run;

proc tabulate data=x.acc_5y ;
class time_range weekd;
table weekd ='',
time_range='0-24 Hours'*(n=''*([style=[background=colorfmt.]])) (all = 'Overall'*n='') / misstext="0" box="Weekday\Time";
format weekd wkday.;
title j=c c=red h=12pt 'Accidents Analysis-Weekday and Hours'; 
run;

title "Top10 Severity Accidents in Each Year";
proc report data=x.all_2 nowd split='#' ; 
column year Location ('Numbers' Number_Casualties n_death Number_Vehicles) Accident_Index ; 
define year/ group "Year" left ;
define Location/"Accident Areas" center WIDTH =25 SPACING=2;
define Number_Casualties/"Casualties" right WIDTH=4 SPACING=2;
define n_death/"Death" right WIDTH=4 SPACING=2;
define Number_Vehicles/"Vehicles#Involved" right WIDTH=4 SPACING=2 ;
define Accident_Index/"Accident Reference" right SPACING=2;
Compute after year;
Line " Next Year";
endcomp;
compute Accident_Index;hlink="D:\financial_tele_pro\report_2022\" ||trim(Accident_Index)||".html";
call define (_col_, 'url',hlink);
call define (_col_, 'Style', 'style={flyover="Click to see '||strip(Accident_Index)||' report"}');
endcomp;
run;

ods html close;
ODS LISTING;

/*****************pie drill down to bar**************/

proc greplay igout=work.gseg nofs;
 delete htmldril ac1 ac11 ac12; /*clean existed graph so that you can reuse same name for graph*/
filename webout "D:\financial_tele_pro\report_2022";
/* set general graphic options */
goptions reset=global gunit=pct
         htitle=6 htext=4
         ftitle=zapfb ftext=swiss border;
/* assign graphics options for ODS output */
goptions transparency noborder
  xpixels=450 ypixels=400
  gsfname=webout device=html;

data x.pie_bar(keep=Accident_Severity _1st_Road_Class Number_Casualties links);
set x.Accidents_5y;
format _1st_Road_Class $rcfmt. Accident_Severity $Cas_Severity. ;
length links $40; /* the HTML variable */
/* add the HTML variable and assign its values */
if Accident_Severity='1' then links='href="ac1.gif"';   
else if Accident_Severity='2' then links='href="ac11.gif"';
else if Accident_Severity='3' then links='href="ac12.gif"';
run;

title "Percentage of Casualties from 2011-2015";
/* Create pie that use the HTML variable */
proc gchart data=x.pie_bar imagemap=accmap ;
  pie3d  Accident_Severity / sumvar=Number_Casualties
   noheading  explode ="Fatal" ANGLE=180
 ctext='dark blue'  
 ascending value=none 
 slice=outside percent=outside
 html=links name='htmldril';
run;

title;
goptions dev=gif;
proc sort data=x.pie_bar;
by Accident_Severity;
RUN;
proc gchart data=x.pie_bar;
 vbar3d _1st_Road_Class / sumvar=Number_Casualties 
 patternid=midpoint 
 name='ac1'; 
 by Accident_Severity;
run;
quit; /***click path <D:\financial_tele_pro\report_2022 \index> to drill down graph***/
/* important: name = naming the GIF files, defaut value length is 8, if you assign a name less than 8,  
graph suffixname:1,11,12,not '1, 2,3*/

