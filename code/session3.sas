proc sql noprint;
select name into: char_list separated by " "
from dictionary.columns
where upcase(libname)="F" and upcase(memname)="TRAIN" and upcase(type)="CHAR";
quit;

%put &char_list;

proc freq data=f.train;
table &char_list;
run;


data f.train;
set f.train;
drop ped_cross_h_con   Carriageway_Hazards Towing_and_Articulation
 veh_loc_res_lane Hit_Object_in_Carriageway Hit_Object_off_Carriageway
 Was_Vehicle_Left_Hand_Drive_;

 run;







/*collapse the levels of categorical var based on its association with KSI*/
%macro clus (file, var, prefix);
proc means data=&file noprint nway;
class &var;
var ksi;
output out=levels mean=prop;
run;

ods output clusterhistory=f.cluster;

proc cluster data=levels method=ward outtree=fortree plots(maxpoints=380);
freq _freq_;
var prop;
id &var;
run;

ods output close;



proc freq data=&file noprint;
table &var*ksi/chisq;
output out=f.chi(keep=_pchi_) chisq;
run;

data f.cutoff;
if _n_=1 then set f.chi;
set f.cluster;
chisquare=_pchi_*rsquared;
degfree=NumberOfClusters-1;
logpvalue=logsdf('CHISQ',chisquare,degfree);
run;

proc plot data=f.cutoff;
plot logpvalue*NumberOfClusters/vpos=30;
run;


proc means data=f.cutoff noprint;
var logpvalue;
output out=f.small minid(logpvalue(numberofclusters))=ncl;
run;

data _null_;
set f.small;
call symput("ncl",ncl);
call symputx("ncl_var",ncl-1);
run;


proc tree data=fortree nclusters=&ncl out=f.clus h=rsq;
id &var;
run;

proc sql noprint;
select count (distinct cluster) into:n
from f.clus;
quit;

%do i=1 %to &n;
%global &prefix._clus_&i;
proc sql noprint;
select distinct &var  into:&prefix._clus_&i separated by  ' ","'
from f.clus
where cluster=input("&i",2.);
quit;
%end;

proc sort data=f.clus;
by clusname;
run;


proc print data=f.clus;
by clusname;
id clusname;
run;



data &file._2;
length cluster 3;
call missing (cluster);
if _n_=1 then do;
	declare hash C(dataset:'f.clus');
	C.definekey("&var");
	C.definedata('CLUSTER');
	C.definedone();
end;

set &file;
rc=C.find();
run;

data &file._3(drop=i cluster rc);
set &file._2;
array c (*) &prefix._clus_1-&prefix._clus_&ncl_var;
do i=1 to dim(c);
c(i)=(cluster=i);
end;
run;
%mend;

%clus (f.train, Vehicle_Manoeuvre, VM);
%clus (f.train_3, Vehicle_Type, VT);
%clus (f.train_3_3,  Junction_Detail, JD);
%clus (f.train_3_3_3,  Junction_Location, JL);



proc datasets lib=f;
change train_3_3_3_3=train2;
run;

/*VARIABLE CLUSTER*/
proc sql noprint;
select name into:num_select separated by " "
from dictionary.columns
where upcase(libname)="F" and upcase(memname)="TRAIN2" and upcase(type)="NUM";
quit;

%put &num_select;

%let num_select=Location_Easting_OSGR Location_Northing_OSGR Longitude Latitude  Speed_limit ksi
Age_of_Driver Age_of_Vehicle mi_junction_control mi__2nd_Road_Class mi_Road_Surface_Conditions
mi_age_band_of_driver mi_Driver_Home_Area_Type month Engine_Capacity VM_clus_1 VM_clus_2 VM_clus_3
VM_clus_4 VM_clus_5 VM_clus_6 VM_clus_7 VM_clus_8 VM_clus_9 VT_clus_1 VT_clus_2 VT_clus_3
VT_clus_4 VT_clus_5 VT_clus_6 JD_clus_1 JD_clus_2 JD_clus_3 JD_clus_4 JL_clus_1 JL_clus_2
JL_clus_3 JL_clus_4 JL_clus_5 JL_clus_6
;



ods trace on;

proc varclus data=f.train2 maxeigen=.7 outtree=fortree short;
var &num_select;
run;

ods trace off;

ods output ClusterQuality=summary  RSquare(match_all)=clusters;
proc varclus data=f.train2 maxeigen=.7 outtree=fortree short;
var &num_select;
run;
ods output close;


data _null_;
set summary;
call symput('ncl',trim(left(numberofclusters-2)));
run;

%put &ncl;


data clusters&ncl._2;
set clusters&ncl;
retain cluster_new;
if not missing(cluster) then cluster_new=cluster;
else cluster=cluster_new;
run;

proc sort data=clusters&ncl._2;
by cluster RSquareRatio NextClosest descending OwnCluster  ;
run;

data f.cluster_f;
set clusters&ncl._2;
by cluster RSquareRatio NextClosest descending OwnCluster  ;
if first.cluster;
run;

proc sql noprint;
select Variable into:reduced separated by " "
from f.cluster_f;
quit;




%put &reduced;
%let reduced=mi_junction_control VT_clus_6 JL_clus_5 JD_clus_1 VM_clus_1 Location_Easting_OSGR 
 Age_of_Vehicle VT_clus_5 VT_clus_2 Location_Northing_OSGR month VM_clus_7
Age_of_Driver JD_clus_4 VM_clus_8 VM_clus_5 VM_clus_9 Speed_limit JL_clus_6 JL_clus_2 VT_clus_1
VM_clus_3 VM_clus_2 JL_clus_4 JL_clus_1 mi_Driver_Home_Area_Type VT_clus_3 VM_clus_6 VM_clus_4
;




%macro test2;
%do i=1 %to 29;
data _null_;
test=scan(symget('reduced'),&i);
call symput("var1",test);
run;


proc freq data=f.train2 noprint;
table ksi*&var1./chisq;
output out=b pchi;
run;

data b2;
set b ;
var1="&var1";
run;

proc append data=b2 base=b_all force;run;

%end;
%mend;


%test2;

proc sql;
select var1 
from b_all
where P_PCHI>0.05;
quit;

%let reduced2=mi_junction_control VT_clus_6 JL_clus_5 JD_clus_1 VM_clus_1 Location_Easting_OSGR 
 Age_of_Vehicle VT_clus_5 VT_clus_2 Location_Northing_OSGR month VM_clus_7
Age_of_Driver JD_clus_4 VM_clus_8 VM_clus_5 VM_clus_9 Speed_limit JL_clus_2 VT_clus_1
VM_clus_3 VM_clus_2 JL_clus_4 JL_clus_1 mi_Driver_Home_Area_Type  VM_clus_6 VM_clus_4
;


