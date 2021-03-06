#======================================================================
param N_mines;
param N_powerhouses;
param N_mid;
param N_trains;
param N_wag_each;
param N_wag_total;

param wagon_max_capacity;
param L;

param each_train_cost;
param each_wagon_cost;

param each_km_cost;

param kappa;
param theta;

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
var n {Mines} >= 0;

var l {Trains, Wagons, Mines, Mids} >= 0;
var r {Trains, Wagons, Mids, Powerhouses} >= 0;
var q {Trains, Wagons} binary;

var x {Trains} binary;
var d {Trains, Mines, Mids} binary;
var e {Trains, Mids, Powerhouses} binary;

var s {Powerhouses} >= 0;

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
		delivery_cost = each_km_cost * (sum {o in Mids} ((sum {m in Mines} (K[m, o] * (sum {i in Trains} (sum {j in Wagons} l[i, j, m, o])))) + (sum {p in Powerhouses} (M[o, p] * (sum {i in Trains} (sum {j in Wagons} r[i, j, o, p]))))));
		
	Max_n{m in Mines}:
		n[m] <= P[m];
		
	Min_s{p in Powerhouses}:
		s[p] >= D[p];
	
	Max_l{i in Trains, j in Wagons, m in Mines, o in Mids}:
		l[i, j, m, o] <= wagon_max_capacity;
		
	Max_r{i in Trains, j in Wagons, o in Mids, p in Powerhouses}:
		r[i, j, o, p] <= wagon_max_capacity;
	
	Each_train_once_in{i in Trains}:
		sum {m in Mines} (sum {o in Mids} d[i, m, o]) <= 1;
		
	d_e_connection{i in Trains, o in Mids}:
		(sum {m in Mines} d[i, m, o]) = (sum {p in Powerhouses} e[i, o, p]);
		
	#Each_train_once_out{i in Trains}:
	#	sum {o in Mids} (sum {p in Powerhouses} e[i, o, p]) <= 1;
		
	Max_d_in{m in Mines, o in Mids}:
		sum {i in Trains} d[i, m, o] <= F[m, o];
		
	Max_d_overall{o in Mids}:
		sum {m in Mines} (sum {i in Trains} d[i, m, o]) <= C[o];
		
	Max_d_out{o in Mids, p in Powerhouses}:
		sum {i in Trains} e[i, o, p] <= G[o, p];
		
	mid_flow{o in Mids}:
		sum {i in Trains} (sum {m in Mines} d[i, m, o]) = sum {i in Trains} (sum {p in Powerhouses} e[i, o, p]);
		
	x_d_connection{i in Trains}:
		x[i] = sum {m in Mines} (sum {o in Mids} d[i, m, o]);
		
	Mining{m in Mines}:
		n[m] = sum {o in Mids} (sum {i in Trains} (sum {j in Wagons} l[i, j, m, o]));
		
	l_r_connection{i in Trains, j in Wagons, o in Mids}:
		sum {m in Mines} l[i, j, m, o] = sum {p in Powerhouses} r[i, j, o, p];
		
	s_r_connection{p in Powerhouses}:
		s[p] = sum {o in Mids} (sum {i in Trains} (sum {j in Wagons} r[i, j, o, p]));

	d_l_connection_1{i in Trains, m in Mines, o in Mids}:
		d[i, m, o] <= kappa * (sum {j in Wagons} l[i, j, m, o]);
		
	d_l_connection_2{i in Trains, m in Mines, o in Mids}:
		L * d[i, m, o] >= sum {j in Wagons} l[i, j, m, o];
		
	e_r_connection_1{i in Trains, o in Mids, p in Powerhouses}:
		e[i, o, p] <= kappa * (sum {j in Wagons} r[i, j, o, p]);
		
	e_r_connection_2{i in Trains, o in Mids, p in Powerhouses}:
		L * e[i, o, p] >= sum {j in Wagons} r[i, j, o, p];
		
	q_l_connection_1{i in Trains, j in Wagons}:
		q[i, j] <= kappa * (sum {m in Mines} (sum {o in Mids} l[i, j, m, o]));
		
	q_l_connection_2{i in Trains, j in Wagons}:
		theta * q[i, j] >= sum {m in Mines} (sum {o in Mids} l[i, j, m, o]);
		
	
