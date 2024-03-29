clear all; close all; clc

tic

pkg load netcdf
pkg load statistics

VARtxt{1}='tas';   VARtxtWITHunits{1}='t (st. C)'; 
VARtxt{2}='pr';    VARtxtWITHunits{2}='R (mm)';    

LOCtxt{ 1}='Zagreb';
LOCtxt{ 2}='Krapina';
LOCtxt{ 3}='Sisak';
LOCtxt{ 4}='Karlovac';
LOCtxt{ 5}='Varazdin';
LOCtxt{ 6}='Koprivnica';
LOCtxt{ 7}='Bjelovar';
LOCtxt{ 8}='Rijeka';
LOCtxt{ 9}='Gospic';
LOCtxt{10}='Virovitica';
LOCtxt{11}='Pozega';
LOCtxt{12}='SlavonskiBrod';
LOCtxt{13}='Zadar';
LOCtxt{14}='Osijek';
LOCtxt{15}='Sibenik';
LOCtxt{16}='Vukovar';
LOCtxt{17}='Split';
LOCtxt{18}='Pazin';
LOCtxt{19}='Dubrovnik';
LOCtxt{20}='Cakovec';
LOCtxt{21}='Djurdjenovac';
LOCtxt{22}='Nasice';

RCPtxt{1}='26';
RCPtxt{2}='45';
RCPtxt{3}='85';

FUTA=17;

for RCP=[1:3] ;                 %-->RCP2.6, RCP4.5, RCP8.5
            models=importdata(['./models_RCP',RCPtxt{RCP},'.txt']);
            nMOD=size(models,1);
            for STT=[1:22];
            for VAR=[1:2] ;     %-->tas, pr
            
            %--------------------------------->
            niz_za_analizu       =NaN;
            niz_za_analizu_trenda=NaN;
            %---------------------------------<

            for MOD=[1:nMOD];
	
                %------------------------
                % READ MODEL DATA
                %------------------------
        	      filename=['./FROM_ESGF_WEB_HIST_RCP',RCPtxt{RCP},'/STATION_',num2str(STT),'_',VARtxt{VAR},'_EUR-11_',models{MOD},'_mon_HISTincluded_1971-2070.nc'];
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
                % SAVE TXT TIMESERIES
                %------------------------
                    if (VAR==1)
                        filename=['STATION',num2str(STT),'_MOD',num2str(MOD),'_RCP',num2str(RCP),'_VAR',num2str(VAR),'_ORIG.txt'];
                        clear zapis; zapis=model_MMYYYY-273.15;
                        save(filename,'-ascii','zapis');
                    end
                    if (VAR==2)
                        filename=['STATION',num2str(STT),'_MOD',num2str(MOD),'_RCP',num2str(RCP),'_VAR',num2str(VAR),'_ORIG.txt'];
                        clear zapis; zapis=model_MMYYYY*24*60*60.*repmat([31 28 31 30 31 30 31 31 30 31 30 31]',100,1);
                        save(filename,'-ascii','zapis');
                    end

                %------------------------
                % PLOTS: P2-HIDRO0, P1-HIDRO0
                %------------------------
                fig=figure(STT+VAR*100); set(gcf,'Position',[0 0 1500 500]);
                subplot(1,3,RCP);
                        if (VAR==1); %mean annual mean temperature
                            plot(MOD,mean(model_P1)-mean(model_HIDRO0),'b o'); hold on
                            plot(MOD,mean(model_P2)-mean(model_HIDRO0),'r s'); hold on
                        end
                        if (VAR==2); %mean annual precipitation amount
                            plot(MOD,12*mean(model_P1)-12*mean(model_HIDRO0),'b o'); hold on
                            plot(MOD,12*mean(model_P2)-12*mean(model_HIDRO0),'r s'); hold on
                        end
                        if (VAR==1); 
                                ylim([-2 6]);          
                                %xlim([-2 6]); 
                                %if (MOD==1); 
                                %    plot([-2 6],[-2 6],'k-'); hold on; 
                                %end
                        end
                        if (VAR==2); 
                                ylim(12*[-20 50]);          
                                %xlim(12*[-20 50]); 
                                %if (MOD==1); 
                                %    plot(12*[-20 50],12*[-20 50],'k-'); hold on; 
                                %end
                        end
                        if (MOD==1)
                                ylabel(['RCM original: godisnji srednjak ',VARtxtWITHunits{VAR}],'Fontsize',FUTA);
                                title([LOCtxt{STT},' RCP',RCPtxt{RCP}],'Fontsize',14);
                                legend('P1-HIDRO0','P2-HIDRO0','Location','northwest');
                        end
                        
                        if (MOD<nMOD+1);
                            niz_za_analizu=[niz_za_analizu; mean(model_P2)-mean(model_HIDRO0)];
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

                            text(0.4,0.80,[' maksimum(P2-P0)=',num2str(round(data_summary(3)*10)/10)],'units','normalized','Fontsize',FUTA-4);
                            text(0.4,0.75,[' srednjak(P2-P0)=',num2str(round(data_summary(2)*10)/10)],'units','normalized','Fontsize',FUTA-4);
                            text(0.4,0.70,['  minimum(P2-P0)=',num2str(round(data_summary(1)*10)/10)],'units','normalized','Fontsize',FUTA-4);
                        end

			set(gca,'Fontsize',FUTA);
			
                        if ((RCP==3)&&(MOD==nMOD));
                                filenamePNG=[LOCtxt{STT},'_',VARtxt{VAR},'_PXvsHIDRO0.png'];
                                print(fig,filenamePNG,'-dpng','-S1500,500');
                        end

            end %models
            end %variable
            end %station
end %RCP scenarios

toc
