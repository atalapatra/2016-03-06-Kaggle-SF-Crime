* Set library;
libname sd160306 "C:\Users\Amit\OneDrive\1 - GWU MSBA\DNSC 6279 Data Mining\Kaggle Project\SF Data" ;

* Load datasets from csv and save to library;
proc import datafile="C:\Users\Amit\OneDrive\1 - GWU MSBA\DNSC 6279 Data Mining\Kaggle Project\SF Data\sampleSubmission.csv" 
	out=sampleSubmission dbms=dlm replace;
	delimiter=',';
	getnames=yes;
run;

data sd160306.sampleSubmission ;
	set sampleSubmission ;
run ;

proc import datafile="C:\Users\Amit\OneDrive\1 - GWU MSBA\DNSC 6279 Data Mining\Kaggle Project\SF Data\test.csv" 
	out=test dbms=dlm replace;
	delimiter=',';
	getnames=yes;
run;

data sd160306.test ;
	set test ;
run ;

proc import datafile="C:\Users\Amit\OneDrive\1 - GWU MSBA\DNSC 6279 Data Mining\Kaggle Project\SF Data\train.csv" 
	out=train dbms=dlm replace;
	delimiter=',';
	getnames=yes;
run;

data sd160306.train ;
	set train ;
run ;

* feature selection;
data sd160306.testmod;
	set sd160306.test;
	Year = year(datepart(Dates));
	Month = month(datepart(Dates));
	Hour = hour(Dates);
run;

data sd160306.trainmod;
	set sd160306.train;
	Year = year(datepart(Dates));
	Month = month(datepart(Dates));
	Hour = hour(Dates);
run;

proc freq sd160306.trainmod ;
	tables sd160306.trainmod / nlevels ;
run;
