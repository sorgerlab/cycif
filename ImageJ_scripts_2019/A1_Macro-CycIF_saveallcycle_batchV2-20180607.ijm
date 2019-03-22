// Batch pre-processing script for t-CycIF, save individual tiffs
// 2018.06.07 Jerry Lin
//Import slide CSV files

//Bug fixed:  allow different cycle numbers for batch processing

pathfile=File.openDialog("Choose the file to Open:"); 
filestring=File.openAsString(pathfile); 
rowdata=split(filestring, "\n"); 				//read all file row by row
startn = getNumber("Please input start slide no:",1);
endn = getNumber("Please input end slide no:",5);
NumberofSlide = rowdata.length-1;

slideName = newArray(NumberofSlide); 
slideDir = newArray(NumberofSlide); 
rows = newArray(NumberofSlide);
cols = newArray(NumberofSlide);
css = newArray(NumberofSlide);
ces = newArray(NumberofSlide);

for(i=1; i<rowdata.length; i++){ 
	columns=split(rowdata[i],","); 
	slideName[i-1] = columns[0];
	slideDir[i-1]=columns[1];
	cols[i-1]= parseInt(columns[2]);
	rows[i-1]= parseInt(columns[3]); 
	css[i-1] = parseInt(columns[4]);
	ces[i-1] = parseInt(columns[5]);
} 

totalslide = slideName.length;

for(i=startn-1;i<slideName.length;i++){
	print(slideName[i]+" "+slideDir[i]+" "+cols[i]+" "+rows[i]);
}
ch = 4; //Please enter channels (physical)

totalslide = slideName.length;

startT = getTime;

//processing all slides

for(slide =startn-1;slide<endn;slide++){

myDIR2 = slideDir[slide]+"\\";
myname = slideName[slide];

setBatchMode(true);

cs = css[slide];
ce = ces[slide];

for(cyc = cs;cyc<=ce;cyc++){

print ("open file:"+myname+"__Cycle"+cyc+" time ="+(getTime-startT)/100);

//print("Now processing Cycle "+cyc+"....");

if(cyc <10){
	mycycle = "Cycle0"+cyc;
}else{
	mycycle = "Cycle"+cyc;
}

myDIR = myDIR2+mycycle+"\\";

run("Bio-Formats", "open="+myDIR2+mycycle+".rcpnl color_mode=Composite concatenate_series open_all_series view=Hyperstack stack_order=XYCZT");

//rname & making folder

rename(myname);
File.makeDirectory(myDIR);

// Background substraction & splitting channels

run("Subtract Background...", "rolling=50 sliding disable");
run("Flip Vertically");
name=getTitle;
print ("open file:"+myname+"__Cycle"+cyc+" time ="+(getTime-startT)/100);

// Making montage & save image

run("Make Montage...", "columns="+cols[slide]+" rows="+rows[slide]+" scale=0.20 increment=1 border=0 font=12");
rename("Montage-"+myname+"-"+mycycle);
run("Save", "save="+myDIR2+"Montage-"+myname+"-"+mycycle+".tif");
close();


//---------------------------------START SAVING TIF FILES-----------------------

selectWindow(myname);
name = getTitle;
n = nSlices;
//ch =4;

j=1;
for(i=1;i<n; i=i+ch){
	selectWindow(name);
	setSlice(i);
	print("current Cycle "+cyc+" slice ="+i);
	run("Duplicate...", "title="+name+"-"+j);
	run("Save", "save="+myDIR+name+"-"+j+".tif");
	selectWindow(name+"-"+j+".tif");
	run("Close");
	j++;
} //end i;

close();
print ("Saving image files:"+myname+"__Cycle:"+cyc+" time ="+(getTime-startT)/1000);
}  //end cyc;

setBatchMode(false);
} //loop slide