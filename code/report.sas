libname kk 'C:\Users\stone\Desktop\FT project\coding\report';

/*proc import datafile='C:\Users\stone\Desktop\FT project\data souce\accidents0515.csv' out=ft.acc_import dbms=dlm replace;
   delimter=',';
   Getnames=yes;
  run;*/
/***read in three csv files***********************************************************************/
data accident_in;
infile 'C:\Users\18144\OneDrive\Desktop\SAS\Project\telecom\UK Accident Analysis\data\Accidents0515.csv' dsd dlm=',' missover firstobs=2;
input
A_Index    :$14.
E_OSGR     :$8.
N_OSGR     :$8.
Longitude          :$12.
Latitude           :$12.
P_Force         :$3.
A_Severity      :$2.
N_Vehicles      :3.0
N_Casualties    :3.0
Date                   :ddmmyy10.
Weekday                :2.0
Time                   :time5.
LA__District  :$4.
LA__Highway   :$10.
F_RClass             :$2.
F_RNumber            :$5.
Road_Type            :$2.
Speed_limit          :3.0
Junction_Dtl             :$2.
Junction_Ctl             :$2.
S_RClass             :$2.
S_RNumber            :$5.
Ped_HMCTL      :$2.
Ped_PhyFclt     :$2.
Light_Cdt      :$2.
Weather_Cdt    :$2.
Road_Scdt      :$2.
Special_Cdtsite     :$2.
Crgway_Hzd          :$2.
Urban_Rural         :$2.
Police_Attend       :$2.
LSOA                :$10.;
label     A_Index = 'Accident_Index '   
           E_OSGR = 'Location_Easting_OSGR' 
           N_OSGR = 'Location_Northing_OSGR '
          P_Force = 'Police_Force'           
       A_Severity = 'Accident_Severity'     
       N_Vehicles = 'Number_of_Vehicles'     
     N_Casualties = 'Number_of_Casualties'   
     LA__District = 'Local_Authority__District'
      LA__Highway = 'Local_Authority__Highway'
         F_RClass = '_1st_Road_Class'             
        F_RNumber = '_1st_Road_Number'            
         S_RClass = '_2nd_Road_Class'             
        S_RNumber = '_2nd_Road_Number'           
        Ped_HMCTL = 'Pedestrian_Crossing_Human_Control'  
      Ped_PhyFclt = 'Pedestrian_Crossing_Physical_Facilities'  
        Road_Scdt = 'Road_Surface_Conditions'           
  Special_Cdtsite = 'Special_Conditions_at_Site'        
       Crgway_Hzd = 'Carriageway_Hazards' ;              
run;
proc format library=kk;
value $roadtype 
1 = 'Roundabout'
2 = 'One way street'
3 = 'Dual carriageway - 2 lanes'
6 = 'Single carriageway - 2 lanes(one in each direction)'
7 = 'Single carriageway - 3 lanes(two way capacity)'
9 =' Unknown';
run;
proc format library=kk.formats;
value weekd
1= Sunday
2= Monday
3= Tuesday
4= Wednesday
5= Thursday
6= Friday
7= Saturday;
run;
proc format library=kk.formats;
value $ roadtype
1 = 'Roundabout'
2 = 'One way street'
3 = 'Dual carriageway - 2 lanes'
6 = 'Single carriageway - 2 lanes (one in each direction)'
7 = 'Single carriageway - 3 lanes (two way capacity)';
run;
proc freq data=kk.acc_5;
table road_type/list missing nocum;
run;

