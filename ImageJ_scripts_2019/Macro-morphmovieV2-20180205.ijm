//Generate morphing movie
//Jerry Lin 2016/12/18


//----------Initialization---------

cycles = getNumber("Please input cycles:",10);
steps = getNumber("Please input steps for each cycle:",15);
chs = 4;

startT = getTime;


pathfile=File.openDialog("Choose the label/csv file to Open:"); 
filestring=File.openAsString(pathfile); 
rowdata=split(filestring, "\n"); 				//read all file row by row

dapilabels = split(rowdata[0],","); 
fitclabels = split(rowdata[1],","); 
cy3labels = split(rowdata[2],","); 
cy5labels = split(rowdata[3],",");
 
labels = newArray(cycles*chs);

for(i=0;i<cycles;i++){
	labels[i*chs+0]=dapilabels[i];
	labels[i*chs+1]=fitclabels[i];
	labels[i*chs+2]=cy3labels[i];
	labels[i*chs+3]=cy5labels[i];
	print("Cycle="+i+" "+dapilabels[i]+" "+fitclabels[i]+" "+cy3labels[i]+" "+cy5labels[i]);
}

absmax =5000;

myDIR = getDirectory("Please choice directory:");
myname = getString("Please enter image name:","MTU481");

rename(myname);
setLocation(10, 10);

selectWindow(myname);
rename("temp");


//-----------Generate RGB stacks & individual Slices----------

for(i=1;i<=cycles;i++){
	//create RGB image
	currentslice = (i-1)*4+1;
	for(j=currentslice;j<=currentslice+3;j++){
		selectWindow("temp");
		setSlice(j);
		run("Enhance Contrast", "saturated=0.3");
		getMinAndMax(min, max);
		min = min+3000;
		if(max<absmax){max = absmax;}
		setMinAndMax(min, max);
		//Generate single slice image
		ch = j-currentslice+1;
		run("Duplicate...", "duplicate channels="+ch+" slices="+i);
		rename("temp2");
	    setLocation(10, 10); 
		run("Capture Image");
		
		rename("Slice"+j);
		setFont("Arial",96);
		setColor("White");
		drawString(labels[j-1],10,96,"Black");
		hei=getHeight;
		setFont("Arial",48);
		drawString(min+"-"+max,10,hei-10,"Black");
		selectWindow("temp2");
		close();
	}
	
	selectWindow("temp");
	run("Capture Image");
	rename("Cycle"+i);
	
	// labels
	setFont("Arial",72);
	setColor("Yellow");
	drawString("Cycle"+i,10,80);
	setColor("Green");
	drawString(fitclabels[i-1],10,160);
	setColor("White");
	drawString(cy3labels[i-1],10,240);
	setColor("Red");
	drawString(cy5labels[i-1],10,320);
}


//--------Generate Morphing movie----------

for(i=1; i<cycles;i++){

c1 = "Cycle"+i;
c2 = "Cycle"+i+1;

run("iMorph ", "image1="+c1+" operation=Linear image2="+c2+" number="+steps);
rename("iMorph"+i);
}

c1 = "Cycle"+cycles;
c2 = "Cycle"+1;
run("iMorph ", "image1="+c1+" operation=Linear image2="+c2+" number="+steps);
rename("iMorph"+cycles);


//---------Concatenate final movie/images-------------

run("Concatenate...", "  title=Movie image1=iMorph1 image2=iMorph2 image3=[-- None --]");

for(j=3;j<=cycles;j++){
run("Concatenate...", "  title=Movie image1=Movie image2=iMorph"+j+" image3=[-- None --]");
}

run("Images to Stack", "name=Stack title=Cycle use");
rename("RGB-"+myname);
run("Save", "save="+myDIR+"\\RGB-"+myname+".tif");

run("Images to Stack", "name=Stack title=Slice use");
rename("Slice-"+myname);
run("Save", "save="+myDIR+"\\Slice-"+myname+".tif");

selectWindow("Movie");
rename("Moive-"+myname);
run("Save", "save="+myDIR+"\\Movie-"+myname+".tif");

selectWindow("temp");
close();

time = (getTime-startT)/1000;

waitForUser( "Pause","All images are generated in "+time+" seconds\nPress Ok to quit script\n");

