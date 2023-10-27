/* Sets */

# Set de Distritos
set D;

# Set de Parkings
set L;


/* Parámetros */

# Tiempo en atender una llamada del distrito D_i
# desde el parking L_j
param T {i in D, j in L};

# Número total de llamadas del distrito D_i
param NUM_LLAMADAS {i in D};

# Número máximo de llamadas que se pueden atender desde cada parking
param NUM_MAX_LLAMADAS_PARKING;

# Tiempo máximo para atender una llamada
param T_MAX;

# Proporción máxima en la que se pueden  diferenciar el
# número de llamadas atendidas por cualquier par de parkings
param PROPORCION_BALANCEO;


#### NUEVOS PARÁMETROS DE LA PARTE 2 ####

# Coste de establecer un nuevo parking
param COSTE_NUEVO_PARKING;

# Coste de cada minuto que se tarde en atender una llamada
param COSTE_MINUTO;

# Porcentaje sobre el máximo número de llamadas atendidas por un solo parking
# a partir del cual se distribuyen las llamadas de un distrito entre 2 o más parkings
param MAX_PORCENT;

# Porcentaje mínimo de llamadas de un distrito que debe atender un parking
# si es que lo atiende
param MIN_PORCENT;

# Indicador de si el parking L_j ya se encuantra construido o no
param YA_CONSTRUIDO {j in L};

# M grande
param M;

# Epsilon pequeño
param EPSILON;


/* Decision variables */

# Número de llamadas realizadas desde el parking D_i
# atendidas por el parking L_j
var x {i in D, j in L} integer >= 0;


#### NUEVAS VARIABLES DE LA PARTE 2 ####

# Variable binaria para la distribución de llamadas cuando se supera
# el porcentaje máximo. Indica si se restringe o no el número de llamadas
var restringir_llamadas {i in D} binary;

# Variable binaria para establecer el mínimo de atención
# Indica si un parking atiende o no a un distrito
var ruta_activa {i in D, j in L} binary;

# Variable binaria que indica si un parking atiende alguna llamada o no
var parking_activo {j in L} binary;


/* Función objetivo */
minimize Cost: sum{j in L} (COSTE_NUEVO_PARKING * (parking_activo[j] - YA_CONSTRUIDO[j]) +
    sum{i in D} COSTE_MINUTO * x[i,j] * T[i,j]);


/* Constraints */

# Número máximo de llamadas por parking
s.t. max_llamadas_parking {j in L}:
    sum{i in D} x[i,j] <= NUM_MAX_LLAMADAS_PARKING;

# Tiempo máximo por viaje
s.t. max_tiempo_viaje {i in D, j in L}:
    x[i,j] * (T_MAX - T[i,j]) >= 0;

# Balanceo de llamadas por distrito (SUSTITUIDO EN LA PARTE 2)
# s.t. balanceo_llamadas {j in L, k in L: j <> k}:
#    sum{i in D} x[i,j] <= PROPORCION_BALANCEO * sum{i in D} x[i,k];

# Distribución de llamadas por distrito
s.t. distribucion_llamadas {i in D}:
    sum{j in L} x[i,j] = NUM_LLAMADAS[i];


#### NUEVAS RESTRICCIONES DE LA PARTE 2 ####

# Distribución de llamadas por distrito cuando se supera el porcentaje máximo
# s.t. distribucion_llamadas_max_1 {i in D}:
#     NUM_LLAMADAS[i] - MAX_PORCENT * NUM_MAX_LLAMADAS_PARKING <= M * restringir_llamadas[i] - EPSILON;
# s.t. distribucion_llamadas_max_2 {i in D}:
#     NUM_LLAMADAS[i] - MAX_PORCENT * NUM_MAX_LLAMADAS_PARKING + M * (1 - restringir_llamadas[i]) >= 0;
# s.t. distribucion_llamadas_max_3 {i in D, j in L}:
#     x[i,j] <= NUM_LLAMADAS[i] - EPSILON + M * (1 - restringir_llamadas[i]);

# s.t. distribucion_llamadas_max {i in D, j in L: NUM_LLAMADAS[i] >= MAX_PORCENT * NUM_MAX_LLAMADAS_PARKING}:
#     x[i,j] <= NUM_LLAMADAS[i] - EPSILON;

s.t. distribucion_llamadas_max {i in D}:
    M * (1 - sum{j in L} ruta_activa[i,j]) + NUM_LLAMADAS[i] <= MAX_PORCENT * NUM_MAX_LLAMADAS_PARKING - EPSILON;

# Mínimo de atención
s.t. min_atencion_1 {i in D, j in L}:
    x[i,j] <= M * ruta_activa[i,j];
s.t. min_atencion_2 {i in D, j in L}:
    x[i,j] + M * (1 - ruta_activa[i,j]) >= 0 + EPSILON;
s.t. min_atencion_3 {i in D, j in L}:
    x[i,j] >= MIN_PORCENT * NUM_LLAMADAS[i] - M * (1 - ruta_activa[i,j]);

# Balanceo de llamadas por distrito (SUSTITUYE A LA RESTRICCIÓN DE LA PARTE 1)
s.t. balanceo_llamadas {j in L, k in L: j <> k}:
    sum{i in D} x[i,j] <= M * (1 - parking_activo[k]) + PROPORCION_BALANCEO * sum{i in D} x[i,k];

# Indicación de actividad de un parking
s.t. actividad_parking_1 {j in L}:
    sum{i in D} x[i,j] <= M * parking_activo[j];
s.t. actividad_parking_2 {j in L}:
    sum{i in D} x[i,j] + M * (1 - parking_activo[j]) >= 0 + EPSILON;


/* Model Results */

end;
