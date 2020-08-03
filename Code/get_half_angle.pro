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

		ang = -1*getAngle(xvals[indFarestPoint], yvals[indFarestPoint])*!dtor
		;ang = -1*getAngle(apexPos[0], apexPos[1])*!dtor
		angArr = n_elements(xVals)
		angArr[*] = ang

		R = [[cos(ang),-sin(ang)], [sin(ang), cos(ang)]]

		x_r = r[0,0] * xVals + r[0,1] * yVals
		y_r = r[1,0] * xVals + r[1,1] * yVals

		indMinXr = where(x_r eq min(x_r))
		indMaxXr = where(x_r eq max(x_r))

		xminR = x_r[indMinXr]
		yminR = y_r[indMinXr]
		xmaxR = x_r[indMaxXr]
		ymaxR = y_r[indMaxXr]

		ang = -1*ang
		R = [[cos(ang),-sin(ang)], [sin(ang), cos(ang)]]
		xmin = r[0,0] * xminR + r[0,1] * yminR
		ymin = r[1,0] * xminR + r[1,1] * yminR
		xmax = r[0,0] * xmaxR + r[0,1] * ymaxR
		ymax = r[1,0] * xmaxR + r[1,1] * ymaxR

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

		x = findgen(10)
		y = x


		DEVICE, SET_FONT='Helvetica', /TT_FONT
		cols = intarr(filecnt)
		!p.thick = 3
		savePlot = 0
		!p.charsize = 2
		loadct, 0
		if savePlot eq 1 then begin
			!p.multi = [0, 1, 3]
			set_plot, 'ps'
			device, filename = plotPath+'/'+date+'.ps', xsize = 15, ysize = 25, xoffset = 2, yoffset = 2, encaps = 0
		endif

		sunsym = SUNSYMBOL()

		;plot for the USER to select the boundaries of the CME
		!p.background = cgcolor('white')
		window, 0, xsize = 750, ysize = 750
		plot, x, y, xrange = xrange, yrange = yrange, xstyle = 1, ystyle = 1 $
		;	, position = [0.3, 0.7, 0.8, 1.0] $
			, /nodata, color = cgcolor('black') $;, title = 'Define CME boundaries, use left and right mouse buttons', color = cgcolor('black')
			, xthick = 2, ythick = 2, ytit = 'y [R'+sunsym+']', xtit = 'x [R'+sunsym+']';, charthick = 2
	

		directionsapex = fltarr(filecnt)
		directionsfPoint = fltarr(filecnt)
		directionsMinx = fltarr(filecnt)
		directionsMaxx = fltarr(filecnt)
		for i = 0, filecnt-1 do begin
			xA = xVals
			yA = yVals
			col = (256./filecnt)*(i+1)-1
			cols[i]= col
			oplot, xa, yA, psym = 8, symsize = 0.3, color = cgcolor('black')
	
			arrow, 0, 0, 0, !y.crange[1]-0.05*maxdiff, /data, color = cgcolor('blue'), linestyle = 2, thick = 3
			xyouts, 0, !y.crange[1]-0.04*maxdiff, 'to Earth', /data, color = cgcolor('blue')
	
	
			directionsApex[i] = atan(apexPositions[0,i]/apexPositions[1,i])
			directionsFPoint[i] = atan(xvals[indFarestPoint]/yvals[indFarestPoint])
			directionsMinx[i] = atan(xvals[indminx]/yvals[indminx])
			directionsMaxx[i] = atan(xvals[indmaxx]/yvals[indmaxx])
		endfor

		;oplot, xvals[indminx], yvals[indminx], psym = 2, color = cgcolor('darkgreen')
		;oplot, xvals[indmaxx], yvals[indmaxx], psym = 2, color = cgcolor('darkgreen')
		;oplot, xvals[indmaxy], yvals[indmaxy], psym = 2, color = cgcolor('darkgreen')
		oplot, xvals[indFarestPoint], yvals[indFarestPoint], psym = 2, color = cgcolor('red')

		PLOTS,[0,xmin], [0,ymin], /data, color = cgcolor('red')
		PLOTS,[0,xmax], [0,ymax], /data, color = cgcolor('green')

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

		Alpha = FINDGEN(17) * (!PI*2/16.)
		USERSYM, COS(Alpha), SIN(Alpha), /FILL
		plots, [0, 0], [0, 0], /data, psym = 8, symsize = 14, color = cgcolor('gold')


		print, 'Click on the screen to define the boundaries: '
		print, 'Left button for left boundary'
		print, 'Right button for right boundary'
		print, 'Middle button to exit'
		cursor, xPos, yPos, /norm, /down

		leftX = xmin
		leftY = ymin
		rightX = xmax
		rightY = ymax

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

					!p.background = cgcolor('white')
					window, 0, xsize = 750, ysize = 750
					plot, x, y, xrange = xrange, yrange = yrange, xstyle = 1, ystyle = 1 $
				;	, position = [0.3, 0.7, 0.8, 1.0] $
					, /nodata, title = 'Define CME boundaries, use left and right mouse buttons', color = cgcolor('black')
	
					for i = 0, filecnt-1 do begin
						xA = xVals
						yA = yVals
						col = (256./filecnt)*(i+1)-1
						cols[i]= col
						oplot, xa, yA, psym = 8, symsize = 0.3, color = cgcolor('black')
	
						arrow, 0, 0, 0, !y.crange[1]-0.03*maxdiff, /data, color = cgcolor('blue')
						xyouts, 0, !y.crange[1]-0.02*maxdiff, 'to Earth', /data, color = cgcolor('blue')
	
					endfor

					;al_legend, times, /top, box = 0, charsize = 0.7, textcolors = cols
					PLOTS,[0,leftx], [0,lefty], /data, color = cgcolor('red')
					PLOTS,[0,rightx], [0,righty], /data, color = cgcolor('darkgreen')
		
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
			;plots, [0, stbx], [0, stby], /data, color = cgcolor('blue'), linestyle = 1
			;plots, [0, stax], [0, stay], /data, color = cgcolor('red'), linestyle = 1



			angleRight = getAngle(rightx, righty)
			angleLeft = getAngle(leftx, lefty)

			ApexAngle = (angleRight+angleleft)/2
			halfAngle = angleRight - apexAngle

			AngleSTB = getAngle(stbx, stby)
			AngleSTA = getAngle(stax, stay)

			ApexAngleSTB = angleSTB - apexangle
			apexAngleSTA = apexangle - angleSTA

			oplot, xvals[indFarestPoint], yvals[indFarestPoint], psym = 2, color = cgcolor('red')
			oplot, fltarr(1) + apexpositions[0], fltarr(1)+apexpositions[1], psym = 2, color = cgcolor('darkgreen')

			maxx = max(plotrangex)
			maxy = max(plotrangey)
		
			range = sqrt(maxx*maxx+maxy*maxy)

			plots, [0, range*sin(apexangle/!radeg)], [0, range*cos(apexAngle/!radeg)], /data, color = cgcolor('gold')
			
			plots, [0, 0], [0, 0], /data, psym = 8, symsize = 14, color = cgcolor('gold')

			PLOTS,[0,xmin], [0,ymin], /data, color = cgcolor('red')
			PLOTS,[0,xmax], [0,ymax], /data, color = cgcolor('green')

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
			apAngle = apexAngle
			apexAngle = -1*apexAngle
			retArr = fltarr(4)
			retArr[0] = halfAngle
			retArr[1] = apexAngle
			retArr[2] = apexanglestb
			retArr[3] = apexanglesta

			print, 'Half angle:', halfangle
			print, 'Apex angle (Earth)', apexangle
			print, 'Apex angle (STB)', apexanglestb
			print, 'Apex angle (STA)', apexanglesta

			msg = Dialog_message('Continue with this selection?', /question, dialog_parent = parent)