data kk.casualty_in;
infile 'C:\Users\stone\Desktop\FT project\data souce\casualties0515.csv' dsd dlm=',' missover;
input
A_Index :$14.
Veh_Ref :$2.
Cas_Ref :$2.
Cas_Class :$2.
Sex_Cas :$2.
Age_Cas :2.0
AgeBand_Cas :$3.
Cas_Severity    :$2.
Ped_Location  :$2.
Ped_Mvmt  :$2.
Car_Psger        :$2.
BusCoach_Psger :$2.
Ped_Worker  :$2.
Cas_Type :$3.
Cas_HomeAType :$2.;
label 
veh_ref = 'Vehicle_Reference' 
Cas_Ref = 'Casualty_Reference' 
Cas_Class = 'Casualty_Class' 
sex_cas = 'Sex_Casualty' 
age_cas = 'Age_Casualty' 
AgeBand_cas = 'AgeBand_Casualty'
Cas_Severity = 'Casualty_Severity' 
Ped_Location = 'Pedestrian_Location'
ped_mvmt = 'Pedestrian_Movement'
Ped_worker = 'Pedestrian_Road_Maintenance_Worker'
cas_type = 'Casualty_Type'
Cas_homeatype = 'Casualty_Home_Area_Type';
run;
Proc format library=kk.formats;
value $ casclass
1 = 'Driver or rider'
2 = 'Passenger'
3 = 'Pedestrian';
run;

data kk.vehicle_in;
infile 'C:\Users\stone\Desktop\FT project\data souce\vehicles0515.csv' dsd dlm=',' missover;
input 
A_Index :$14.
Veh_Ref :$2.
Veh_Type      :$3.
Towing_Atcltn :$2.
Veh_Manoeuvre        :$3.
Veh_restrctLane :$2.
Jun_Location            :$2.
Skidding_Overturning     :$2.
HitObj_Crgway    :$2.
VehLeav_Crgway  :$2.
HitObj_offCrgway   :$3.
fPoint_Impact          :$2.
VehLHand_Drive  :$2.
Driver_JourneyPurpose    :$3.
Sex_Driver         :$2.
Age_Driver         :3.0
AgeBand_Driver    :3.
Engine_Capacity       :$8.
Propulsion_Code              :$2.
Age_Veh               :3.0
Driver_IMDDecile            :$2.
Driver_HomeAType        :$2.;
label 
Veh_Ref = 'Vehicle_Reference'
Veh_Type = 'Vehicle_Type'      
Towing_Atcltn = 'Towing_and_Articulation' 
Veh_Manoeuvre = 'Vehicle_Manoeuvre'        
Veh_restrctLane = 'Vehicle_Location-Restricted_Lane' 
Jun_Location  = 'Junction_Location'            
HitObj_Crgway = 'Hit_Object_in_Carriageway'    
VehLeav_Crgway  = 'Vehicle_Leaving_Carriageway'  
HitObj_offCrgway = 'Hit_Object_off_Carriageway'   
fPoint_Impact = 'first_Point_of_Impact'          
VehLHand_Drive  = 'Was_Vehicle_Left_Hand_Drive'  
Driver_HomeAType = 'Driver_Home_Area_Type' ;   
run;
Proc format library=kk.formats;
value  ageband  
                 1='0-5'
			     2='6-10'
			     3='11-15'
			     4='16-20'
			     5='21-25'
			     6='26-35'
			     7='36-45'
			     8='46-55'
			     9='56-65'
			    10='66-75'
			    11='75+' ;
run;
proc format library=kk.formats;
value $ gender 1='Male'
               2='Female';
run;
data kk.location;
infile 'C:\Users\stone\Desktop\FT project\data souce\losa_ref.csv' dsd dlm=',' missover;
input 
PCD7	$:8.
PCD8	$:8.
OA11CD	$:10.
LSOA    	$:10.
LSOA11NM	$:30.
MSOA11CD	$:10.
MSOA11NM	$:30.
LAD11CD	    $:10.
City        $:40.
LAD11NMW	$:2.
PCDOASPLT   $:2.
;
run;

 
/***get 5 years data for three tables*******************************************/
data kk.acc_5;
set kk.accident_in;
if substr(a_index,1,4) in ('2011','2012', '2013', '2014', '2015');
run;
data kk.cas_5;
set kk.casualty_in;
if substr(a_Index,1,4) in ('2011','2012', '2013', '2014', '2015');
run;
data kk.veh_5;
set kk.vehicle_in;
if substr(a_Index,1,4) in ('2011','2012', '2013', '2014', '2015');
run;
/*** see three table freq*********************************************/
  proc freq data= kk.acc_5 ;
  table   
