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
;       prepare_realtime_data
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
;		baseDiffTime: set this keyword to a time that should be the base for base difference images. e.g.: '02:39:09'
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
pro prepare_realtime_data, datetime, stdet, ladet, diffImgST, diffImgLA, baseST, baseLA, status = status, parent = parent
	common threshs, minthresh, maxthresh
;!!!! JUST FOR TEST!!!!!
if 0 eq 1 then begin
	date = '20200303'
	time = '21:24:09'
	;date = '20101026'
	;time = '14:39:09'
	datetime = date+'T'+time
	ladet = 'C2'
	stdet = 'cor2'
	rectify = 1
	diffImgST = 1
	diffImgLA = 1
	advanced = 1
	baseST = '20:24:09'
	baseLA = baseST
	basediffTime = ''
endif
; !!!! END JUST FOR TEST !!!!!
status = 0
date = strmid(datetime, 0, 8)
time = strmid(datetime, 9, 8)

stdet = strlowcase(stdet)

baseSTdate = strmid(baseST, 0,8)
baseSTtime = strmid(baseST, 9,8)

baseLAdate = strmid(baseLA, 0,8)
baseLAtime = strmid(baseLA, 9,8)

imgsize = 512

;setenv, 'LASCO_DIR=/nas/helio/data/LASCO/'
;setenv, 'SECCHI_LZ=/nas/helio/data/STEREO/secchi/'

;find images
laPath = getenv('LASCO_DIR')+ ladet+'/realtime/'+date+'/'
aPath = getenv('SECCHI_LZ')+'beacon/ahead/img/'+stdet+'/'+date+'/'

filesLa = file_search(laPath, '*.fts')
filesa = file_search(aPath, '*.fts')

if filesLa[0] eq '' or filesa[0] eq '' then begin
	msg = Dialog_message('Data not available! Please download!', /info, dialog_parent = parent)
	status = 0
