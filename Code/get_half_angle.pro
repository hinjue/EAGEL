function getAngle, x, y
	
	angle = atan(x/y)*!radeg
	
	if y lt 0 then begin
		if x lt 0 then begin
			angle = angle-180
		endif else angle = 180+angle
	endif

	return, angle
end






;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!! START of program !!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
;+
; NAME:
;       get_half_angle
;
; PURPOSE:
;       plots the ecliptic cut for the user, which has to define the boundaries of the CME
;
; CALLING SEQUENCE:
;      hAn = get_half_angle('20101104T02:39:09', sgui, swire, ev.top)
;
; INPUTS:
;       datetime: date and time of the desired event (format is important)
;		sgui: structure from GCS fitting
;		swire: structure from GCS fitting
;		parent: id of the calling widget
;
; OUTPUTS:
;       2D array with 4 entries:
;			0: Half width
;			1: angle to Earth
;			2: angle to STB
;			3: angle to STA
;
; MODIFICATION HISTORY:
;       20180711: created by jhinterreiter
;-

function get_half_angle, datetime, sgui, swire, parent

	date = strmid(datetime, 0, 8)

	hr = strmid(datetime,9,2)
	mi = strmid(datetime,12,2)
	se = strmid(datetime,15,2)
	tim = hr+mi+se

	filesPath = getenv('EAGEL_DIR')+'/results/'+date+'/'
	if isa(sgui, /array) eq 1 then begin
		filecnt = 1
		erDate = sgui.eruptiondate
		times = strmid(erDate, strpos(erDate, 'T')+1, 8)
	endif else begin
		files = file_search(filesPath+date+'_'+tim+'params.sav')
		filecnt = n_elements(files)

		pos = strpos(files, '_', /reverse_search)
		times = strmid(files, pos[0]+1, 6)

		restore, files, /verbose
	endelse
	print, 'creating ecliptic cut...'

	widget_control, /hourglass

	apexPositions = fltarr(2, 1)
	listX = list()
	listy = list()

	plotPath = filespath+'plots/'

	; get the values from the ecliptic cut
	res = get_ecliptic_cut(sgui, apexPos = apexPos, swire = swire, /correctForTiltOfSolarRotAx)
	
	; to stop hourglass cursor
	w = widget_event(/nowait)
	print, 'ecliptic cut available'
	
	if isa(res, /array) eq 1 then begin

		listX.add, reform(res[0,*])
		listy.add, reform(res[1,*])
		apexPositions[0,0] = apexPos[0]
		apexPositions[1,0] = apexPos[1]


		yVals = listy[0]
		xVals = listx[0]

		points = dblarr(2, n_elements(xvals))
		points[0,*]=xvals
		points[1,*]=yvals

		radius = sqrt(xvals*xvals + yvals*yvals)
		indFarestPoint = where(radius eq max(radius))

		indMinX = where(xvals eq min(xvals))
		indMaxX = where(xvals eq max(xvals))
		indmaxy = where(yvals eq max(yvals))

		if(n_elements(indmaxy) gt 1) then begin
			imy = indmaxy
			indmaxy = indmaxy[where(indmaxy eq where(radius eq max(radius[indmaxy])))]
		endif


		plotRangeX = [min(listx[filecnt-1]), max(listx[filecnt-1])]
		plotRangey = [min(listy[filecnt-1]), max(listy[filecnt-1])]

		minx = min(plotrangeX)
		;if (min(plotrangex) gt -1) then minx = -1

		xDiff = plotRangeX[1] - minx;max(xaxis)-min(xaxis)
		yDiff = plotRangey[1] - plotRangey[0];max(yaxis)-min(yaxis)

		maxDiff = round(max([xdiff, ydiff])*1.3)
		xrange = [minx-maxdiff*0.1, minx-maxdiff*0.1 + maxDiff]
		yrange = [min(plotRangey)-maxdiff*0.1, min(plotRangeY)-maxdiff*0.1 + maxDiff]

		;xrange = [-10, 15]
		;yrange = [-5, 20]

		x = findgen(10)
		y = x

		;; Make a vector of 16 points, A[i] = 2pi/16:
			Alpha = FINDGEN(17) * (!PI*2/16.)
			;; Define the symbol to be a unit circle with 16 points, ;; and set the filled flag:
			USERSYM, COS(Alpha), SIN(Alpha), /FILL


		cols = intarr(filecnt)
		savePlot = 0
		loadct, 0
		if savePlot eq 1 then begin
			!p.multi = [0, 1, 3]
			set_plot, 'ps'
			posUnder = strpos(files, '_', /reverse_search)+1
			timFiles = strmid(files, posUnder, 6)
			device, filename = plotPath+'/'+date+'.ps', xsize = 15, ysize = 25, xoffset = 2, yoffset = 2, encaps = 0
		endif

		;plot for the USER to select the boundaries of the CME
		window, 0, xsize = 750, ysize = 750
		plot, x, y, xrange = xrange, yrange = yrange, xstyle = 1, ystyle = 1 $
		;	, position = [0.3, 0.7, 0.8, 1.0] $
			, /nodata, title = 'Define CME boundaries, use left and right mouse buttons'
	
	

		directionsapex = fltarr(filecnt)
		directionsfPoint = fltarr(filecnt)
		directionsMinx = fltarr(filecnt)
		directionsMaxx = fltarr(filecnt)
		for i = 0, filecnt-1 do begin
			xA = listx[i]
			yA = listy[i]
			col = (256./filecnt)*(i+1)-1
			cols[i]= col
			oplot, xa, yA, psym = 8, symsize = 0.3, color = col
	
			arrow, 0, 0, 0, !y.crange[1]-0.03*maxdiff, /data, color = cgcolor('blue')
			xyouts, 0, !y.crange[1]-0.02*maxdiff, 'to Earth', /data, color = cgcolor('blue')
	
	
			directionsApex[i] = atan(apexPositions[0,i]/apexPositions[1,i])
			directionsFPoint[i] = atan(xvals[indFarestPoint]/yvals[indFarestPoint])
			directionsMinx[i] = atan(xvals[indminx]/yvals[indminx])
			directionsMaxx[i] = atan(xvals[indmaxx]/yvals[indmaxx])
		endfor

		oplot, xvals[indminx], yvals[indminx], psym = 2, color = cgcolor('green')
		oplot, xvals[indmaxx], yvals[indmaxx], psym = 2, color = cgcolor('green')
		oplot, xvals[indmaxy], yvals[indmaxy], psym = 2, color = cgcolor('green')
		oplot, xvals[indFarestPoint], yvals[indFarestPoint], psym = 2, color = cgcolor('red')


		al_legend, times, /top, box = 0, charsize = 0.7, textcolors = cols


		xrange = !x.crange
		yrange = !y.crange

		diffx = xrange[1]-xrange[0]
		diffy = yrange[1]-yrange[0]

		xminB = xrange[0]+0.8*diffx
		xmaxB = xrange[0]+0.95*diffx

		yminB = yrange[0]+0.9*diffy
		ymaxB = yrange[0]+0.95*diffy


		loadct, 0

		; 'Button' to confirm selection
		POLYFILL, [xminB,xmaxB,xmaxb,xminb], [yminB, yminB,ymaxB, ymaxB], COLOR = cgcolor('gray'), /data
		xyouts, xrange[0]+0.84*diffx, yrange[0]+0.915*diffy, 'Done', color = cgcolor('black'), /data, charsize = 2



		print, 'Click on the screen to define the boundaries: '
		print, 'Left button for left boundary'
		print, 'Right button for right boundary'
		print, 'Middle button to exit'
		cursor, xPos, yPos, /norm, /down

		leftX = 0
		leftY = 0
		rightX = 0
		rightY = 0

		;WHILE (!MOUSE.button NE 2) DO BEGIN
		msg = ''
		while msg ne 'Yes' do begin
			done = 0
			; do until 'OK' is clicked
			WHILE (!MOUSE.button NE 2) and done ne 1 DO BEGIN

				cursor, xpos, ypos, /data, /down
	
				if xpos gt xminB and xpos lt xmaxB and ypos gt yminB and ypos lt ymaxB then begin
					done = 1
				endif else begin
					if !MOUSE.button eq 1 then begin
						leftX = xpos
						leftY = ypos
					endif
	
					if !MOUSE.button eq 4 then begin
						rightX = xpos
						rightY = ypos
					endif

					window, 0, xsize = 750, ysize = 750
					plot, x, y, xrange = xrange, yrange = yrange, xstyle = 1, ystyle = 1 $
				;	, position = [0.3, 0.7, 0.8, 1.0] $
					, /nodata, title = 'Define CME boundaries, use left and right mouse buttons'
	
					for i = 0, filecnt-1 do begin
						xA = listx[i]
						yA = listy[i]
						col = (256./filecnt)*(i+1)-1
						cols[i]= col
						oplot, xa, yA, psym = 8, symsize = 0.3, color = col
	
						arrow, 0, 0, 0, !y.crange[1]-0.03*maxdiff, /data, color = cgcolor('blue')
						xyouts, 0, !y.crange[1]-0.02*maxdiff, 'to Earth', /data, color = cgcolor('blue')
	
					endfor

					al_legend, times, /top, box = 0, charsize = 0.7, textcolors = cols
					PLOTS,[0,leftx], [0,lefty], /data, color = cgcolor('red')
					PLOTS,[0,rightx], [0,righty], /data, color = cgcolor('green')
		
					POLYFILL, [xminB,xmaxB,xmaxb,xminb], [yminB, yminB,ymaxB, ymaxB], COLOR = cgcolor('gray'), /data
					xyouts, xrange[0]+0.84*diffx, yrange[0]+0.915*diffy, 'Done', color = cgcolor('black'), /data, charsize = 2
			;		xyouts, xrange[0]+0.5*diffx, yrange[0]+0.915*diffy, 'use left and right mouse buttons', color = cgcolor('black'), /data, charsize = 1.5

				endelse	
			ENDWHILE

			yr = strmid(datetime, 0,4)
			mn = strmid(datetime, 4,2)
			dy = strmid(datetime, 6,2)
			time = strmid(datetime, 9, 9)

			stDate = yr+'-'+mn+'-'+dy+'T'+time
			;stDate = '2008-12-01T00:00:00'

			sta = get_stereo_coord(stdate, 'STA', system = 'HEE', /meter, /novelocity)
			stb = get_stereo_coord(stdate, 'STB', system = 'HEE', /meter, /novelocity)

			ang = -90./!radeg
			RMat = [[cos(ang),-sin(ang)],$
				[sin(ang), cos(ang)]]

			rsun = 695508000

			sta = sta/rsun
			stb = stb/rsun

			staRot = rmat # sta[0:1]
			stbRot = rmat # stb[0:1]

			stax = staRot[0]
			stay = staRot[1]

			stbx = stbRot[0]
			stby = stbRot[1]
		
			; plot line to STA and STB
			plots, [0, stbx], [0, stby], /data, color = cgcolor('blue')
			plots, [0, stax], [0, stay], /data, color = cgcolor('red')



			angleRight = getAngle(rightx, righty)
			angleLeft = getAngle(leftx, lefty)

			ApexAngle = (angleRight+angleleft)/2
			halfAngle = angleRight - apexAngle

			AngleSTB = getAngle(stbx, stby)
			AngleSTA = getAngle(stax, stay)

			ApexAngleSTB = angleSTB - apexangle
			apexAngleSTA = apexangle - angleSTA

			oplot, xvals[indFarestPoint], yvals[indFarestPoint], psym = 2, color = cgcolor('red')
			oplot, fltarr(1) + apexpositions[0], fltarr(1)+apexpositions[1], psym = 2, color = cgcolor('green')

			maxx = max(plotrangex)
			maxy = max(plotrangey)
		
			range = sqrt(maxx*maxx+maxy*maxy)

			plots, [0, range*sin(apexangle/!radeg)], [0, range*cos(apexAngle/!radeg)], /data, color = cgcolor('yellow')

			;print, 'Left: ', angleLeft
			;print, 'Right: ', angleRight
			;print, 'Apex: ', apexangle


			if savePlot eq 1 then begin
				device, /close
				set_plot, 'x'
				!p.multi = 0
			endif


			hAngleCal = (directionsMaxx - directionsMinx)/2
			hangleMinApex = (directionsApex-directionsMinx)
			hangleMaxApex = (directionsMaxx-directionsApex)
			hangleMinFPoint = (directionsfPoint-directionsMinx)
			hangleMaxFpoint = (directionsMaxx-directionsFpoint)


			; remember the values
			retArr = fltarr(4)
			retArr[0] = halfAngle
			retArr[1] = ApexAngle
			retArr[2] = apexanglestb
			retArr[3] = apexanglesta

			print, 'Half angle:', halfangle
			print, 'Apex angle (Earth)', apexangle
			print, 'Apex angle (STB)', apexanglestb
			print, 'Apex angle (STA)', apexanglesta

			msg = Dialog_message('Continue with this selection?', /question, dialog_parent = parent)
