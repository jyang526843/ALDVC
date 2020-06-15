% ==============================================
% function ALDIC: Subpb1 3D DVC
% ==============================================

function [USubpb1,HPar,ALSub1Time,ConvItPerEle] = Subpb13(USubpb2,FSubpb2,udual,vdual,coordinatesFEM,...
    Df,Img1,Img2,winsize,mu,beta,HPar,ALSolveStep,tol,ICGNmethod,ClusterNo,interpmethod,displayIterOrNot,MaxIterNum)

DIM = 3;
temp = zeros(size(coordinatesFEM,1),1); UPar = cell(DIM,1); for tempi = 1:DIM, UPar{tempi} = temp; end
ConvItPerEle = zeros(size(coordinatesFEM,1),1);
HtempPar = zeros(length(HPar{1}),size(HPar,1));
for tempj = 1:size(HPar,1), HtempPar(:,tempj)=HPar{tempj}; end
 
% ------ Within each iteration step ------
% disp('This step takes not short time, please drink coffee and wait.'); tic;
% -------- How to change parallel pools ---------
% myCluster = parcluster('local');
% myCluster.NumWorkers = 4;  % 'Modified' property now TRUE
% saveProfile(myCluster);    % 'local' profile now updated,
%                            % 'Modified' property now FALSE
% -------------- Or we can do this --------------
% Go to the Parallel menu, then select Manage Cluster Profiles.
% Select the "local" profile, and change NumWorkers to 4.
% -----------------------------------------------
switch ClusterNo
    case 0 || 1
        h = waitbar(0,'Please wait for Subproblem 1 IC-GN iterations!'); tic;
        for tempj = 1:size(coordinatesFEM,1)  % tempj is the element index
            
            %try
                
                HLocal = zeros(12,12);
                if ALSolveStep > 1
                    HLocal(1:12) = [HPar{1}(tempj); HPar{2}(tempj); HPar{3}(tempj); HPar{4}(tempj); HPar{5}(tempj); HPar{6}(tempj); ...
                        HPar{7}(tempj); HPar{8}(tempj); HPar{9}(tempj); HPar{10}(tempj); HPar{11}(tempj); HPar{12}(tempj)];
                    HLocal(12+2:12*2) = [HPar{13}(tempj); HPar{14}(tempj); HPar{15}(tempj); HPar{16}(tempj); HPar{17}(tempj); ...
                        HPar{18}(tempj); HPar{19}(tempj); HPar{20}(tempj); HPar{21}(tempj); HPar{22}(tempj); HPar{23}(tempj)];
                    HLocal(12*2+3:12*3) = [HPar{24}(tempj); HPar{25}(tempj); HPar{26}(tempj); HPar{27}(tempj); HPar{28}(tempj); ...
                        HPar{29}(tempj); HPar{30}(tempj); HPar{31}(tempj); HPar{32}(tempj); HPar{33}(tempj)];
                    HLocal(12*3+4:12*4) = [HPar{34}(tempj); HPar{35}(tempj); HPar{36}(tempj); HPar{37}(tempj); HPar{38}(tempj); ...
                        HPar{39}(tempj); HPar{40}(tempj); HPar{41}(tempj); HPar{42}(tempj)];
                    HLocal(12*4+5:12*5) = [HPar{43}(tempj); HPar{44}(tempj); HPar{45}(tempj); HPar{46}(tempj); HPar{47}(tempj); ...
                        HPar{48}(tempj); HPar{49}(tempj); HPar{50}(tempj)];
                    HLocal(12*5+6:12*6) = [HPar{51}(tempj); HPar{52}(tempj); HPar{53}(tempj); HPar{54}(tempj); HPar{55}(tempj); ...
                        HPar{56}(tempj); HPar{57}(tempj)];
                    HLocal(12*6+7:12*7) = [HPar{58}(tempj); HPar{59}(tempj); HPar{60}(tempj); HPar{61}(tempj); HPar{62}(tempj); ...
                        HPar{63}(tempj)];
                    HLocal(12*7+8:12*8) = [HPar{64}(tempj); HPar{65}(tempj); HPar{66}(tempj); HPar{67}(tempj); HPar{68}(tempj)];
                    HLocal(12*8+9:12*9) = [HPar{69}(tempj); HPar{70}(tempj); HPar{71}(tempj); HPar{72}(tempj)];
                    HLocal(12*9+10:12*10) = [HPar{73}(tempj); HPar{74}(tempj); HPar{75}(tempj)];
                    HLocal(12*10+11:12*11) = [HPar{76}(tempj); HPar{77}(tempj)];
                    HLocal(12*12) = [HPar{78}(tempj)];
                    
                    HLocal = HLocal'+HLocal-diag(diag(HLocal));
                    
                end
                
                DfEle = struct(); DfEle.imgSize = Df.imgSize;
                xyz1 = coordinatesFEM(tempj,:) - 0.5*winsize; xyz7 = xyz1 + winsize;
                 
                ImgEle = struct();
                ImgEle.Imgf = Img1(xyz1(1)-3:1:xyz7(1)+3, xyz1(2)-3:1:xyz7(2)+3, xyz1(3)-3:1:xyz7(3)+3);
                ImgEle.Imgg = Img2;
                ImgEle.ImggAxis = [1,size(Img2,1),1,size(Img2,2),1,size(Img2,3)]-1;
                 
                [Utemp, ConvItPerEle(tempj), HtempPar(tempj,:)] = ...
                    funICGN_Subpb13(coordinatesFEM(tempj,:),DfEle,ImgEle,winsize,...
                    HLocal,beta,mu,udual(DIM^2*tempj-(DIM^2-1):DIM^2*tempj),vdual(DIM*tempj-(DIM-1):DIM*tempj),...
                    USubpb2(DIM*tempj-(DIM-1):DIM*tempj),FSubpb2(DIM^2*tempj-(DIM^2-1):DIM^2*tempj),tol,ICGNmethod,interpmethod,MaxIterNum);
                
