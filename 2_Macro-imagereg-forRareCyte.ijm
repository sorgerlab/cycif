// Image registration for RareCyte 
// 20161221 Jerry Lin

// Need Macro-SaveTiffxx.ijm for processing RPCNL files

//Initialization
cs = getNumber("Please enter start Cycle:", 0);			//Start Cycle
ce = getNumber("Please enter end Cycle",12);		//End  Cycle
startT = getTime;

myDIR = getString("Please enter image directory:","F:\\Tonsil1\\");
myName = getString("Please enter image name","Tonsil1");
myName = myName+"-";
myframe = getNumber("Please enter total frames",196);
sf = getNumber("Please enter start frames",1);

setBatchMode(true);

//---------- Main loop --> processing frame by frame----------------

for(f=sf; f<=myframe;f++){		//loop: frame

// Open files
for(c=cs;c<=ce;c++){		//loop: cycle

open(myDIR+"Cycle"+c+"\\"+myName+f+".tif");
//run("16-bit");
//run("Subtract Background...", "rolling=50");
//print ("open file:"+myDIR+"Cycle"+c+"\\"+myName+f+".tif");
run("Split Channels");
}		//loop: cycle
	  

// Registration
print ("Regitration:"+myName+f+".tif");

run("Images to Stack", "name=DAPI title=C1-"+myName+" use");
run("Images to Stack", "name=FITC title=C2-"+myName+" use");
run("Images to Stack", "name=Cy3 title=C3-"+myName+" use");
run("Images to Stack", "name=Cy5 title=C4-"+myName+" use");

selectWindow("DAPI");

run("Duplicate...", "title=Mask duplicate");
run("Subtract Background...", "rolling=20 disable stack");
run("Enhance Contrast...", "saturated=1 normalize process_all");

run("MultiStackReg", "stack_1=Mask action_1=Align file_1="+myDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");

selectWindow("Mask");
close();

run("MultiStackReg", "stack_1=DAPI action_1=[Load Transformation File] file_1="+myDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");

run("MultiStackReg", "stack_1=FITC action_1=[Load Transformation File] file_1="+myDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");

run("MultiStackReg", "stack_1=Cy3 action_1=[Load Transformation File] file_1="+myDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");

run("MultiStackReg", "stack_1=Cy5 action_1=[Load Transformation File] file_1="+myDIR+"reg-"+f+".txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");

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
setBatchMode(false);

