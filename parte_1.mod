/* Sets */

# Set de Distritos
set D;

# Set de Parkings
set L;


/* Parámetros */

# Tiempo en atender una llamada del distrito D_i
# desde el parking L_j
param t {i in D, j in L};

# Número total de llamadas del distrito D_i
param num_llamadas {i in D};

# Número máximo de llamadas que se pueden atender desde cada parking
param num_max_llamadas_parking;

# Tiempo máximo para atender una llamada
param t_max;

# Proporción máxima en la que se pueden  diferenciar el
# número de llamadas atendidas por cualquier par de parkings
param proporcion_balanceo;


/* Decision variables */

# Número de llamadas realizadas desde el parking D_i
# atendidas por el parking L_j
var x {i in D, j in L} integer >= 0;


/* Función objetivo */
minimize TotalTime: sum{i in D, j in L} x[i,j] * t[i,j];


/* Constraints */

# Número máximo de llamadas por parking
s.t. max_llamadas_parking {j in L}:
    sum{i in D} x[i,j] <= num_max_llamadas_parking;

# Tiempo máximo por viaje
s.t. max_tiempo_viaje {i in D, j in L}:
    x[i,j] * (t_max - t[i,j]) >= 0;

# Balanceo de llamadas por distrito
s.t. balanceo_llamadas {j in L, k in L: j <> k}:
    sum{i in D} x[i,j] <= proporcion_balanceo * sum{i in D} x[i,k];

# Distribución de llamadas por distrito
s.t. distribucion_llamadas {i in D}:
    sum{j in L} x[i,j] = num_llamadas[i];


/* Model Results */

end;