%             catch
%                 
%                 Utemp = nan(3,1); ConvItPerEle(tempj) = 0;
%                 
%             end
             
            if displayIterOrNot == 1, disp(['ele ',num2str(tempj),' converge or not is ',num2str(ConvItPerEle(tempj)),' (1-converged; 0-unconverged)']); end
            
            % ------ Store solved deformation gradients ------
            UPar{1}(tempj) = Utemp(1); UPar{2}(tempj) = Utemp(2); UPar{3}(tempj) = Utemp(3);
            waitbar(tempj/(size(coordinatesFEM,1)));
            
        end
        close(h); ALSub1Time = toc;
        
    otherwise
        
        temp = zeros(size(coordinatesFEM,1),1); UtempPar2 = temp; VtempPar2 = temp; WtempPar2 = temp;
        ConvItPerEle2 = zeros(size(coordinatesFEM,1),1); 
        imgSize = Df.imgSize; tic; 
        % -----------------------------------------------
        % Start parallel computing
        % ****** This step needs to be careful: may be out of memory ******
        % delete(gcp);parpool(ClusterNo); tic;
        
        % ------ Prestore subset info for parfor ------
        %DfElePar = cell(1,size(coordinatesFEM,1));
        imgSubsetPar = cell(1,size(coordinatesFEM,1)); imgSubsetParIndex = zeros(1,size(coordinatesFEM,1));
        U0Par = cell(1,size(coordinatesFEM,1)); Vdual0Par = U0Par;
        F0Par = cell(1,size(coordinatesFEM,1)); Udual0Par = F0Par;
        hbar = waitbar(0,'Pre-store subset info before parfor Subproblem 1 IC-GN iterations!');
         
        for tempj = 1:size(coordinatesFEM,1)
            
