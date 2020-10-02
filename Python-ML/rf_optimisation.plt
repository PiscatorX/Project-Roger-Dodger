set dgrid3d 30, 30
set hidden3d
set  datafile separator tab
set contour surface
show contour
#set datafile columnheaders
splot "rf_optimisation2.tsv" using 1:2:4  with lines