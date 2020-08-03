;+
; NAME:
;       get_ecliptic_cut
;
; PURPOSE:
;       uses the parameter from GCS (sgui) and gets the ecliptic cut
;
; CALLING SEQUENCE:
;       e.g: res = get_ecliptic_cut(sgui, apexPos = apexPos, swire = swire, /correctForTiltOfSolarRotAx)
;
; INPUTS:
;       sgui: structure from GCS fitting
;
; OUTPUTS:
;       2D array with the points in the ecliptic (index 0: xValues, index 1: yValues)
;
; KEYWORDS:
;		apexPos: returns the projected position of the apex
;		correctForTiltOfSolarRotAx: correction applied due to the difference of HEEQ and HEE
;		swire: structure from GCS fitting; if set the plot will contain LASCO view
;		wfo: face on width
;		nrPointsFactor: factor for how many points the cme cloud should have (the larger the number, the more points => takes longer to create cloud)
;
; MODIFICATION HISTORY:
;       20180711: created by jhinterreiter
;-

function get_ecliptic_cut, sgui, ApexPos = apexPos, $
	correctForTiltOfSolarRotAx = correctForTiltOfSolarRotAx, swire = swire, cmeWidth = cmeWidth, nrPointsFactor = nrPointsFactor;, savePlot = savePlot


size_factor=4*sgui.hgt
if keyword_set(nrPointsFactor) then size_factor = nrPointsFactor*sgui.hgt
;size_factor = 0.2*sgui.hgt

oldshell = sgui.nbvertshell
oldcirup = sgui.nbvertcirup
oldaxisp = sgui.nbvertaxisp

axis_grid_points=sgui.nbvertshell*size_factor
shell_grid_points=sgui.nbvertcirup*size_factor
leg_axis_grid_points=sgui.nbvertaxisp*size_factor

sgui.nbvertaxisp=leg_axis_grid_points
sgui.nbvertcirup=shell_grid_points
sgui.nbvertshell=axis_grid_points


; create a cloud with much more points to get a 'smooth' front
ocout=cmecloud(sgui.han,sgui.hgt,sgui.nbvertaxisp,sgui.nbvertcirup,sgui.rat,sgui.nbvertshell,/distjuncisleadingedge)

sgui.nbvertshell = oldshell
sgui.nbvertcirup = oldcirup
sgui.nbvertaxisp = oldaxisp

x_or = reform(ocout[0,*])
y_or = reform(ocout[1,*])
z_or = reform(ocout[2,*])

x = x_or
y = y_or
z = z_or

cmeWidth = fltarr(2)
cmeWidth[0] = max(y)
cmeWidth[1] = max(x)

isStony = sgui.carrorstony
;print, sgui.lon*!radeg-sgui.carrstonyshiftdeg
theta = -1*sgui.lat*!radeg ; in 
phi = sgui.lon*!radeg-sgui.carrstonyshiftdeg
if sgui.carrorstony eq 0 then begin
	phi = sgui.lon*!radeg-sgui.hdra.crln_obs+sgui.hdra.hgln_obs
endif
rotation = sgui.rot*!radeg
height = sgui.hgt ; in rsun_rad



;correctForTiltOfSolarRotAx = 0
if keyword_set(correctForTiltOfSolarRotAx) eq 1 then begin
	print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	print, '!!! Correct for tilt of Solar Rotation Axis !!!'
	print, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
	sc = 'Earth'
	
	th = 0.
	ph = 90./!radeg

	Xq = 1*cos(th)*cos(ph)
	Yq = 1*cos(th)*sin(ph)
	Zq = 1*sin(th)

	etime = sgui.eruptiondate

	coord = [Xq, Yq, Zq]
	coord[0, *] = xq
	coord[1, *] = yq
	coord[2, *] = zq

	tim = anytim(etime)

	convert_sunspice_coord, tim, coord, 'HEEQ', 'HEE';, spacecraft = sc

	tiltAngle = reform(atan(coord(2,*)/coord(1,*)))
	tiltAngleDeg = tiltAngle*!radeg


	th = 0.
	ph = 0.

	Xq = 1*cos(th)*cos(ph)
	Yq = 1*cos(th)*sin(ph)
	Zq = 1*sin(th)

	coord = [Xq, Yq, Zq]
	coord[0, *] = xq
	coord[1, *] = yq
	coord[2, *] = zq

	convert_sunspice_coord, tim, coord, 'HEEQ', 'HEE';, spacecraft = sc

	latAngle = reform(atan(coord(2,*)/coord(0,*)))
	latAngleDeg = latAngle*!radeg

;	print, 'latAngle [deg]: ', latAngleDeg
;	print, 'tiltAngle [deg]: ', tiltAngleDeg

	theta = theta - latAngleDeg
	rotation = rotation + tiltAngleDeg
endif


;theta = !pi/3

zeta = 0;sgui.rot*!radeg


euler_angles = [phi, theta, rotation]
angTmp = euler_angles
euler_angles = euler_angles*!pi/180.


