; startup file for IDL
; insert path where EAGEL and the coyote library can be found

r1=expand_path('+/home/jhinterreiter/EAGEL/')
!path = !path + ':' + r1
r1=expand_path('+/home/jhinterreiter/coyote/')
!path = !path + ':' + r1

ssw_path, /secchi
ssw_path, /lasco

; also set environment for EAGEL_DIR. Folder where EAGEL can be found
setenv, 'EAGEL_DIR=/home/jhinterreiter/EAGEL/'


print, '!!!!!!!!!!!!!!!!'
print, '!!!All loaded!!!'
print, '!!!!!!!!!!!!!!!!'
