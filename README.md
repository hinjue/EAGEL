# EAGEL
EAGEL (Eclptic cut Angles from Gcs for ELevohi)

With this tool the direction and the half width of CMEs in the ecliptic can be determined. 

It helps to download STEREO and SoHO/LASCO coronagraph images, preprocess the images and 
do GCS fitting. Based on the GCS fitting, a ecliptic cut of the hallow croissant shaped 
CME is performed where then the user selects the boundaries of the CME. As an output the 
half with and the propagation direction (regarding STA/STB and Earth) of the CME is given.

The tool uses the IDL SolarSoft built in function 'rtsccguicloud.pro' to do the GCS 
fitting. For a detailed description see Thernisien et al. 2006 and 2009.

For pre-processing the coronagraph images the coyote library by David Fanning 
(http://www.idlcoyote.com/documents/programs.php) is needed.

EAGEL was developed and tested with IDL Version 8.6
