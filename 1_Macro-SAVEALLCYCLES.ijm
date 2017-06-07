// Save color hyperstack into individual tiff(4ch) & Montage with Flat-field
// 20161210 Jerry Lin

myDIR2 = getString("Please enter directory","C:\\RCPNL\\Shaolin-Tonsil\\Tonsil1\\");
myname = getString("Please enter image name","Tonsil1");

cs = getNumber("Enter start cycle:",0);
ce = getNumber("Enter end cycle:",12);


//mycycle = getString("Please enter the Cycle","4");
//mycycle = "Cycle"+mycycle;

//myDIR = "F:\\"+myname+"\\"+mycycle+"\\";
//myDIR2 = "F:\\"+myname+"\\";

cols= getNumber("Please enter cols:", 5);
rows =  getNumber("Please enter rows:",8);
ch = getNumber("Please enter channels:",4);
startT = getTime;

setBatchMode(true);

for(cyc = cs;cyc<=ce;cyc++){

print("Now processing Cycle "+cyc+"....");

mycycle = "Cycle"+cyc;
myDIR = myDIR2+mycycle+"\\";

run("Bio-Formats", "open="+myDIR2+mycycle+".rcpnl color_mode=Composite concatenate_series open_all_series view=Hyperstack stack_order=XYCZT");

//rname & making folder

rename(myname);
File.makeDirectory(myDIR);

// Background substraction & splitting channels

run("Subtract Background...", "rolling=50 sliding disable");
run("Flip Vertically");
name=getTitle;
print ("open file:"+myname+"Cycle"+cyc+" time ="+(getTime-startT)/100);

// Making montage & save image

run("Make Montage...", "columns="+cols+" rows="+rows+" scale=0.20 increment=1 border=0 font=12");
rename("Montage-"+myname+"-"+mycycle);
run("Save", "save="+myDIR2+"Montage-"+myname+"-"+mycycle+".tif");
close();


//---------------------------------START SAVING TIF FILES-----------------------

selectWindow(myname);
name = getTitle;
n = nSlices;
//ch =4;

j=1;
for(i=1;i<n; i=i+ch){
	selectWindow(name);
	setSlice(i);
	print("current Cycle "+cyc+" slice ="+i);
	run("Duplicate...", "title="+name+"-"+j);
	run("Save", "save="+myDIR+name+"-"+j+".tif");
	selectWindow(name+"-"+j+".tif");
	run("Close");
	j++;
} //end i;

close();
print ("Saving image files:"+myname+"Cycle"+cyc+" time ="+(getTime-startT)/1000);
}  //end cyc;

setBatchMode(false);