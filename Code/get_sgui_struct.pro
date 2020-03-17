;+
; NAME:
;       get_sgui_struct
;
; PURPOSE:
;       creates a similar structure as sgui from GCS fitting from already existing GCS fittings from HELCATS
;
; CALLING SEQUENCE:
;       sgui = get_sgui_struct(date)
;
; INPUTS:
;       date: date of the event
;
; OUTPUTS:
;       sgui: sgui struct similar to that from GCS fitting
;		-1: if GCS fitting was not performed within the HELCATS project
; 
; NOTE:
;		date and time are used from predate and pretime (may be different if GCS fitting is done manually)
;		reads following file: getenv('DATA_DIR') + 'HELCATS/GCSParameterHelcats.sav'
;
; MODIFICATION HISTORY:
;       20180711: created by jhinterreiter
;-
function get_sgui_struct, date, cmeheight = cmeheight, nbvertaxisp = nbvertaxisp, nbvertcirup = nbvertcirup, nbvertshell=nbvertshell

create_gcs_sav_file
files = getenv('DATA_DIR') + 'HELCATS/GCSParameterHelcats.sav'

restore, files;, /verbose


indInList = where(double(date) eq double(iddate))

sguiStruct = {hgt:0.0, lon:0.0, lat:0.0, rot:0.0, rat:0.0, han:0.0, eruptiondate:'', carrstonyshiftdeg:0.0, carrorstony:0B, $
		nbvertaxisp:0, nbvertcirup:0, nbvertshell:0, loncarr:0.0}


;if n_elements(indInList) gt 1 then return, 1

if indInList[0] ne -1 then begin
	elemCnt = n_elements(indInList)
	sguiStruct = replicate(sguiStruct, elemCnt)
	
	for i = 0, elemCnt-1 do begin
		selCME = indInList[i]
		sguidate = predate[selCME]
		time = pretime[selCME]
		lon = stolon[selCME]/!radeg
		lat = stolat[selCME]/!radeg
		rot = tilt[selCME]/!radeg
		rat = ssprat[selCME]
		halfAngle = h_angle[selcme]/!radeg
		loncarr = carlon[selCME]/!radeg

		height = 5.
		nbaxisp = 5
		nbcirup = 20
		nbshell = 50
		if keyword_set(cmeheight) then height = cmeheight
		if keyword_set(nbvertaxisp) then nbaxisp = nbvertaxisp
		if keyword_set(nbvertcirup) then nbcirup = nbvertcirup
		if keyword_set(nbvertshell) then nbshell = nbvertshell

		sguiStruct[i].hgt = height
		sguiStruct[i].lon = lon
		sguiStruct[i].lat = lat
		sguiStruct[i].rot = rot
		sguiStruct[i].rat = rat
		sguiStruct[i].han = halfangle
		sguiStruct[i].eruptiondate = sguidate+'T'+time+':00.000'
		sguiStruct[i].carrstonyshiftdeg = 0.0
		sguiStruct[i].carrorstony = 1
		sguiStruct[i].loncarr = loncarr 
		sguiStruct[i].nbvertaxisp = nbaxisp
		sguiStruct[i].nbvertcirup = nbcirup
		sguiStruct[i].nbvertshell = nbshell
	endfor
	return, sguiStruct
endif

return, -1
end