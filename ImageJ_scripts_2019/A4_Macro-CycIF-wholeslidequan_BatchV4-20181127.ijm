//Batch quantification of t-CyCIF images V4
//2018.11.27 Jerry Lin
//Need preprocessed/registrated tif files

//Bug fixed:  allow different cycle numbers for batch processing
//Add feature: Save mask files
//Save both overlay masks & count masks

//-------------Initialization--------------------- 

pathfile=File.openDialog("Choose the file to Open:"); 
filestring=File.openAsString(pathfile); 
rowdata=split(filestring, "\n"); 				//read all file row by row

NumberofSlide = rowdata.length-1;

slideName=newArray(NumberofSlide); 
slideDir=newArray(NumberofSlide); 
rows=newArray(NumberofSlide);
cols=newArray(NumberofSlide);
css=newArray(NumberofSlide);
ces=newArray(NumberofSlide);

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

for(i=0;i<slideName.length;i++){
	print(slideName[i]+" "+slideDir[i]+" "+cols[i]+" "+rows[i]);
}
ss = getNumber("Enter start slide no:",1);
se = getNumber("Enter end slide no:",slideName.length);

// startimg = getNumber("Enter start image frame no:",1);		

waitForUser("Pause","Press Ok to start quantification");

startT = getTime;

startimg= 1; //start image for processing

run("Set Measurements...", "area mean standard min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display add redirect=None decimal=3");

run("Close All");

//--------------Main loop for all slides--------------

for(slide = ss-1; slide<se; slide++){

cs = css[slide];
ce = ces[slide];
channels= (ce-cs+1)*4; //total channels (=cycles*4)

totalimage = cols[slide]*rows[slide];
print("Total images ="+totalimage);

myDIR = slideDir[slide]+"\\";
myName = slideName[slide];	

for(img =startimg;img<=totalimage;img++){ 	//loop:img

open(myDIR+myName+"-"+img+".tif");

//-----------break color hyperstack into stack----------

rename("temp");
run("Split Channels");
selectWindow("C1-temp");
run("Remove Slice Labels");
run("Stack to Images");
selectWindow("C2-temp");
run("Remove Slice Labels");
run("Stack to Images");
selectWindow("C3-temp");
run("Remove Slice Labels");
run("Stack to Images");
selectWindow("C4-temp");
run("Remove Slice Labels");
run("Stack to Images");
run("Images to Stack", "name=Stack title=-temp use");
run("Grays");

rename(myName+"-"+img);
print ("processing:"+myName+"-"+img+" time ="+(getTime-startT)/1000);

//--------------Generate Mask ROI-------------------

run("Duplicate...", "title=maskstack duplicate range=1-"+channels/4);

selectWindow("maskstack");
run("Z Project...", "projection=[Min Intensity]");

rename("MASK");
selectWindow("MASK");
run("Unsharp Mask...", "radius=4 mask=0.80");
run("Subtract...", "value=1500");

run("Select All");
getStatistics(area, mean);
run("Select None");
selectWindow("MASK");
setAutoThreshold("Li dark");
run("Convert to Mask");
run("Close-");

if(mean > 50){
run("Watershed");
print("Performing Watershed");
}

selectWindow("maskstack");
close();

selectWindow("MASK");
roiManager("Deselect");
run("Analyze Particles...", "size=20-200 circularity=0.10-1.00 show=[Count Masks] exclude clear include add");

selectWindow("Count Masks of MASK");
saveAs("Tiff",myDIR+"HistoMask-"+myName+"-"+img+".tif");
close();

// enlarge ROI 
selectWindow("MASK");
run("Out [-]");

print ("Enlarging ROIs:"+myName+"-"+img+" time ="+(getTime-startT)/1000);

counts=roiManager("count");

selectWindow("MASK");
for(i=0; i<counts; i++) {
    roiManager("Select", i);
    run("Enlarge...", "enlarge=2 pixel");
    roiManager("Update");
}

print ("Measuring:"+myName+"-"+img+" time ="+(getTime-startT)/1000);

roiManager("Deselect");
selectWindow("MASK");

saveAs("Tiff",myDIR+"Mask-"+myName+"-"+img+".tif");
close();

//----------------Measure multi-stack------------------

run("Clear Results");
run("Set Measurements...", "area mean standard min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display add redirect=None decimal=3");
setSlice(1);
roiManager("Measure");
for (i=1;i<channels;i++)		//measure each frames (expect the first frame)
{
run("Next Slice [>]");
roiManager("Measure");
}
close();


saveAs("Results", myDIR+"Results-"+myName+"-"+img+".csv");
run("Clear Results");
run("Close All");

if(counts>0){
	roiManager("Delete");
} //if(count>0)

print ("Finishing:"+myName+"-"+img+" time ="+(getTime-startT)/1000);

}  //loop:img


} //loop:slide
