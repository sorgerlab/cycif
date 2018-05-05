// script for merge CycIF imaging & measure single-cell data from InCell
// Jerry 2018/03/20
// Cytosol/Ring measurement

// Initialization

row = newArray(" ","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R");

path = getDirectory("Select the image directory");
path = path+"\\";

sR = getNumber("Please enter initial row:",1);
eR = getNumber("Please enter final row:",12);
sC = getNumber("Please enter inital column:",1);
eC = getNumber("Please enter final column:",20);
maxF = getNumber("Please enter max frame:",4);
bs = getNumber("Please enter cytosol expand pixel:",2);
maxCy = getNumber("Please enter max cycle:",7);

channels=maxCy*4;

startT = getTime;

// loop through all wells/sites

for (r=sR;r<=eR;r++)		//row array
{
for (c=sC;c<=eC;c++)		//column array
{
for (f=1;f<=maxF;f++)		//field
{

// Close previous images
while (nImages>0) {
          selectImage(nImages);
          close();
}
if (isOpen("ROI Manager")) {
      selectWindow("ROI Manager");
      run("Close");
}

// Convert field & column to string

if(maxF<10){
	ff = ""+f;
}else if(maxF<100){
	ff = ""+f;
	while(lengthOf(ff)<2) {ff = "0"+ff;}
}else {
	ff = ""+f;
	while(lengthOf(ff)<3) {ff = "0"+ff;}
}

if(eC<10){
	cc = ""+c;
}else if(eC<100){
	cc = ""+c;
	while(lengthOf(cc)<2) {cc = "0"+cc;}
}else {
	cc = ""+c;
	while(lengthOf(cc)<3) {cc = "0"+ff;}
}
rr = row[r];

// Open all images for each cycle

filename = rr+" - "+cc+"(fld "+ff+" wv Blue - FITC).tif";

print ("-------------------------");
if(File.exists(path+"Cycle1\\"+filename)){

print("Processing:"+filename);
	
for (Cy=1; Cy<=maxCy; Cy++){
run("Image Sequence...", "open=["+path+"Cycle"+Cy+"\\A - 03(fld 01 wv Blue - FITC).tif] file=["+rr+" - "+cc+"(fld "+ff+"] sort");
run("Subtract Background...", "rolling=50 stack");
run("Stack to Images");
}

run("Images to Stack", "name=DAPI title=DAPI");
run("Images to Stack", "name=FITC title=FITC");
run("Images to Stack", "name=Cy3 title=dsRed");
run("Images to Stack", "name=Cy5 title=Cy5");

// Registration (multistackReg)

selectWindow("DAPI");
run("MultiStackReg", "stack_1=DAPI action_1=Align file_1="+path+"reg1.txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");
run("MultiStackReg", "stack_1=FITC action_1=[Load Transformation File] file_1="+path+"reg1.txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
run("MultiStackReg", "stack_1=Cy3 action_1=[Load Transformation File] file_1="+path+"reg1.txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
run("MultiStackReg", "stack_1=Cy5 action_1=[Load Transformation File] file_1="+path+"reg1.txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");

// Generate mask & ROIs
selectWindow("DAPI");
run("Z Project...", "projection=[Min Intensity]");
run("Gaussian Blur...", "sigma=4");
run("Unsharp Mask...", "radius=4 mask=0.90");
rename("MASK");
setAutoThreshold("Li dark");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=20-250 circularity=0.10-1.00 show=[Count Masks] clear include add in_situ");

selectWindow("MASK");
saveAs("Tiff", path+"mask-"+rr+cc+"_fld"+ff+".tif");
close();

// Generate merge image stack
selectWindow("DAPI");
run("Stack to Images");
selectWindow("Cy3");
run("Stack to Images");
selectWindow("Cy5");
run("Stack to Images");
selectWindow("FITC");
run("Stack to Images");

imagename=rr+cc+"_fld"+ff;
run("Images to Stack", "name="+imagename+" title=[] use");

run("Clear Results");


//Nuclear measurement
run("Set Measurements...", "area mean standard min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display add redirect=None decimal=3");
setSlice(1);
roiManager("Measure");

for (i=1;i<channels;i++)		//measure each frames (expect the first frame)
{
run("Next Slice [>]");
roiManager("Measure");
}

saveAs("Results", path+"Results-Nuc-"+imagename+".txt");
run("Clear Results");
print("Measuring Nucleus: Well ",rr,"-",cc,"-",ff," finished:",(getTime-startT)/1000);

// Cytosol measurment
open(path+"mask-"+imagename+".tif");
rename("MASK");
selectWindow("MASK");

counts=roiManager("count");
for(i=0; i<counts; i++) {
    roiManager("Select", i);
    run("Make Band...", "band="+bs);
    roiManager("Update");
}
close();

roiManager("Deselect");
selectWindow(imagename);

setSlice(1);
roiManager("Measure");

for (i=1;i<channels;i++)		//measure each frames (expect the first frame)
{
run("Next Slice [>]");
roiManager("Measure");
}

saveAs("Results", path+"Results-Cyto-"+imagename+".txt");
run("Clear Results");
print("Measuring Cytosol: Well ",rr,"-",cc,"-",ff," finished:",(getTime-startT)/1000);


//Save mutliplexed image

selectWindow(imagename);
run("Stack to Hyperstack...", "order=xyzct channels="+channels+" slices=1 frames=1 display=Grayscale");
saveAs("Tiff", path+imagename+".tif");

run("Close");


}else{
	print(filename+" not exist...");
} //if (file exist)

} //for f
} //for c
} //for r


