// Single-site registration (tiff files) for Mike
// 20190412 Jerry Lin

myPath = getDirectory("Please choose the image directory");
myCycle = getNumber("Please enter how many cycles/images:",2);
myCh  = getNumber("Please enter how many channels per image:",3);
maskCh = getNumber("Which channel will you use for registration:",1);
myName = getString("Please enter the output file name:","test1");

//-------Open images and split channels------
for(cy=1;cy<=myCycle;cy++){
	open(myPath+"Cycle"+cy+".tif");
	run("Stack to Images");
}

//----------reassemly the stacks-----------
for(ch=1;ch<=myCh;ch++){
	run("Images to Stack", "name=ch"+ch+" title=-000"+ch+" use");
}

//--------registration--------
selectWindow("ch"+maskCh);
run("Duplicate...", "title=mask duplicate");
selectWindow("mask");
run("MultiStackReg", "stack_1=mask action_1=Align file_1="+myPath+"\\reg1.txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");
selectWindow("mask");
run("Close");

for(ch=1;ch<=myCh;ch++){
	selectWindow("ch"+ch);
	run("MultiStackReg", "stack_1=ch"+ch+" action_1=[Load Transformation File] file_1="+myPath+"\\reg1.txt stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
}

//-----Create composite and save image-----

if(myCh==3){
	run("Merge Channels...", "c1=ch1 c2=ch2 c3=ch3 create ignore");
	rename(myName);
	setSlice(1);
	run("Blue");
	setSlice(2);
	run("Green");
	setSlice(3);
	run("Red");
	run("Save", "save="+myPath+"\\"+myName+".tif");
}else if(myCh==2){
	run("Merge Channels...", "c1=ch1 c2=ch2 create ignore");
	rename(myName);
	setSlice(1);
	run("Blue");
	setSlice(2);
	run("Red");
	run("Save", "save="+myPath+"\\"+myName+".tif");
}else{
	print("Unable to create composite image");
}

