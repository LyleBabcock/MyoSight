////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// MyoSight - Semi-Automated Skeletal Muscle Cross Sectional Area, Fiber-Type and MyoNuclei Analysis ///////
////////////////////////////////////////////// By Lyle Babcock /////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///// Initialisation - Closing all open windows /////
	roiManager("Reset");
	setBackgroundColor(0, 0, 0);
	run("Close All");

if (isOpen("Summary")) {
    selectWindow("Summary");
    run("Close");
}
if (isOpen("Results")) {
    selectWindow("Results");
    run("Close");  
}
if (isOpen("Log")) {
    selectWindow("Log");
    run("Close");
}
if (isOpen("Console")) {
    selectWindow("Console");
    run("Close");
}

///// Dialog: Image Type /////
	Dialog.create("MyoSight: Skeletal Muscle Image Analysis");
	Dialog.setInsets(0, 0, 0);
	items = newArray("Bio-format Image","Other");
	Dialog.addRadioButtonGroup("Choose Image Type", items, 1, 2, "Bio-format Image");
	Dialog.show()
	Image_Type = Dialog.getRadioButton();


///// Dialog: Channel & Color /////
	Dialog.create("MyoSight: Skeletal Muscle Image Analysis");
if (Image_Type == "Bio-format Image") {
	Dialog.setInsets(0, 0, 0);
	Dialog.addMessage("Channel Information\n==========================");
	items = newArray("Fiber Borders","MHCI","MHCIIa","MHCIIb","DAPI","Satellite Cells","None");
	Dialog.addChoice("Channel 1", items, "None");
	Dialog.addChoice("Channel 2", items, "None");
	Dialog.addChoice("Channel 3", items, "None");
	Dialog.addChoice("Channel 4", items, "None");
	Dialog.addChoice("Channel 5", items, "None");
	Dialog.addChoice("Channel 6", items, "None");
	Dialog.addChoice("Channel 7", items, "None");
   
	Dialog.setInsets(20, 0, 0);
	Dialog.addMessage("Color Information\n==========================");
	items = newArray("Fiber Borders", "MHCI", "MHCIIa", "MHCIIb", "DAPI", "Satellite Cells", "*None*");
	Dialog.addChoice("Red", items, "*None*");
	Dialog.addChoice("Green", items,"*None*");
	Dialog.addChoice("Blue", items, "*None*");
	Dialog.addChoice("Gray", items, "*None*")
	Dialog.addChoice("Cyan", items, "*None*");
	Dialog.addChoice("Magenta", items, "*None*");
	Dialog.addChoice("Yellow", items, "*None*")
	Dialog.show();
}
	Channel_1 = Dialog.getChoice();
	Channel_2 = Dialog.getChoice();
	Channel_3 = Dialog.getChoice();
	Channel_4 = Dialog.getChoice();
	Channel_5 = Dialog.getChoice();
	Channel_6 = Dialog.getChoice();
	Channel_7 = Dialog.getChoice();
	
	c_1 = Dialog.getChoice();
	c_2 = Dialog.getChoice();
	c_3 = Dialog.getChoice();
	c_4 = Dialog.getChoice();
	c_5 = Dialog.getChoice();
	c_6 = Dialog.getChoice();
	c_7 = Dialog.getChoice();

///// Create a Directory to Save Results /////
	Done = false;
	while (Done == false){

showMessage("After clicking 'OK', select a folder where your results file will be generated");

	dir = getDirectory("Choose a Directory");
	Results = dir+"Results"+File.separator;
	File.makeDirectory(Results);

showMessage("After clicking 'OK', choose an image file to be analyzed");

///// Splitting, Identifying and Naming Open Images /////
if (Image_Type == "Bio-format Image") {
	run("Bio-Formats Importer", "open=[] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    title = getTitle();
    run("Split Channels");

if (Channel_1 != "None") {
	selectWindow("C1-"+title);
    rename(Channel_1);
}
if (Channel_2 != "None") {
    selectWindow("C2-"+title);
    rename(Channel_2);
}
if (Channel_3 != "None") {
    selectWindow("C3-"+title);
    rename(Channel_3);
}
if (Channel_4 != "None") {
	selectWindow("C4-"+title);
    rename(Channel_4);
}
if (Channel_5 != "None") {
    selectWindow("C5-"+title);
    rename(Channel_5);
}
if (Channel_6 != "None") {
	selectWindow("C6-"+title));
    rename(Channel_6);
}
if (Channel_7 != "None") {
	selectWindow("C7-"+title));
    rename(Channel_7);
}
selectWindow("Fiber Borders");
}

