#======================================================================
param Model symbolic := "Sieciowe_produkcja_dystrybucja";
param FileCSV symbolic := "Wyniki_symulacji.csv";

#======================================================================
param N_mines := 2;
param N_powerhouses := 2;
param N_mid := 2;

param N_wag_each := 31;

param wagon_max_capacity := 20;

param each_train_cost := 6448;
param each_wagon_cost := 171;

param each_km_cost := 0.11;

#======================================================================
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
var n {Mines} >= 0; #ile ton wyprodukowano w m-tej kopalni

var f {Mines, Mids, Powerhouses} >= 0; #przep³yw ton wêgla m -> o -> p
var w {Mines, Mids, Powerhouses} integer;  #ile u¿ytych wagonów
var t {Mines, Mids, Powerhouses} integer; #ile u¿ytych poci¹gów

var s {Powerhouses} >= 0; #ile ton dostarczono do p-tej elektrowni

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
		train_cost = each_train_cost * (sum {m in Mines} (sum {o in Mids} (sum {p in Powerhouses} t[m, o, p])));
		
	Wagon_cost:
		wagon_cost = each_wagon_cost * (sum {m in Mines} (sum {o in Mids} (sum {p in Powerhouses} w[m, o, p])));
		
	Delivery_cost:
		wagon_cost = each_km_cost * (sum {o in Mids} ((sum {m in Mines} (K[m, o] * (sum {p in Powerhouses} f[m, o, p]))) + (sum {p in Powerhouses} (M[o, p] * (sum {m in Mines} f[m, o, p])))));
		
	Max_n{m in Mines}:
		n[m] <= P[m];
		
	Min_s{p in Powerhouses}:
		s[p] >= D[p];
		
	Min_w{m in Mines, o in Mids, p in Powerhouses}:
		w[m, o, p] >= 0;
		
	Min_t{m in Mines, o in Mids, p in Powerhouses}:
		t[m, o, p] >= 0;
		
	f_w_connection{m in Mines, o in Mids, p in Powerhouses}:
		wagon_max_capacity * w[m, o, p] >= f[m, o, p];
		
	w_t_connection{m in Mines, o in Mids, p in Powerhouses}:
		N_wag_each * t[m, o, p] >= w[m, o, p];
		
	Max_from_m_to_o{m in Mines, o in Mids}:
		sum {p in Powerhouses} t[m, o, p] <= F[m, o];
		
	Max_through_o{o in Mids}:
		sum {m in Mines} (sum {p in Powerhouses} t[m, o, p]) <= C[o];
		
	Max_from_o_to_p{o in Mids, p in Powerhouses}:
		sum {m in Mines} t[m, o, p] <= G[o, p];
		
	n_f_connection{m in Mines}:
		n[m] = sum {o in Mids} (sum {p in Powerhouses} f[m, o, p]);
		
	f_s_connection{p in Powerhouses}:
		s[p] = sum {m in Mines}(sum {o in Mids} f[m, o, p]);
