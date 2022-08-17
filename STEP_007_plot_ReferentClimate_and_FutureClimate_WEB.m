clear all; close all; clc

tic

pkg load netcdf
pkg load statistics

%-------------------------------------------------------------------------------------------------------------

VARtxt{1}='tas';      VARtxtWITHunits{1}='t (st. C)';
VARtxt{2}='pr';       VARtxtWITHunits{2}='R (mm)';

RCPtxt{1}='26';       
RCPtxt{2}='45';          
RCPtxt{3}='85';

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

FUTA=18;

%-------------------------------------------------------------------------------------------------------------

for RCP=[1:3] ;                 %-->RCP2.6, RCP4.5, RCP8.5

    models=importdata(['./models_RCP',RCPtxt{RCP},'.txt']);
    nMOD=size(models,1);

   for STT=[1:20];    %1:22
    for VAR=[1:2];     %-->tas, pr
            niz_za_analizu       =NaN;
            for MOD=[1:nMOD];
                model_MMYYYY=load(['./PODACI_txt/STATION_',num2str(STT),'_MOD_',num2str(MOD),'_RCP',num2str(RCP),'_VAR',num2str(VAR),'_ORIG.txt']);

                model_P0=model_MMYYYY(120+1:120+12*30)';       %---> 1981-2010
                vremenski_niz=reshape(model_P0,12,30)';

                model_P0    =mean(  vremenski_niz);
                model_P0_std=std(   vremenski_niz);
                model_P0_cvv=std(   vremenski_niz)./mean(   vremenski_niz); clear vremenski_niz
                MATRIX_MOD(RCP,STT,VAR,MOD,1:12)    =model_P0;
                MATRIX_MOD_STD(RCP,STT,VAR,MOD,1:12)=model_P0_std;
                MATRIX_MOD_CVV(RCP,STT,VAR,MOD,1:12)=model_P0_cvv;

                model_P2=model_MMYYYY(840+1:840+12*30)';       %---> 2041-2070
                vremenski_niz=reshape(model_P2,12,30)';

                model_P2    =mean(  vremenski_niz);
                model_P2_std=std(   vremenski_niz);
                model_P2_cvv=std(   vremenski_niz)./mean(   vremenski_niz); clear vremenski_niz
                P2_MATRIX_MOD(RCP,STT,VAR,MOD,1:12)    =model_P2;
                P2_MATRIX_MOD_STD(RCP,STT,VAR,MOD,1:12)=model_P2_std;
                P2_MATRIX_MOD_CVV(RCP,STT,VAR,MOD,1:12)=model_P2_cvv;
                
            end %MOD 

