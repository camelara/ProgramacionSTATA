* Carlos Alberto Melara

* Ejercicios de exploración y análisis de datos

* Preparando entorno
	clear all
	set memory 300m
	*set maxvar 5000
	set matsize 800
	set more off, perm
	cd "C:\Manejo de datos\ProgramacionSTATA\"


******************************* 1. Análisis de datos ************************ 
* 
* Carga de archivo. 
import excel "C:\Manejo de datos\ProgramacionSTATA\Datos\Gravity CA-ADAUE.xlsx",firstrow  clear
save "Datos\Gravity.dta", replace

* Grafico multiple de analisis
twoway (line ImportacionesT year, by(Socio)), ///
    title("Importaciones") ///
    legend(pos(6) cols(3))   // Ajusta la leyenda
	
* Grafico de importaciones en el tiempo
graph hbar ImportacionesT, over(Socio, sort(1) descending) ///
    title("Top Socios Comerciales 2004-2019") ///
    ytitle("ImportacionesT") ///
    bar(1, color(blue)) 
	
* Listado de top socios 2019
list Socio ImportacionesT if year == 2019 in 1/10
	

****************** 2. Modelo de gravedad del comercio ************************
	
* Abriendo el archivo
use "Datos\Gravity.dta", clear

* Especificar la estructura del panel
encode Socio, gen(Socio_num)
xtset Socio_num year

* Modelo con efectos fijos
xtreg LOG_Importaciones LOG_PIB distwces ADA, fe 
estimates store modelo_fe   // Guardar los resultados como "modelo_fe"
	
	
* Modelo con efectos aleatorios
xtreg LOG_Importaciones LOG_PIB distwces ADA, re 
estimates store modelo_re   // Guardar los resultados como "modelo_fe"


* Prueba de Haussman
hausman modelo_fe modelo_re
	
	
*********** Otro caso detratamiento a bases de datos ************************
* Ejercicio de left-join o merge de dos bases de datos
import excel "C:\Manejo de datos\ProgramacionSTATA\Datos\PIB.xlsx",firstrow  clear
save "Datos\PIB.dta", replace

import excel "C:\Manejo de datos\ProgramacionSTATA\Datos\Exportaciones.xlsx",firstrow  clear
save "Datos\Export.dta", replace

use "Datos\Export.dta", clear
merge 1:1 year using  "Datos\PIB.dta" 
* Eliminando filas sin correspondencia 1 a 1
drop if _merge == 1 | _merge == 2
drop _merge

save "Datos\Dataset_consolidado.dta", replace
	