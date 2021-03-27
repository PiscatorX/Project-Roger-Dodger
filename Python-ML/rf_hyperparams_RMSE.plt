reset
set term pdfcairo enhanced
set datafile separator tab
set pm3d
set hidden3d
set palette rgb 10,13,33
set contour
set view map
set tics scale 0.25
set xtics font "Helvetica, 12" offset 0,0.5 
set ytics font "Helvetica, 12" offset 1.5
set xlabel "Number of trees" font "Helvetica, 12" offset 0,1 
set ylabel "Number of features" font "Helvetica, 12" offset 1.5,0 
set key on outside top title "RMSE"  
set output "RF_hyperparams_RMSE.pdf"
splot "RF_optimisation.friday.cluster" using 2:1:5  notitle with lines 