if (Image_Type == "Other") {
	open(); 
	rename("Fiber Borders");
}

/////////////////////////////////////// Identifying Fiber Borders ///////////////////////////////////////

///// User Input: Segmentation and Thresholding /////	
	isFinished = false;

while (isFinished ==false){
	Dialog.create("MyoSight: Skeletal Muscle Image Analysis");
	Dialog.setInsets(0, 0, 0);
if (Image_Type == "Other") {
	Dialog.setInsets(0, 0, 0);
	Dialog.addMessage("Set Scale\n==========================");
	Dialog.addNumber("Distance in Pixels", 300); 
	Dialog.addNumber("Known Distance", 100);
}
	Dialog.setInsets(0, 0, 0);
	Dialog.addMessage("Segmentation and Analysis\n==========================");
	Dialog.addNumber("Prominence", 2500);
	Dialog.addNumber("Particle Size", 300);
	
	Dialog.setInsets(20, 0, 0);
	Dialog.addMessage("Thresholding\n==========================");
	items = newArray("Huang", "Default", "Intermodes", "IsoData", "Li", "MaxEntropy", "Mean", "Moments", "Otsu", "Triangle", "Yen");
	Dialog.addChoice("Threshold Type", items, "Default");
	Dialog.show();

	Threshold = Dialog.getChoice();

if (Image_Type == "Other") {
	Distance_in_Pixels = Dialog.getNumber();
	Known_Distance = Dialog.getNumber();
}
	Prominence = Dialog.getNumber();
	Particle_Size = Dialog.getNumber();

if (Image_Type == "Bio-format Image") {
	selectWindow("Fiber Borders");
	Fiber_Borders = getImageID();
    run("Duplicate...", " ");
    mask = getImageID(); 
}

if (Image_Type == "Other") {
	run("Set Scale...", "distance=Distance_in_Pixels  known=Known_Distance unit=µm");
	selectWindow("Fiber Borders");
	Fiber_Borders = getImageID();
	run("Duplicate...", " ");
	mask = getImageID();
}

	run("Clear Results");
	roiManager("reset");
	
///// Segmentation /////
    run("Set Measurements...", "area mean display add redirect=None decimal=3");
	run("Find Edges");
	run("Gaussian Blur...", "sigma=5");
	run("Enhance Contrast...", "saturated=10");
	run("Find Maxima...", "prominence=Prominence light output=[Segmented Particles]");
	run("Analyze Particles...", "size=Particle_Size circularity=.4 show=Masks display exclude summarize add in_situ");

///// Overlay Segmentation and Threshold /////
	roiManager("Show All");
	selectImage(Fiber_Borders);
	run("Duplicate...", " ");

	run("Enhance Contrast", "saturated=0.35");
	roiManager("Set Color", "red");
	roiManager("Set Line Width", 2);
	roiManager("Show All without labels");
	run("Flatten");
	run("Despeckle");
	run("Enhance Contrast", "saturated=0.35");
    run("Smooth");
	roiManager("reset");
	run("Clear Results");
    run("16-bit");
	setAutoThreshold(Threshold);
	run("Convert to Mask");
	run("Invert");
	run("Options...", "iterations=2 count=1 black do=Dilate");
	run("Invert");
	run("Options...", "iterations=3 count=1 black do=Dilate");
	run("Analyze Particles...", "size=Particle_Size circularity=0.1-1.00 show=Nothing display exclude summarize add in_situ");

///////////////////////////////// Manual Corrections of Fiber Borders ////////////////////////////////////
	if (Image_Type == "Bio-format Image") {
	roiManager("UseNames", "false");
	roiManager("Show All with labels");
	selectImage(Fiber_Borders);
	run("Merge Channels...", "c1=["+c_1+"] c2=["+c_2+"] c3=["+c_3+"] c4=["+c_4+"] c5=["+c_5+"] c6=["+c_6+"] c7=["+c_7+"] keep");
	roiManager("Show All");
}

else {
	roiManager("UseNames", "false");
	roiManager("Show All with labels");
	selectImage(Fiber_Borders);
	roiManager("Show All");
}
	
	waitForUser("Corrections", "Review all segmented ROIs. Delete and re-draw inaccurate fiber borders.\nWhen finished, or if you wish to reanalyze, click 'Ok'");

	Dialog.create("MyoSight: Skeletal Muscle Image Analysis");
	Dialog.addMessage("If the analysis of fiber borders is complete, Check 'Analysis Complete' and click 'Ok'.\nIf prominence and particle size need adjusting leave un-checked and click 'Ok'\n=============================================");
	Dialog.addCheckbox("Analysis Complete", false);
	Dialog.show();

	isFinished = Dialog.getCheckbox();

if (isFinished == false) {
if (Image_Type == "Bio-format Image") {
	selectWindow("RGB");
	run("Close");
}
	selectWindow("Fiber Borders-1");
	run("Close");
	selectWindow("Fiber Borders-2");
	run("Close");
	selectWindow("Fiber Borders-3");
	run("Close");
	selectWindow("Fiber Borders-1 Segmented");
	run("Close");
	run("Clear Results");
	roiManager("reset");
}
}