%            try
                
                % Save RAM and pre-store all the image subset info.
                DfEle = struct();
                DfEle.imgSize = imgSize;
                
                xyz1 = coordinatesFEM(tempj,:) - 0.5*winsize; xyz7 = xyz1 + winsize;
                
                ImgEle = struct();
                ImgEle.Imgf = Img1(xyz1(1)-3:1:xyz7(1)+3, xyz1(2)-3:1:xyz7(2)+3, xyz1(3)-3:1:xyz7(3)+3);
                
                xyz1g = floor(coordinatesFEM(tempj,:) + USubpb2(3*tempj+[-2,-1,0])' - max([0.55*winsize,0.5*winsize+3]));
                xyz7g = ceil(coordinatesFEM(tempj,:) + USubpb2(3*tempj+[-2,-1,0])' + max([0.55*winsize,0.5*winsize+3]));
                
                % If image out of border, use original full size image
                if (xyz1g(1)<1) || (xyz7g(1)>size(Img2,1)) || (xyz1g(2)<1) || (xyz7g(2)>size(Img2,2)) || (xyz1g(3)<1) || (xyz7g(3)>size(Img2,3))
                    ImgEle.Imgg = Img2;
                    ImgEle.ImggAxis = [1,size(Img2,1),1,size(Img2,2),1,size(Img2,3)]-1;
                else % otherwise use only neighboring voxels to save memory
                    ImgEle.Imgg = Img2(xyz1g(1):1:xyz7g(1), xyz1g(2):1:xyz7g(2), xyz1g(3):1:xyz7g(3));
                    ImgEle.ImggAxis = [xyz1g(1),xyz7g(1),xyz1g(2),xyz7g(2),xyz1g(3),xyz7g(3)]-1;
                    imgSubsetParIndex(tempj) = 1; % Label subsets which will be solved only using surrounding voxels
                end
                
                DfElePar{:,tempj} = DfEle;
                imgSubsetPar{:,tempj} = ImgEle;
                U0Par{:,tempj} = USubpb2(3*tempj-2:3*tempj); Vdual0Par{:,tempj} = vdual(3*tempj-2:3*tempj);
                F0Par{:,tempj} = FSubpb2(9*tempj-8:9*tempj); Udual0Par{:,tempj} = udual(9*tempj-8:9*tempj);
                
%            catch
%                 
%                 DfElePar{:,tempj} = [];
%                 imgSubsetPar{:,tempj} = [];
%                 U0Par{:,tempj} = zeros(3,1); Vdual0Par{:,tempj} = zeros(3,1);
%                 F0Par{:,tempj} = zeros(9,1); Udual0Par{:,tempj} = zeros(9,1);
%                 
%             end
            
            waitbar(tempj/(size(coordinatesFEM,1)));
            
        end
        close(hbar);
        
        [~,imgSubsetParIndexList] = find(imgSubsetParIndex == 1); % Label subsets which will be solved only using surrounding voxels input
        [~,imgSubsetParIndexFull] = find(imgSubsetParIndex == 0); % Subsets will be solved using full image voxels input
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % --------------- Start Local ICGN --------------
        hbar = parfor_progressbar(length(imgSubsetParIndexList),'Part 1: Parallel-computing Subproblem 1 IC-GN iterations!');
        parfor tempjj = 1:length(imgSubsetParIndexList) %size(coordinatesFEM,1)
            
            tempj = imgSubsetParIndexList(tempjj);
            
%             try
                
                HLocal = zeros(12,12);
                
                if ALSolveStep > 1
                    HLocal(1:12) = [HPar{1}(tempj); HPar{2}(tempj); HPar{3}(tempj); HPar{4}(tempj); HPar{5}(tempj); HPar{6}(tempj); ...
                        HPar{7}(tempj); HPar{8}(tempj); HPar{9}(tempj); HPar{10}(tempj); HPar{11}(tempj); HPar{12}(tempj)];
                    HLocal(12+2:12*2) = [HPar{13}(tempj); HPar{14}(tempj); HPar{15}(tempj); HPar{16}(tempj); HPar{17}(tempj); ...
                        HPar{18}(tempj); HPar{19}(tempj); HPar{20}(tempj); HPar{21}(tempj); HPar{22}(tempj); HPar{23}(tempj)];
                    HLocal(12*2+3:12*3) = [HPar{24}(tempj); HPar{25}(tempj); HPar{26}(tempj); HPar{27}(tempj); HPar{28}(tempj); ...
                        HPar{29}(tempj); HPar{30}(tempj); HPar{31}(tempj); HPar{32}(tempj); HPar{33}(tempj)];
                    HLocal(12*3+4:12*4) = [HPar{34}(tempj); HPar{35}(tempj); HPar{36}(tempj); HPar{37}(tempj); HPar{38}(tempj); ...
                        HPar{39}(tempj); HPar{40}(tempj); HPar{41}(tempj); HPar{42}(tempj)];
                    HLocal(12*4+5:12*5) = [HPar{43}(tempj); HPar{44}(tempj); HPar{45}(tempj); HPar{46}(tempj); HPar{47}(tempj); ...
                        HPar{48}(tempj); HPar{49}(tempj); HPar{50}(tempj)];
                    HLocal(12*5+6:12*6) = [HPar{51}(tempj); HPar{52}(tempj); HPar{53}(tempj); HPar{54}(tempj); HPar{55}(tempj); ...
                        HPar{56}(tempj); HPar{57}(tempj)];
                    HLocal(12*6+7:12*7) = [HPar{58}(tempj); HPar{59}(tempj); HPar{60}(tempj); HPar{61}(tempj); HPar{62}(tempj); ...
                        HPar{63}(tempj)];
                    HLocal(12*7+8:12*8) = [HPar{64}(tempj); HPar{65}(tempj); HPar{66}(tempj); HPar{67}(tempj); HPar{68}(tempj)];
                    HLocal(12*8+9:12*9) = [HPar{69}(tempj); HPar{70}(tempj); HPar{71}(tempj); HPar{72}(tempj)];
                    HLocal(12*9+10:12*10) = [HPar{73}(tempj); HPar{74}(tempj); HPar{75}(tempj)];
                    HLocal(12*10+11:12*11) = [HPar{76}(tempj); HPar{77}(tempj)];
                    HLocal(12*12) = [HPar{78}(tempj)];
                    
                    HLocal = HLocal'+HLocal-diag(diag(HLocal));
                end
                
                %[Utemp, ConvItPerEle2(tempjj), HtempPar2(tempjj,:)] = ...
                [Utemp, ConvItPerEle2(tempjj), ~] = ...
                    funICGN_Subpb13(coordinatesFEM(tempj,:),DfElePar{:,tempj},imgSubsetPar{:,tempj},winsize,...
                    HLocal,beta,mu,Udual0Par{:,tempj},Vdual0Par{:,tempj},...
                    U0Par{:,tempj},F0Par{:,tempj},tol,ICGNmethod,interpmethod,MaxIterNum);
                %HLocal,beta,mu,udual(DIM^2*tempj-(DIM^2-1):DIM^2*tempj),vdual(DIM*tempj-(DIM-1):DIM*tempj),...
                %USubpb2(DIM*tempj-(DIM-1):DIM*tempj),FSubpb2(DIM^2*tempj-(DIM^2-1):DIM^2*tempj),tol,ICGNmethod,interpmethod);
                
%             catch
%                 
%                 Utemp = nan(3,1); ConvItPerEle2(tempjj) = 0;
%                 % HtempPar2(tempjj,:) = zeros(1,78);
%                 
%             end
            
            if displayIterOrNot == 1, disp(['ele ',num2str(tempj),' converge or not is ',num2str(ConvItPerEle2(tempjj)),' (1-converged; 0-unconverged)']); end
            % ------ Store solved deformation gradients ------
            UtempPar2(tempjj) = Utemp(1); VtempPar2(tempjj) = Utemp(2); WtempPar2(tempjj) = Utemp(3);
            % if ALSolveStep == 1
            %     HPar1(tempj) = Htemp(1); HPar2(tempj) = Htemp(2); HPar3(tempj) = Htemp(3); HPar4(tempj) = Htemp(4); HPar5(tempj) = Htemp(5);
            %     HPar6(tempj) = Htemp(6); HPar7(tempj) = Htemp(8); HPar8(tempj) = Htemp(9); HPar9(tempj) = Htemp(10); HPar10(tempj) = Htemp(11);
            %     HPar11(tempj) = Htemp(12); HPar12(tempj) = Htemp(15); HPar13(tempj) = Htemp(16); HPar14(tempj) = Htemp(17);
            %     HPar15(tempj) = Htemp(18); HPar16(tempj) = Htemp(22); HPar17(tempj) = Htemp(23); HPar18(tempj) = Htemp(24);
            %     HPar19(tempj) = Htemp(29); HPar20(tempj) = Htemp(30); HPar21(tempj) = Htemp(36);
            % end
            hbar.iterate(1);
            
        end
        close(hbar);
        
        ConvItPerEle(imgSubsetParIndexList) = ConvItPerEle2(1:length(imgSubsetParIndexList));
        % HtempPar(imgSubsetParIndexList,:) = HtempPar2(1:length(imgSubsetParIndexList),:);
        
        UtempPar(imgSubsetParIndexList) = UtempPar2(1:length(imgSubsetParIndexList));
        VtempPar(imgSubsetParIndexList) = VtempPar2(1:length(imgSubsetParIndexList));
        WtempPar(imgSubsetParIndexList) = WtempPar2(1:length(imgSubsetParIndexList));
        
        % -----------------------------------------------
        hbar = waitbar(0,'Part 2: Sequential-computing left Subproblem 1 IC-GN iterations!');
        for tempjj = 1:length(imgSubsetParIndexFull) %size(coordinatesFEM,1)
            
            tempj = imgSubsetParIndexFull(tempjj);
%             try
                
                HLocal = zeros(12,12);
                
                if ALSolveStep > 1
                    HLocal(1:12) = [HPar{1}(tempj); HPar{2}(tempj); HPar{3}(tempj); HPar{4}(tempj); HPar{5}(tempj); HPar{6}(tempj); ...
                        HPar{7}(tempj); HPar{8}(tempj); HPar{9}(tempj); HPar{10}(tempj); HPar{11}(tempj); HPar{12}(tempj)];
                    HLocal(12+2:12*2) = [HPar{13}(tempj); HPar{14}(tempj); HPar{15}(tempj); HPar{16}(tempj); HPar{17}(tempj); ...
                        HPar{18}(tempj); HPar{19}(tempj); HPar{20}(tempj); HPar{21}(tempj); HPar{22}(tempj); HPar{23}(tempj)];
                    HLocal(12*2+3:12*3) = [HPar{24}(tempj); HPar{25}(tempj); HPar{26}(tempj); HPar{27}(tempj); HPar{28}(tempj); ...
                        HPar{29}(tempj); HPar{30}(tempj); HPar{31}(tempj); HPar{32}(tempj); HPar{33}(tempj)];
                    HLocal(12*3+4:12*4) = [HPar{34}(tempj); HPar{35}(tempj); HPar{36}(tempj); HPar{37}(tempj); HPar{38}(tempj); ...
                        HPar{39}(tempj); HPar{40}(tempj); HPar{41}(tempj); HPar{42}(tempj)];
                    HLocal(12*4+5:12*5) = [HPar{43}(tempj); HPar{44}(tempj); HPar{45}(tempj); HPar{46}(tempj); HPar{47}(tempj); ...
                        HPar{48}(tempj); HPar{49}(tempj); HPar{50}(tempj)];
                    HLocal(12*5+6:12*6) = [HPar{51}(tempj); HPar{52}(tempj); HPar{53}(tempj); HPar{54}(tempj); HPar{55}(tempj); ...
                        HPar{56}(tempj); HPar{57}(tempj)];
                    HLocal(12*6+7:12*7) = [HPar{58}(tempj); HPar{59}(tempj); HPar{60}(tempj); HPar{61}(tempj); HPar{62}(tempj); ...
                        HPar{63}(tempj)];
                    HLocal(12*7+8:12*8) = [HPar{64}(tempj); HPar{65}(tempj); HPar{66}(tempj); HPar{67}(tempj); HPar{68}(tempj)];
                    HLocal(12*8+9:12*9) = [HPar{69}(tempj); HPar{70}(tempj); HPar{71}(tempj); HPar{72}(tempj)];
                    HLocal(12*9+10:12*10) = [HPar{73}(tempj); HPar{74}(tempj); HPar{75}(tempj)];
                    HLocal(12*10+11:12*11) = [HPar{76}(tempj); HPar{77}(tempj)];
                    HLocal(12*12) = [HPar{78}(tempj)];
                    
                    HLocal = HLocal'+HLocal-diag(diag(HLocal));
                end
                
                % [Utemp, ConvItPerEle(tempj), HtempPar(tempj,:)] = ...
                [Utemp, ConvItPerEle(tempj),~] = ...
                    funICGN_Subpb13(coordinatesFEM(tempj,:),DfElePar{:,tempj},imgSubsetPar{:,tempj},winsize,...
                    HLocal,beta,mu,Udual0Par{:,tempj},Vdual0Par{:,tempj},...
                    U0Par{:,tempj},F0Par{:,tempj},tol,ICGNmethod,interpmethod,MaxIterNum);
                %HLocal,beta,mu,udual(DIM^2*tempj-(DIM^2-1):DIM^2*tempj),vdual(DIM*tempj-(DIM-1):DIM*tempj),...
                %USubpb2(DIM*tempj-(DIM-1):DIM*tempj),FSubpb2(DIM^2*tempj-(DIM^2-1):DIM^2*tempj),tol,ICGNmethod,interpmethod);
                
