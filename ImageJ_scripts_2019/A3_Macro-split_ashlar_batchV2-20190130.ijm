// Marco split ashlar ome-tiff into single-frame tiff (batch model)
// Jerry Lin 2018/11/12
// Need guild csv

//Initialization
myDIR = getDirectory("Please Select directory:");


pathfile=File.openDialog("Choose the CSV file to Open:"); 
filestring=File.openAsString(pathfile); 
rowdata=split(filestring, "\n"); 				//read all file row by row
startn = getNumber("Please input start slide no:",1);
NumberofSlide = rowdata.length-1;
endn = getNumber("Please input end slide no:",NumberofSlide);

slideName = newArray(NumberofSlide); 
slideFiles = newArray(NumberofSlide); 

for(i=1; i<rowdata.length; i++){ 
	columns=split(rowdata[i],","); 
	slideName[i-1] = columns[1];
	slideFiles[i-1] = columns[0];
} 

totalslide = slideName.length;

for(i=startn-1;i<slideName.length;i++){
	print(slideName[i]+" "+slideFiles[i]);
}
ch = 4; //Please enter channels (physical)

totalslide = slideName.length;

startT = getTime;

//processing all slides

for(slide =startn-1;slide<endn;slide++){

filename = slideFiles[slide];
myName = slideName[slide];

mynewDIR = myDIR+myName;
File.makeDirectory(mynewDIR+"\\");

startT = getTime;

run("Bio-Formats", "open="+filename+" color_mode=Default concatenate_series rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT series_3 c_begin_1=1 c_end_1=1 c_step_1=1");
print ("Opening rcpnl files:"+filename+" time ="+(getTime-startT)/1000);

// Determine parameters
height = getHeight*4;
width = getWidth*4;
gridW = round(width/1280);
gridH = round(height/1024);
stepW=round(width/gridW)+1;
stepH=round(height/gridH)+1;

print("width ="+width+";height="+height+";grid="+gridW+"x"+gridH+";size="+stepW+"x"+stepH);
close();

// Main loop : saving single tif files
print ("Saving tif files: time ="+(getTime-startT)/1000);

index1 = 1;
for(row =1;row<=gridH;row++){
	for(col=1;col<=gridW;col++){
		startX = 0+(col-1)*stepW;
		startY = 0+(row-1)*stepH;
		print(row+","+col);
		print(startX+","+startY);
		run("Bio-Formats", "open="+filename+" color_mode=Default concatenate_series crop rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1 x_coordinate_1="+startX+" y_coordinate_1="+startY+" width_1="+stepW+" height_1="+stepH);
		cycles = nSlices/4;
		run("Stack to Hyperstack...", "order=xyczt(default) channels=4 slices="+cycles+" frames=1 display=Composite");
		setSlice(1);
		run("Blue");
		setSlice(2);
		run("Green");
		setSlice(3);
		run("Grays");
		setSlice(4);
		run("Red");
		saveAs("Tiff", mynewDIR+"\\"+myName+"-"+index1+".tif");
		index1++;
		close();
	}
}
print ("Writing the log file: time ="+(getTime-startT)/1000);

f = File.open(mynewDIR+"\\"+myName+".log.txt");

//f = File.open("H:\\TEST1.log");

print(f,"name\tGridW\tGridH\tStepW\tStepH");
print(f,myName+"\t"+gridW+"\t"+gridH+"\t"+stepW+"\t"+stepH);

File.close(f);

} // slide




