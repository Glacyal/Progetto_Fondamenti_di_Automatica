% Progetto in MatLab
% Antonio Marino Matricola 179054

%Ripulisco l'area di lavoro tramite i seguenti comandi:
clear; close all;


%Immetto la funzione di trasferimento con il costrutto tf:
s = tf('s');
G = (5625)/((s+25)*(s^2+20*s+225));

%Per le specifiche statiche richieste il controllore deve avere la forma:
C_static = 10.1/s;

%Calcolo la funzione di anello non compensata
L_nonComp = series(C_static,G);

%Valuto il margine di fase per ispezione e salvo i valori
figure(1);
 margin(L_nonComp);
 [Km,Phim,w_u,w_c] = margin(L_nonComp);

%Da cui risultano:
%Margine di Ampiezza    Km = 1.3201
%Margine di Fase        Phim = 17.0413
%Ultimate Frequency     w_u = 11.1803 rad/s
%Crossover Frequency    w_c = 9.2107 rad/s

%Determino il valore dello smorzamento a partire dal suo legame con
%il picco di risonanza. Cerco di avere un picco di risonanza inferiore
%ai 3dB:
delta = smorz_Mr(3);

%Da qui ricavo il Margine di Fase garantito:
phim_garantito = delta*100;

%Scelgo una pulsazione di attraversamento di progetto compatibile con
%l'approssimazione in MF e con le richieste:
wc_progetto = 11.5;

%Valuto la funzione di anello non compensata in corrispondenza della
%pulsazione di progetto
[mod_progetto, phase_progetto] = bode(L_nonComp, wc_progetto);

%Modulo     mod_progetto = 0.7239 (non dB)
%Fase       phase_progetto = -182.7401 gradi
%--------------------------------------------------------------------------
%Calcolo il valore del margine di fase che posso raggiungere
%posizionando la pulsazione di attraversamento in corrispondenza di
%11.5 rad/s
%Tale valore è 180-abs(phase_progetto) = -2.7401 gradi

%Il modulo è inferiore all'unità e la fase è inferiore 
%al margine di fase richiesto: mi serve una rete anticipatrice.

%Calcolo l'amplificazione richiesta
m = 1/mod_progetto;

%Calcolo incremento in fase richiesto con la seguente formula:
%Margine_Fase_Garantito - (180 - abs(Fase_di_L_Non_Compensata_in_wc_prog))
theta = phim_garantito - (180-abs(phase_progetto)) + 1;

%m = 1.3814
%theta = 42.0633
%///////////////////////////////////////////////////////////////////////
tiporete(L_nonComp,wc_progetto,phim_garantito);
%///////////////////////////////////////////////////////////////////////
%Ora posso procedere a calcolare la rete correttrice:
[tau1,tau2] = generica(wc_progetto,m,theta);

%I valori di tau1 e tau2 sono entrambe positivi e posso procedere:
C_rete = (1+s*tau1)/(1+s*tau2);

%Determino la funzione del controllore completato:
C = series(C_static,C_rete);

%Determino la funzione di anello compensata:
L = series(C,G);

%Sovrappongo in un grafico la funzione di anello non compensata,
%la rete correttrice e la funzione di anello compensata
figure(2)
hold on;
margin(L_nonComp); 
bode(C_rete); 
margin(L);
legend('L Non-Compensata','Rete Correttrice', 'L Compensata');

%Valuto le specifiche della funzione di anello per verificare
%di aver raggiunto l'obiettivo. Disegno il diagramma di Bode:
figure(3);
margin(L);

%Determino la funzione del sistema retroazionato o sensitività
%complementare:
T = feedback(L,1);

%Valuto le specifiche del sistema a ciclo chiuso:
figure(4);
bode(T)
w_bw = bandwidth(T);
M_r  = getPeakGain(T);