%------------------------------------ RAW: P0 ------------------------------------------------------------

            figRAW(RCP)=figure(STT+VAR*10^2); set(gcf,'Position',[ 1    181   1440    900]);

            subplot(2,3,RCP)
                skup=squeeze(MATRIX_MOD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    c=errorbar([1:12],ens_mean,ens_devc           ); hold on; set(c,'Linewidth',2);
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            if (VAR==1); ylim([-10  35]); ylabel('t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([0 400]); ylabel('R (mm)','Fontsize',FUTA);   end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
                  	    set(gca,'Fontsize',FUTA)
            subplot(2,3,RCP+3)
                skup=squeeze(MATRIX_MOD_STD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    c=errorbar([1:12],ens_mean,ens_devc           ); hold on; set(c,'Linewidth',2);
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            if (VAR==1); ylim([0   5]); ylabel('std t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([0 300]); ylabel('std R (mm)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
                            set(gca,'Fontsize',FUTA)
                            text(0.05,0.05,'\copyright DHMZ','units','normalized','Fontsize',FUTA);
%               if (RCP==3);
                  filenamePNG=['RCP',num2str(RCP),'_evaluation_',LOCtxt{STT},'_',VARtxt{VAR},'_P0_RAW.png'];
                  print(figRAW(RCP),filenamePNG,'-dpng','-S1300,750');
                  close(figRAW(RCP))
%               end

%------------------------------------ RAW: P2-----------------------------------------------------------------

            P2_figRAW=figure(STT+VAR*10^3); set(gcf,'Position',[ 1    181   1440    900]);
            subplot(2,3,RCP)
                skup=squeeze(P2_MATRIX_MOD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    c=errorbar([1:12],ens_mean,ens_devc           ); hold on; set(c,'Linewidth',2);
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            if (VAR==1); ylim([-10  35]); ylabel('t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([0 400]); ylabel('R (mm)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
            subplot(2,3,RCP+3)
                skup=squeeze(P2_MATRIX_MOD_STD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    c=errorbar([1:12],ens_mean,ens_devc           ); hold on; set(c,'Linewidth',2);
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            if (VAR==1); ylim([0   5]); ylabel('std t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([0 300]); ylabel('std R (mm)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
%               if (RCP==3);
%                  filenamePNG=['future_',LOCtxt{STT},'_',VARtxt{VAR},'_P2_RAW.png'];
%                  print(P2_figRAW,filenamePNG,'-dpng','-S1300,750');
%                  close(P2_figRAW)
%               end

%------------------------------------ RAW: CV VERSION, PRECIPITATION ONLY, P0 ----------------------------
        if (VAR==2);
            figRAW_CV(RCP)=figure(STT+VAR*10^4); set(gcf,'Position',[ 1    181   1440    900]);
            subplot(2,3,RCP)
                skup=squeeze(MATRIX_MOD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    c=errorbar([1:12],ens_mean,ens_devc           ); hold on; set(c,'Linewidth',2);
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]); xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            ylim([0 400   ]); ylabel('R (mm)','Fontsize',FUTA);
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
             subplot(2,3,RCP+3)
                skup=squeeze(MATRIX_MOD_CVV(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup);
                ens_devc=std(skup);
                ens_mini=min(skup);
                ens_maxi=max(skup);
                    c=errorbar([1:12],ens_mean,ens_devc           ); hold on; set(c,'Linewidth',2);
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]); xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            ylim([0      3]); ylabel('cv R','Fontsize',FUTA);
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			                      set(gca,'Fontsize',FUTA)			
                            text(0.05,0.05,'\copyright DHMZ','units','normalized','Fontsize',FUTA);
%               if (RCP==3);
                  filenamePNG=['RCP',num2str(RCP),'_evaluation_',LOCtxt{STT},'_',VARtxt{VAR},'_P0_RAWvsOBS_CVVversion.png'];
                  print(figRAW_CV(RCP),filenamePNG,'-dpng','-S1300,750');
                  close(figRAW_CV(RCP))
%               end
         end
%------------------------------------ RAW: P2 vs. P0-------------------------------------------

            P2vsP0_figRAW(RCP)=figure(STT+VAR*10^5); set(gcf,'Position',[ 1    181   1440    900]);
            subplot(2,3,RCP)
                skup1=squeeze(   MATRIX_MOD(RCP,STT,VAR,1:nMOD,1:12));
                skup2=squeeze(P2_MATRIX_MOD(RCP,STT,VAR,1:nMOD,1:12));

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
                            if (VAR==1); ylim([-3    6]); ylabel('P2-P0 t (degC)','Fontsize',FUTA); end
                            if (VAR==2); ylim([-100 150]); ylabel('(P2-P0)/P0 R (%)','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
			    set(gca,'Fontsize',FUTA)
            subplot(2,3,RCP+3)
                skup1=squeeze(   MATRIX_MOD_STD(RCP,STT,VAR,1:nMOD,1:12));
                skup2=squeeze(P2_MATRIX_MOD_STD(RCP,STT,VAR,1:nMOD,1:12));
                ens_mean=mean(skup2./skup1);
                ens_devc= std(skup2./skup1);
                ens_mini= min(skup2./skup1);
                ens_maxi= max(skup2./skup1);
                    plot([0.5 12.5],[1 1],'r--'); hold on
                    c=errorbar([1:12],ens_mean,ens_devc           ); hold on; set(c,'Linewidth',2);
                    plot(    [1:12],ens_mini,'g'); hold on
                    plot(    [1:12],ens_maxi,'g'); hold on
                            xlim([0.5 12.5]);           xlabel('vrijeme (mjesec)','Fontsize',FUTA)
                            if (VAR==1); ylim([0.4 2]); ylabel('P2/P0 std t','Fontsize',FUTA); end
                            if (VAR==2); ylim([0   4]); ylabel('P2/P0 std R','Fontsize',FUTA);     end
                            title([LOCtxt{STT},' RCP',RCPtxt{RCP},' N:',num2str(nMOD)],'Fontsize',FUTA)
                            text(0.05,0.05,'\copyright DHMZ','units','normalized','Fontsize',FUTA);
			    set(gca,'Fontsize',FUTA)
%               if (RCP==3);
                  filenamePNG=['RCP',num2str(RCP),'_P2vsP0_',LOCtxt{STT},'_',VARtxt{VAR},'.png'];
                  print(P2vsP0_figRAW(RCP),filenamePNG,'-dpng','-S1300,750');
                  close(P2vsP0_figRAW(RCP))
%               end

end %variable      %-->tas, pr
end %station    
end %RCP scenarios %---> RCP2.6, RCP4.5, RCP8.5

toc