endif else begin

	mreadfits, filesla, hdrl
	mreadfits, filesa, hdra
	hdrl_here = hdrl
	hdra_here = hdra

	dt_l=min(abs(anytim(hdrl.time_d$obs)-anytim(time)),min_l)
	l_img=laPath + hdrl[min_l].filename
	l_img_before=laPath + hdrl[min_l-1].filename
	LABaseTime = hdrl[min_l-1].date_d$obs + ' ' + hdrl[min_l-1].time_d$obs


	time_st=strmid(date,0,4)+'-'+strmid(date,4,2)+'-'+strmid(date,6,2)+'T'+time+'.000'
	dt_sta=min(abs(anytim(hdra.date_d$obs)-anytim(time_st)),min_a)
	a_img=aPath+hdra[min_a].filename
	a_img_before=aPath+hdra[min_a-1].filename
	ABaseTime = hdra[min_a-1].date_d$obs


	if diffImgST eq 2 then begin
		date = strmid(baseST, 0, 8)
		timeBSST = strmid(baseST, 9, 8)
		aPath = getenv('SECCHI_LZ')+'beacon/ahead/img/'+stdet+'/'+date+'/'
		filesa = file_search(aPath, '*.fts')
		mreadfits, filesa, hdra

		time_st=strmid(date,0,4)+'-'+strmid(date,4,2)+'-'+strmid(date,6,2)+'T'+timeBSST+'.000'
		dt_sta=min(abs(anytim(hdra.date_d$obs)-anytim(time_st)),min_abd)
		a_img_before=aPath+hdra[min_abd].filename
		ABaseTime = hdra[min_abd].date_d$obs
	endif

	if diffImgLA eq 2 then begin
		date = strmid(baseLA, 0, 8)
		timeBSLA = strmid(baseLA, 9, 8)
		laPath = getenv('LASCO_DIR')+ ladet+'/realtime/'+date+'/'

		filesLa = file_search(laPath, '*.fts')
		mreadfits, filesla, hdrl

		dt_l=min(abs(anytim(hdrl.time_d$obs)-anytim(timeBSLA)),min_lbd)
		l_img_before=laPath + hdrl[min_lbd].filename
		LABaseTime = hdrl[min_lbd].date_d$obs + ' ' + hdrl[min_lbd].time_d$obs
	endif

	;ima_final=scc_mk_image(a_img,minmax=[0.95,1.2],outsize=imgsize,outhdr=hdra2,/nologo,/nodatetime,/nopop)
	fits2map, l_img, mapL
	fits2map, a_img, mapA


	fits2map, l_img_before, mapLB
	fits2map, a_img_before, mapAB

	; STA
	scaling = 10000.

	minA = min(mapa.data)
	diffA = max(mapa.data)-min(mapa.data)
	sc = diffA/scaling
	dataA = (mapa.data - minA)/sc

	if diffImgST eq 0 then begin
		scAB = CONGRID(dataA, 512, 512, /INTERP)
	endif
	if diffImgST eq 1 or diffImgST eq 2 then begin
		minAB = min(mapab.data)
		diffAB = max(mapab.data)-min(mapab.data)
		sc = diffAB/scaling
		dataAB = (mapab.data - minAB)/sc

		scAB = dataA - dataAB
		scAB = CONGRID(scAB, 512, 512, /INTERP)
	endif


	; LASCO
	;mapFA = mapA
	;mapFA.data = mapA.data-mapAB.data

	minL = min(mapL.data)
	diffL = max(mapL.data)-min(mapL.data)
	sc = diffL/scaling
	dataL = (mapL.data - minL)/sc



	if diffImgLA eq 0 then begin
		scLB = CONGRID(dataL, 512, 512, /INTERP)
		;scLB = dataL
	endif
	if diffImgLA eq 1 or diffImgLA eq 2 then begin
		minLB = min(mapLB.data)
		diffLB = max(mapLB.data)-min(mapLB.data)
		sc = diffLB/scaling
		dataLB = (mapLB.data - minLB)/sc

		scLB = dataL - dataLB
		scLB = CONGRID(scLB, 512, 512, /INTERP)
	endif


	mapFL = mapL
	mapFL.data = mapL.data-mapLB.data
	mapfl.data = bytscl(mapfl.data, min=-100,max=200)

	scaledA = bytscl(mapa.data, min=min(mapa.data), max=max(mapa.data))
	scaledAB = bytscl(mapab.data, min=min(mapab.data), max=max(mapab.data))

	fa = scaledA-scaledAB

	print, 'Base time STA: ' + ABaseTime
	print, 'Base time LASCO: ' + LABaseTime


	cgStretch, /block, scLB, notify_pro = 'testNotify', title = 'LASCO Image, Time:' + mapL.time
	iml_final=Bytscl(scLB, min=minThresh, max=maxThresh)

	cgStretch, /block, scAB, notify_pro = 'testNotify', title = 'STA Image, Time:' + mapA.time
	ima_final=Bytscl(scAB, min=minThresh, max=maxThresh)



	msg = 'Yes'
	filePrepared = check_filesPrepared(datetime, isPrepared = isFilePrepared)
	if isfilePrepared then begin
		loadct, 0
		smallSize = imgsize/2

		r_iml = rebin(iml_final, smallSize, smallSize)
		r_ima = rebin(ima_final, smallSize, smallSize)
		r_imb = rebin(ima_final, smallSize, smallSize)
		window, 1, xsize=3*smallSize, ysize=smallSize, ypos = 0, xpos = 0, title = 'NEW:	STB: '+hdra_here[min_a].date_d$obs+'       Lasco '+ladet+':'+hdrl_here[min_l].time_d$obs+'       STA: '+hdra_here[min_a].date_d$obs
		tv, r_imb, 0
		tv, r_iml, 1
		tv, r_ima, 2

		restore, filePrepared
		r_iml = rebin(iml, smallSize, smallSize)
		r_ima = rebin(ima, smallSize, smallSize)
		r_imb = rebin(imb, smallSize, smallSize)
		window, 2, xsize=3*smallSize, ysize=smallSize, ypos = smallsize+30, xpos = 0, title = 'OLD:	STB: '+hdra.date_d$obs+'       Lasco '+ladet+':'+hdrl.time_d$obs+'       STA: '+hdra.date_d$obs
		tv, r_imb, 0
		tv, r_iml, 1
		tv, r_ima, 2
		
		msg = Dialog_message('Do you want to save the new images?', /question, dialog_parent = parent)
		window, 1
		window, 2
		wdelete, 1
		wdelete, 2
	endif


	if msg eq 'Yes' then begin
		iml = iml_final
		ima = ima_final
		hdrl = hdrl_here[min_l]
		hdra = hdra_here[min_a]
		imb = ima
		hdrb = hdra

		;hdrl = lasco_fitshdr2struct(hdrl)

		tim = strmid(time, 0, 2)+strmid(time, 3, 2)+strmid(time, 6, 2)
		savPath = getenv('EAGEL_DIR')+'/results/'+date+'/'
		if (file_exist(savPath) eq 0) then file_mkdir, savPath

		save, iml, hdrl, ima, hdra, imb, hdrb, filename = savPath+date+'_'+tim+'.sav'
	endif
	status = 1
endelse
end