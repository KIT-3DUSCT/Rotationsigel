function visualizeRotatedAperture(TASElements,profile,invert,mm)
if ~exist('invert','var') invert=1; end  %%invert for switched Z of matlab
if ~exist('mm','var') mm=0; end %%%if geom in mm

HW.nTAS=length(TASElements);%157;
%profile=[14.000000000000000   0.030300000000000;   6.199999999999998   0.025100000000000;  18.000000000000000   0.024900000000000;  -2.800000000000003   0.023500000000000;   9.599999999999998   0.022300000000000;  15.399999999999999   0.021300000000000;   4.199999999999998   0.019900000000000;  12.000000000000000   0.018900000000000;   6.999999999999998   0.018500000000000;  -1.600000000000001   0.016300000000000;   9.999999999999998   0.015700000000000;  15.799999999999999   0.015300000000000;   4.399999999999999   0.014700000000000;  18.000000000000000   0.013700000000000;   6.799999999999999   0.012700000000000;  12.599999999999998   0.011100000000000;   9.199999999999999   0.009500000000000;  -0.400000000000002   0.009500000000000;  17.000000000000000   0.008700000000000;   3.799999999999999   0.006900000000000;  11.199999999999999   0.006300000000000;  16.199999999999999   0.004100000000000;   7.399999999999999   0.003500000000000];
%load('geometryFileUSCT3Dv2_3.mat')

recposAll=[];  emitposAll=[]; recposNormalsAll=[];  emitposNormalsAll=[];

for j=1:HW.nTAS
    for i=1:size(TASElements(1).receiverPositions,1)
        recposAll= [recposAll; TASElements(j).receiverPositions(i,1:3)];
        recposNormalsAll= [recposNormalsAll; TASElements(j).receiverNormals(i,1:3)];
       
    end; 
end

for j=1:HW.nTAS
    for i=1:size(TASElements(1).emitterPositions,1)
        emitposAll=[emitposAll; TASElements(j).emitterPositions(i,1:3)];
        emitposNormalsAll=[emitposNormalsAll; TASElements(j).emitterNormals(i,1:3)];
    end; 
end

 if mm
     emitposAll=emitposAll/1000;
     recposAll= recposAll/1000;
 end
        
recposAllNew=[];recposNormalsAllNew=[];emitposAllNew=[];emitposNormalsAllNew=[];
for j=1:size(profile,1)
   %%%read out actual pos and create transform matrix
    rotshift=-20; %verschiebung um 20 grad ->
    transform_matrix= makehgtform('zrotate',2*pi*(rotshift+profile(j,1))/360)*makehgtform('translate',[0 0 profile(j,2)]);

    %transform it to the actual lift and rot-pos
     for i=1:size(recposAll,1)
         temp=([recposAll(i,:) 1]) * transform_matrix';
         recposAllNew(i,:,j)=[temp(1)/temp(4) temp(2)/temp(4) temp(3)/temp(4)];
         temp=([recposNormalsAll(i,:) 1]) * transform_matrix';
         recposNormalsAllNew(i,:,j)=[temp(1)/temp(4) temp(2)/temp(4) recposNormalsAll(i,3)];
     end
     for i=1:size(emitposAll,1)
         temp=([emitposAll(i,:) 1]) * transform_matrix';
         emitposAllNew(i,:,j)=[temp(1)/temp(4) temp(2)/temp(4) temp(3)/temp(4)];
         temp=([emitposNormalsAll(i,:) 1]) * transform_matrix';
         emitposNormalsAllNew(i,:,j)=[temp(1)/temp(4) temp(2)/temp(4) emitposNormalsAll(i,3)];
     end

   %  recposAll=recposAll-repmat(min([recposAll;emitposAll]),[HW.nTAS 1]);
   %  emitposAll=emitposAll-repmat(min([recposAll;emitposAll]),[HW.nTAS 1]);
   
end

%%invert 
if ~invert
emitposAllNew(:,2:3,:)= emitposAllNew(:,2:3,:).*-1;
recposAllNew(:,2:3,:)=recposAllNew(:,2:3,:).*-1;
emitposNormalsAllNew(:,2:3,:)= emitposNormalsAllNew(:,2:3,:).*-1;
recposNormalsAllNew(:,2:3,:)=recposNormalsAllNew(:,2:3,:).*-1;
end

%%draw
figure; hold on
for i=1:size(profile,1)  
    quiver3(recposAllNew(:,1,i),recposAllNew(:,2,i),recposAllNew(:,3,i),recposNormalsAllNew(:,1,i),recposNormalsAllNew(:,2,i),recposNormalsAllNew(:,3,i))
    
end
title(sprintf('Rotationsigel %d MPs',size(profile,1)));

if 0
%%%exact center!
dist=sqrt(sum(TASElements(1).receiverPositions(:,1:2).^2,2)); %bottom one

centerPos=zeros(size(TASElements,2),size(TASElements(1).receiverPositions,1),3);
for i=1:size(TASElements,2)
    centerPos(i,:,:)=cross(TASElements(i).receiverNormals,TASElements(i).receiverPositions)./repmat(dist,[1 3]); %%rotated doesnt matter
end
centerPos=reshape(centerPos,[size(TASElements(1).receiverPositions,1)*size(TASElements,2) 3]);

plot3(centerPos(:,1),centerPos(:,2),centerPos(:,3),'x')
end

disp('done');


end