if (Image_Type == "Other") {
	selectWindow("Fiber Borders");
	run("Flatten");
	saveAs(".tif", Results+"Fiber Borders");
}
	selectWindow("Results");
	roiManager("save", Results+File.separator+"ROISet.zip");
	run("Clear Results");
	roiManager("reset");
	
//////////////////////////////////////// Fiber Type Identification ///////////////////////////////////////
if ((isOpen("MHCI"))||(isOpen("MHCIIa"))||(isOpen("MHCIIb"))) {
	
///// User Input: Thresholding Values /////
	FTFinished = false;

	while (FTFinished ==false) {
	Dialog.create("MyoSight: Skeletal Muscle Image Analysis");
	Dialog.setInsets(0, 0, 0);
	Dialog.addMessage("If fiber type stains are present,\n select the threshold values for\n fibertype qualification.\n=========================");
	Dialog.addNumber("MHC I", 7500);
	Dialog.addNumber("MHC IIa", 7500);
	Dialog.addNumber("MHC IIb", 7500);
	Dialog.show();

	MHCI_Threshold = Dialog.getNumber();
	MHCIIa_Threshold = Dialog.getNumber();
	MHCIIb_Threshold = Dialog.getNumber();

	run("Clear Results");
	roiManager("reset");
	roiManager("open", Results+"ROISet.zip");
	
///// MHCI /////
if (isOpen("MHCI")) {
	selectWindow("MHCI");
	run("From ROI Manager");
	roiManager("multi-measure append");
	nROI = roiManager("count");
for (i = 0; i < nROI; i++) {
	Mean = getResult("Mean",i);
if (Mean > MHCI_Threshold) {
	roiManager("select", i);
	roiManager("rename", "I");
		}
	}
}
	run("Clear Results");

///// MHCIIa /////
if (isOpen("MHCIIa")) {
	selectWindow("MHCIIa");
	run("From ROI Manager");
	roiManager("deselect");
	roiManager("multi-measure append");
	nROI = roiManager("count");
for (i = 0; i < nROI; i++) {
	Mean = getResult("Mean",i);
if (Mean > MHCIIa_Threshold) {	
	roiManager("select", i);
 if (Roi.getName == "I") {
 	roiManager("select", i);
	roiManager("rename", "I/IIa");
	}
  else {
  	roiManager("select", i);
	roiManager("rename", "IIa");
  }	
		}
	}
}
	run("Clear Results");

///// MHCIIb /////
if (isOpen("MHCIIb")) {
	selectWindow("MHCIIb");
	run("From ROI Manager");
	roiManager("deselect");
	roiManager("multi-measure append");
	nROI = roiManager("count");
for (i = 0; i < nROI; i++) {
	Mean = getResult("Mean",i );
if (Mean > MHCIIb_Threshold) {
	roiManager("select", i);
	roiManager("rename", "IIb");
		}
	}
}
	run("Clear Results");

///// MHCIIx /////
	nROI = roiManager("count");
for (i = 0; i < nROI; i++) {
	roiManager("select", i);
if ((Roi.getName != "I") &&  (Roi.getName != "IIa") && (Roi.getName != "IIb") && (Roi.getName != "I/IIa")) {
	roiManager("select", i);
	roiManager("rename", "IIx");
	}
}

///////////////////////////// Manual Corrections of Fibertype Analysis //////////////////////////////////
if (Image_Type == "Bio-format Image") {
	roiManager("UseNames", "true");
	roiManager("Show All with labels");
	selectWindow("RGB");
	roiManager("Show All");
}

	waitForUser("Corrections", "Review all labeled fiber types and rename any inaccuate labels.\nWhen finished, or if you wish to reanalyze, click 'Ok'.");

	Dialog.create("MyoSight: Skeletal Muscle Image Analysis");
	Dialog.addMessage("If the fibertype analysis is complete, Check 'Analysis Complete' and click 'Ok'.\nIf threshold values need to be adjusted, leave un-checked and click 'Ok'\n=============================================");
	Dialog.addCheckbox("Analysis Complete", false);
	Dialog.show();

	FTFinished = Dialog.getCheckbox();

if (FTFinished == false) {
	roiManager("reset");
}
}


//////////////////////////////// Saving CSA and Fibertype Analysis ////////////////////////////////////////	
	run("Clear Results");
if (Image_Type == "Bio-format Image")  {
	selectImage(Fiber_Borders);
}

	run("Set Measurements...", "area feret's display redirect=None decimal=3");
	roiManager("measure");
	selectWindow("Results");
	roiManager("save", Results+File.separator+"ROISet.zip");
	run("Clear Results");
	roiManager("reset");

	
if (Image_Type == "Bio-format Image")  {
	selectWindow("RGB");
	rename("CSA & Fibertype Analysis");
}

	run("Flatten");
	saveAs(".tif", Results+getTitle());
	
}

