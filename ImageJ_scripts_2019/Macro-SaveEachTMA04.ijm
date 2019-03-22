// Macro for saving each TMA from montage
// Jerry Lin 2017/07/21

myDIR = getDirectory("Z:\\data\\RareCyte\\MELANOMATMA\\");
myName = getString("Please enter the file name","test1");
cycles = getNumber("Pease enter how many cycles in the images:",10);
startn = getNumber("Please enter initial number:",1);

//myCyc = "Cycle3";

counts=roiManager("count");
for(i=0; i<counts; i++) {
    roiManager("Select", i);
    run("Duplicate...", "title="+myName+"-"+(i+1)+" duplicate");
    run("Stack to Hyperstack...", "order=xyczt(default) channels=4 slices="+cycles+" frames=1 display=Composite");
	Stack.setDisplayMode("color");
	Stack.setChannel(1);
	run("Blue");
	Stack.setChannel(2);
	run("Green");
	Stack.setChannel(3);
	run("Grays");
	Stack.setChannel(4);
	run("Red");
	Stack.setDisplayMode("composite");
    run("Save", "save="+myDIR+myName+"-"+(i+startn)+".tif");
    run("Close");
}