A_index 
A_Severity                            
Weekday              
F_RClass                       
Road_Type           
Speed_limit         
Junction_Dtl            
Junction_Ctl            
S_RClass            
Ped_HMCTL      
Ped_PhyFclt     
Light_Cdt     
Weather_Cdt    
Road_Scdt      
Special_Cdtsite     
Crgway_Hzd          
Urban_Rural         
Police_Attend/list missing nocum  ;
run;

proc freq data=kk.cas_5 ;
table
Cas_Class 
Sex_Cas 
AgeBand_Cas 
Cas_Severity    
Ped_Location  
Ped_Mvmt  
Car_Psger        
BusCoach_Psger 
Ped_Worker  
Cas_Type 
Cas_HomeAType /list missing nocum;
run;
proc freq data=kk.veh_5;
table
Veh_Type      
Towing_Atcltn 
Veh_Manoeuvre        
Veh_restrctLane 
Jun_Location            
Skidding_Overturning    
HitObj_Crgway    
VehLeav_Crgway  
HitObj_offCrgway  
fPoint_Impact         
VehLHand_Drive  
Driver_JourneyPurpose    
Sex_Driver                
AgeBand_Driver    
Propulsion_Code                          
Driver_IMDDecile           
Driver_HomeAType /list missing nocum;      
run;
/***graph1 number of accident and number of severity for 5 years distribution*************************/
proc freq data=kk.acc_5;
table a_severity/missing list;
run;
data kk.acc_year;
set kk.acc_5;
year= input((substr(A_index,1,4)), best4.);
hour= hour(time);
month=month(date);
if a_severity in ('1','2') then flag_sev = 1;
else flag_sev = 0 ;
run;

proc sql;
create table kk.acc2 as select year, count(a_index) as number_of_accident, sum(flag_sev) as number_of_severity from kk.acc_year
group by year;
quit;
/***calculate casualty for graph1***********************************/
proc sql;
create table kk.acc1 as
select year, count(cas_ref) as number_of_casualty, sum(flag_fatal) as number_of_death from kk.cas_acc_veh1
group by year;
quit;

proc sql;
create table kk.graph1_acc as select a.*, b.* from kk.acc2 as a left join kk.acc1 as b
on a.year=b.year;
quit;
/***general report for yearmonth graph7*************************************************************/