if (isOpen("DAPI")) {

showMessage("MyoSight will now analyze myonuclei and may take 2-3 minutes.\nDuring this process, do not click on any FIJI windows.");

setBatchMode(true);
////////////////////////////////////////// Myonuclei Detection ///////////////////////////////////////////

if (isOpen("DAPI")) {
	selectWindow("DAPI");
	run("Duplicate...", "title=[DAPI Temp]");
	selectWindow("DAPI Temp");
	setAutoThreshold("Otsu dark");
	setOption("BlackBackground", true);
	setAutoThreshold("Otsu dark");
	run("Convert to Mask");
	run("Watershed");
	run("Set Measurements...", "area centroid redirect=None decimal=3");
	run("Analyze Particles...", "size=1.0--Infinity circularity=0-1.00 display exclude summarize add");
	getPixelSize(unit, pixelWidth, pixelHeight);
	ScaleFactor = 1/pixelWidth;
	counts=nResults;
	nuclei_counts = newArray(counts);
	roiManager("reset");
	roiManager("open", Results+"ROISet.zip");
	
for (i=0;i<counts; i++) {
	CntrdX = getResult("X", i);
	CntrdY = getResult("Y", i);
	X = CntrdX*ScaleFactor;
	Y = CntrdY*ScaleFactor;
	makePoint(X, Y, "cross");
	roiManager("add");
}
	roiManager("Show All without labels");
	
for (i=0;i<counts; i++){
	nuclei_counts[i] = 0;
  for (j=0;j<roiManager("count");j++){
    roiManager('select',newArray(i,j));
    roiManager("AND");
   if ((i!=j)&&(selectionType>-1)) {
    	nuclei_counts[i]++;
    }
  }
}
	roiManager("show all");
	selectWindow("DAPI Temp");
	rename("Myonuclei Analysis");
	run("Flatten");
	saveAs(".tif", Results+getTitle()); 
	run("Clear Results");
	roiManager("reset");

}
/////////////////////////////////////// Central Nuclei Detection /////////////////////////////////////////
	centronuclei_counts = newArray(counts);
if (isOpen("DAPI")) {
	roiManager("open", Results+"ROISet.zip");
	roiManager("multi-measure append");
	counts=roiManager("count");
for(i=0; i<counts; i++) {
		Size = getResult("Area", i);
    	roiManager("Select", i);
    if (Size < 200) {
    	run("Enlarge...", "enlarge=-3");    
}
	if ((Size >= 200)&&(Size < 800)) {
		run("Enlarge...", "enlarge=-5");
}
	else {
		run("Enlarge...", "enlarge=-9");
}
		roiManager("Update");
}
		run("Clear Results");

	selectWindow("DAPI");
	setAutoThreshold("Otsu dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Watershed");
	run("Analyze Particles...", "size=1.0--Infinity circularity=0-1.00 display exclude summarize add");
	roiManager("Show All without labels");

	
for (i=0;i<counts; i++){
	centronuclei_counts[i] = 0;
  for (j=0;j<roiManager("count");j++){
    roiManager('select',newArray(i,j));
    roiManager("AND");
    if ((i!=j)&&(selectionType>-1)) {
    	centronuclei_counts[i]++;
    }
  }
}
 	roiManager("show all");
	selectWindow("DAPI");
	rename("Central Nuclei Analysis");
	run("Flatten");
	saveAs(".tif", Results+getTitle());
	run("Clear Results");
	roiManager("reset"); 
}
}
/////////////////////////////////////// Saving Final Results //////////////////////////////////////
	roiManager("open", Results+"ROISet.zip");
	selectWindow("Fiber Borders");
	run("From ROI Manager");
	run("Set Measurements...", "area feret's display redirect=None decimal=3");
	roiManager("multi-measure append");
	updateResults();
