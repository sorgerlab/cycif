//Read color stack/hyperstack & quantification
//20161219 Jerry Lin
//Need preprocessed/registrated tif files


//Initialization 

//startimg = 1;			// begin of fram
//endimg = 238;		// end of frame
maskch = 7;			//cycle of DAPI for generating mask
startT = getTime;

myDIR = getString("Enter the image directory","C:\\rcpnl\\shaolin-tonsil\\tonsil1\\");
myName = getString("Enter file header:","Tonsil1");
startimg= getNumber("Enter starting image:",1);
totalimage = getNumber("Enter number of images:",238);
channels=getNumber("Enter number of channels:",40);
maskch = getNumber("Enter cycle for mask:",7);
ensize = getNumber("Enter size for enlarge ROIs(3 for 10x and 6 for 40x images):",3);

//myName = getTitle;

setBatchMode(true);

for(img =startimg;img<=totalimage;img++){ 	//loop:img

open(myDIR+myName+"-"+img+".tif");

//break color hyperstack into stack

rename("temp");
run("Split Channels");
selectWindow("C1-temp");
run("Stack to Images");
selectWindow("C2-temp");
run("Stack to Images");
selectWindow("C3-temp");
run("Stack to Images");
selectWindow("C4-temp");
run("Stack to Images");
run("Images to Stack", "name=Stack title=-temp use");
run("Grays");

rename(myName+"-"+img);
print ("processing:"+myName+"-"+img+" time ="+(getTime-startT)/1000);


// Generate Mask/ROI
setSlice(maskch);
run("Duplicate...", "title=MASK");
run("Subtract Background...", "rolling=10 disable");
run("Subtract...", "value=1500");
//setOption("BlackBackground", false);
run("Make Binary");
run("Watershed");
roiManager("Deselect");
run("Analyze Particles...", "size=20-400 circularity=0.20-1.00 exclude clear include add");

// enlarge ROI 

selectWindow("MASK");
run("Out [-]");
run("Out [-]");

counts=roiManager("count");
for(i=0; i<counts; i++) {
    roiManager("Select", i);
    run("Enlarge...", "enlarge="+ensize+" pixel");
    roiManager("Update");
}

print ("Measuring:"+myName+"-"+img+" time ="+(getTime-startT)/1000);

roiManager("Deselect");
selectWindow("MASK");
close();

//Measure multi-stack

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
setBatchMode(false);