proc sql;
create table kk.mony as select year, month, count(a_index) as number_of_accident, sum(N_Casualties) as number_of_casualties, sum(N_vehicles) as number_of_vehicles
from kk.acc_year
group by 1,2
order by 1, 2 ;
quit;
data kk.mony1;
set kk.mony;
yearmon=mdy(put(month,z2.),1,year);
format yearmon monyy7.;
run;
/***graph2  which day which hour with most accident***************************************************/
/***join accident and vehicle table****************************************************/
/***total vehicles =1321317**********************************************************************/
data temp;
set kk.acc_5 end = eof;
total + n_vehicles;
if eof; output;
run;
/***total casualties = 964009 **************************************************************************/
data temp2;
set kk.acc_5 end = eof;
total+n_casualties;
if eof; output;
run;
proc sql;
create table kk.veh_acc as select 
a.A_Index, a.Veh_Ref, a.Veh_Type, a.Driver_JourneyPurpose, a.Sex_Driver, a.Age_Driver, a.AgeBand_Driver, a.Age_Veh, a.Veh_Manoeuvre,
b.P_Force, b.A_Severity, b.N_Casualties, b.Date, b.Weekday, b.Time, b.LA__District, b.LA__Highway, b.F_RClass, b.F_RNumber, 
b.Road_Type, b.Speed_limit, b.Junction_Dtl, b.Junction_Ctl, b.S_RClass, b.S_RNumber,b.Ped_HMCTL, b.Ped_PhyFclt,
b.Light_Cdt, b.Weather_Cdt, b.Road_Scdt, b.Special_Cdtsite, b.Crgway_Hzd, b.Urban_Rural, b.Police_Attend, b.LSOA, b.year, b.hour, b.flag_sev,
b.E_OSGR,b.N_OSGR, b.Longitude, b.Latitude 
from kk.veh_5 as a left join kk.acc_year as b
on a.A_index = b.A_index;
quit;
proc freq data= kk.acc_year;
table weekday hour/list missing;
run;
proc freq data=kk.veh_acc;
table veh_type Veh_Manoeuvre/list missing;
run;
data kk.acc_year1;
set kk.acc_year;
if missing(hour) then delete;
data kk.acc_year2;
set kk.acc_year1;
if flag_sev=1 then output;
run;
proc sql;
create table kk.graph2_sev as select weekday, hour, count(a_index) as number_of_severity
from kk.acc_year2
group by weekday, hour;
quit;
proc sql;
create table kk.graph2_daytime as select weekday, hour, count(a_index) as number_of_accident, sum(flag_sev) as number_of_severity
from kk.acc_year1
group by weekday, hour;
quit;
data tet;
set kk.graph2_daytime;
format weekday weekday.;
run;
proc print;
run;

proc tabulate data= kk.graph2_f;
class weekday hour ;
var number_of_accident ;
table weekday*(number_of_accident='')*format=6.0*[ STYLE=[BACKGROUND=colorfmt. ]],hour='0-24 Hours' all='Total' ;
run;

proc univariate data=kk.graph2_daytime;
var number_of_accident;
run;
proc format library=kk.formats;
value colorfmt 
low-400='#FFCCCC'
401-600='#FF9999'
601-1600='#FF6666'
1601-4300='#FF3333'
4301-6000='#FF0000'
6001-8700='#CC0000'
8701-10000='#990000'
10001-30000='#660000';
run;

proc univariate data=kk.graph2_sev;
var number_of_severity;
run;
proc format library= kk.formats;
value red
low-100='#FFA07A'
101-200='#FF9999'
201-320='#F08080'
321-650='#FA8072'
651-930='#FF0000'
931-1215='#DC143C'
1216-1500='#B22222'
1501-2000='#8B0000';
run;
proc format library= kk.formats;
value brown
low-100='#F5DEB3'
101-200='#F4A460'
201-320='#DAA520'
321-650='#CD853F'
651-930='#D2691E'
931-1215='#A0522D'
1216-1500='#A52A2A'
1501-2000='#800000';
run;
proc tabulate data= kk.graph2_sev;
class weekday hour ;
var number_of_severity ;
table weekday*(number_of_severity='')*format=6.0*[ STYLE=[BACKGROUND=colorfmt_sev. ]],hour='0-24 Hours' all='Total';
run;

/***graph3 driver gender *********************************************************/
proc sql;
select distinct a_index from kk.veh_acc;
quit;
proc freq data=kk.veh_acc;
table ageband_driver sex_driver/list missing nocum;
run;
data kk.veh_acc1;
set kk.veh_acc;
if (ageband_driver='-1') or (sex_driver in ('-1','3')) then delete;
run;

proc sql;
create table kk.veh_acc2 as select ageband_driver, sex_driver, a_index, flag_sev
from kk.veh_acc1
group by ageband_driver, sex_driver,a_index
order by ageband_driver, sex_driver, a_index, flag_sev desc;
quit;

data kk.veh_acc3;
set kk.veh_acc2;
by ageband_driver sex_driver a_index;
if first.a_index  ;
run;

