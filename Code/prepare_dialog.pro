PRO prepareCleanup, ev
	window, 1
	wdelete, 1
	setButtonSensitivity, 1
	WIDGET_CONTROL, ev, /destroy
end

PRO prepareDialog_event, ev
	;print, 'changed'
END

Pro closePrepare_event, ev
	window, 1
	wdelete, 1
	setButtonSensitivity, 1
	WIDGET_CONTROL, ev.top, /destroy
end


; event when clicking on 'Process'
pro callPrepareData, ev, advanced
	; global variables to save position and selections from the window
	common widPrepare, isPrepare, datTim, stdet, ladet, rect, diffImg, adv
	common widGL, widgetGL
	common widPositon, widOffsetPos
	
	
	widget_control, widgetGL, tlb_get_offset = offset	
	widOffsetPos = offset
	
	widget_control, ev.id, get_value = myval
	txtStart = WIDGET_INFO( ev.top, FIND_BY_UNAME ='txtDatePrepare')
	widget_control, txtStart, get_value = datetime
	dpList = WIDGET_INFO( ev.top, FIND_BY_UNAME ='dropList_ST')
	SelItemST = widget_info(dpList, /Droplist_select)
	widget_control, dpList, get_value = ST_det
	dpList = WIDGET_INFO( ev.top, FIND_BY_UNAME ='dropList_LA')
	SelItemLA = widget_info(dpList, /Droplist_select)
	widget_control, dpList, get_value = LA_det
	btnRect = WIDGET_INFO( ev.top, FIND_BY_UNAME ='CBRectify')
	widget_control, btnRect, get_value = rectify
	btnDiff = WIDGET_INFO( ev.top, FIND_BY_UNAME ='CBDiff')
	widget_control, btnDiff, get_value = diff


	stdet = ST_det[SelItemSt]
	ladet = LA_det[selItemLA]
	rect = rectify
	adv = advanced
	diffImg = diff
	dattim = datetime
	isPrepare = 1

	
	filePrepared = check_filesPrepared(datetime, isPrepared = isFilePrepared)
	if isfilePrepared then begin
	
		msg = Dialog_message('Images already prepared. Do you want to redo?', /question, dialog_parent = ev.top)
		;window, 1
		;wdelete, 1
		if msg eq 'No' then isPrepare = 0
		if msg eq 'Yes' then begin	
			; close all the windows and get back to eagel.pro
			WIDGET_CONTROL, ev.top, /DESTROY
			WIDGET_CONTROL, widgetGL, /DESTROY
			;prepareData, datetime, ST_det[SelItemSt], LA_det[selItemLA], rectify, diff, advanced, ev.top, status = status
		endif
	endif else begin
		; close all the windows and get back to eagel.pro
		WIDGET_CONTROL, ev.top, /DESTROY
		WIDGET_CONTROL, widgetGL, /DESTROY
		;prepareData, datetime, ST_det[SelItemSt], LA_det[selItemLA], rectify, diff, advanced, ev.top, status = status
	endelse
	

end


pro advancedDLG_event, ev
	callPrepareData, ev, 1
;	WIDGET_CONTROL, ev.top, /destroy
END

pro prepareDLG_event, ev
	callPrepareData, ev, 0
;	WIDGET_CONTROL, ev.top, /destroy
END





;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!! START of program !!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;+
; NAME:
;       prepare_dialog
;
; PURPOSE:
;		Opens a dialog to select which images should be prepared/processed
;
; CALLING SEQUENCE:
;		prepare_dialog, ev.top, datetime
;
; INPUTS:
;       groupLeader: id of the calling widget
;		startDate: date shown in the window       
;
; MODIFICATION HISTORY:
;       20181129: created by jhinterreiter
;-
pro prepare_dialog, groupLeader, startDate
common widGL, widgetGL

widgetGl = groupLeader

basePrepare = widget_base(group_leader = groupLeader, xsize = 200, ysize = 185, frame = 0, title = 'Download Data', tab_mode = 1, /modal)
labDate = widget_label(basePrepare, value = 'Date:', /align_left, yoffset = 15)
txtDate = widget_text(basePrepare, value = startDate, uname = 'txtDatePrepare', yoffset = 10, xoffset = 50, /editable, /all_events);, event_pro='test_event')
labDetStereo = widget_label(basePrepare, value = 'Detector Stereo:', yoffset = 50)
labDetLasco = widget_label(basePrepare, value = 'Detector Lasco:', yoffset = 80)

drpListLASCO = widget_droplist(basePrepare, value = ['C2', 'C3'], uname = 'dropList_LA', Tab_mode = 1, xoffset = 100, yoffset = 70);, func_get_value = 'getVAlDLST')
drpListST = widget_droplist(basePrepare, value = ['COR2', 'COR1'], uname = 'dropList_ST', Tab_mode = 1, xoffset = 100, yoffset = 40);, func_get_value = 'getVAlDLST')

btnRectify = CW_BGROUP(basePrepare, 'Rectify', /COLUMN, /NONEXCLUSIVE, yoffset = 105, uname='CBRectify') 
btnDiff = CW_BGROUP(basePrepare, 'Diff Images', /COLUMN, /NONEXCLUSIVE, xoffset = 75, yoffset = 105, uname='CBDiff')


btnprepare = WIDGET_BUTTON(basePrepare, VALUE='Process', uvalue='PREPARE', xoffset = 10, yoffset = 160, event_pro = 'prepareDLG_event');, sensitive= 1)
btnadvanced = WIDGET_BUTTON(basePrepare, VALUE='Advanced', uvalue='ADVANCED', xoffset = 75, yoffset = 160, event_pro = 'advancedDLG_event');, sensitive= 1)
btnDone = WIDGET_BUTTON(basePrepare, VALUE='Done', uvalue = 'DONE', xoffset = 150, yoffset = 160, event_pro = 'closePrepare_event')


WIDGET_CONTROL, basePrepare, /REALIZE

XMANAGER, 'prepareDialog', basePrepare, cleanup = 'PrepareCleanup';, /no_block

end