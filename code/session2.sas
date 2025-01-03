/*use ACCIDENT and VEHICLES*/
/*except Number_of_Casualties*/
proc sql;
create table f.acc_veh(where=( accident_index is not missing) 
rename=(Pedestrian_Crossing_Human_Contro=ped_cross_h_con
Pedestrian_Crossing_Physical_Fac=ped_cross_phy_fac
Vehicle_Location_Restricted_Lane=veh_loc_res_lane )) as
select a.*,b.* 
from f.accident a right join f.vehicles b
on a.accident_index=b.accident_index
;
quit;
/* delete engine capacity=-1 and transform the rest obs into log()*/
proc sql;
select count(*) as count
from acc_veh3
where  Engine_Capacity__CC_=-1;
quit;





/*time band*/
ods trace on;
proc univariate data=f.acc_veh;
var time;
run;
ods trace off;


ods output Quantiles=f.time_check;
proc univariate data=f.acc_veh;
var time;
run;
ods output close;

data f.time_check;
set f.time_check;
time=put(estimate, time5.3);
run;


proc freq data=f.acc_veh;
table Driver_Home_Area_Type;
run;


proc logistic data=f.acc_veh desc;
class Driver_Home_Area_Type;
model KSI_target=Driver_Home_Area_Type;
run;



/*age of veh*/
proc univariate data=f.acc_veh;
var  Age_of_Vehicle;
run;

proc freq data=f.acc_veh2;
table Age_of_Vehicle;
run;

proc logistic data=f.acc_veh desc;
model KSI_target=Age_of_Vehicle;
run;




/*find all char var*/
proc sql ;
describe table dictionary.columns;quit;

proc sql feedback;
select name into: char_list separated by " "
from dictionary.columns
where upcase(libname)="F" and upcase(memname)="ACC_VEH2" and upcase(type)="CHAR";
quit;

%put &char_list;

proc freq data=f.acc_veh2;
table &char_list/missing list;
run;


/*find all num var*/
proc sql feedback;
select name into: num_list separated by " "
from dictionary.columns
where upcase(libname)="F" and upcase(memname)="ACC_VEH" and upcase(type)="NUM";
quit;

%put &num_list;

proc means data=f.acc_veh;
var &num_list;
run;


data f.acc_veh2;
set f.acc_veh(drop=Accident_Index Accident_Severity Number_of_Casualties
 Vehicle_Reference
Did_Police_Officer_Attend_Scene_  year LSOA_of_Accident_Location);

where speed_limit not in (0 10) and
Engine_Capacity__CC_ ne -1 and 
0<=Age_of_Vehicle<=50 and
junction_detail ne "-1" and
Hit_Object_off_Carriageway ne "-1" and
Journey_Purpose_of_Driver ne "-1" and
sex_of_driver ne "-1" and 
  ped_cross_h_con ne "-1" and 
   ped_cross_phy_fac ne "-1" and 
    Road_Surface_Conditions ne "-1" and 
	 Special_Conditions_at_Site ne "-1" and
	  Carriageway_Hazards ne "-1" and 
Vehicle_Type ne "-1" and  Towing_and_Articulation ne "-1"
and  Vehicle_Manoeuvre ne "-1" and  veh_loc_res_lane ne "-1" and 
 Junction_Location ne "-1" and  Skidding_and_Overturning ne "-1" and 
  Hit_Object_in_Carriageway ne "-1" and 
 Vehicle_Leaving_Carriageway ne "-1" and 
  _1st_Point_of_Impact ne "-1" and 
   Was_Vehicle_Left_Hand_Drive_ ne "-1";
   run;

/*missing indicator*/
%let list=junction_control 
_2nd_Road_Class
Road_Surface_Conditions 
age_band_of_driver
Driver_Home_Area_Type
;

%put &list;

%let mi_list=%sysfunc(prxchange(s/(\w+)/mi_$1/,-1,&list));

%put &mi_list;


data f.acc_veh2_mi(drop=i);
set f.acc_veh2;
array m(*) &mi_list;
array l (*) &list;
do i=1 to dim(m);
	m(i)=(l(i)="-1");
end;
run;


proc univariate data=f.acc_veh2_mi;
var age_of_driver;
run;




/*derive variable time_band month Engine_Capacity*/
data f.acc_veh3 (drop= time date  _1st_Road_Number _2nd_Road_Number Driver_IMD_Decile
Engine_Capacity__CC_ rename=(ksi_target=ksi) );  
set f.acc_veh2_mi;
if time<'8:00't then time_band="before 8:00";
else if '8:00't<=time<'10:00't then time_band="8:00-10:00";
else if '10:00't<=time<'15:00't then time_band="10:00-15:00";
else if '15:00't<=time<='18:00't then time_band="15:00-18:00";
else time_band="after 18:00";
month=month(date);
Engine_Capacity=log(Engine_Capacity__CC_);
run;





proc univariate data=f.acc_veh3;
var Engine_Capacity;
run;

proc logistic data=f.acc_veh3 desc;
model KSI_target=Engine_Capacity;
run;

proc freq data=acc_veh3;
where ksi_target="1";
table time_band;
run;


proc logistic data=acc_veh3;
class time_band;
model KSI_target=time_band;
run;


/*split into TRAIN and VALIDATE*/
proc means data=f.acc_veh3 noprint;
var ksi;
output out=sum mean=rho1;
run;

data _null_;
set sum;
call symput("rho1",rho1);
call symput("pi1",rho1);
run;
%put &rho1 &pi1;

data f.train(drop=u) f.validate(drop=u);
set f.acc_veh3;
u=ranuni(200);
if u<=.7 then output f.train;
else output f.validate;
run;








