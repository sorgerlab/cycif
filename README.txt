ImageJ & Matlab scripts for processing t-CyCIF files (rpcnl files)

Jia-Ren Lin 2017/06/07

System requirement:  
ImageJ 1.49j or above
	Matlab 2015a or above

Third-Party plugin & software:
For ImageJ/Fiji::
TurboReg: http://bigwww.epfl.ch/thevenaz/turboreg/
StackReg: http://bigwww.epfl.ch/thevenaz/stackreg/
MultiStackReg: http://bradbusse.net/downloads.html
For Matlab::
Cyt package: https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html

Step 0:  Rearrange your image files (rpcnl files) to one folder, and rename file to Cycle0.rpcnl…CycleX.rpcnl (Alternatively use the Matlab rename script we provided 0_CycIF_rename_rcpnl.m).

Step 1: Save induvial frame from different cycles:  Run ImageJ macro 1_Macro-SAVEALLCYCLES.ijm. 

Step 2: Registration:  Run ImageJ macro 2_Macro-imagereg-forRareCyte.ijm.

Step 3: Segmentation & quantification: Run ImageJ macro 3_Macro-CycIF-wholeSlidequan.ijm

Step 4: Import data files to Matlab:  Generate a cell array with labels for each channels (plus four additional readings: 'AREA', 'CIRC', 'X','Y'.   Then run Matlab script CycIF_readwholeslide.m

Step 5. Using "writetable" function to generate CSV files, then you can import & analyze in CYT package. 
    