%             catch
%                 
%                 Utemp = nan(3,1); ConvItPerEle(tempj) = 0;
%                 % HtempPar(tempj,:) = zeros(1,78);
%                 
%             end
            
            if displayIterOrNot == 1, disp(['ele ',num2str(tempj),' converge or not is ',num2str(ConvItPerEle2(tempjj)),' (1-converged; 0-unconverged)']); end
            % ------ Store solved deformation gradients ------
            UtempPar(tempj) = Utemp(1); VtempPar(tempj) = Utemp(2); WtempPar(tempj) = Utemp(3);
            % if ALSolveStep == 1
            %     HPar1(tempj) = Htemp(1); HPar2(tempj) = Htemp(2); HPar3(tempj) = Htemp(3); HPar4(tempj) = Htemp(4); HPar5(tempj) = Htemp(5);
            %     HPar6(tempj) = Htemp(6); HPar7(tempj) = Htemp(8); HPar8(tempj) = Htemp(9); HPar9(tempj) = Htemp(10); HPar10(tempj) = Htemp(11);
            %     HPar11(tempj) = Htemp(12); HPar12(tempj) = Htemp(15); HPar13(tempj) = Htemp(16); HPar14(tempj) = Htemp(17);
            %     HPar15(tempj) = Htemp(18); HPar16(tempj) = Htemp(22); HPar17(tempj) = Htemp(23); HPar18(tempj) = Htemp(24);
            %     HPar19(tempj) = Htemp(29); HPar20(tempj) = Htemp(30); HPar21(tempj) = Htemp(36);
            % end
            waitbar(tempjj/(length(imgSubsetParIndexFull)));
            
        end
        
        
        
        close(hbar); ALSub1Time = toc;
        %for tempi = 1:78, eval(['HPar{',num2str(tempi),'}=HPar',num2str(tempi),';']); end
        UPar{1} = UtempPar; UPar{2} = VtempPar; UPar{3} = WtempPar;
        
        % clear HPar1 HPar2 HPar3 HPar4 HPar5 HPar6 HPar7 HPar8 HPar9 HPar10 HPar11 HPar12 HPar13 HPar14 HPar15 HPar16 HPar17 HPar18 HPar19 HPar20 HPar21
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
USubpb1 = USubpb2;
USubpb1(1:DIM:end) = UPar{1}; USubpb1(2:DIM:end) = UPar{2}; USubpb1(3:DIM:end) = UPar{3};
% USubpb1 = USubpb1 + 0.1; % empirical errors improvement. I don't know exactly why this helps.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ------ Clear bad points for Local DIC ------
% find bad points after Local Subset ICGN
[row1,~] = find(ConvItPerEle(:)>MaxIterNum);
[row2,~] = find(ConvItPerEle(:,1)<1);
row = unique(union(row1,row2));
% find bad points with unusual ICGN steps
% rownans = unique(union (row1,row2) ); rowconv = setdiff(1:1:size(coordinatesFEM,1), rownans);
% meanConvItPerEle = mean(ConvItPerEle(rowconv)); stdConvItPerEle = std(ConvItPerEle(rowconv));
% [row3,~] = find(ConvItPerEle(rowconv)>meanConvItPerEle + 0.1*stdConvItPerEle);
% row = unique(union(rownans,row3));
% row = unique(union(row1,row2));

