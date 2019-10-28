;+
; NAME:
;       get_main_layout
;
; PURPOSE:
;       get the main layout of the widget
;
; CALLING SEQUENCE:
;       base = get_main_layout(date_time, 0, btnArr = btns, widPos)
;
; INPUTS:
;       datetime: date and time that should be shown in the widget
;		sensitive: button sensitivity (1 for sensitive, 0 for insensitive)
;		offsetPos: Position of the window on the screen
;
; OUTPUTS:
;       base: id of the widget
;
; KEYWORDS:
;		btnArr: array with buttons on the widget
;
; MODIFICATION HISTORY:
;       20180711: created by jhinterreiter
;-
function get_main_layout, datetime, sensitive, btnArr = btnArr, offsetPos

	xsize = offsetPos[0]
	ysize = offsetPos[1]
	title = 'EAGEL Tool'


	base = widget_base(xsize = xsize, ysize = ysize, frame = 0, title = title, /column, xoffset = offsetPos[2], yoffset = offsetPos[3])
	labStartDate = widget_label(base, value = 'Date:', /align_left, yoffset = 10)
	txtStartDate = widget_text(base, value = datetime, uname = 'txtStart', xoffset = 100, /editable, /all_events, tab_mode = 1, sensitive = sensitive);, event_pro='test_event')

	baseButtons = WIDGET_BASE(base, /ROW, /ALIGN_CENTER, tab_mode = 1)
	btnGetParameter = WIDGET_BUTTON(baseButtons, VALUE='Create EC cut', uvalue='createECcut', event_pro = 'createECcut_event', tab_mode = 1, sensitive = sensitive)
	btnGetParameter = WIDGET_BUTTON(baseButtons, VALUE='Run GCS', uvalue='runGCS', event_pro = 'runGCS_event', tab_mode = 1, sensitive = sensitive)
	;btnRunGCS = WIDGET_BUTTON(baseButtons, VALUE='run GCS', uvalue='RUN_GCS', event_pro = 'runGCS_event', /tab_mode);, sensitive= 1)
	btnPrepare = WIDGET_BUTTON(baseButtons, VALUE='Prepare Images', uvalue='PrepData', event_pro = 'prepare_event', tab_mode = 1, sensitive = sensitive)
	btnDownload = WIDGET_BUTTON(baseButtons, VALUE='Download Images', uvalue='DWLDIMGS', event_pro='downloadImgs_event', tab_mode = 1, sensitive = sensitive)
	btnClose = WIDGET_BUTTON(baseButtons, VALUE='Close', uvalue = 'CLOSE', event_pro = 'close_event', tab_mode = 1, sensitive =sensitive)

	childBtns = widget_info(baseButtons, /all_children)
	n_btns = widget_info(baseButtons, /n_children)

	btnArr = intarr(n_btns+1)
	for i = 0, n_btns-1 do begin
		btnArr[i] = childBtns[i]
	endfor
	btnArr[i] = txtStartDate


	baseTexts = WIDGET_BASE(base, /COLUMN, /ALIGN_Left, /tab_mode)
	labEmpty = widget_label(baseTexts, value = '', /align_left)
	labExpl = widget_label(baseTexts, value = 'Date:', /align_left)
	labExpl = widget_label(baseTexts, value = '    Date and time of the event (Format is YYYYMMDDThh:mm:ss)', /align_left)
;	labExpl = widget_label(baseTexts, value = '    Recommended times are: hh:08:09, hh:24:09, hh:39:09, hh:54:09', /align_left)
	labEmpty = widget_label(baseTexts, value = '', /align_left)
	labExpl = widget_label(baseTexts, value = 'Button "Get Angles":', /align_left)
	labExpl = widget_label(baseTexts, value = '    Opens GCS gui, subsequently creates ecliptic cut which is used to select the limits of the CME', /align_left)
	labEmpty = widget_label(baseTexts, value = '', /align_left)
	labExpl = widget_label(baseTexts, value = 'Button "Prepare Images":', /align_left)
	labExpl = widget_label(baseTexts, value = '    Processing of LASCO, STA, STB images so that they can be used for GCS fitting', /align_left)
	labEmpty = widget_label(baseTexts, value = '', /align_left)
	labExpl = widget_label(baseTexts, value = 'Button "Download Images":', /align_left)
	labExpl = widget_label(baseTexts, value = '    Downloads all necessary images', /align_left)
	labExpl = widget_label(baseTexts, value = '    Select time range large enough', /align_left)


	return, base
end