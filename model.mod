#======================================================================
param Model symbolic := "Sieciowe_produkcja_dystrybucja";
param FileCSV symbolic := "Wyniki_symulacji.csv";

#======================================================================
param N_mines := 2;
param N_powerhouses := 2;
param N_mid := 2;
param N_trains := 45 + 46;
param N_wag_each := 31;
param N_wag_total := N_trains * N_wag_each;

param wagon_max_capacity := 20;
param L := N_wag_each * wagon_max_capacity;

param each_train_cost := 6448;
param each_wagon_cost := 171;

param each_km_cost := 0.11;

#======================================================================
set Trains := 1..N_trains;
set Wagons := 1..N_wag_each;
set Mines := 1..N_mines;
set Mids := 1..N_mid;
set Powerhouses := 1..N_powerhouses;

#======================================================================
param K {Mines, Mids} >= 0;
param M {Mids, Powerhouses} >= 0;

param R {Mines} >= 0;
param P {Mines} >= 0;

param D {Powerhouses} >= 0;

param F {Mines, Mids} >= 0;
param G {Mids, Powerhouses} >= 0;
param C {Mids} >= 0;

#======================================================================
table T_K IN "CSV" "K.csv":
	[m, o], K~K;
	
table T_M IN "CSV" "M.csv":
	[o, p], M~M;
	
table T_R IN "CSV" "R.csv":
	[m], R~R;
	
table T_P IN "CSV" "P.csv":
	[m], P~P;
	
table T_D IN "CSV" "D.csv":
	[p], D~D;
	
table T_F IN "CSV" "F.csv":
	[m, o], F~F;
	
table T_G IN "CSV" "G.csv":
	[o, p], G~G;
	
table T_C IN "CSV" "C.csv":
	[o], C~C;

#======================================================================
var n {Mines} integer;

var x {Trains} binary;
var l {Trains, Wagons} integer;
var q {Trains, Wagons} binary;

var d {Trains, Mines, Mids} binary;
var e {Trains, Mids, Powerhouses} binary;

var s {Powerhouses} integer;

var mining_cost >= 0;
var train_cost >= 0;
var wagon_cost >= 0;
var delivery_cost >= 0;

#======================================================================
minimize funkcja_celu:
	mining_cost + train_cost + wagon_cost + delivery_cost;

#======================================================================
subject to
	Mining_cost:
		mining_cost = sum {m in Mines} (n[m] * R[m]);
		
	Train_cost:
		train_cost = each_train_cost * (sum {i in Trains} x[i]);
		
	Wagon_cost:
		wagon_cost = each_wagon_cost * (sum {i in Trains} (sum {j in Wagons} q[i, j]));
		
	Delivery_cost:
		wagon_cost = each_km_cost * (sum {o in Mids} ((sum {m in Mines} (K[m, o] * (sum {i in Trains} d[i, m, o]))) + (sum {p in Powerhouses} (M[o, p] * (sum {i in Trains} e[i, o, p])))));
		
	Min_n{m in Mines}:
		n[m] >= 0;
	Max_n{m in Mines}:
		n[m] <= P[m];
		
	Min_s{p in Powerhouses}:
		s[p] >= D[p];
	
	Min_l{i in Trains, j in Wagons}:
		l[i, j] >= 0;
	Max_l{i in Trains, j in Wagons}:
		l[i, j] <= wagon_max_capacity;
	
	Each_train_once_in{i in Trains}:
		sum {m in Mines} (sum {o in Mids} d[i, m, o]) <= 1;
		
	Each_train_once_out{i in Trains}:
		sum {o in Mids} (sum {p in Powerhouses} e[i, o, p]) <= 1;
		
	Max_d_in{m in Mines, o in Mids}:
		sum {i in Trains} d[i, m, o] <= F[m, o];
		
	Max_d_overall{o in Mids}:
		sum {m in Mines} (sum {i in Trains} d[i, m, o]) <= C[o];
		
	Max_d_out{o in Mids, p in Powerhouses}:
		sum {i in Trains} e[i, o, p] <= G[o, p];
		
		
	x_d_connection{i in Trains}:
		x[i] = sum {m in Mines} (sum {o in Mids} d[i, m, o]);
		
	mid_flow{o in Mids}:
		(sum {i in Trains} (sum {m in Mines} d[i, m, o])) - (sum {i in Trains} (sum {p in Powerhouses} e[i, o, p])) = 0;
		
	d_e_connection{i in Trains, o in Mids}:
		(sum {m in Mines} d[i, m, o]) = (sum {p in Powerhouses} e[i, o, p]);
		
	#n_l_connection{m in Mines}:
	#	(sum {o in Mids} (sum {i in Trains: d[i, m, o] >= 1} (sum {j in Wagons} l[i, j]))) <= n[m];
		
	n_l_connection{m in Mines}:
		(sum {o in Mids} (sum {i in Trains} (if d[i, m, o] >= 1 then (sum {j in Wagons} l[i, j]) else 0))) <= n[m];
		
## to be continued