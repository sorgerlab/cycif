ImageJ & Matlab scripts for processing t-CyCIF files.

Key references:

1. Highly multiplexed imaging of single cells using a high-throughput cyclic immunofluorescence method
JR Lin, M Fallahi-Sichani, PK Sorger - Nature communications, 2015

2. Highly multiplexed immunofluorescence imaging of human tissues and tumors using t-CyCIF and conventional optical microscopes
JR Lin, B Izar, S Mei, S Wang, P Shah, C Yapp… - eLife, 2018 in press

This work was funded by NIH/NIGMS LSP grant P50-GM107618,NIH LINCS grant U54-HL127365, and NIH STTR grant R41-CA224503.
----------------------------------------------------------------------------------------------------------------------------
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

---------------------------------------------------------------------------------------------------------------------------
Instructions:

Step 0:  Rearrange your image files (rpcnl files) to one folder, and rename file to Cycle0.rpcnl…CycleX.rpcnl, or use the Matlab rename script we provided (CycIF_rename_rcpnl.m).

Step 1: Save induvial frame from different cycles:  Run ImageJ macro 1_Macro-SAVEALLCYCLES.ijm. 

Step 2: Registration:  Run ImageJ macro 2_Macro-imagereg-forRareCyte.ijm.

Step 3: Segmentation & quantification: Run ImageJ macro 3_Macro-CycIF-wholeSlidequan.ijm

Step 4: Import data files to Matlab:  Generate a cell array with labels for each channels (plus four additional readings: 'AREA', 'CIRC', 'X','Y'.   Then run Matlab script CycIF_readwholeslide.m

Step 5. Using "writetable" function to generate CSV files, then you can import & analyze in CYT package. 
    
---------------------------------------------------------------------------------------------------------------------------
Sample images:

A set of t-CyCIF sample images could be found here:

https://www.dropbox.com/sh/fhn8qbow3qk2lc1/AABOIbSk7JoshSukS33HB1cQa?dl=0

8-cycle CyCIF experiment was done with a Breast xenograft sample.  Each rcpnl file contains 7x6 grids with 4-ch images.  
