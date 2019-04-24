;+
; NAME:
;		EAGEL (Eclptic cut Angles from Gcs for ELevohi)
;
; PURPOSE:
;       starts a widget to download lasco, stereo images, process data and perform GCS fitting.
;		then the ecliptic cut from the GCS hollow shell is created
;		selecting the boundaries of the CME to get the half width and the angles to the SC
;		result is saved in getenv('EAGEL_DIR')+'/results/'+date+'/'
;
; CALLING SEQUENCE:
;       EAGEL, '20101104', datetime = '20101104T02:39:09'
;
; INPUTS:
;       ELEvoHIDate: Date of the event, will be used as date for the resulting .sav file
;
; KEYWORDS: 
;		datetime: date and time show in the widget: e.g.: '20101104T02:39:09' (format is important)
;
; OUTPUTS:
;       .sav and .dat file with the half width and the angles
;
; MODIFICATION HISTORY:
;       20181120: created by jhinterreiter
;-
pro EAGEL, ELEvoHIDate, datetime = datetime
	common widPrepare, isPrepare, dattim, stdet, ladet, rect, diffImgST, diffImgLA, adv
	common widPositon, widOffsetPos
	
	
read_eagel_config_file

isPrepare = 0

;predefined date
date_time = '20101104T01:54:09'

dattim = date_time
xsize = 1024
ysize = 512
widPos = intarr(4)
widPos[0] = xsize
widPos[1] = ysize
widOffsetPos = intarr(2)
scSize = get_screen_size()
print, scSize
widOffsetPos[0] = scSize[0]/2 - xsize/2
widOffsetPos[1] = scSize[1]/2 - ysize/2
widPos[2] = widOffsetPos[0]
widPos[3] = widOffsetPos[1]


if keyword_set(datetime) then dattim = datetime

while 1 eq 1 do begin
	date_time = dattim
	
	; calls the widget
	widget_get_angles, ElevoHIDate, date_time, widPos
	date_time = dattim
	
	; if prepare_data is called widget is closed and a dummy window is opened (otherwise cgstretch does not work)
	if isPrepare eq 1 then begin
		widPos[2] = widOffsetPos[0]
		widPos[3] = widOffsetPos[1]
		base = get_main_layout(date_time, 0, btnArr = btns, widPos)
		WIDGET_CONTROL, base, /REALIZE
		widget_control, /hourglass
		prepare_data, date_time, stdet, ladet, rect, diffImgST, diffImgLA, adv, parent = base
		widget_control, base, /destroy
	endif
	if isPrepare ne 1 then break
	isPrepare = 0
endwhile

print, 'EAGEL closed'
end