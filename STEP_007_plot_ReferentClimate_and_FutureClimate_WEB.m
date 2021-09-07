
clear all; close all; clc

tic

pkg load netcdf
pkg load statistics

%-------------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------------

VARtxt{1}='tas';      VARtxtDHMZ{1}='temp';    VARtxtWITHunits{1}='t (deg C)';
VARtxt{2}='pr';       VARtxtDHMZ{2}='oborina'; VARtxtWITHunits{2}='R (mm)';

LOCtxt{1}='Cres';     LOCtxt{2}='Zadar';       LOCtxt{3}='VelaLuka';
RCPtxt{1}='26';       RCPtxt{2}='45';          RCPtxt{3}='85';

delta=nan(3,39,3,12); %3 stations, max RCP models+4 DHMZ, 3 RCPs, 12 months); %<-- Hardcoded
epsil=nan(3,39,3,12);

FUTA=18;
%-------------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------------

for RCP=[1:3] ;                 %-->RCP2.6, RCP4.5, RCP8.5

            models=importdata(['./models_RCP',RCPtxt{RCP},'.txt']);
            nMOD=size(models,1);

            for STT=[1:3] ;     %-->Cres, Zadar, Vela Luka
            for VAR=[1:2] ;     %-->tas, pr

            niz_za_analizu       =NaN;

            for MOD=[1:nMOD];
	
                %------------------------
                % READ MODEL DATA
                %------------------------
        	    filename=['../FROM_ESGF_UKV_HIST_RCP',RCPtxt{RCP},'/STATION_',num2str(STT),'_',VARtxt{VAR},'_EUR-11_',models{MOD},'_mon_HISTincluded_1971-2070.nc'];
	            model_MMYYYY=squeeze(ncread(filename,VARtxt{VAR}));

                %------------------------
                % COMPUTE MODEL HIDRO0 climatology (1981-2010 mean); some hard-coding
                %------------------------
                    model_HIDRO0=model_MMYYYY(120+1:120+12*30)';       %---> 1981-2010
                    vremenski_niz=reshape(model_HIDRO0,12,30)';

                    if (VAR==1); 
                        vremenski_niz=vremenski_niz-273.15; 
                    end
                    if (VAR==2); %assumption: 365 day calendar 
                        vremenski_niz=vremenski_niz*24*60*60.*repmat([31 28 31 30 31 30 31 31 30 31 30 31],30,1); 
                    end

                    model_HIDRO0    =mean(  vremenski_niz);
                    model_HIDRO0_std=std(   vremenski_niz);
                    model_HIDRO0_cvv=std(   vremenski_niz)./mean(   vremenski_niz); clear vremenski_niz
                    % This will be used in the plotting step
                          MATRIX_MOD(RCP,STT,VAR,MOD,1:12)    =model_HIDRO0;
                          MATRIX_MOD_STD(RCP,STT,VAR,MOD,1:12)=model_HIDRO0_std;
                          MATRIX_MOD_CVV(RCP,STT,VAR,MOD,1:12)=model_HIDRO0_cvv;

                %------------------------
                % COMPUTE MODEL P2 climatology (2041-2070 mean); some hard-coding
                %------------------------
                    model_P2=model_MMYYYY(840+1:840+12*30)';       %---> 2041-2070
                    vremenski_niz=reshape(model_P2,12,30)';

                    if (VAR==1); 
                        vremenski_niz=vremenski_niz-273.15; 
                    end
                    if (VAR==2); %assumption: 365 day calendar 
                        vremenski_niz=vremenski_niz*24*60*60.*repmat([31 28 31 30 31 30 31 31 30 31 30 31],30,1); 
                    end

                    model_P2    =mean(  vremenski_niz);
                    model_P2_std=std(   vremenski_niz);
                    model_P2_cvv=std(   vremenski_niz)./mean(   vremenski_niz); clear vremenski_niz
                    % This will be used in the plotting step
                          P2_MATRIX_MOD(RCP,STT,VAR,MOD,1:12)    =model_P2;
                          P2_MATRIX_MOD_STD(RCP,STT,VAR,MOD,1:12)=model_P2_std;
                          P2_MATRIX_MOD_CVV(RCP,STT,VAR,MOD,1:12)=model_P2_cvv;
                
                %------------------------
                % READ OBS DATA
                %------------------------
        	      filename=['./DIR_DHMZ_mjerenja/DHMZ_',VARtxtDHMZ{VAR},'_',LOCtxt{STT},'_HIDRO0.txt'];
	              DHMZ  =load(filename);                            %---> 1981-2010 mean: 12 numbers
                      obs   =DHMZ(1,:);
                      obs_sd=DHMZ(2,:);
                      if (MOD==1);              % This will be used in the plotting step
                          MATRIX_OBS(STT,VAR,1:12)    =obs;
                          MATRIX_OBS_STD(STT,VAR,1:12)=obs_sd;
                          MATRIX_OBS_CVV(STT,VAR,1:12)=obs_sd./obs;
                      end

                %------------------------
                % BIAS CORRECTION: DETERMINE COEFFICIENTS
                %------------------------
	              if (VAR==1); 
                            delta(STT,MOD,RCP,:)=obs -model_HIDRO0; 
                            MATRIX_MOD_DELTA(RCP,STT,MOD,1:12)    =delta(STT,MOD,RCP,:);
                      end
        	      if (VAR==2); 
                            epsil(STT,MOD,RCP,:)=obs./model_HIDRO0; 
                            MATRIX_MOD_EPSIL(RCP,STT,MOD,1:12)    =epsil(STT,MOD,RCP,:);
                      end
                
                %------------------------
                % BIAS CORRECTION: APPLY ON THE ORIGINAL TIMESERIES
                %------------------------
	              if (VAR==1)
                                        BC=squeeze(delta(STT,MOD,RCP,:))'; % simplify
                                        BC=repmat(BC,1,100)';              % 1971.-2070. > 100 years
                        model_MMYYYY_BC=BC+model_MMYYYY;
        	      end
               	      if (VAR==2)
                                        BC=squeeze(epsil(STT,MOD,RCP,:))'; % simplify
                                        BC=repmat(BC,1,100)';              % 1971.-2070. > 100 years
                        model_MMYYYY_BC=BC.*model_MMYYYY;
                      end

                %------------------------
                % COMPUTE MODEL HIDRO0 climatology (1981-2010 mean); BC
                %------------------------
                      model_HIDRO0_BC=model_MMYYYY_BC(120+1:120+12*30)';      %---> 1981-2010
                      vremenski_niz=reshape(model_HIDRO0_BC,12,30)';

                      if (VAR==1);
                          vremenski_niz=vremenski_niz-273.15;
                      end
                      if (VAR==2); %assumption: 365 day calendar
                          vremenski_niz=vremenski_niz*24*60*60.*repmat([31 28 31 30 31 30 31 31 30 31 30 31],30,1);
                      end

                      model_HIDRO0_BC=   mean(   vremenski_niz);
                      model_HIDRO0_BC_std=std(   vremenski_niz);
                      model_HIDRO0_BC_cvv=std(   vremenski_niz)./mean(   vremenski_niz); clear vremenski_niz
                      % This will be used in the plotting step
                            MATRIX_MOD_BC(RCP,STT,VAR,MOD,1:12)    =model_HIDRO0_BC;
                            MATRIX_MOD_BC_STD(RCP,STT,VAR,MOD,1:12)=model_HIDRO0_BC_std;
                            MATRIX_MOD_BC_CVV(RCP,STT,VAR,MOD,1:12)=model_HIDRO0_BC_cvv;

                %------------------------
                % COMPUTE MODEL P2 climatology (2041-2070 mean); BC
                %------------------------
                      model_P2_BC=model_MMYYYY_BC(840+1:840+12*30)';      %---> 2041-2070
                      vremenski_niz=reshape(model_P2_BC,12,30)';

                      if (VAR==1);
                          vremenski_niz=vremenski_niz-273.15;
                      end
                      if (VAR==2); %assumption: 365 day calendar
                          vremenski_niz=vremenski_niz*24*60*60.*repmat([31 28 31 30 31 30 31 31 30 31 30 31],30,1);
                      end

                      model_P2_BC=   mean(   vremenski_niz);
                      model_P2_BC_std=std(   vremenski_niz);
                      model_P2_BC_cvv=std(   vremenski_niz)./mean(   vremenski_niz); clear vremenski_niz
                      % This will be used in the plotting step
                            P2_MATRIX_MOD_BC(RCP,STT,VAR,MOD,1:12)    =model_P2_BC;
                            P2_MATRIX_MOD_BC_STD(RCP,STT,VAR,MOD,1:12)=model_P2_BC_std;
                            P2_MATRIX_MOD_BC_CVV(RCP,STT,VAR,MOD,1:12)=model_P2_BC_cvv;

                %------------------------
                % PLOTS: HIDRO0 RAW
                %------------------------
