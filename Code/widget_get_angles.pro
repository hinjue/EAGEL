
; sets the sensitivity of all the buttons of the main widget
pro setButtonSensitivity, sensitive
	common widIds, btns
	
	for i = 0, n_elements(btns)-1 do begin
		widget_control, btns[i], sensitive = sensitive
	endfor
end


; checks if GCS fitting for a given date and time was already done
function check_GCSDone, date_time, isDone = isDone
	;date_time = '20120614T14:39:09'
	date = strmid(date_time, 0, 8)

	hr = strmid(date_time,9,2)
	mi = strmid(date_time,12,2)
	se = strmid(date_time,15,2)
	tim = hr+mi+se

	savPath = getenv('EAGEL_DIR')+'/results/'+date+'/'

	filesgui = file_search(savPath+date+'_'+tim+'params.sav')
	isDone = 0
	if filesgui ne '' then isDone = 1
	return, filesgui
end

; checks if the images for a given date and time were already prepared
function check_filesPrepared, date_time, isPrepared = isPrepared
	;date_time = '20120614T14:39:09'
	date = strmid(date_time, 0, 8)

	hr = strmid(date_time,9,2)
	mi = strmid(date_time,12,2)
	se = strmid(date_time,15,2)
	tim = hr+mi+se

	savPath = getenv('EAGEL_DIR')+'/results/'+date+'/'

	filesgui = file_search(savPath+date+'_'+tim+'.sav')
	isPrepared = 0
	if filesgui ne '' then isPrepared = 1
	return, filesgui
end


PRO widgetGetAngles_event, ev
;	do nothing
END


; event when clicking on 'Prepare'
pro prepare_event, ev
	txtStart = WIDGET_INFO( ev.top, FIND_BY_UNAME ='txtStart')
	widget_control, txtStart, get_value = datetime
	setButtonSensitivity, 0
	
	prepare_dialog, ev.top, datetime
end


; event when clicking on 'Download'
pro downloadImgs_event, ev
	setButtonSensitivity, 0
	txtStart = WIDGET_INFO( ev.top, FIND_BY_UNAME ='txtStart')
	widget_control, txtStart, get_value = datetime
	download_dialog, ev.top, datetime
	setButtonSensitivity, 1
end

; close the window
PRO close_event, ev
	WIDGET_CONTROL, ev.top, /DESTROY
end


; event when clicking on 'Get Angles'
PRO getParameter_event, ev
	common angs, retAngles, ELEvoHI
	txtStart = WIDGET_INFO( ev.top, FIND_BY_UNAME ='txtStart')
	
	widget_control, txtStart, get_value = datetime
	date = strmid(datetime[0], 0, 8)
	sgui = get_sgui_struct(date)
	
	doSelectBoundaries = 0
	paramsExist = isa(sgui, /array)
	
	msg = 'No'
	
	; check if there are GCS fits from HELCATS
	if paramsExist eq 1 then begin
		msg = Dialog_message('Do wou want to use existing GCS parameter (from Helcats)?', /question, dialog_parent = ev.top)
		if msg eq 'Yes' then begin
			doSelectBoundaries = 1
			swire = 0
		endif
	endif
	
	if msg eq 'No' then begin	
		redoGCS = 1
		filePrepared = check_filesPrepared(datetime, isPrepared = isFilePrepared)
		fileDone = check_GCSDone(datetime, isDone = isGCSdone)
		if isFilePrepared eq 0 then begin
			msg = Dialog_message('Prepare images first.', /info, dialog_parent = ev.top)
			isGCSDone = 1
			redoGCS = 1
		endif else begin
			msg = 'Yes'
			if isGCSDone eq 1 then begin
				msg = Dialog_message('GCS fitting already done. Do you want to redo?', /question, dialog_parent = ev.top)
			endif
		
			if msg eq 'Yes' then begin
				setButtonSensitivity, 0
				; run gcs
				saved = run_gcs(datetime, filePrepared, fileDone)
				window, 0
				window, 1
				window, 20
				wdelete, 0
				wdelete, 1
				wdelete, 20
				setButtonSensitivity, 1 
				if saved eq 1 then begin
					doSelectBoundaries = 1
					fileDone = check_GCSDone(datetime, isDone = isGCSdone)
					restore, fileDone, /verbose
				endif
			endif 
			if msg eq 'No' then begin
				restore, fileDone, /verbose
				doSelectBoundaries = 1
			endif
			;	runGCS, date
		endelse
	endif
	
	if doSelectBoundaries eq 1 then begin
		setButtonSensitivity, 0
		tim = strmid(datetime[0], 9, strlen(datetime[0]))
		tim = repstr(tim, ':', '')
		; get angles (half width, angle to Earth, angle to STB and angle to STA
		hAn = get_half_angle(datetime, sgui, swire, ev.top)
		;hAn = get_ha_test(datetime, sgui, swire, ev.top)
		setButtonSensitivity, 1
		
		if isa(han, /array) eq 0 then begin
			msg = Dialog_message('CME cloud not in ecliptic', /info, dialog_parent = ev.top)
		endif else begin
			retAngles = han
		
			; save the values
			savPath = getenv('EAGEL_DIR')+'results/EAGEL4ELEvoHI/'+ELEvoHI+'/'
			if (file_exist(savPath) eq 0) then file_mkdir, savPath
			savFileName = savPath + 'EAGEL_results_'+repstr(datetime, ':', '')
		
			openw, unit, savFileName+'.dat', /get_lun
			printf, unit, 'Half angle:', han[0]
			printf, unit, 'Apex angle (Earth):', han[1]
			printf, unit, 'Apex angle (STB):',  han[2]
			printf, unit, 'Apex angle (STA):',  han[3]

			free_lun, unit

			halfAngle = han[0]
			apexE = han[1]
			apexSTB = han[2]
			apexSTA = han[3]
		
			fname = savFileName+'.sav'
			save, halfAngle, apexE, apexSTB, apexSTA, filename = fname
			print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
			print, 'file saved to ' + fname
		
			msg = Dialog_message('File saved to '+fname, /info, dialog_parent = ev.top)
		endelse
		
	endif

end





;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!! START of program !!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;+
; NAME:
;       widget_get_angles
;
; PURPOSE:
;       Main widget that. Initial window for the user interaction
;
; CALLING SEQUENCE:
;       widget_get_angles, ElevoHIDate, datetime, widPos
;
; INPUTS:
;       ELEvoHIDate: Date of the event, will be used as date for the resulting .sav file
;		datetime: date and time show in the widget: e.g.: '20101104T02:39:09' (format is important)
;		widgetPositions: Position where to place the window on the screen
;
; MODIFICATION HISTORY:
;       20181129: created by jhinterreiter
;-
pro widget_get_angles, ELEvoHIDate, datetime, widgetPositions


common widIds, btns
common angs, retAngles, ELEvoHI
common widLeader, widID

ELEvoHI = ELEvoHIDate
retAngles = -1

base = get_main_layout(datetime, 1, btnArr = btns, widgetPositions)

widID = base

WIDGET_CONTROL, base, /REALIZE


XMANAGER, 'widgetGetAngles', base;, /no_block

angles = retAngles


end