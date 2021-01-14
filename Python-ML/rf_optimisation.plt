reset
set term pdfcairo enhanced
set datafile separator tab
set isosample 250
set pm3d
unset surface
set view map
set contour
unset key
set palette rgbformulae 33,13,10
set cblabel "Accuracy" font "Verdana, 14"
set lmargin at screen 0.1
set rmargin at screen 0.85
set xlabel "Number of trees" font "Verdana, 14"
set ylabel "Number of features" font "Verdana, 14" 
set output "rf_opt_acc.pdf"
splot "rf_optimisation.tsv2" using 2:1:6 title '' with lines 


#set view map
#set cntrlabel start 5 interval 20
#set xtics font "Verdana, 12"
#set ytics font "Verdana, 12" 


# set zlabel "Accuracy" font "Verdana, 16" rotate by 90


#unset surface
# set lmargin at screen 0.1
# set rmargin at screen 0.85



#unset key
#set style textbox  opaque margins  0.5,  0.5 fc  bgnd noborder linewidth  1.0
#set view map scale 1
#set samples 25, 25
#set isosamples 26, 26
#unset surface 
#set contour base
#set cntrlabel  format '%8.3g' font ',7' start 2 interval 20
#set cntrparam order 8
#set cntrparam bspline
#set cntrparam levels 10
#set title "" 





#set xrange [ 100 : 2000 ]
#set x2range [ * : * ] noreverse writeback
#set yrange [ 1 : 21 ] 
#set y2range [ * : * ] noreverse writeback
#set zlabel "Z " 
#set zlabel  offset character 1, 0, 0 font "" textcolor lt -1 norotate
#set zrange [ -1.20000 : 1.20000 ] noreverse writeback
#set cbrange [ * : * ] noreverse writeback
#set rrange [ * : * ] noreverse writeback
#NO_ANIMATION = 1
## Last datafile plotted: "glass.dat"

#reset samples 20
#set pm3d
#set view 55,300

# unset surface
# #set view 64,354
# #set samples 100
# set isosamples 50,50
#set cntrparam levels 20
