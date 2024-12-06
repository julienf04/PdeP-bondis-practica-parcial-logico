% recorrido(linea, zona, calle que atraviesa)
% recorrido(linea, gba(zona interna), calle que atraviesa)

% Recorridos en GBA:
recorrido(17, gba(sur), mitre).
recorrido(24, gba(sur), belgrano).
recorrido(247, gba(sur), onsari).
recorrido(60, gba(norte), maipu).
recorrido(152, gba(norte), olivos).

% Recorridos en CABA:
recorrido(17, caba, santaFe).
recorrido(152, caba, santaFe).
recorrido(10, caba, santaFe).
recorrido(160, caba, medrano).
recorrido(24, caba, corrientes).

linea(Linea) :- recorrido(Linea, _, _).
zona(Zona) :- recorrido(_, Zona, _).
calle(Calle) :- recorrido(_, _, Calle).
pasaPorZona(Linea, Zona) :- recorrido(Linea, Zona, _).
calleEnZona(Zona, Calle) :- recorrido(_, Zona, Calle).


combinar(Linea1, Linea2) :- recorrido(Linea1, Zona, Calle), recorrido(Linea2, Zona, Calle).


cruzaGeneralPaz(Linea) :- pasaPorZona(Linea, gba(_)), pasaPorZona(Linea, caba).
jurisdiccion(Linea, nacional) :- cruzaGeneralPaz(Linea).
jurisdiccion(Linea, provincial(Provincia)) :- pasaPorZona(Linea, Provincia), not(cruzaGeneralPaz(Linea)).


cantidadLineas(CantidadLineas, Zona, Calle) :-
    calleEnZona(Zona, Calle),
    findall(Linea, recorrido(Linea, Zona, Calle), Lineas),
    length(Lineas, CantidadLineas).

% Si hay más de una calle más transitada, entonces verifica para todas ellas.
% Por ejemplo, gba(norte) tiene a maipu y olivos como calles más transitadas
masTransitada(Zona, Calle) :-
    cantidadLineas(CantidadLineas, Zona, Calle),
    forall(
        (cantidadLineas(CantidadOtrasLineas, Zona, OtraCalle), Calle \= OtraCalle),
        CantidadLineas >= CantidadOtrasLineas
    ).
    

transbordo(Zona, Calle) :-
    cantidadLineas(CantidadLineas, Zona, Calle),
    CantidadLineas >= 3,
    forall(recorrido(Linea, Zona, Calle), jurisdiccion(Linea, nacional)).



% 5)

% beneficio(linea, tipo de beneficio, costo beneficiado)
beneficio(_, estudiantil, 50).
beneficio(Linea, casasParticulares(ZonaDomicilio), 0) :- pasaPorZona(Linea, ZonaDomicilio).
beneficio(Linea, jubilado, CostoBeneficiado) :- valor(Linea, Costo), CostoBeneficiado is Costo / 2.

% beneficiario(persona, tipo de beneficio)
beneficiario(pepito, casasParticulares(gba(oeste))).
beneficiario(juanita, estudiantil).
beneficiario(marta, jubilado).
beneficiario(marta, casasParticulares(caba)).
beneficiario(marta, casasParticulares(gba(sur))).
% Por principio de universo cerrado, no hace falta poner que tito no tiene ningun beneficio.


cantidadCallesRecorridas(Linea, Cantidad) :-
    linea(Linea),
    findall(Calle, recorrido(Linea, _, Calle), Calles),
    length(Calles, Cantidad).

pasaPorZonasGBADiferentes(Linea) :-
    pasaPorZona(Linea, gba(Zona1)),
    pasaPorZona(Linea, gba(Zona2)),
    Zona1 \= Zona2.

plus(Linea, 50) :- pasaPorZonasGBADiferentes(Linea), !.
plus(_, 0).

valor(Linea, 500) :- jurisdiccion(Linea, nacional).
valor(Linea, 350) :- jurisdiccion(Linea, provincial(caba)).
valor(Linea, Valor) :- jurisdiccion(Linea, provincial(gba(_))),
    cantidadCallesRecorridas(Linea, Cantidad),
    plus(Linea, Plus),
    Valor is (25 * Cantidad) + Plus.


beneficioDePersona(Persona, Linea, TipoBeneficio, Valor) :- beneficiario(Persona, TipoBeneficio), beneficio(Linea, TipoBeneficio, Valor).

mejorBeneficio(Linea, Persona, Valor) :-
    beneficioDePersona(Persona, Linea, TipoBeneficio, Valor),
    forall(
        (beneficioDePersona(Persona, Linea, OtroTipoBeneficio, OtroValor), OtroTipoBeneficio \= TipoBeneficio),
        Valor =< OtroValor
    ).
    
    
abonar(Linea, Persona, Valor) :- mejorBeneficio(Linea, Persona, Valor), !.
abonar(Linea, _, Valor) :- valor(Linea, Valor).


% Si se quisiera agregar otro posible beneficio, simplemente se deberia crear el predicado correspondiente.
% Por ejemplo: beneficio(Linea, discapacitado, CostoBeneficiado)
% Esto puede que desencadene la necesidad (o preferencia) de crear más predicados auxiliares que mejoren la expresividad.
% Tambien puede que tengan que crearse nuevos predicados en base a nuevos requerimientos donde se use el
% beneficio discapacitado de alguna manera en especial no contemplada por nuestra base de conocimientos actual.