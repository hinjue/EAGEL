; to get the min and max threshold when cgstretch is called
pro testNotify, ob
	common threshs, minthresh, maxthresh
;	print, ob.minthresh
;	print, ob.maxthresh
	
	minthresh = ob.minthresh
	maxthresh = ob.maxthresh
end


;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!! START of program !!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;+
; NAME:
;       prepare_data
;
; PURPOSE:
;       Makes 'nice' images that can are used for GCS fitting
;
; CALLING SEQUENCE:
;		prepare_data, date_time, stdet, ladet, rect, diffImgST, diffImgLA, adv
;
; INPUTS:
;       date_time: date and time of the images to prepare. e.g.: '20101104T03:39:09' 
;		stdet: STEREO detector ('COR1' or 'COR2')
;		ladet: LASCO detector ('C2' or 'C3')
;		rectify: set to 1 if the LASCO image is upside down
;		diffImgST: set to 1 if a difference image is desired for STEREO
;		diffImgLA: set to 1 if a difference image is desired for LASCO
;		advanced: set to 1 if you want to run cgstretch for the images, otherwise standard parameter are used
;
; KEYWORDS:
;		status: 0 or 1: depending on the result of the program
;
; NOTE:
;       'SECCHI_LZ' has to be set! setenv, 'SECCHI_LZ=/home/jhinterreiter/data/stereo'
;		'LASCO_DIR' has to be set!
;		'EAGEL_DIR' hat to be set!
;
; MODIFICATION HISTORY:
;       20181129: created by jhinterreiter
;-
pro prepare_data, datetime, stdet, ladet, rectify, diffImgST, diffImgLA, advanced, baseST, baseLA, status = status, parent = parent
	common threshs, minthresh, maxthresh

status = 0

;!!!! JUST FOR TEST!!!!!
if 0 eq 1 then begin
	date = '20101104'
	time = '03:39:09'
	datetime = date+'T'+time
	ladet = 'C3'
	stdet = 'cor2'
	rectify = 1
	diffImgST = 0
	diffImgLA = 0
	advanced = 1
	baseST = '20101104T02:39:09'
	baseLA = baseST
endif
; !!!! END JUST FOR TEST !!!!!

date = strmid(datetime, 0, 8)
time = strmid(datetime, 9, 8)

stdet = strlowcase(stdet)


imgsize = 512


;find images
laPath = getenv('LASCO_DIR')+ ladet+'/'+date+'/'
aPath = getenv('SECCHI_LZ')+'L0/a/img/'+stdet+'/'+date+'/'
bPath = getenv('SECCHI_LZ')+'L0/b/img/'+stdet+'/'+date+'/'

if stdet eq 'cor1' then begin
	aPath = getenv('SECCHI_LZ')+'L0/a/seq/'+stdet+'/'+date+'/'
	bPath = getenv('SECCHI_LZ')+'L0/b/seq/'+stdet+'/'+date+'/'
endif

filesLa = file_search(laPath, '*.fts')
filesa = file_search(aPath, '*.fts')
filesb = file_search(bPath, '*.fts')

STBNotAvailable = 0

if filesLa[0] eq '' or (filesa[0] eq '' and filesb[0] eq '') then begin
	msg = Dialog_message('Data not available! Please download!', /info, dialog_parent = parent)
	status = 0
