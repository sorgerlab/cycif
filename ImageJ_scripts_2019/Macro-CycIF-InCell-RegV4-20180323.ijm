//script for InCell registration (slide, single-region)
//Jerry 2018/03/18


path = getDirectory("Select the image directory");
maxF = getNumber("Please enter max frame:",10);
maxCy = getNumber("Please enter max cycle:",5);
myName = getString("Please enter image name:","test1");


startT = getTime;

channels=maxCy*4;


for (f=1;f<=maxF;f++)		//field loop
{


//Convert field number to string
if(maxF<10){
	ff = ""+f;
}else if(maxF<100){
	ff = ""+f;
	while(lengthOf(ff)<2) {ff = "0"+ff;}
}else {
	ff = ""+f;
	while(lengthOf(ff)<3) {ff = "0"+ff;}
}

// Close previous images 
while (nImages>0) {
          selectImage(nImages);
          close();
}

if (isOpen("ROI Manager")) {
      selectWindow("ROI Manager");
      run("Close");
}

// Open images from each cycles

for (cy=1;cy<=maxCy;cy++)
{
run("Image Sequence...", "open=["+path+"Cycle"+cy+"\\A - 1(fld "+ff+" wv Green - dsRed).tif] file=[A - 1(fld "+ff+"] sort");
run("Stack to Images");
}

// Restack images by channels
run("Images to Stack", "name=DAPI title=DAPI");

run("Images to Stack", "name=FITC title=FITC");

run("Images to Stack", "name=Cy5 title=Cy5");

run("Images to Stack", "name=Cy3 title=dsRed");



// Registration
selectWindow("DAPI");
run("Duplicate...", "title=MASK duplicate");
selectWindow("MASK");
run("Subtract Background...", "rolling=10 disable stack");
run("Enhance Contrast...", "saturated=10 normalize process_all");

selectWindow("MASK");
run("MultiStackReg", "stack_1=MASK action_1=Align file_1="+path+"reg-"+ff+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");
selectWindow("DAPI");
run("MultiStackReg", "stack_1=DAPI action_1=[Load Transformation File] file_1="+path+"reg-"+ff+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
selectWindow("FITC");
run("MultiStackReg", "stack_1=FITC action_1=[Load Transformation File] file_1="+path+"reg-"+ff+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
selectWindow("Cy3");
run("MultiStackReg", "stack_1=Cy3 action_1=[Load Transformation File] file_1="+path+"reg-"+ff+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
selectWindow("Cy5");
run("MultiStackReg", "stack_1=Cy5 action_1=[Load Transformation File] file_1="+path+"reg-"+ff+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");

selectWindow("MASK");
close();

selectWindow("DAPI");
run("Stack to Images");
selectWindow("FITC");
run("Stack to Images");
selectWindow("Cy3");
run("Stack to Images");
selectWindow("Cy5");
run("Stack to Images");

run("Images to Stack", "name="+myName+"_fld"+ff+" title=[] use");
run("Stack to Hyperstack...", "order=xyzct channels="+channels+" slices=1 frames=1 display=Grayscale");


//Save mutliplexed image
saveAs("Tiff", path+myName+"-"+ff+".tif");
run("Close");

print("Processning:",ff," finisehd:",(getTime-startT)/1000);

} //for f


