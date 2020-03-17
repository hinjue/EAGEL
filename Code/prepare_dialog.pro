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
	common widPrepare, isPrepare, datTim, stdet, ladet, rect, diffImgST, diffImgLA, adv, baseST, baseLA
	common widGL, widgetGL
	common widPositon, widOffsetPos
	
	
	widget_control, widgetGL, tlb_get_offset = offset	
	widOffsetPos = offset
	
	olddatetime = datTim
	
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
	

	btnLAdirect = WIDGET_INFO(ev.top, FIND_BY_UNAME ='LAdirect')
	btnLARD = WIDGET_INFO(ev.top, FIND_BY_UNAME ='LARD')
	btnLABD = WIDGET_INFO(ev.top, FIND_BY_UNAME ='LABD')
	directSelect = widget_info(btnLAdirect, /button_set)
	rdSelect = widget_info(btnLARD, /button_set)
	bdSelect = widget_info(btnLABD, /button_set)
	txtLABD = WIDGET_INFO( ev.top, FIND_BY_UNAME ='txtBDLA')
	widget_control, txtLABD, get_value = baseLA

	LAdiffSelect = 0

	if directSelect eq 1 then LAdiffSelect = 0
	if rdSelect eq 1 then LAdiffSelect = 1
	if bdSelect eq 1 then LAdiffSelect = 2



	btnSTdirect = WIDGET_INFO(ev.top, FIND_BY_UNAME ='STdirect')
	btnSTRD = WIDGET_INFO(ev.top, FIND_BY_UNAME ='STRD')
	btnSTBD = WIDGET_INFO(ev.top, FIND_BY_UNAME ='STBD')
	directSelect = widget_info(btnSTdirect, /button_set)
	rdSelect = widget_info(btnSTRD, /button_set)
	bdSelect = widget_info(btnSTBD, /button_set)
	txtSTBD = WIDGET_INFO( ev.top, FIND_BY_UNAME ='txtBDST')
	widget_control, txtSTBD, get_value = baseST

	STdiffSelect = 0

	if directSelect eq 1 then STdiffSelect = 0
	if rdSelect eq 1 then STdiffSelect = 1
	if bdSelect eq 1 then STdiffSelect = 2


	stdet = ST_det[SelItemSt]
	ladet = LA_det[selItemLA]
	rect = rectify
	adv = advanced
	diffImgST = STdiffSelect
	diffImgLA = LAdiffSelect
	dattim = datetime
	isPrepare = 1
	
	filePrepared = check_filesPrepared(datetime, isPrepared = isFilePrepared)
	if isfilePrepared then begin

		if datetime ne olddatetime then begin	
			imgsize = 256
			restore, filePrepared
			r_iml = rebin(iml, imgsize, imgsize)
			r_ima = rebin(ima, imgsize, imgsize)
			r_imb = rebin(imb, imgsize, imgsize)


			window, 1, xsize=3*imgsize, ysize=imgsize;, title = 'STB: '+hdrb.date_obs+'       Lasco '+ladet+':'+hdrl.time_obs+'       STA: '+hdra.date_obs
			tv, r_imb, 0
			tv, r_iml, 1
			tv, r_ima, 2
		endif
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
		
		window, 1, xsize = 1, ysize = 1
		wdelete, 1
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
	common realTimeImages, rtActive

	yr = strmid(startdate, 0, 4)
	mo = strmid(startdate, 4, 2)
	dy = strmid(startdate, 6, 2)

	stDate = yr+'-'+mo+'-'+dy+strmid(startDate, 8, 12)

	bsStDate = anytim(anytim(stDate) - 60*60., /ccsds)
	yr = strmid(bsStDate, 0, 4)
	mo = strmid(bsStDate, 5, 2)
	dy = strmid(bsStDate, 8, 2)
	baseSTDate = yr + mo + dy + strmid(bsStDate, 10, 9)
	baseLADate = baseSTDate

	widgetGl = groupLeader

	basePrepare = widget_base(group_leader = groupLeader, xsize = 500, ysize = 150, frame = 0, title = 'Download Data', tab_mode = 1, /modal)
	;basePrepare = widget_base(xsize = 350, ysize = 150, frame = 0, title = 'Download Data', tab_mode = 1)
	labDate = widget_label(basePrepare, value = 'Date:', /align_left, yoffset = 15)
	txtDate = widget_text(basePrepare, value = startDate, uname = 'txtDatePrepare', yoffset = 10, xoffset = 50, /editable, /all_events, xsize = 71);, event_pro='test_event')
	labDetStereo = widget_label(basePrepare, value = 'Detector Stereo:', yoffset = 50)
	labDetLasco = widget_label(basePrepare, value = 'Detector Lasco:', yoffset = 80)


	drpListLASCO = widget_droplist(basePrepare, value = ['C2', 'C3'], uname = 'dropList_LA', Tab_mode = 1, xoffset = 100, yoffset = 70);, func_get_value = 'getVAlDLST')
	if rtActive eq 0 then drpListST = widget_droplist(basePrepare, value = ['COR2'], uname = 'dropList_ST', Tab_mode = 1, xoffset = 100, yoffset = 40);, func_get_value = 'getVAlDLST')
	if rtActive eq 1 then drpListST = widget_droplist(basePrepare, value = ['COR2'], uname = 'dropList_ST', Tab_mode = 1, xoffset = 100, yoffset = 40);, func_get_value = 'getVAlDLST')

	;btnDiffST = CW_BGROUP(basePrepare, 'RD', /COLUMN, /NONEXCLUSIVE, xoffset = 175, yoffset = 40, uname='CBDiffST')
	;labDate = widget_label(basePrepare, value = 'BD:', /align_left, yoffset = 48, xoffset = 300)
	txtbsST = widget_text(basePrepare, value = baseSTDate, uname = 'txtBDST', yoffset = 40, xoffset = 325, /editable, /all_events, xsize = 25);, event_pro='test_event')
	btnRectify = CW_BGROUP(basePrepare, 'Rectify', /COLUMN, /NONEXCLUSIVE, xoffset = 175, yoffset = 95, uname='CBRectify') 
	;btnDiffLA = CW_BGROUP(basePrepare, 'RD', /COLUMN, /NONEXCLUSIVE, xoffset = 175, yoffset = 70, uname='CBDiffLA')
	;labDate = widget_label(basePrepare, value = 'BD:', /align_left, yoffset = 78, xoffset = 300)
	txtbsLA = widget_text(basePrepare, value = baseLADate, uname = 'txtBDLA', yoffset = 70, xoffset = 325, /editable, /all_events, xsize = 25);, event_pro='test_event')




	btnprepare = WIDGET_BUTTON(basePrepare, VALUE='Process', uvalue='PREPARE', xoffset = 20, yoffset = 120, event_pro = 'prepareDLG_event');, sensitive= 1)
	if rtActive eq 0 then btnadvanced = WIDGET_BUTTON(basePrepare, VALUE='Advanced', uvalue='ADVANCED', xoffset = 227, yoffset = 120, event_pro = 'advancedDLG_event', sensitive= pro_exists('cgstretch'))
	btnDone = WIDGET_BUTTON(basePrepare, VALUE='Done', uvalue = 'DONE', xoffset = 450, yoffset = 120, event_pro = 'closePrepare_event')


	tlb = Widget_Base(basePrepare, Title=' Radio Buttons', Column=3, yoffset = 40, xoffset = 175, /Exclusive)
	btnDirectST = Widget_Button(tlb, Value='Direct', uname='STdirect')
	btnRDST = Widget_Button(tlb, Value='RD', uname='STRD')
   	btnBDST = Widget_Button(tlb, Value='BD:', uname='STBD')
   	Widget_Control, btnDirectST, Set_Button=1

   	tlb = Widget_Base(basePrepare, Title=' Radio Buttons', Column=3, yoffset = 70, xoffset = 175, /Exclusive)
	btnDirectLA = Widget_Button(tlb, Value='Direct', uname='LAdirect')
	btnRDLA = Widget_Button(tlb, Value='RD', uname='LARD')
   	btnBDLA = Widget_Button(tlb, Value='BD:', uname='LABD')
   	Widget_Control, btnDirectLA, Set_Button=1

	filePrepared = check_filesPrepared(startDate, isPrepared = isFilePrepared)
	if isfilePrepared then begin
		imgsize = 256
		restore, filePrepared
		r_iml = rebin(iml, imgsize, imgsize)
		r_ima = rebin(ima, imgsize, imgsize)
		r_imb = rebin(imb, imgsize, imgsize)

		window, 1, xsize=3*imgsize, ysize=imgsize, title = 'STB:        Lasco        STA: '
		tv, r_imb, 0
		tv, r_iml, 1
		tv, r_ima, 2
	end

	WIDGET_CONTROL, basePrepare, /REALIZE
	
	
	XMANAGER, 'prepareDialog', basePrepare, cleanup = 'PrepareCleanup';, /no_block
	
	


end