endif else begin

	if filesb[0] eq '' then STBNotAvailable = 1
	;mreadfits, '/home/jhinterreiter/data/lasco/monthly/2m_orcl_all.fts', ind, dat

	mreadfits, filesla, hdrl
	mreadfits, filesa, hdra
	if STBNotAvailable eq 0 then mreadfits, filesb, hdrb

	; get images and image before (for diffImages)
	dt_l=min(abs(anytim(hdrl.time_d$obs)-anytim(time)),min_l)
	l_img=laPath + hdrl[min_l].filename
	l_img_before=laPath + hdrl[min_l-1].filename
	LABaseTime = hdrl[min_l-1].date_d$obs + ' ' + hdrl[min_l-1].time_d$obs
	if diffImgLA eq 2 then begin
		dateBS = strmid(baseLA, 0, 8)
		timeBSLA = strmid(baseLA, 9, 8)
		laPath = getenv('LASCO_DIR')+ ladet+'/'+dateBS+'/'

		filesLa = file_search(laPath, '*.fts')
		mreadfits, filesla, hdrl_b

		dt_l=min(abs(anytim(hdrl_b.time_d$obs)-anytim(timeBSLA)),min_lbd)
		l_img_before=laPath + hdrl_b[min_lbd].filename
		LABaseTime = hdrl_b[min_lbd].date_d$obs + ' ' + hdrl_b[min_lbd].time_d$obs
	endif

	time_st=strmid(date,0,4)+'-'+strmid(date,4,2)+'-'+strmid(date,6,2)+'T'+time+'.000'
	dt_sta=min(abs(anytim(hdra.date_d$obs)-anytim(time_st)),min_a)
	a_img=aPath+hdra[min_a].filename
	a_img_before=aPath+hdra[min_a-1].filename
	ABaseTime = hdra[min_a-1].date_d$obs
	if stdet eq 'cor1' then a_img_after = aPath+hdra[min_a+1].filename

	if diffImgST eq 2 then begin
		dateBS = strmid(baseST, 0, 8)
		timeBSST = strmid(baseST, 9, 8)
		aPath = getenv('SECCHI_LZ')+'L0/a/img/'+stdet+'/'+dateBS+'/'
		filesa = file_search(aPath, '*.fts')
		mreadfits, filesa, hdra_b

		time_st_bs=strmid(dateBS,0,4)+'-'+strmid(dateBS,4,2)+'-'+strmid(dateBS,6,2)+'T'+timeBSST+'.000'
		dt_sta=min(abs(anytim(hdra_b.date_d$obs)-anytim(time_st_bs)),min_abd)
		a_img_before=aPath+hdra_b[min_abd].filename
		ABaseTime = hdra_b[min_abd].date_d$obs
	endif

	if STBNotAvailable eq 0 then begin
		dt_stb=min(abs(anytim(hdrb.date_d$obs)-anytim(time_st)),min_b)
		b_img=bPath+hdrb[min_b].filename
		b_img_before=bPath+hdrb[min_b-1].filename
		BBaseTime = hdrb[min_b-1].date_d$obs
		if stdet eq 'cor1' then b_img_after=bPath+hdrb[min_b+1].filename

		if diffImgST eq 2 then begin
			dateBS = strmid(baseST, 0, 8)
			timeBSST = strmid(baseST, 9, 8)
			bPath = getenv('SECCHI_LZ')+'L0/b/img/'+stdet+'/'+dateBS+'/'
			filesb = file_search(bPath, '*.fts')
			mreadfits, filesb, hdrb_b

			time_st_bs=strmid(dateBS,0,4)+'-'+strmid(dateBS,4,2)+'-'+strmid(dateBS,6,2)+'T'+timeBSST+'.000'
			dt_stb=min(abs(anytim(hdrb_b.date_d$obs)-anytim(time_st_bs)),min_bbd)
			b_img_before=bPath+hdrb_b[min_bbd].filename
			BBaseTime = hdrb_b[min_bbd].date_d$obs
		endif
	endif

	if diffImgST gt 0 then begin
		print, 'Base time STA: ' + ABaseTime
		print, 'Base time STB: ' + BBaseTime
	endif
	if diffImgLA gt 0 then print, 'Base time LASCO: ' + LABaseTime

	; !!!!! LASCO !!!!!!
	pan = imgsize/float(1024)
	
	if DiffImgLA ge 1 then begin
		iml2 = mk_img(l_img, -20, 80, hdrl2, use_model=2,pan=pan,/diff, /inmask, rectify = rectify, /no_display)
		iml1 = mk_img(l_img_before, -20, 80, hdrl1, use_model=2,pan=pan,/diff, /inmask, rectify = rectify, /no_display)


		imlok=iml2-iml1
		iml_final=bytscl(imlok,min=-10,max=20)
	endif else begin
		iml_final = mk_img(l_img,-20,80,hdrl2,use_model=2,/DIFF,/inmask,pan=pan,/DO_BYTSCL,/NO_DISPLAY, rectify = rectify)
	endelse
	
	hdrl2ST = lasco_fitshdr2struct(hdrl2)
	
	loadct, 0
	; run cg_stretch
	if advanced eq 1 then begin
		cgStretch, /block, iml_final, notify_pro = 'testNotify', title = 'LASCO Image, Time: '+ hdrl2ST.date_obs + ' ' + hdrl2ST.time_obs;, group_leader = groupleader
		iml_final=Bytscl(iml_final,min=minThresh, max=maxThresh)
	endif	
	
	widget_control, /hourglass
	
	
	; !!!!! STEREO !!!!!
	if stdet eq 'cor1' then begin
		a_img_new = [a_img_before, a_img, a_img_after]

		secchi_prep, a_img_new, hdra2, ima, outsize=imgsize, /polariz_on, /pb, /rotate_on, /rotinterp_on, /calimg_off
		ma=get_smask(hdra2)
		ima_final=ma*bytscl(sqrt(ima))

		if STBNotAvailable eq 0 then begin
			b_img_new = [b_img_before, b_img, b_img_after]
			secchi_prep, b_img_new, hdrb2, imb, outsize=imgsize, /polariz_on, /pb, /rotate_on, /rotinterp_on, /calimg_off
			mb=get_smask(hdrb2)
			imb_final=mb*bytscl(sqrt(imb))
		endif

	endif else begin

		; !!!!! STA !!!!!!
		if diffImgST ge 1 then begin
			ima1ok=scc_mk_image(a_img_before,outsize=imgsize,outhdr=hdra1,/nologo,/nodatetime,/nopop,/noscale,/norotate);, /mask_occ)
			ima2ok=scc_mk_image(a_img,outsize=imgsize,outhdr=hdra2,/nologo,/nodatetime,/nopop,/noscale,/norotate);, /mask_occ)
			imaDiff=ima2ok-ima1ok
			imabs = bytscl(imadiff,min=-0.1, max=0.1)
			mask=get_smask(hdra2)
			ima_final=mask*imabs
		endif else begin
			ima_final=scc_mk_image(a_img,minmax=[0.95,1.2],outsize=imgsize,outhdr=hdra2,/nologo,/nodatetime,/nopop)
		endelse

		if STBNotAvailable eq 0 then begin
			; !!!!! STB !!!!!!
			if diffImgST ge 1 then begin
				imb1ok=scc_mk_image(b_img_before,outsize=imgsize,outhdr=hdrb1,/nologo,/nodatetime,/nopop,/noscale,/norotate);, /mask_occ)
				imb2ok=scc_mk_image(b_img,outsize=imgsize,outhdr=hdrb2,/nologo,/nodatetime,/nopop,/noscale,/norotate);, /mask_occ)
				imbDiff=imb2ok-imb1ok
				imbbs = bytscl(imbdiff,min=-0.1, max=0.1)
				mask=get_smask(hdrb2)
				imb_final=mask*imbbs
			endif else begin
				imb_final=scc_mk_image(b_img,minmax=[0.95,1.2],outsize=imgsize,outhdr=hdrb2,/nologo,/nodatetime,/nopop)
			endelse
		endif

	endelse
	
	; to stop hourglass cursor
	w = widget_event(/nowait)
	loadct, 0
	if advanced eq 1 then begin
		cgStretch, ima_final, /block, notify_pro = 'testNotify', title = 'STA Image, Time: ' + hdra2.date_obs
		ima_final=Bytscl(ima_final,min=minThresh, max=maxThresh)
		loadct, 0
		if STBNotAvailable eq 0 then begin
			cgStretch, imb_final, /block, notify_pro = 'testNotify', title = 'STB Image, Time: ' + hdrb2.date_obs
			imb_final=Bytscl(imb_final,min=minThresh, max=maxThresh)
		endif
	endif
	
	widget_control, /hourglass

	iml_new = iml_final
	hdrl = hdrl2st
	ima_new = ima_final
	hdra = hdra2
	if STBNotAvailable eq 0 then begin
		imb_new = imb_final
		hdrb = hdrb2
	endif else begin
		imb = -1
		hdrb = -1
	endelse
	
	
	loadct, 0

	smallSize = imgsize/2
	if STBNotAvailable eq 0 then begin
		r_iml = rebin(iml_new, smallSize, smallSize)
		r_ima = rebin(ima_new, smallSize, smallSize)
		r_imb = rebin(imb_new, smallSize, smallSize)
		window, 1, xsize=3*smallSize, ysize=smallSize, ypos = 0, xpos = 0, title = 'NEW:	STB: '+hdrb.date_obs+'       Lasco '+ladet+':'+hdrl.time_obs+'       STA: '+hdra.date_obs
		tv, r_imb, 0
		tv, r_iml, 1
		tv, r_ima, 2
	endif else begin
		r_iml = rebin(iml_new, smallSize, smallSize)
		r_ima = rebin(ima_new, smallSize, smallSize)
		
		window, 1, xsize=2*smallSize, ysize=smallSize, ypose = 0, xpos = 0, title = 'NEW:	Lasco '+ladet+':'+hdrl.time_obs+'       STA: '+hdra.date_obs
		tv, r_iml, 0
		tv, r_ima, 1
	endelse
	
	msg = 'Yes'
	filePrepared = check_filesPrepared(datetime, isPrepared = isFilePrepared)
	if isfilePrepared then begin

		restore, filePrepared
		if STBNotAvailable eq 0 then begin
			r_iml = rebin(iml, smallSize, smallSize)
			r_ima = rebin(ima, smallSize, smallSize)
			r_imb = rebin(imb, smallSize, smallSize)
			window, 2, xsize=3*smallSize, ysize=smallSize, ypos = smallsize+30, xpos = 0, title = 'OLD:	STB: '+hdrb.date_obs+'       Lasco '+ladet+':'+hdrl.time_obs+'       STA: '+hdra.date_obs
			tv, r_imb, 0
			tv, r_iml, 1
			tv, r_ima, 2
		endif else begin
			r_iml = rebin(iml, smallSize, smallSize)
			r_ima = rebin(ima, smallSize, smallSize)
		
			window, 2, xsize=2*smallSize, ysize=smallSize, ypos = smallsize+30, xpos = 0, title = 'OLD:	Lasco '+ladet+':'+hdrl.time_obs+'       STA: '+hdra.date_obs
			tv, r_iml, 0
			tv, r_ima, 1
		endelse
		
		msg = Dialog_message('Do you want to save the new images?', /question, dialog_parent = parent)
		window, 1
		window, 2
		wdelete, 1
		wdelete, 2
	endif

	
	if msg eq 'Yes' then begin
		ima = ima_new
		imb = imb_new
		iml = iml_new
		tim = strmid(time, 0, 2)+strmid(time, 3, 2)+strmid(time, 6, 2)
	
		savPath = getenv('EAGEL_DIR')+'/results/'+date+'/'
		if (file_exist(savPath) eq 0) then file_mkdir, savPath
	
		;save the images
		save, iml, hdrl, ima, hdra, imb, hdrb, filename = savPath+date+'_'+tim+'.sav'
	endif

	status = 1
	; to stop hourglass cursor
	w = widget_event(/nowait)

endelse
end