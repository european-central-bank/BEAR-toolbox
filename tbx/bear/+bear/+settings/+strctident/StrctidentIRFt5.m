classdef StrctidentIRFt5 < bear.settings.strctident.Strctident

    properties

        Instrument='MHF';% specify Instrument to identfy Shock
        startdateIV='1992m2';
        enddateIV='2003m12';
        bootstraptype=1; %1=wild bootstrap Mertens&Ravn(2013), 2=moving block bootstrap Jentsch&Lunsford(2018)
        Thin=10;
        prior_type_reduced_form=1; %1=flat (standard), 2=normal wishart , related to the IV routine
        Switchprobability=0; % (=0 standard) related to the IV routine, governs the believe of the researcher if the posterior distribution of Sigma|Y as specified by the standard inverse Wishart distribution, is a good proposal distribution for Sigma|Y, IV. If gamma = 1, beta and sigma are drawn from multivariate normal and inverse wishart. If not Sigma may be drawn around its previous value if randnumber < gamma
        prior_type_proxy=1; %1=inverse gamma (standard) 2=high relevance , related to the IV routine, priortype for the proxy equation (relevance of the proxy)

    end

end