;rotate the CME point cloud

Rx = [[1.,0.,0.],$
	[0.,cos(euler_angles[0]),-sin(euler_angles[0])],$
	[0.,sin(euler_angles[0]), cos(euler_angles[0])]]
Ry = [[cos(euler_angles[1]),0.,sin(euler_angles[1])],$
	[0,1.,0.],$
	[-sin(euler_angles[1]),0.,cos(euler_angles[1])]]
Rz = [[cos(euler_angles[2]),-sin(euler_angles[2]),0.],$
	[sin(euler_angles[2]), cos(euler_angles[2]),0.],$
	[0.,0.,1.]]

euler_angles = angTmp

R = Rx # Ry # Rz

x_c = r[0,0] * x + r[0,1] * y + r[0,2] * z
y_c = r[1,0] * x + r[1,1] * y + r[1,2] * z
z_c = r[2,0] * x + r[2,1] * y + r[2,2] * z


thetarad = -1*theta/!radeg
phirad = -1*phi/!radeg

xApex = height*cos(thetarad)*cos(phirad)
yApex = height*cos(thetarad)*sin(phirad)
zApex = height*sin(thetarad)

xp_or = x_c
yp_or = y_c
zp_or = z_c

; use only the ecliptic values
ind = where(abs(xp_or) lt 0.01)
;help, ind



; if non are returned the CME did not propagate in the ecliptic
if ind(0) eq -1 then begin
	print, '!!!!!!!!!!!!!!!!!!!!!!!'
	print, '!!! not in ecliptic !!!'
	print, '!!!!!!!!!!!!!!!!!!!!!!!'
	return, -1
endif


xcut = xp_or(ind)
yCut = -1*yp_or(ind)
zCut = zp_or(ind)

xAxis = ycut
yAxis = zcut

xDiff = max(xaxis)-min(xaxis)
yDiff = max(yaxis)-min(yaxis)

maxDiff = round(max([xdiff, ydiff])*1.3)
xrange = [min(xaxis)-maxdiff*0.1, min(xaxis)-maxdiff*0.1 + maxDiff]
yrange = [min(yaxis)-maxdiff*0.1, min(yaxis)-maxdiff*0.1 + maxDiff]

if ind(0) ne -1 then begin

	datetime = sgui.eruptiondate
	date = repstr(strmid(datetime, 0, 10), '-', '')
	time = repstr(strmid(datetime, 11, 8), ':', '')
	

	lon = strtrim(fix(phi),2)
	lat = strtrim(fix(sgui.lat*!radeg), 2)
	rot = strtrim(fix(rotation), 2)
	
	savePlot = 1
	;plot the results
	if savePlot eq 1 then begin
		!p.multi = [0, 1, 3]
		set_plot, 'ps'
		plotPath = getenv('EAGEL_DIR')+'/results/'+date+'/plots/'
		if file_test(plotPath, /directory) eq 0 then file_mkdir, plotPath, /NOEXPAND_PATH
		
		device, filename = plotPath + 'cut_'+time+'.ps', xsize = 15, ysize = 25, xoffset = 2, yoffset = 2, encaps = 0
	endif
	
	;; Make a vector of 16 points, A[i] = 2pi/16:
	Alpha = FINDGEN(17) * (!PI*2/16.)
	;; Define the symbol to be a unit circle with 16 points, ;; and set the filled flag:
	USERSYM, COS(Alpha), SIN(Alpha), /FILL

	plot, xAxis, yAxis, psym = 8, symsize = 0.3 $
	, xstyle = 1, ystyle = 1 $
	, xrange = xrange, yrange = yrange $
	, ytit = 'y [rsun]', xtit = 'x [rsun]' $
	, title = 'Lon: '+lon+'      Lat: ' + lat + '      Rot: '+rot, charsize = 2 $
	, position = [0.3, 0.7, 0.8, 1.0]

	arrow, 0, 0, 0, !y.crange[1]-1.5, /data, color = cgcolor('blue')
	
		
	arrow, 0, 0, yApex, xApex, /data, color = cgcolor('green')
	xyouts, 0, !y.crange[1]-1, 'to Earth', /data, color = cgcolor('blue')
	
	xyouts, !x.crange[0]-(!x.crange[1]-!x.crange[0])*0.4, !y.crange[1], 'Top View', color = cgcolor('red'), /data

	if keyword_set(swire) eq 1 then begin
;		oplot, y_ev, z_ev, color = cgcolor('red')
		tvscl, swire.slasco.im
		xyouts, !x.crange[0]-(!x.crange[1]-!x.crange[0])*0.4, !y.crange[0]-(!x.crange[1]-!x.crange[0])*0.7, 'Earth View', color = cgcolor('red'), /data
	endif

		
	if savePlot eq 1 then begin
		device, /close
		set_plot, 'x'
		!p.multi = 0
	endif
	
endif


points = dblarr(2, n_elements(xAxis))
points[0,*]=xAxis
points[1,*]=yAxis
ApexPos = [yApex, xApex]
return, points
end