;			msg = 'Yes'
			!Mouse.Button = 1
			if msg eq 'Yes' then begin 

				print, plotpath + '/'+ date
				;/home/jhinterreiter/EAGEL//results/20101026/plots//20101026
				set_plot, 'ps'
				device, filename = plotPath+'/'+date+'_new.eps', xsize = 15, ysize = 13.81, xoffset = 2, yoffset = 2, encaps = 0
				
				plot, x, y, xrange = xrange, yrange = yrange, xstyle = 1, ystyle = 1 $
				, /nodata, color = cgcolor('black') $;, title = 'Define CME boundaries, use left and right mouse buttons', color = cgcolor('black')
				, xthick = 3, ythick = 3, ytit = 'y [R'+sunsym+']', xtit = 'x [R'+sunsym+']', charthick = 2, charsize = 1.5


				oplot, xa, yA, psym = 8, symsize = 0.3, color = cgcolor('black')

				PLOTS,[0,xmin], [0,ymin], /data, color = cgcolor('red'), thick = 5
				PLOTS,[0,xmax], [0,ymax], /data, color = cgcolor('green'), thick = 5

				PLOTS, xvals[indFarestPoint], yvals[indFarestPoint], psym = 2, color = cgcolor('red')
				oplot, fltarr(1) + apexpositions[0], fltarr(1)+apexpositions[1], psym = 2, color = cgcolor('darkgreen')
	
				arrow, 0, 0, 0, !y.crange[1]-0.05*maxdiff, /data, color = cgcolor('blue'), linestyle = 2, thick = 1
				xyouts, 0, !y.crange[1]-0.04*maxdiff, 'to Earth', /data, color = cgcolor('blue'), charsize = 1, charthick = 2

				plots, [0, range*sin(apAngle/!radeg)], [0, range*cos(apAngle/!radeg)], /data, color = cgcolor('gold'), thick = 5
			
				plots, [0, 0], [0, 0], /data, psym = 8, symsize = 9.5, color = cgcolor('gold')


				device, /close
				set_plot, 'x'
				!p.multi = 0


				wdelete, 0
			endif
			if msg eq 'No' then begin
				msg = Dialog_message('Do you want to quit?', /question, dialog_parent = parent)
				if msg eq 'Yes' then begin
					wdelete, 0
					return, -1
				endif
			endif
		endwhile
		

		loadct, 0
		!p.background = cgcolor('black')
		return, retArr
	endif
	!p.background = cgcolor('black')
	msg = Dialog_message('CME cloud not in ecliptic', /info, dialog_parent = parent)
	return, -1
end
