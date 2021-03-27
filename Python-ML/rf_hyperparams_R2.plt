reset
set term pdfcairo enhanced
set datafile separator tab
set pm3d
set hidden3d
#set palette rgb 33,13,10
set contour
set view map
set tics scale 0.25
set xtics font "Helvetica, 12" offset 0,0.5 
set ytics font "Helvetica, 12" offset 1.5
set xlabel "Number of trees" font "Helvetica, 12" offset 0,1 
set ylabel "Number of features" font "Helvetica, 12" offset 1.5,0 
set key on outside top title "R^2"  
set output "RF_hyperparams_R2.pdf"
splot "RF_optimisation.friday.cluster" using 2:1:6  notitle with lines 