if (isOpen("Central Nuclei Analysis")) {
for (i = 0; i < counts; i++) {
	setResult("Central Nuclei", i, centronuclei_counts[i]);
}
}
if (isOpen("Myonuclei Analysis")) {
for (i = 0; i < counts; i++) {
	setResult("Total Myonuclei", i, nuclei_counts[i]);
}
}

if (isOpen("Myonuclei Analysis")); {
	n=nResults;
for (i = 0; i<n; i++) {
	TotNuc=getResult("Total Myonuclei", i);
	CenNuc=getResult("Central Nuclei", i);
	Perinuclei = TotNuc - CenNuc;
	setResult("Perinuclei", i, Perinuclei);
}
}

	selectWindow("Results");
	roiManager("save", Results+File.separator+"ROISet.zip");
	updateResults();

if (Image_Type == "Bio-format Image") {	
for (i=0; i<nResults; i++) {
    oldLabel = getResultLabel(i);
    delimiter = indexOf(oldLabel, ":");
    newLabel = substring(oldLabel, delimiter+1);
    setResult("Label", i, newLabel);
		}
	}
	selectWindow("Results");
	saveAs(".text", Results+"Results");

///////////////////////////////////////// Close Program ////////////////////////////////////////////
	run("Close All");
	selectWindow("Summary");
	run("Close");
	selectWindow("ROI Manager");
	run("Close");
	selectWindow("Results");
	run("Close");
if (isOpen("Log")) {
	selectWindow("Log");
	run("Close");
}

setBatchMode(false);

	Dialog.create("MyoSight: Skeletal Muscle Image Analysis");
	Dialog.addMessage("If the analysis is complete, Check 'Analysis Complete' and click 'Ok'.\nIf there is another image to analyze leave un-checked and click 'Ok'.\n=============================================");
	Dialog.addCheckbox("Analysis Complete", false);
	Dialog.show();

	Done = Dialog.getCheckbox();
}

