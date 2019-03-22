// Flat-field with BaSiC and save tiff, stitching and save montage
// 2018/05/03 Jerry Lin


//-----------------------Initialization---------------------------
myDIR = getDirectory("Please Select directory:");

filename = File.openDialog("Select imgae file:");
myname = getString("Please enter new image name:","test1");
startT = getTime;

cols= getNumber("Please enter cols:", 13);
rows =  getNumber("Please enter rows:",9);

frames = cols*rows;
if(frames>99){
	maxdig = 3;
}else if(frames >9){
	maxdig = 2;
}else{
	maxdig = 1;
}

//---------------open rpcnl file----------------
mynewDIR = myDIR+"\\"+myname+"-stitch";

print ("Opening rcpnl files:"+filename+" time ="+(getTime-startT)/1000);

run("Bio-Formats", "open="+filename+" color_mode=Composite concatenate_series open_all_series view=Hyperstack stack_order=XYCZT");
rename(myname);

print ("open file:"+filename+" time ="+(getTime-startT)/100);


setSlice(1);
resetMinAndMax();
run("Blue");
setSlice(2);
run("Green");
resetMinAndMax();
setSlice(3);
run("Grays");
resetMinAndMax();
setSlice(4);
resetMinAndMax();
run("Red");

// Montage prior correction
run("Flip Vertically");
run("Make Montage...", "columns="+cols+" rows="+rows+" scale=0.20 increment=1 border=0 font=12");
rename("Montage-"+myname+"-original");
run("Save", "save="+myDIR+"\\Montage-"+myname+"-original.tif");
selectWindow("Montage-"+myname+"-original.tif");
close();

//---------------rename & making folder--------------

File.makeDirectory(mynewDIR+"\\");

selectWindow(myname);
rename("temp");

run("Split Channels");

//--------- Run BaSiC for all four channels ---------------

for(i=1;i<=4;i++){

selectWindow("C"+i+"-temp");
run("Stack to Images");
run("Images to Stack", "name=C"+i+"-temp title=[] use");

run("BaSiC ", "processing_stack=C"+i+"-temp flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate flat-field only (ignore dark-field)] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");
selectWindow("Flat-field:C"+i+"-temp");
close();
selectWindow("C"+i+"-temp");		//close original image
close();
}

// --------------Merge back to one hyperstack----------------

run("Merge Channels...", "c1=Corrected:C1-temp c2=Corrected:C2-temp c3=Corrected:C3-temp c4=Corrected:C4-temp create");
selectWindow("Composite");
rename(myname);


setSlice(1);
resetMinAndMax();
run("Blue");
setSlice(2);
run("Green");
resetMinAndMax();
setSlice(3);
run("Grays");
resetMinAndMax();
setSlice(4);
resetMinAndMax();
run("Red");

//waitForUser("Debugging");

print ("Flatting images:"+filename+" time ="+(getTime-startT)/100);



//---------------------- Making montage & save image-----------------------------


selectWindow(myname);

// Montage post-correction
run("Make Montage...", "columns="+cols+" rows="+rows+" scale=0.20 increment=1 border=0 font=12");
rename("Montage-"+myname);
run("Save", "save="+myDIR+"\\Montage-"+myname+".tif");
selectWindow("Montage-"+myname+".tif");
close();



//---------------------------------START SAVING TIF FILES-----------------------

selectWindow(myname);

n = nSlices;
ch =4;
print ("Saving image files:"+myname+" time ="+(getTime-startT)/1000);

j=1;
for(i=1;i<n; i=i+ch){
	selectWindow(myname);
	setSlice(i);
	print("Current slice ="+i);
	run("Duplicate...", "title="+myname+"-"+j);

	
	if(j>99){
		currdig = 3;
	}else if(j >9){
		currdig = 2;
	}else{
		currdig = 1;
	}


	if(maxdig-currdig>1){
		zeros = "00";
	}else if (maxdig-currdig>0){
		zeros = "0";
	}else{
		zeros = "";
	}
			

	run("Save", "save="+mynewDIR+"\\"+myname+"-"+zeros+j+".tif");
	selectWindow(myname+"-"+zeros+j+".tif");
	run("Close");
	j++;
} //end i;

close();

//----------------------stitching & saving---------------------------

if(maxdig>2){
	mydig ="iii";
}else if(maxdig>1){
	mydig ="ii";
}else{
	mydig ="i";
}
print ("Start stitching image files:"+myname+" time ="+(getTime-startT)/1000);

run("Grid/Collection stitching", "type=[Grid: row-by-row] order=[Right & Down                ] grid_size_x="+cols+" grid_size_y="+rows+" tile_overlap=5 first_file_index_i=1 directory="+mynewDIR+" file_names="+myname+"-{"+mydig+"}.tif output_textfile_name="+myname+"sti.txt fusion_method=[Max. Intensity] regression_threshold=0.65 max/avg_displacement_threshold=1.50 absolute_displacement_threshold=2.50 add_tiles_as_rois compute_overlap ignore_z_stage computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
selectWindow("Fused");
rename("Stitch-"+myname);
setSlice(1);
setMinAndMax(1000, 50000);
run("Blue");
setSlice(2);
run("Green");
setMinAndMax(3000, 35000);
setSlice(3);
run("Grays");
setMinAndMax(500, 20000);
setSlice(4);
run("Red");
setMinAndMax(2000, 20000);

run("Save", "save="+myDIR+"\\Stitch-"+myname+".tif");

print ("Finish stitching & saving files:"+myname+" time ="+(getTime-startT)/1000);
