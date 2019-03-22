// Making zooming movies
// Jerry Lin 2018/05/04


// Initialization

myName = getString("Enter image name:","26531PRE");
xc = getNumber("Please enter the X center:",8142);
yc = getNumber("Please enter the Y center:",7880);
intz = getNumber("Please enter the initial magnificaiton:",5);
endz = getNumber("Please enter the final magnification:",100);
stepz = getNumber("Please enter the step of magnification:",2);

waitForUser("Pause","Make sure the image is open, press OK to start");

deb = 1;

// Making movies
frame = 1;
startT = getTime;

z = intz;

while(z<=endz){
	selectWindow(myName);
	run("Set... ", "zoom="+z+" x="+xc+" y="+yc);
	run("Capture Image");
	rename("frame-"+frame);
	
	if(deb==1){
		setFont("Arial", 36, " antialiased");
		setColor("white");
		Overlay.drawString("Zoom:"+z+"%", 10, 40, 0.0);
		Overlay.show();
		run("Flatten");
	}
	print ("Generate frame "+frame+"  time ="+(getTime-startT)/1000);
	frame++;
	cz = z;
	if(z<20){
		z = z+stepz*0.5;
	}else if(z<50){
		z = z+stepz;
	}else{
		z = z+stepz*2;
	}//endif
}//endwhile

// Finish final frame

if(cz<endz){
	z=endz;
	selectWindow(myName);
	run("Set... ", "zoom="+z+" x="+xc+" y="+yc);
	run("Capture Image");
	rename("frame-"+frame);
	if(deb==1){
		setFont("Arial", 36, " antialiased");
		setColor("white");
		Overlay.drawString("Zoom:"+z+"%", 10, 40, 0.0);
		Overlay.show();
		run("Flatten");
	}
	print ("Generate frame "+frame+"  time ="+(getTime-startT)/1000);
}

run("Images to Stack", "name="+myName+"-zoom title=frame- use");
