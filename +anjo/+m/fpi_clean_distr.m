function Fout = fpi_clean_distr(F,Ferr,nsigma)

Fout = F;
Fout.data(Fout.data<nsigma*Ferr.data) = 0;


end