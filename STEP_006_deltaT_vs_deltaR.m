clear all; close all; clc

tic

racun            =1;                %STATUS: OK
crtanje_YEAR     =1;                %STATUS: OK
crtanje_MULTIYEAR=1;                %STATUS: OK
FUTA=16;

%------------------------------------------------------------------------------

 M_R=[14 22 39]; %number of models in RCP2.6, RCP4.5 and RCP8.5
%M_R=[13 18 35]; %number of models in RCP2.6, RCP4.5 and RCP8.5 ali bez DHMZ

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

RCPtxt{1}='2.6';
RCPtxt{2}='4.5';
RCPtxt{3}='8.5';

%------------------------------------------------------------------------------

if (racun==1);

for S=[1:22];
for R=[1:3];
for M=[1:M_R(R)];

  %--------> MONTHLY MEANS and MONTHLY SUM
  v1_MON{S,R,M}=load(['./PODACI_txt/STATION_',num2str(S),'_MOD_',num2str(M),'_RCP',num2str(R),'_VAR1_ORIG.txt']);
  v2_MON{S,R,M}=load(['./PODACI_txt/STATION_',num2str(S),'_MOD_',num2str(M),'_RCP',num2str(R),'_VAR2_ORIG.txt']);

  %--------> ANNUAL MEANS and ANNUAL SUM
  clear temp; temp=v1_MON{S,R,M}; v1_YEAR{S,R,M}=mean(reshape(temp,12,100));
  clear temp; temp=v2_MON{S,R,M}; v2_YEAR{S,R,M}= sum(reshape(temp,12,100));

  %--------> P0 and P2 MULTI-ANNUAL means
  clear temp; temp=v1_YEAR{S,R,M};
                   v1_MULTIYEAR_H{S,R,M}   =mean(temp(11:40));                     %1981-2010
                   v1_MULTIYEAR_F{S,R,M}   =mean(temp(71:100));                    %2041-2070
                   v1_diff_MULTIYEAR{S,R,M}=v1_MULTIYEAR_F{S,R,M}-v1_MULTIYEAR_H{S,R,M};

  clear temp; temp=v2_YEAR{S,R,M};
                   v2_MULTIYEAR_H{S,R,M}   =mean(temp(11:40));                     %1981-2010
                   v2_MULTIYEAR_F{S,R,M}   =mean(temp(71:100));                    %2041-2070
                   v2_diff_MULTIYEAR{S,R,M}=v2_MULTIYEAR_F{S,R,M}./v2_MULTIYEAR_H{S,R,M};

end
  %--------> statistics
                                    a=[v1_diff_MULTIYEAR{S,R,1:M_R(R)}];
                v1_STAT(S,R,1)= max(a);
                v1_STAT(S,R,2)=mean(a);
                v1_STAT(S,R,3)= min(a);
                v1_STAT(S,R,4)=prctile(a,75);
                v1_STAT(S,R,5)=prctile(a,50);
                v1_STAT(S,R,6)=prctile(a,25);

                                    a=[v2_diff_MULTIYEAR{S,R,1:M_R(R)}];
                v2_STAT(S,R,1)= max(a);
                v2_STAT(S,R,2)=mean(a);
                v2_STAT(S,R,3)= min(a);
                v2_STAT(S,R,4)=prctile(a,75);
                v2_STAT(S,R,5)=prctile(a,50);
                v2_STAT(S,R,6)=prctile(a,25);


end
end

end %racun

%------------------------------------------------------------------------------

if (crtanje_YEAR==1);

for S=[1:22];
for R=[1:3];
  figure(S) %everyting raw
  for M=[1:M_R(R)];
      subplot(3,2, 1+(R-1)*2)
        plot(v1_YEAR{S,R,M}-v1_MULTIYEAR_H{S,R,M},'k'); hold on
           ylim([-4 8])
           title([LOCtxt{S},' RCP',RCPtxt{R},' N:',num2str(M_R(R))])
		set(gca,'Fontsize',FUTA)
      subplot(3,2, 2+(R-1)*2)
        plot(v2_YEAR{S,R,M}./v2_MULTIYEAR_H{S,R,M},'k'); hold on
           ylim([0.5 3])
           title([LOCtxt{S},' RCP',RCPtxt{R},' N:',num2str(M_R(R))])
		set(gca,'Fontsize',FUTA)
  end
end
end

end %crtanje

%------------------------------------------------------------------------------

if (crtanje_MULTIYEAR==1);

  for S=[1:22];
  for R=[1:3];
  fig=figure(100+S); set(gcf,'Position',[1    472   1440    437]);
  for M=[1:M_R(R)];
      subplot(1,3,R)

         plot(v2_MULTIYEAR_F{S,R,M}/v2_MULTIYEAR_H{S,R,M},v1_MULTIYEAR_F{S,R,M}-v1_MULTIYEAR_H{S,R,M},'s b'); hold on

          xlim([ 0.8 1.2]);          
          ylim([-1.0 3.5]);
          title([LOCtxt{S},' RCP',RCPtxt{R},' N:',num2str(M_R(R))])
          ylabel('P2-P0 t (degC)')
          xlabel('P2/P0 R (-)')
		set(gca,'Fontsize',FUTA)

%-------> Adding table
          if (M==1)
            text(0.1,0.95,'Max :','units','normalized'); text(0.3,0.95,num2str(round(v1_STAT(S,R,1)*100)/100),'units','normalized');
            text(0.1,0.90,'Mean:','units','normalized'); text(0.3,0.90,num2str(round(v1_STAT(S,R,2)*100)/100),'units','normalized');
            text(0.1,0.85,'Min :','units','normalized'); text(0.3,0.85,num2str(round(v1_STAT(S,R,3)*100)/100),'units','normalized');
            text(0.1,0.15,'P75 :','units','normalized'); text(0.3,0.15,num2str(round(v1_STAT(S,R,4)*100)/100),'units','normalized');
            text(0.1,0.10,'P50 :','units','normalized'); text(0.3,0.10,num2str(round(v1_STAT(S,R,5)*100)/100),'units','normalized');
            text(0.1,0.05,'P25 :','units','normalized'); text(0.3,0.05,num2str(round(v1_STAT(S,R,6)*100)/100),'units','normalized');
          end

%-------> Adding table
          if (M==1)
            text(0.7,0.95,'Max :','units','normalized'); text(0.9,0.95,num2str(round(v2_STAT(S,R,1)*100)/100),'units','normalized');
            text(0.7,0.90,'Mean:','units','normalized'); text(0.9,0.90,num2str(round(v2_STAT(S,R,2)*100)/100),'units','normalized');
            text(0.7,0.85,'Min :','units','normalized'); text(0.9,0.85,num2str(round(v2_STAT(S,R,3)*100)/100),'units','normalized');
            text(0.7,0.15,'P75 :','units','normalized'); text(0.9,0.15,num2str(round(v2_STAT(S,R,4)*100)/100),'units','normalized');
            text(0.7,0.10,'P50 :','units','normalized'); text(0.9,0.10,num2str(round(v2_STAT(S,R,5)*100)/100),'units','normalized');
            text(0.7,0.05,'P25 :','units','normalized'); text(0.9,0.05,num2str(round(v2_STAT(S,R,6)*100)/100),'units','normalized');
          end

  end
  filenamePNG=['STATION_',num2str(S),'_MeanChange.png'];
  print(fig,filenamePNG,'-dpng','-S1400,400');
end
end

end %crtanje MULTIYEAR

toc