%                fig=figure(STT+VAR*10); set(gcf,'Position',[ 1    181   1440    613]);
%                subplot(1,3,RCP);
%                        plot(model_HIDRO0,'b o'); hold on
%                        if (MOD==1);
%                        plot(obs,'r'); hold on
%                        end
%                            xlim([0.5 12.5]);
%                            if (VAR==1); ylim([0  30]); end
%                            if (VAR==2); ylim([0 300]); end
%                        if ((RCP==3)&&(MOD==nMOD));
%                                filenamePNG=[LOCtxt{STT},'_',VARtxt{VAR},'_HIDRO0_scatterDiagram.png'];
%                                print(fig,filenamePNG,'-dpng','-S1500,500');
%                        end

            end %MOD 

%-------------------------------------------------------------------------------------------------------------
%------------------------------------ RAW: HIRDO0 ------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------------

            figRAW=figure(STT+VAR*10^2); set(gcf,'Position',[ 1    181   1440    613]);

            subplot (2,3,RCP)
                skup=squeeze(MATRIX_MOD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],MATRIX_OBS(STT,VAR,1:12),'r'); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                           if (VAR==1); ylim([0  30]); ylabel('tas (degC)','Fontsize',FUTA); end
                            if (VAR==1); ylim([0  30]); ylabel('t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([0 300]); ylabel('R (mm)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
                  	    set(gca,'Fontsize',FUTA)
            subplot (2,3,RCP+3)
                skup=squeeze(MATRIX_MOD_STD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                    plot(    [1:12],MATRIX_OBS_STD(STT,VAR,1:12),'r'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                           if (VAR==1); ylim([0   3]); ylabel('std tas (degC)','Fontsize',FUTA); end
                            if (VAR==1); ylim([0   3]); ylabel('std t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([0 250]); ylabel('std R (mm)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
                            set(gca,'Fontsize',FUTA)
               if (RCP==3);
                  filenamePNG=['evaluation_',LOCtxt{STT},'_',VARtxt{VAR},'_HIDRO0_RAWvsOBS.png'];
                  print(figRAW,filenamePNG,'-dpng','-S1300,750');
               end

%-------------------------------------------------------------------------------------------------------------
%------------------------------------ BIAS CORRECTED: HIDRO0--------------------------------------------------
%-------------------------------------------------------------------------------------------------------------

            figBC=figure(STT+VAR*10^3); set(gcf,'Position',[ 1    181   1440    613]);
            subplot (2,3,RCP)
                skup=squeeze(MATRIX_MOD_BC(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                    plot(    [1:12],MATRIX_OBS(STT,VAR,1:12),'r');
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                           if (VAR==1); ylim([0  30]); ylabel('tas (degC)','Fontsize',FUTA); end
                            if (VAR==1); ylim([0  30]); ylabel('t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([0 300]); ylabel('R (mm)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
            subplot (2,3,RCP+3)
                skup=squeeze(MATRIX_MOD_BC_STD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                    plot(    [1:12],MATRIX_OBS_STD(STT,VAR,1:12),'r');
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                           if (VAR==1); ylim([0   3]); ylabel('std tas (degC)','Fontsize',FUTA); end
                            if (VAR==1); ylim([0   3]); ylabel('std t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([0 250]); ylabel('std R (mm)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
               if (RCP==3);
                  filenamePNG=['evaluation_',LOCtxt{STT},'_',VARtxt{VAR},'_HIDRO0_BCvsOBS.png'];
                  print(figBC,filenamePNG,'-dpng','-S1300,750');
               end
%-------------------------------------------------------------------------------------------------------------
%------------------------------------ BIAS CORRECTED: P2------------------------------------------------------
%-------------------------------------------------------------------------------------------------------------

            P2_figBC=figure(STT+VAR*10^3+10); set(gcf,'Position',[ 1    181   1440    613]);
            subplot (2,3,RCP)
                skup=squeeze(P2_MATRIX_MOD_BC(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                           if (VAR==1); ylim([0  30]); ylabel('tas (degC)','Fontsize',FUTA); end
                            if (VAR==1); ylim([0  30]); ylabel('t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([0 300]); ylabel('R (mm)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
            subplot (2,3,RCP+3)
                skup=squeeze(P2_MATRIX_MOD_BC_STD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                           if (VAR==1); ylim([0   3]); ylabel('std tas (degC)','Fontsize',FUTA); end
                            if (VAR==1); ylim([0   3]); ylabel('std t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([0 250]); ylabel('std R (mm)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
               if (RCP==3);
                  filenamePNG=['future_',LOCtxt{STT},'_',VARtxt{VAR},'_P2_BC.png'];
                  print(P2_figBC,filenamePNG,'-dpng','-S1300,750');
               end


        if (VAR==2);
%-------------------------------------------------------------------------------------------------------------
%------------------------------------ RAW: CV VERSION, PRECIPITATION ONLY, HIDRO0 ----------------------------
%-------------------------------------------------------------------------------------------------------------
            figRAW_CV=figure(STT+VAR*10^4); set(gcf,'Position',[ 1    181   1440    613]);
            subplot (2,3,RCP)
                skup=squeeze(MATRIX_MOD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                    plot(    [1:12],MATRIX_OBS(STT,VAR,1:12),'r');
                            xlim([0.5 12.5]); xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            ylim([0 300   ]); ylabel('R (mm)','Fontsize',FUTA);
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
             subplot (2,3,RCP+3)
                skup=squeeze(MATRIX_MOD_CVV(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                    plot(    [1:12],MATRIX_OBS_CVV(STT,VAR,1:12),'r');
                            xlim([0.5 12.5]); xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                            ylim([0      3]); ylabel('cv R (-)','Fontsize',FUTA);
                             ylim([0      3]); ylabel('cv R','Fontsize',FUTA);
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)			
               if (RCP==3);
                  filenamePNG=['evaluation_',LOCtxt{STT},'_',VARtxt{VAR},'_HIDRO0_RAWvsOBS_CVVversion.png'];
                  print(figRAW_CV,filenamePNG,'-dpng','-S1300,750');
               end

%-------------------------------------------------------------------------------------------------------------
%------------------------------------ BIAS CORRECTED: CV VERSION, PRECIPITATION ONLY, HIDRO0 -----------------
%-------------------------------------------------------------------------------------------------------------
            figBC_CV=figure(STT+VAR*10^5); set(gcf,'Position',[ 1    181   1440    613]);
            subplot (2,3,RCP)
                skup=squeeze(MATRIX_MOD_BC(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                    plot(    [1:12],MATRIX_OBS(STT,VAR,1:12),'r');
                            xlim([0.5 12.5]); xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            ylim([0 300   ]); ylabel('R (mm)','Fontsize',FUTA);
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
            subplot (2,3,RCP+3)
                skup=squeeze(MATRIX_MOD_BC_CVV(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                    plot(    [1:12],MATRIX_OBS_CVV(STT,VAR,1:12),'r');
                            xlim([0.5 12.5]); xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                            ylim([0      3]); ylabel('cv R (-)','Fontsize',FUTA);
                             ylim([0      3]); ylabel('cv R','Fontsize',FUTA);
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
                            set(gca,'Fontsize',FUTA)
               if (RCP==3);
                  filenamePNG=['evaluation_',LOCtxt{STT},'_',VARtxt{VAR},'_HIDRO0_BCvsOBS_CVVversion.png'];
                  print(figBC_CV,filenamePNG,'-dpng','-S1300,750');
               end

        end %VAR==2

%-------------------------------------------------------------------------------------------------------------
%------------------------------------ BIAS CORRECTED: CV VERSION, PRECIPITATION ONLY; P2----------------------
%-------------------------------------------------------------------------------------------------------------
        if (VAR==2);
            P2_figBC_CV=figure(STT+VAR*10^5+10); set(gcf,'Position',[ 1    181   1440    613]);
            subplot (2,3,RCP)
                skup=squeeze(P2_MATRIX_MOD_BC(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]); xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            ylim([0 300   ]); ylabel('R (mm)','Fontsize',FUTA);
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
                            set(gca,'Fontsize',FUTA)
            subplot (2,3,RCP+3)
                skup=squeeze(P2_MATRIX_MOD_BC_CVV(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    errorbar([1:12],ens_mean,ens_devc           ); hold on
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]); xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                            ylim([0      3]); ylabel('cv R (-)','Fontsize',FUTA);
                             ylim([0      3]); ylabel('cv R','Fontsize',FUTA);
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
               if (RCP==3);
                  filenamePNG=['future_',LOCtxt{STT},'_',VARtxt{VAR},'_P2_BC_CVVversion.png'];
                  print(P2_figBC_CV,filenamePNG,'-dpng','-S1300,750');
               end
        end %VAR==2


%-------------------------------------------------------------------------------------------------------------
%------------------------------------ CORRECTION FACTORS------------------------------------------------------
%-------------------------------------------------------------------------------------------------------------

            figCORR=figure(STT+VAR*10^6); set(gcf,'Position',[ 1    181   1440    613]);
            subplot (1,3,RCP)
                if (VAR==1)
                    skup=squeeze(MATRIX_MOD_DELTA(RCP,STT,1:nMOD,1:12));
                end
                if (VAR==2)
                    skup=squeeze(MATRIX_MOD_EPSIL(RCP,STT,1:nMOD,1:12));
                end
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
		    if (VAR==1);
			    plot([0.5 12.5],[0 0],'r--'); hold on
		    end
		    if (VAR==2);
			    plot([0.5 12.5],[1 1],'r--'); hold on
		    end
                    e=errorbar([1:12],ens_mean,ens_devc           ); set(e,'linewidth',2); hold on
                    %plot(    [1:12],ens_mini,'g'); hold on
                    %plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);          xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                            if (VAR==1); ylim([-5 5]); ylabel('temperature correction (degC)','Fontsize',FUTA); end
                             if (VAR==1); ylim([-5 5]); ylabel('adt. korekcija temperature (degC)','Fontsize',FUTA); end
%                            if (VAR==2); ylim([-1 5]); ylabel('precipitation correction (-)','Fontsize',FUTA);  end
                             if (VAR==2); ylim([-1 5]); ylabel('rel. korekcija oborine','Fontsize',FUTA);  end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
                            grid off
			    set(gca,'Fontsize',FUTA)
               if (RCP==3);
                  filenamePNG=['correctionFactors_',LOCtxt{STT},'_',VARtxt{VAR},'_HIDRO0_BCvsOBS.png'];
                  print(figCORR,filenamePNG,'-dpng','-S1300,500');
               end
%-------------------------------------------------------------------------------------------------------------
%------------------------------------ BIAS CORRECTED: P2 vs. HIDRO0-------------------------------------------
%-------------------------------------------------------------------------------------------------------------

            P2vsHIDRO0_figBC=figure(STT+VAR*10^7); %set(gcf,'Position',[ 1    181   1440    613]);
            subplot (2,3,RCP)
		skup1=squeeze(   MATRIX_MOD_BC(RCP,STT,VAR,1:nMOD,1:12));
                skup2=squeeze(P2_MATRIX_MOD_BC(RCP,STT,VAR,1:nMOD,1:12));

		if (VAR==1)
	                ens_mean=mean(skup2-skup1);
        	        ens_devc= std(skup2-skup1);
        	        ens_mini= min(skup2-skup1);
        	        ens_maxi= max(skup2-skup1);
		end
		if (VAR==2)
	                ens_mean=mean((skup2-skup1)./skup1*100);
        	        ens_devc= std((skup2-skup1)./skup1*100);
        	        ens_mini= min((skup2-skup1)./skup1*100);
        	        ens_maxi= max((skup2-skup1)./skup1*100);
		end

	            plot([0.5 12.5],[0 0],'r--'); hold on
                    c=errorbar([1:12],ens_mean,ens_devc           ); hold on; set(c,'Linewidth',2);
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            if (VAR==1); ylim([-2    5]); ylabel('P2-HIRDO0 t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([-100 150]); ylabel('(P2-HIDRO0)/HIDRO0 R (%)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
            subplot (2,3,RCP+3)
		skup1=squeeze(   MATRIX_MOD_BC_STD(RCP,STT,VAR,1:nMOD,1:12));
                skup2=squeeze(P2_MATRIX_MOD_BC_STD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup2./skup1);
                ens_devc= std(skup2./skup1);
                ens_mini= min(skup2./skup1);
                ens_maxi= max(skup2./skup1);
		    plot([0.5 12.5],[1 1],'r--'); hold on
                    c=errorbar([1:12],ens_mean,ens_devc           ); hold on; set(c,'Linewidth',2);
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
%                            if (VAR==1); ylim([0.4 2]); ylabel('P2/HIDRO0 std tas (-)','Fontsize',FUTA); end
                             if (VAR==1); ylim([0.4 2]); ylabel('P2/HIDRO0 std t','Fontsize',FUTA); end
%                            if (VAR==2); ylim([0   4]); ylabel('P2/HIDRO0 std R (-)','Fontsize',FUTA);     end
                             if (VAR==2); ylim([0   4]); ylabel('P2/HIDRO0 std R','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
               if (RCP==3);
                  filenamePNG=['P2vsHIDRO0_',LOCtxt{STT},'_',VARtxt{VAR},'_BC.png'];
                  print(P2vsHIDRO0_figBC,filenamePNG,'-dpng','-S1300,750');
               end


end %variable      %-->tas, pr
end %station       %-->Cres, Zadar, Vela Luka
end %RCP scenarios %---> RCP2.6, RCP4.5, RCP8.5

toc
