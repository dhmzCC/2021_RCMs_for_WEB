
clear all; close all; clc

tic

pkg load netcdf
pkg load statistics

VARtxt{1}='tas';   VARtxtDHMZ{1}='temp';    VARtxtWITHunits{1}='t (deg C)'; 
VARtxt{2}='pr';    VARtxtDHMZ{2}='oborina'; VARtxtWITHunits{2}='R (mm)';    

LOCtxt{1}='Cres';
LOCtxt{2}='Zadar';
LOCtxt{3}='VelaLuka';

RCPtxt{1}='26';
RCPtxt{2}='45';
RCPtxt{3}='85';

delta=nan(3,39,3,12); %3 stations, max RCP models+4 DHMZ, 3 RCPs, 12 months); %<-- Hardcoded
epsil=nan(3,39,3,12);

FUTA=17;


for RCP=[1:3] ;                 %-->RCP2.6, RCP4.5, RCP8.5
            models=importdata(['./models_RCP',RCPtxt{RCP},'.txt']);
            nMOD=size(models,1);
            for STT=[1:3] ;     %-->Cres, Zadar, Vela Luka
            for VAR=[1:2] ;     %-->tas, pr
            

            %--------------------------------->
            niz_za_analizu       =NaN;
            niz_za_analizu_trenda=NaN;
            %---------------------------------<

            for MOD=[1:nMOD];
	
                %------------------------
                % READ MODEL DATA
                %------------------------
        	      filename=['../FROM_ESGF_UKV_HIST_RCP',RCPtxt{RCP},'/STATION_',num2str(STT),'_',VARtxt{VAR},'_EUR-11_',models{MOD},'_mon_HISTincluded_1971-2070.nc'];
	              model_MMYYYY=squeeze(ncread(filename,VARtxt{VAR}));

                %------------------------
                % COMPUTE MODEL HIDRO0 climatology (1981-2010 mean); also P1 (2011-2040)&P2(2041-2070); some hard-coding
                %------------------------
                    model_HIDRO0=model_MMYYYY(120+1:120+12*30)';       %---> 1981-2010
                    model_HIDRO0=reshape(model_HIDRO0,12,30)';
                    model_HIDRO0=mean(   model_HIDRO0);

                        model_P1=model_MMYYYY(480+1:480+12*30)';       %---> 2011-2040
                        model_P1=reshape(model_P1,12,30)';
                        model_P1=mean(   model_P1);

                            model_P2=model_MMYYYY(840+1:840+12*30)';   %---> 2041-2070
                            model_P2=reshape(model_P2,12,30)';
                            model_P2=mean(   model_P2);
                
                %------------------------
                % READ OBS DATA
                %------------------------
        	      filename=['./DIR_DHMZ_mjerenja/DHMZ_',VARtxtDHMZ{VAR},'_',LOCtxt{STT},'_HIDRO0.txt'];
	              obs  =load(filename);                            %---> 1981-2010 mean: 12 numbers
		      obs=obs(1,:);

                %------------------------
                % UNITS CHANGE
                %------------------------
                    % tas: K -> deg C
                    % pr : kg / m2 /s -> mm (ignoring leap years, 360 calendar)
                    if (VAR==1); 
                        model_HIDRO0=model_HIDRO0-273.15; 
                        model_P1    =    model_P1-273.15; 
                        model_P2    =    model_P2-273.15; 
                    end
                    if (VAR==2); %assumption: 365 day calendar 
                        model_HIDRO0=model_HIDRO0*24*60*60.*[31 28 31 30 31 30 31 31 30 31 30 31]; 
                        model_P1    =    model_P1*24*60*60.*[31 28 31 30 31 30 31 31 30 31 30 31]; 
                        model_P2    =    model_P2*24*60*60.*[31 28 31 30 31 30 31 31 30 31 30 31]; 
                    end

                %------------------------
                % BIAS CORRECTION: DETERMINE COEFFICIENTS
                %------------------------
	              if (VAR==1); delta(STT,MOD,RCP,:)=obs -model_HIDRO0; end
        	      if (VAR==2); epsil(STT,MOD,RCP,:)=obs./model_HIDRO0; end
                
                %------------------------
                % BIAS CORRECTION: APPLY ON THE ORIGINAL TIMESERIES
                %------------------------
                    if (VAR==1)
                                        BC=squeeze(delta(STT,MOD,RCP,:))'; % simplify
                                        BC=repmat(BC,1,100)';              % 1971.-2070. > 100 years
                        model_MMYYYY_BC=BC+model_MMYYYY;
                        filename=['STATION_',num2str(STT),'_MOD_',num2str(MOD),'_RCP',num2str(RCP),'_VAR',num2str(VAR),'.txt'];
                        clear zapis; zapis=model_MMYYYY_BC-273.15;
                        save(filename,'-ascii','zapis');
                    end
                    if (VAR==2)
                                        BC=squeeze(epsil(STT,MOD,RCP,:))'; % simplify
                                        BC=repmat(BC,1,100)';              % 1971.-2070. > 100 years
                        model_MMYYYY_BC=BC.*model_MMYYYY;
                        filename=['STATION_',num2str(STT),'_MOD_',num2str(MOD),'_RCP',num2str(RCP),'_VAR',num2str(VAR),'.txt'];
                        clear zapis; zapis=model_MMYYYY_BC*24*60*60.*repmat([31 28 31 30 31 30 31 31 30 31 30 31]',100,1);
                        save(filename,'-ascii','zapis');
                    end

                %------------------------
                % COMPUTE MODEL HIDRO0 climatology (1981-2010 mean); also P1 (2011-2040)&P2(2041-2070): BC
                %------------------------
                    model_HIDRO0_BC=model_MMYYYY_BC(120+1:120+12*30)';      %---> 1981-2010
                    model_HIDRO0_BC=reshape(model_HIDRO0_BC,12,30)';
                    model_HIDRO0_BC=mean(   model_HIDRO0_BC);

                        model_P1_BC=model_MMYYYY_BC(480+1:480+12*30)';      %---> 2011-2040
                        model_P1_BC=reshape(model_P1_BC,12,30)';
                        model_P1_BC=mean(   model_P1_BC);

                            model_P2_BC=model_MMYYYY_BC(840+1:840+12*30)';  %---> 2041-2070
                            model_P2_BC=reshape(model_P2_BC,12,30)';
                            model_P2_BC=mean(   model_P2_BC);

                %------------------------
                % UNITS CHANGE: BC
                %------------------------
                    % tas: K -> deg C
                    % pr : kg / m2 /s -> mm (ignoring leap years, 360 calendar)
                    if (VAR==1); 
                        model_HIDRO0_BC=model_HIDRO0_BC-273.15; 
                        model_P1_BC=        model_P1_BC-273.15; 
                        model_P2_BC=        model_P2_BC-273.15; 
                    end
                    if (VAR==2); %assumption: 365 calendar
                        model_HIDRO0_BC=model_HIDRO0_BC*24*60*60.*[31 28 31 30 31 30 31 31 30 31 30 31]; 
                        model_P1_BC=        model_P1_BC*24*60*60.*[31 28 31 30 31 30 31 31 30 31 30 31]; 
                        model_P2_BC=        model_P2_BC*24*60*60.*[31 28 31 30 31 30 31 31 30 31 30 31]; 
                    end

                %------------------------
                % PLOTS: P2-HIDRO0, P1-HIDRO0
                %------------------------
                fig=figure(STT+VAR*10); set(gcf,'Position',[0 0 1500 500]);
                subplot(1,3,RCP);
                        if (VAR==1); %mean annual mean temperature
                            plot(mean(model_P1)-mean(model_HIDRO0),mean(model_P1_BC)-mean(model_HIDRO0_BC),'b o'); hold on
                            plot(mean(model_P2)-mean(model_HIDRO0),mean(model_P2_BC)-mean(model_HIDRO0_BC),'r s'); hold on
                        end
                        if (VAR==2); %mean annual precipitation amount
                            plot(12*mean(model_P1)-12*mean(model_HIDRO0),12*mean(model_P1_BC)-12*mean(model_HIDRO0_BC),'b o'); hold on
                            plot(12*mean(model_P2)-12*mean(model_HIDRO0),12*mean(model_P2_BC)-12*mean(model_HIDRO0_BC),'r s'); hold on
                        end
                        if (VAR==1); 
                                xlim([-2 6]); 
                                ylim([-2 6]);          
                                if (MOD==1); 
                                    plot([-2 6],[-2 6],'k-'); hold on; 
                                end
                        end
                        if (VAR==2); 
                                xlim(12*[-20 50]); 
                                ylim(12*[-20 50]);          
                                if (MOD==1); 
                                    plot(12*[-20 50],12*[-20 50],'k-'); hold on; 
                                end
                        end
                        if (MOD==1)
%                                xlabel(['RCM original: mean annual ',VARtxtWITHunits{VAR}],'Fontsize',FUTA);
%                                ylabel(['RCM BC      : mean annual ',VARtxtWITHunits{VAR}],'Fontsize',FUTA);
                                xlabel(['RCM original: godisnji srednjak ',VARtxtWITHunits{VAR}],'Fontsize',FUTA);
                                ylabel(['RCM BC      : godisnji srednjak ',VARtxtWITHunits{VAR}],'Fontsize',FUTA);
                                title([LOCtxt{STT},' RCP',RCPtxt{RCP},' PX-HIRDO0'],'Fontsize',14);
                                legend('P1-HIDRO0','P2-HIDRO0','Location','west');
                                grid off
                                axis equal
                        end
                        
                        if (MOD<nMOD+1);
                            niz_za_analizu=[niz_za_analizu; mean(model_P2_BC)-mean(model_HIDRO0_BC)];
                        end
                        if (MOD==nMOD);
                            if (VAR==1)
                                data_summary(1)= nanmin(niz_za_analizu);
                                data_summary(2)=nanmean(niz_za_analizu);
                                data_summary(3)= nanmax(niz_za_analizu);
                            end
                            if (VAR==2)
                                data_summary(1)=12*nanmin(niz_za_analizu);
                                data_summary(2)=12*nanmean(niz_za_analizu);
                                data_summary(3)=12*nanmax(niz_za_analizu);
                            end

                            text(0.4,0.30,[' maks(P2-HIDRO0)=',num2str(round(data_summary(3)*10)/10)],'units','normalized','Fontsize',FUTA-4);
                            text(0.4,0.25,['srednj(P2-HIDRO0)=',num2str(round(data_summary(2)*10)/10)],'units','normalized','Fontsize',FUTA-4);
                            text(0.4,0.20,[' min(P2-HIDRO0)=',num2str(round(data_summary(1)*10)/10)],'units','normalized','Fontsize',FUTA-4);
                        end
			set(gca,'Fontsize',FUTA);
			
                        if ((RCP==3)&&(MOD==nMOD));
                                filenamePNG=[LOCtxt{STT},'_',VARtxt{VAR},'_PXvsHIDRO0.png'];
                                print(fig,filenamePNG,'-dpng','-S1500,500');
                        end

                %------------------------
                % PLOTS: trends
                %------------------------
                fig=figure(STT+VAR*10+100); set(gcf,'Position',[0 0 1500 500]);
                    if (VAR==1)
                        niz_OG=mean(reshape(model_MMYYYY   ,12,100));
                        niz_BC=mean(reshape(model_MMYYYY_BC,12,100));
                    end
                    if (VAR==2)
                        niz_OG=mean(reshape(model_MMYYYY   ,12,100));
                        niz_BC=mean(reshape(model_MMYYYY_BC,12,100));
                    end
                    if (VAR==2);
                        niz_OG=niz_OG*24*60*60*365;
                        niz_BC=niz_BC*24*60*60*365; 
                    end
                        A_OG=polyfit([1:100],niz_OG,1);
                        A_BC=polyfit([1:100],niz_BC,1);

                subplot(1,3,RCP)
                    plot(A_OG(1)*10,A_BC(1)*10,'r s'); hold on
                        if (VAR==1); 
                                 xlim([-0.1 0.6]); 
                                 ylim([-0.1 0.6]);          
                                 if (MOD==1); 
                                     plot([-0.1 0.6],[-0.1 0.6],'k-'); hold on; 
                                 end
                        end
                        if (VAR==2); 
                                 xlim([-50 120]); 
                                 ylim([-50 120]);          
                                 if (MOD==1); 
                                     plot([-50 120],[-50 120],'k-'); hold on; 
                                 end
                        end
                        if (MOD==1)
%                                xlabel(['RCM original: trend of mean annual ',VARtxtWITHunits{VAR},'/10yr'],'Fontsize',FUTA);
%                                ylabel(['RCM BC: trend of mean annual ',VARtxtWITHunits{VAR},'/10yr'],'Fontsize',FUTA);
                                xlabel(['RCM original: trend godisnje ',VARtxtWITHunits{VAR},'/10god'],'Fontsize',FUTA);
                                ylabel(['RCM BC: trend godisnje ',VARtxtWITHunits{VAR},'/10god'],'Fontsize',FUTA);
                                title([LOCtxt{STT},' RCP',RCPtxt{RCP},' trendovi'],'Fontsize',14);
                                grid off
                                axis equal
                        end

                        if (MOD<nMOD+1);
                            niz_za_analizu_trenda=[niz_za_analizu_trenda; A_BC(1)*10];
                        end
                        if (MOD==nMOD);
                            data_summary(1)= nanmin(niz_za_analizu_trenda);
                            data_summary(2)=nanmean(niz_za_analizu_trenda);
                            data_summary(3)= nanmax(niz_za_analizu_trenda);

                            text(0.4,0.30,[' maks. trend=',num2str(round(data_summary(3)*100)/100)],'units','normalized','Fontsize',FUTA-4);
                            text(0.4,0.25,['srednj. trend=',num2str(round(data_summary(2)*100)/100)],'units','normalized','Fontsize',FUTA-4);
                            text(0.4,0.20,[' min. trend=',num2str(round(data_summary(1)*100)/100)],'units','normalized','Fontsize',FUTA-4);
                        end
			set(gca,'Fontsize',FUTA);

                        if ((RCP==3)&&(MOD==nMOD));
                                filenamePNG=[LOCtxt{STT},'_',VARtxt{VAR},'_trend_HIDRO0.png'];
                                print(fig,filenamePNG,'-dpng','-S1500,500');
                        end

            end %models
            end %variable
            end %station
end %RCP scenarios

toc