;			msg = 'Yes'
			!Mouse.Button = 1
			if msg eq 'Yes' then wdelete, 0
			if msg eq 'No' then begin
				msg = Dialog_message('Do you want to quit?', /question, dialog_parent = parent)
				if msg eq 'Yes' then begin
					wdelete, 0
					return, -1
				endif
			endif
		endwhile
		
		
		;!!!TODO remove again
		makepsPlot = 0
		if makepsPlot eq 1 then begin
		;	!p.multi = [0, 1, 3]
			set_plot, 'ps'
			!p.thick = 3
			plotPath = '/home/jhinterreiter/'
;			if file_test(plotPath, /directory) eq 0 then file_mkdir, plotPath, /NOEXPAND_PATH
			
		
			device, filename = plotPath + '_cut.ps', xsize = 15, ysize = 25, xoffset = 2, yoffset = 2, encaps = 0
			
			
;			window, 0, xsize = 750, ysize = 750
			plot, x, y, xrange = xrange, yrange = yrange, xstyle = 1, ystyle = 1 $
				, position = [0.3, 0.7, 0.8, 1.0] $
			, /nodata, ytitle = 'r [R!D!9n!N!X]', xtitle = 'r [R!D!9n!N!X]', thick = 4;, title = 'Define CME boundaries, use left and right mouse buttons'
	
			for i = 0, filecnt-1 do begin
				xA = listx[i]
				yA = listy[i]
				col = (256./filecnt)*(i+1)-1
				cols[i]= col
				oplot, xa, yA, psym = 8, symsize = 0.3, color = cgcolor('black')	
				arrow, 0, 0, 0, !y.crange[1]-0.03*maxdiff, /data, color = cgcolor('blue')
				xyouts, 0.09, !y.crange[1]-0.05*maxdiff, 'to Earth', /data, color = cgcolor('blue')
	
			endfor

			;al_legend, times, /top, box = 0, charsize = 0.7, textcolors = cols
			PLOTS,[0,leftx], [0,lefty], /data, color = cgcolor('red'), thick = 2
			PLOTS,[0,rightx], [0,righty], /data, color = cgcolor('green'), thick = 2
		;	plots, [0, stbx], [0, stby], /data, color = cgcolor('blue')
		;	plots, [0, stax], [0, stay], /data, color = cgcolor('red')
			;oplot, xvals[indFarestPoint], yvals[indFarestPoint], psym = 2, color = cgcolor('red')
			;oplot, fltarr(1) + apexpositions[0], fltarr(1)+apexpositions[1], psym = 2, color = cgcolor('green')
			plots, [0, range*sin(apexangle/!radeg)], [0, range*cos(apexAngle/!radeg)], /data, color = cgcolor('gray'), thick = 2


			device, /close
			set_plot, 'x'
			!p.multi = 0
			!p.thick = 0.0
		endif
		;!!!TODO end remove again

		loadct, 0
		return, retArr
	endif

	msg = Dialog_message('CME cloud not in ecliptic', /info, dialog_parent = ev.top)
	return, -1
end
