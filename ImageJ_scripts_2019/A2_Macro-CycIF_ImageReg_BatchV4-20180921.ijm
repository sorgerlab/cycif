// Batch Image registration for t-CyCIF images (from RareCyte) 
// 2018.06.07 Jerry Lin

// Need Macro-SaveTiffxx.ijm for processing RPCNL files
// Import slide CSV files

//Bug fixed:  allow different cycle numbers for batch processing

pathfile=File.openDialog("Choose the file to Open:"); 
filestring=File.openAsString(pathfile); 
rowdata=split(filestring, "\n"); 				//read all file row by row
startn = getNumber("Please input the start slide no:",1);
//endn = getNumber("Please input the end slide no:",10);

NumberofSlide = rowdata.length-1;

endn = getNumber("Please input the end slide no:",NumberofSlide);

slideName=newArray(NumberofSlide); 
slideDir=newArray(NumberofSlide); 
rows=newArray(NumberofSlide);
cols=newArray(NumberofSlide);


for(i=1; i<rowdata.length; i++){ 
	columns=split(rowdata[i],","); 
	slideName[i-1] = columns[0];
	slideDir[i-1]=columns[1];
	cols[i-1]= parseInt(columns[2]);
	rows[i-1]= parseInt(columns[3]); 
	cs = parseInt(columns[4]);
	ce = parseInt(columns[5]);
} 

totalslide = slideName.length;

for(i=startn-1;i<slideName.length;i++){
	print(slideName[i]+" "+slideDir[i]+" "+cols[i]+" "+rows[i]);
}

waitForUser( "Pause","Press Ok to start registration");

totalslide = slideName.length;

startT = getTime;

for(slide =startn-1;slide<endn;slide++){

myDIR = slideDir[slide]+"\\";
myName = slideName[slide];
myName = myName+"-";
myframe = cols[slide]*rows[slide];

//setBatchMode(true);

//---------- Main loop --> processing frame by frame----------------
sf = 1;

for(f=sf; f<=myframe;f++){		//loop: frame

// Open files
for(c=cs;c<=ce;c++){		//loop: cycle

if(c<10){
	open(myDIR+"Cycle0"+c+"\\"+myName+f+".tif");
}else{
	open(myDIR+"Cycle"+c+"\\"+myName+f+".tif");
}

run("Split Channels");
}		//loop: cycle
	  

//------ Main section for Registration----------
print ("Regitration:"+myName+f+".tif");

run("Images to Stack", "name=DAPI title=C1-"+myName+" use");
run("Images to Stack", "name=FITC title=C2-"+myName+" use");
run("Images to Stack", "name=Cy3 title=C3-"+myName+" use");
run("Images to Stack", "name=Cy5 title=C4-"+myName+" use");

selectWindow("DAPI");

run("Duplicate...", "title=Mask duplicate");

// new modula to skip registration for low nuclei regions

run("Duplicate...", "title=test1 duplicate slices=1");
selectWindow("test1");
run("Select All");
getStatistics(area, mean);
run("Select None");
close();


// multistackreg

if(mean>200){
	print("Processing multistack registartion....");
	selectWindow("Mask");
	run("Subtract Background...", "rolling=20 disable stack");
	run("Enhance Contrast...", "saturated=1 normalize process_all");
	run("MultiStackReg", "stack_1=Mask action_1=Align file_1="+myDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");

	selectWindow("DAPI");
	run("MultiStackReg", "stack_1=DAPI action_1=[Load Transformation File] file_1="+myDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
	selectWindow("FITC");
	run("MultiStackReg", "stack_1=FITC action_1=[Load Transformation File] file_1="+myDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
	selectWindow("Cy3");
	run("MultiStackReg", "stack_1=Cy3 action_1=[Load Transformation File] file_1="+myDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
	selectWindow("Cy5");
	run("MultiStackReg", "stack_1=Cy5 action_1=[Load Transformation File] file_1="+myDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
}

selectWindow("Mask");
close();

// Restacking & save tiff file

run("Merge Channels...", "c1=DAPI c2=FITC c3=Cy3 c4=Cy5 create");

setSlice(1);
run("Blue");
setSlice(2);
run("Green");
setSlice(3);
run("Grays");
setSlice(4);
run("Red");

saveAs("Tiff", myDIR+myName+f+".tif");
print ("Save:"+myDIR+myName+f+".tif");
run("Close All");

print ("processing:"+myName+"-"+f+" time ="+(getTime-startT)/1000);
}	//loop:frame

}  //loop:slides