proc sql;
create table kk.graph3_vehacc as 
select ageband_driver, sex_driver, count(a_index) as number_of_accident, sum(flag_sev) as number_of_severity from kk.veh_acc3
group by 1, 2;
quit;
proc sgplot data=kk.graph3_vehacc;
vbar Ageband_driver /group=sex_driver groupdisplay=cluster response=number_of_accident;
vline ageband_driver/group=sex_driver response= number_of_severity;
run;

/***Graph4 casualty *****************************************************/
/***join three tables****************************************************/
proc sql;
create table kk.cas_acc_veh as select 
a.Cas_Ref, a.Cas_Class, a.Sex_Cas, a.Age_Cas, a.AgeBand_Cas, a.Cas_Severity, a.Ped_Location, a.Ped_Mvmt,
a.Car_Psger, a.BusCoach_Psger, a.Ped_Worker, a.Cas_Type, a.Cas_HomeAType, b.* from kk.cas_5 as a left join kk.veh_acc as b
on a.A_index = b.A_index and a.veh_ref=b.veh_ref;
quit;

proc freq data=kk.cas_acc_veh;
table cas_class car_psger buscoach_psger cas_type  road_type /missing list nocum;
run;

data kk.cas_acc_veh1;
set kk.cas_acc_veh;
if cas_severity= '1' then flag_fatal=1;
else flag_fatal=0;
if road_type = '9' then delete;
run;

proc sql;
create table KK.graph4_RTCAS AS
select road_type, cas_class, count(cas_ref) as number_of_casualty, sum(flag_fatal)as number_of_death from kk.cas_acc_veh1
group by road_type, cas_class;
quit;

proc freq data=kk.acc_5;
table road_type/list missing;
run;

proc sgplot data=kk.graph4_rtcas;
vbar road_type /group=cas_class groupdisplay=cluster response=number_of_casualty;
vline road_type /group=cas_class response= number_of_death;
run;
/***Graph5 location accident***********************************************************/
/*** get unique city table**********************************************/
proc freq data=kk.location;
table city LSOA/list missing;
run;
proc sort data=kk.location out=kk.location1;
by LSOA;
run;
data kk.city;
set kk.location1;
by LSOA;
IF first.LSOA;
RUN;
proc freq data=kk.acc_5;
table LSOA/list missing nocum;
run;
/***merge city and acc tables*******************************************************************/
proc sql;
create table kk.city_acc as
select a.*, b.city from kk.acc_year as a left join kk.city as b
on a.LSOA=b.LSOA;
QUIT;

data kk.city_acc1;
set kk.city_acc;
if city='' or LSOA='' then delete;
run;

proc sql;
create table kk.city_acc2 as 
select year, city, count(a_index) as number_of_accident, sum(flag_sev) as number_of_severity from kk.city_acc1
group by year, city;
quit;

proc freq data=kk.city;
table city/list missing nocum;
run;

data kk.city_acc3;
set kk.city_acc2;
acc_ratio=round(number_of_severity/number_of_accident, .01);
run;

/***to calcuation location casaulty ******************************************************************/
/*** join accident casualty two tables together**********************************/


proc sql;
create table kk.loc_cas as select a.*, b.city from kk.cas_acc_veh1 as a left join kk.city as b
on a.LSOA=b.LSOA;
QUIT;

data kk.loc_cas1;
set kk.loc_cas;
if city=''  then delete;
run;
proc sql;
create table kk.loc_cas2 as select year, city, count(cas_ref) as number_of_casualty, sum(flag_fatal) as number_of_death from kk.loc_cas1
group by 1, 2;
quit;
/***join loc_cas2 and city_acc3 two tables************************************/

proc sql;
create table kk.graph5_loc as select a.*, b.* from kk.city_acc3 as a left join kk.loc_cas2 as b
on a.year=b.year and a.city=b.city;
quit;

proc sort data=kk.graph5_loc out=kk.loc_cas3;
by year descending number_of_accident;
run;
data kk.graph5_f;
set kk.loc_cas3;
by year ;
if first.year then total=0;
total+1;
if total<=5 then output;
run;

/***Graph6 special condition comparion, weather surface road*********************************/