disp(['Local step bad subsets total # is: ', num2str(length(row))]);
USubpb1(3*row-2) = NaN; USubpb1(3*row-1) = NaN; USubpb1(3*row) = NaN;
% Plotdisp_show(full(USubpb1),elementsFEM(:,1:4) ,coordinatesFEM );
% Plotuv(full(USubpb1),x0,y0);
% ------ inpaint nans using gridfit ------
Coordxnodes = unique(coordinatesFEM(:,1)); Coordynodes = unique(coordinatesFEM(:,2)); Coordznodes = unique(coordinatesFEM(:,3));
nanindex = find(isnan(USubpb1(1:3:end))==1); notnanindex = setdiff([1:1:size(coordinatesFEM,1)],nanindex);
[Xq,Yq,Zq] = ndgrid(Coordxnodes,Coordynodes,Coordznodes);
M = length(Coordxnodes);  N = length(Coordynodes);  L = length(Coordznodes);

% --- Apply only for non-grid meshes ---
% u1temp = griddata(coordinatesFEM(notnanindex,1),coordinatesFEM(notnanindex,2),coordinatesFEM(notnanindex,3),full(USubpb1(3*notnanindex-2)),Xq,Yq,Zq,'natural');
% v1temp = griddata(coordinatesFEM(notnanindex,1),coordinatesFEM(notnanindex,2),coordinatesFEM(notnanindex,3),full(USubpb1(3*notnanindex-1)),Xq,Yq,Zq,'natural');
% w1temp = griddata(coordinatesFEM(notnanindex,1),coordinatesFEM(notnanindex,2),coordinatesFEM(notnanindex,3),full(USubpb1(3*notnanindex-0)),Xq,Yq,Zq,'natural');
%
% u1temp = inpaint_nans3(reshape(u1temp,M,N,L),1);
% v1temp = inpaint_nans3(reshape(v1temp,M,N,L),1);
% w1temp = inpaint_nans3(reshape(w1temp,M,N,L),1);

u1temp = inpaint_nans3(reshape(USubpb1(1:3:end),M,N,L),1);
v1temp = inpaint_nans3(reshape(USubpb1(2:3:end),M,N,L),1);
w1temp = inpaint_nans3(reshape(USubpb1(3:3:end),M,N,L),1);

% Add remove outliers median-test based on:
% u1=cell(2,1); u1{1}=u1temp; u1{2}=v1temp;
% [u2] = removeOutliersMedian(u1,4); u2temp=u2{1}; v2temp=u2{2};
for tempi = 1:size(coordinatesFEM,1)
    if ismember(tempi,nanindex) == 1
        [row1,col1] = find(Coordxnodes==coordinatesFEM(tempi,1));
        [row2,col2] = find(Coordynodes==coordinatesFEM(tempi,2));
        [row3,col3] = find(Coordznodes==coordinatesFEM(tempi,3));
        USubpb1(3*tempi-2) = u1temp(row1,row2,row3);
        USubpb1(3*tempi-1) = v1temp(row1,row2,row3);
        USubpb1(3*tempi)   = w1temp(row1,row2,row3);
    end
end


for tempj = 1:size(HtempPar,2), HPar{tempj} = HtempPar(:,tempj); end




