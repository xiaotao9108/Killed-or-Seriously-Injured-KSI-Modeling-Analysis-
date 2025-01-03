proc sql noprint;
select name into:class_var separated by " "
from dictionary.columns
where upcase(libname)="F" and upcase(memname)="TRAIN2" and upcase(type)="CHAR";
quit;

%put &class_var;

%let class_var= Day_of_Week  _1st_Road_Class
Road_Type  Junction_Control _2nd_Road_Class ped_cross_phy_fac Light_Conditions
Weather_Conditions Road_Surface_Conditions Special_Conditions_at_Site Urban_or_Rural_Area
 Skidding_and_Overturning Vehicle_Leaving_Carriageway _1st_Point_of_Impact  Sex_of_Driver
Age_Band_of_Driver Propulsion_Code Driver_Home_Area_Type time_band;


/*build model*/
proc freq data=f.train2;
table ksi;
run;

ods trace on;
proc logistic data=f.train2 desc namelen=40;
class &class_var;
model ksi= &class_var &reduced2/selection=backward fast ;
run;
ods trace off;


ods output  ParameterEstimates=paraest;
proc logistic data=f.train2 desc namelen=40  ;
class &class_var;
model ksi=&class_var  &reduced2/selection=backward fast  ;
run;
ods output close;


data f.paraest;
set paraest;
where ProbChiSq<.05;
run;


proc sql noprint;
select distinct variable into:selected separated by " "
from f.paraest;
quit;



proc sql noprint;
select distinct variable into:char separated by " "
from f.paraest a
where a.variable in (select name from dictionary.columns 
					where upcase(libname)="F" and
					upcase(memname)="TRAIN2" and
					upcase(type)="CHAR");
quit;

%put &selected;


ods output ParameterEstimates=f.para_betas;
proc logistic data=f.train2 desc outest=betas namelen=40 ;
class &char;
model ksi= &selected;
run;
ods output close;

proc sql;
select count(distinct variable) as count 
from f.para_betas
where ProbChiSq<.05;
quit;



/*model formula*/
data f.paraest2;
set f.para_betas;
where ProbChiSq<0.05;
if not missing (ClassVal0) then var= compress(variable||"= ' "||ClassVal0||" '");
else var= variable;
run;

proc sql noprint;
select  "( "||compress(var)||" )"||"*"||trim(left(put(Estimate,D8.)))  into:formula separated by " + "
from f.paraest2;
quit;

%put &formula;







/*validate model*/
/*same proformance with stepwise and forward*/
proc sql;
select distinct variable  
from f.para_betas
where variable contains "_clus_" and ProbChiSq<.05;
quit;

data f.validate2;
set f.validate;
JD_clus_1= ( Junction_Detail in ("& JD_clus_1") );
VM_clus_1= ( Vehicle_Manoeuvre in ("&VM_clus_1") );
VM_clus_2= ( Vehicle_Manoeuvre in ("&VM_clus_2") );
VM_clus_3= ( Vehicle_Manoeuvre in ("&VM_clus_3") );
VM_clus_4= ( Vehicle_Manoeuvre in ("&VM_clus_4") );
VM_clus_5= ( Vehicle_Manoeuvre in ("&VM_clus_5") );
VM_clus_7= ( Vehicle_Manoeuvre in ("&VM_clus_7") );
VM_clus_8= ( Vehicle_Manoeuvre in ("&VM_clus_8") );
VM_clus_9= ( Vehicle_Manoeuvre in ("&VM_clus_9") );
VT_clus_1= ( Vehicle_Type in ("&VT_clus_1") );
VT_clus_2= ( Vehicle_Type in ("&VT_clus_2") );
VT_clus_5= ( Vehicle_Type in ("&VT_clus_5") );
VT_clus_6= ( Vehicle_Type in ("&VT_clus_6") );
JL_clus_4= ( Junction_Location in ("&JL_clus_4") );
JL_clus_5= ( Junction_Location in ("&JL_clus_5") );
run;

proc sql noprint;
select distinct variable into:selected separated by " "
from f.para_betas
where ProbChiSq<.05;
quit;



proc sql noprint;
select distinct variable into:char separated by " "
from f.para_betas a
where a.variable in (select name from dictionary.columns 
					where upcase(libname)="F" and
					upcase(memname)="TRAIN2" and
					upcase(type)="CHAR");
quit;

%put &selected;

%let selected=Age_of_Driver Age_of_Vehicle Day_of_Week Driver_Home_Area_Type  JD_clus_1 JL_clus_4
JL_clus_5 Junction_Control Light_Conditions Location_Easting_OSGR Location_Northing_OSGR
Road_Surface_Conditions Road_Type Sex_of_Driver Skidding_and_Overturning
Special_Conditions_at_Site Speed_limit Urban_or_Rural_Area VM_clus_1 VM_clus_2 VM_clus_3 VM_clus_4
VM_clus_5 VM_clus_7 VM_clus_8 VM_clus_9 VT_clus_1 VT_clus_2 VT_clus_5 VT_clus_6
Vehicle_Leaving_Carriageway Weather_Conditions _1st_Point_of_Impact _1st_Road_Class
_2nd_Road_Class ped_cross_phy_fac time_band
;

%put &char;

proc logistic data=f.validate2 desc inest=betas plots=none;
class &char;
model ksi= &char &selected/maxiter=0  outroc=roc ;
run;


proc gplot data=roc;
plot _SENSIT_*_1MSPEC_;
run;
quit;

data roc1;

   set roc;

   cutoff=_PROB_*&pi1*(1-&rho1)/(_PROB_*&pi1*(1-&rho1)+

          (1-_PROB_)*(1-&pi1)*&rho1);

   specif=1-_1MSPEC_;

   tp=&pi1*_SENSIT_;

   fn=&pi1*(1-_SENSIT_);

   tn=(1-&pi1)*specif;

   fp=(1-&pi1)*_1MSPEC_;

   depth=tp+fp;

   pospv=tp/depth;

   negpv=tn/(1-depth);

   acc=tp+tn;

   lift=pospv/&pi1;

   keep cutoff tn fp fn tp _SENSIT_ _1MSPEC_ specif depth

        pospv negpv acc lift;

run;


proc gplot data=roc1;
plot lift*depth;
run;
quit;




