libname f "C:\Users\18144\OneDrive\Desktop\SAS\Project\202201-202202\2015-19 data\file";
data f.ACCIDENT ;
infile "C:\Users\18144\OneDrive\Desktop\SAS\Project\202201-202202\2015-19 data\car_accident\Accidents0515.csv"  MISSOVER DSD  firstobs=2;
input             Accident_Index :$15.
                Location_Easting_OSGR 
                Location_Northing_OSGR 
                  Longitude 
               Latitude 
                Police_Force  $
            Accident_Severity $
                Number_of_Vehicles 
                 Number_of_Casualties 
               Date :ddmmyy10.
               Day_of_Week $
                 Time  :time5.
                 Local_Authority__District_ $
                  Local_Authority__Highway_ :$10.
                 _1st_Road_Class $
                  _1st_Road_Number $
                Road_Type $
                Speed_limit 
             Junction_Detail $
                 Junction_Control $
                _2nd_Road_Class $
                 _2nd_Road_Number $
                Pedestrian_Crossing_Human_Contro $
                Pedestrian_Crossing_Physical_Fac $
              Light_Conditions $
            Weather_Conditions $
              Road_Surface_Conditions $
                 Special_Conditions_at_Site $
                 Carriageway_Hazards $
                 Urban_or_Rural_Area $
                  Did_Police_Officer_Attend_Scene_ $
                LSOA_of_Accident_Location :$15.     ;
*if date>='01JAN2013'd;
year=year(date);
if year>=2011;
if Accident_Severity in ("1" "2") then KSI_target=1;
else KSI_target=0;
format time time5.3;
run;

proc sql;
select count(distinct accident_index) as count
from accident;
quit;


proc freq data=accident ;
table year KSI_target Police_Force Accident_Severity Day_of_Week              
				Local_Authority__District_ 
                  Local_Authority__Highway_ 
                 _1st_Road_Class
                  _1st_Road_Number
                Road_Type Junction_Detail 
                 Junction_Control 
                _2nd_Road_Class 
                Pedestrian_Crossing_Human_Contro 
                Pedestrian_Crossing_Physical_Fac 
              Light_Conditions
            Weather_Conditions 
              Road_Surface_Conditions 
                 Special_Conditions_at_Site 
                 Carriageway_Hazards 
                 Urban_or_Rural_Area 
                  Did_Police_Officer_Attend_Scene_ 
                LSOA_of_Accident_Location  ;
run;

proc freq data=accident;
table LSOA_of_Accident_Location ;
run;



proc means data=accident min max;
var Number_of_Vehicles  Number_of_Casualties Speed_limit ;
where speed_limit ne 0;
run;

proc print data=accident;
where speed_limit=0;
run;


     data f.CASUALTIES    ;
    infile 'C:\Users\18144\OneDrive\Desktop\SAS\Project\202201-202202\2015-19 data\car_accident\Casualties0515.csv' 
delimiter = ',' MISSOVER DSD firstobs=2 ;
     input
                Accident_Index :$13.
               Vehicle_Reference $
               Casualty_Reference $
             Casualty_Class $
             Sex_of_Casualty $
             Age_of_Casualty 
              Age_Band_of_Casualty $
                Casualty_Severity $
                 Pedestrian_Location $
                 Pedestrian_Movement $
                Car_Passenger $
                Bus_or_Coach_Passenger $
              Pedestrian_Road_Maintenance_Work $
               Casualty_Type $
                Casualty_Home_Area_Type  $     ;
     run;




 data f.VEHICLES    ;
infile 'C:\Users\18144\OneDrive\Desktop\SAS\Project\202201-202202\2015-19 data\car_accident\Vehicles0515.csv' 
delimiter = ',' MISSOVER DSD lrecl=13106 firstobs=2 ;
input   Accident_Index :$13.
         Vehicle_Reference $
          Vehicle_Type $
          Towing_and_Articulation $
          Vehicle_Manoeuvre $
          Vehicle_Location_Restricted_Lane $
          Junction_Location $
         Skidding_and_Overturning $
          Hit_Object_in_Carriageway $
         Vehicle_Leaving_Carriageway $
          Hit_Object_off_Carriageway $
         _1st_Point_of_Impact $
         Was_Vehicle_Left_Hand_Drive_ $
          Journey_Purpose_of_Driver $
         Sex_of_Driver $
         Age_of_Driver 
         Age_Band_of_Driver $
         Engine_Capacity__CC_ 
        Propulsion_Code $
         Age_of_Vehicle 
         Driver_IMD_Decile $
         Driver_Home_Area_Type  $    ;  

run;

proc means data=vehicles min max mean ;
var  Age_of_Driver   Age_of_Vehicle  Engine_Capacity__CC_ ;
run;

proc freq data=vehicles;
table age_band_of_driver;
run;

proc freq data=vehicles;
table Vehicle_Manoeuvre ;
run;

proc freq data=vehicles ;
table            Towing_and_Articulation 
          Vehicle_Manoeuvre 
          Vehicle_Location_Restricted_Lane 
          Junction_Location 
         Skidding_and_Overturning 
          Hit_Object_in_Carriageway 
         Vehicle_Leaving_Carriageway 
          Hit_Object_off_Carriageway 
         _1st_Point_of_Impact 
         Was_Vehicle_Left_Hand_Drive_ 
          Journey_Purpose_of_Driver 
         Sex_of_Driver 
		Age_Band_of_Driver
		Driver_IMD_Decile 
         Driver_Home_Area_Type  ;
run;

proc sql;
select count(distinct Accident_Index) as count
from accident;
quit;



proc freq data=accident;
table Junction_Detail Junction_Control;
by year;
run;

proc sql;
select count(distinct Police_Force) as count
from accident;
quit;
 

proc freq data=accident;
table Police_Force;
run;
