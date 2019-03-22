// Marco Generate cell gallery from a list
// Jerry Lin 2019/03/06
// Need list csv (frame,x,y)


//-------Initialization------

pathfile=File.openDialog("Choose the CSV file for cell list:");

myDIR = getDirectory("Please Select image/tile directory:");
myDIRout = getDirectory("Please Select output directory:");
myName = getString("Please input image name/header:","LUNG7941");
boxsize = getNumber("Please input box size (in um):",25);

scalefactor = 3.08;		//40x image on RareCyte


//-------Parsing CSV----------
filestring=File.openAsString(pathfile); 
rowdata=split(filestring, "\n"); 				//read all file row by row
NumberofCells = rowdata.length;

allFrames = newArray(NumberofCells); 
allXs = newArray(NumberofCells); 
allYs = newArray(NumberofCells);


for(i=0; i<rowdata.length; i++){ 
	columns=split(rowdata[i],","); 
	allFrames[i] = columns[0];
	allXs[i] = columns[1];
	allYs[i] = columns[2];
} 

//-------Loop through cells & save----------
for(cellno=1;cellno<=NumberofCells;cellno++){
	print("Cellno="+cellno+";frame="+allFrames[cellno-1]+";X="+allXs[cellno-1]+";Y="+allYs[cellno-1]);
	open(myDIR+"\\"+myName+"-"+allFrames[cellno-1]+".tif");
	run("Specify...", "width="+boxsize+" height="+boxsize+" x="+allXs[cellno-1]+" y="+allYs[cellno-1]+" slice=1 centered scaled");
	run("Duplicate...", "title=Cell_"+cellno+" duplicate");
	run("Canvas Size...", "width="+(boxsize*scalefactor+5)+" height="+(boxsize*scalefactor+5)+" position=Center");
	run("Save", "save="+myDIRout+"//Cell_"+cellno+".tif");
	selectWindow(myName+"-"+allFrames[cellno-1]+".tif");
	close();
}	//for cellno

//----- Making montage--------

cellno=1;
selectWindow("Cell_"+cellno+".tif");
run("Hyperstack to Stack");
run("Enhance Contrast...", "saturated=1 normalize process_all");
rename("allimage");

for(cellno=2;cellno<=NumberofCells;cellno++){
	selectWindow("Cell_"+cellno+".tif");
	run("Hyperstack to Stack");
	run("Enhance Contrast...", "saturated=1 normalize process_all");
	run("Combine...", "stack1=allimage stack2=Cell_"+cellno+".tif combine");
	rename("allimage");
}

//------reslice using label list---------

pathfile=File.openDialog("Choose the CSV file for label list:");
filestring=File.openAsString(pathfile);
rowdata=split(filestring, "\n"); 

subslices = rowdata[0];
print (subslices);
labels = rowdata[1];
print (labels);

selectWindow("allimage");
run("Make Substack...", "  slices="+subslices);
rename("subimage");

selectWindow("subimage");
alllabel=split(labels,","); 

for(slice=1;slice<=nSlices;slice++){
	setSlice(slice);
	run("Set Label...", "label="+alllabel[slice-1]);
}
selectWindow("subimage");
run("Make Montage...", "columns="+nSlices+" rows=1 scale=1 font=18 label");

