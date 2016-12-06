************************************************************************
file with basedata            : cm227_.bas
initial value random generator: 2003194688
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  97
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       15       10       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        2          3           5   9  11
   3        2          3           8  12  16
   4        2          2           7  15
   5        2          3           6  12  16
   6        2          3          13  14  15
   7        2          3           8  10  16
   8        2          2          11  14
   9        2          2          12  14
  10        2          1          13
  11        2          1          13
  12        2          2          15  17
  13        2          1          17
  14        2          1          17
  15        2          1          18
  16        2          1          18
  17        2          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     8       0    4    0    4
         2     8       3    0    5    0
  3      1     4       3    0    7    0
         2     5       0    2    0    3
  4      1     2       8    0    4    0
         2     4       8    0    0    1
  5      1     1       0    8    0    6
         2     8       5    0    3    0
  6      1     2       3    0    0    5
         2     4       0    5    0    4
  7      1     4       9    0    6    0
         2     8       5    0    0    3
  8      1     3       9    0    5    0
         2     7       0    4    0    3
  9      1     1       6    0    7    0
         2     9       0    6    2    0
 10      1     4       0    7    0    7
         2     8       3    0    0    6
 11      1     2       0    7    0    5
         2     3       0    4    0    4
 12      1     4       0    6    1    0
         2     5       0    3    1    0
 13      1     1       0    5    4    0
         2     4       0    4    0    6
 14      1     1       8    0    7    0
         2     9       4    0    7    0
 15      1     1       0   10    5    0
         2     4       0    8    0    6
 16      1     5       0    3    0    6
         2     6       7    0    0    4
 17      1     2       2    0    0    7
         2     5       0    7    0    6
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   21   54   62
************************************************************************