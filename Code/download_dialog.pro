
PRO DownloadDialog_event, ev
;	print, 'changed'
END

Pro closeDownload_event, ev
;	common userDecision, decDownload
;	decdownload = 0
	WIDGET_CONTROL, ev.top, /destroy
end


; is called when button 'download' is pressed
pro downloadDW_event, ev
;	common userDecision, decDownload	
	common realTimeImages, rtActive
	txtStart = WIDGET_INFO( ev.top, FIND_BY_UNAME ='txtStartDownload')
	widget_control, txtStart, get_value = startDate
	txtEnd = WIDGET_INFO( ev.top, FIND_BY_UNAME ='txtEndDownload' )
	widget_control, txtEnd, get_value = endDate
	dpList = WIDGET_INFO( ev.top, FIND_BY_UNAME ='dropList_ST')
	SelItemST = widget_info(dpList, /Droplist_select)
	widget_control, dpList, get_value = ST_det
	dpList = WIDGET_INFO( ev.top, FIND_BY_UNAME ='dropList_LA')
	SelItemLA = widget_info(dpList, /Droplist_select)
	widget_control, dpList, get_value = LA_det
	
	
	labINfo = WIDGET_INFO( ev.top, FIND_BY_UNAME ='LABINFO')
	widget_control, labINfo, set_value = 'Donwload may take a while...'
	
;	print, startDate, endDate, ST_det[SelItemSt], LA_det[selItemLA]
	widget_control, /hourglass
	if rtActive eq 0 then download_images, startdate, enddate, ST_det[SelItemSt], LA_det[selItemLA], status = status
	if rtActive eq 1 then download_realtime_images, ST_det[SelItemSt], LA_det[selItemLA], startdate, status = status
	if status eq 1 then widget_control, labINfo, set_value = 'Donwload complete!'
	if status eq 0 then begin
		msg = Dialog_message('Downloading images did not work', /error, dialog_parent = ev.top)
		widget_control, labInfo, set_value = 'Something went wrong!'
	endif
;	decDownload = status
END








;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!! START of program !!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;+
; NAME:
;       download_dialog
;
; PURPOSE:
;       creates a window to select the startdate, enddate, LASCO and STEREO detectors
;		calls download_images
;
; CALLING SEQUENCE:
;       download_dialog, ev.top, '20101104T02:39:09'
;
; INPUTS:
;       groupLeader: id of the calling widget
;		startDate: date shown in the window
;
; MODIFICATION HISTORY:
;       20181129: created by jhinterreiter
;-
pro download_dialog, groupLeader, startDate
common realTimeImages, rtActive

baseDownload = widget_base(group_leader = groupLeader, xsize = 450, ysize = 135, frame = 0, title = 'Download Images', tab_mode = 1, /modal)
;baseDownload = widget_base(xsize = 512, ysize = 512, frame = 0, title = 'Download Data', tab_mode = 1)
labStartDate = widget_label(baseDownload, value = 'Start date:', /align_left, yoffset = 15)
txtStartDate = widget_text(baseDownload, value = startDate, uname = 'txtStartDownload', yoffset = 10, xoffset = 100, /editable, /all_events);, event_pro='test_event')
labEndDate = widget_label(baseDownload, value = 'End date:', /align_left, yoffset = 45)
txtEndDate = widget_text(baseDownload, value = startDate, uname = 'txtEndDownload', yoffset = 40, xoffset = 100, /editable)
labDetStereo = widget_label(baseDownload, value = 'Detector Stereo:', yoffset = 15, xoffset = 250)
labDetLasco = widget_label(baseDownload, value = 'Detector Lasco:', yoffset = 45, xoffset = 250)

drpListLASCO = widget_droplist(baseDownload, value = ['C2', 'C3'], uname = 'dropList_LA', Tab_mode = 1, xoffset = 345, yoffset = 35);, func_get_value = 'getVAlDLST')
if rtActive eq 1 then drpListST = widget_droplist(baseDownload, value = ['COR2'], uname = 'dropList_ST', Tab_mode = 1, xoffset = 345, yoffset = 5);, func_get_value = 'getVAlDLST')
if rtActive eq 0 then drpListST = widget_droplist(baseDownload, value = ['COR2', 'COR1'], uname = 'dropList_ST', Tab_mode = 1, xoffset = 345, yoffset = 5);, func_get_value = 'getVAlDLST')


btnClose = WIDGET_BUTTON(baseDownload, VALUE='Done', uvalue = 'CLOSE', xoffset = 400, yoffset = 100, event_pro = 'closeDownload_event')
btnDownload = WIDGET_BUTTON(baseDownload, VALUE='Download', uvalue='DOWNLOAD', xoffset = 10, yoffset = 100, event_pro = 'downloadDW_event');, sensitive= 1)
labInfo = widget_label(baseDownload, value = '', uname = 'LABINFO', xoffset = 75, yoffset = 100, /align_center, xsize = 300, ysize = 20)


WIDGET_CONTROL, baseDownload, /REALIZE

XMANAGER, 'DownloadDialog', baseDownload;, /no_block

end