function Dataset_NN = data_manipulation_for_optimisation(cases_opt,Dataset,x)

global Tmax

[K N] = size(Dataset);
Dataset_NN = zeros(K,Tmax);

switch cases_opt
    case 1 %ITALY
        try
            for i=1:K
                switch i
                    case 1
                        Dataset_NN(i,:) = ITquarante_incoming(x(1:3));
                    case 2
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        tmp(x(4)+x(5):end) = var_values(x(4):Tmax-x(5));
                        if x(5)>0 
                            tmp(x(4):min(Tmax,x(4)+x(5)-1)) = var_values(x(4):x(4)+x(5)-1);
                        end
                        Dataset_NN(i,:) =  tmp;
                    case 3
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        dx = x(6)-34;
                        tmp(x(6):end) = var_values(x(6)-dx:Tmax-dx);
                        if dx>0
                            tmp(x(6)-dx:x(6)-1) = zeros(1,dx);
                        end
                        Dataset_NN(i,:) =  tmp;
                    case 4
                        step = 0:1/4:1;
                        start = x(7);
                        for j=2:5
                            if start<Tmax && x(7+j-1)~=0
                                Dataset_NN(i,start:end) = step(j);
                                start = start+x(7+j-1);
                            end
                        end
                    case 5
                        step = 0:1/8:1;
                        step(end-1)=step(end);
                        step(end)=[];
                        start = x(12);
                        for j=2:8
                            if start<Tmax && x(12+j-1)~=0
                                Dataset_NN(i,start:end) = step(j);
                                start = start+x(12+j-1);
                            end
                        end
                    case 6
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        tmp(x(20)+x(21):end) = var_values(x(20):Tmax-x(21));
                        Dataset_NN(i,:) =  tmp;
                    case 7
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        tmp(x(22)+x(23):end) = var_values(x(22):Tmax-x(23));
                        if x(23)>0 
                            tmp(x(22):min(Tmax,x(22)+x(23)-1)) = var_values(x(22):x(22)+x(23)-1);
                        end
                        Dataset_NN(i,:) =  tmp;
                    case 8
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        tmp(x(24)+x(25):end) = var_values(x(24):Tmax-x(25));
                        if x(25)>0 
                            tmp(x(24):min(Tmax,x(24)+x(25)-1)) = var_values(x(24):x(24)+x(25)-1);
                        end
                        Dataset_NN(i,:) =  tmp;                    
                    case 9
                        Dataset_NN(i,:) = Dataset(i,1:Tmax);
                    case 10
                        Dataset_NN(i,:) = Dataset(i,1:Tmax);
                    case 11
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        tmp(x(26)+x(27):end) = var_values(x(26):Tmax-x(27));
                        Dataset_NN(i,:) =  tmp;
                end
            end              
        catch e
            disp('ERROR')
        end

    case 2 %TAIWAN
        try
            for i=1:K
                switch i
                    case 1
                        tmp = TWquarante_incoming(x(1:12));
                        Dataset_NN(i,:) = tmp(1:Tmax);
                    case 2
                        step = 0:1:6;
                        start = x(13);
                        for j=2:7
                            if start<Tmax && x(13+j-1)~=0
                                Dataset_NN(i,start:end) = step(j);
                                start = start+x(13+j-1);
                            end
                        end
                    case 3
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        dx = x(20)-43; 
                        tmp(x(20):end) = var_values(x(20)-dx:Tmax-dx);
                        if dx>0
                            tmp(x(20)-dx:x(20)-1) = zeros(1,dx);
                        end
                        Dataset_NN(i,:) =  tmp;
                    case 4
                        step = 0:1:7;
                        start = x(21);
                        for j=2:8
                            if start<Tmax && x(21+j-1)~=0
                                Dataset_NN(i,start:end) = step(j);
                                start = start+x(21+j-1);
                            end
                        end                        
                    case 5
                        step = 0:1:17;
                        start = x(29);
                        for j=2:18
                            if start<Tmax && x(29+j-1)~=0
                                Dataset_NN(i,start:end) = step(j);
                                start = start+x(29+j-1);
                            end
                        end                      
                    case 6
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        tmp(x(47)+x(48):end) = var_values(x(47):Tmax-x(48));
                        Dataset_NN(i,:) =  tmp;
                    case 7
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        tmp(x(49)+x(50):end) = var_values(x(49):Tmax-x(50));
                        if x(50)>0 
                            tmp(x(49):min(Tmax,x(49)+x(50)-1)) = var_values(x(49):min(Tmax,x(49)+x(50)-1));
                        end
                        Dataset_NN(i,:) =  tmp;
                    case 8
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        tmp(x(51)+x(52):end) = var_values(x(51):Tmax-x(52));
                        if x(52)>0 
                            tmp(x(51):min(Tmax,x(51)+x(52)-1)) = var_values(x(51):min(Tmax,x(51)+x(52)-1));
                        end
                        Dataset_NN(i,:) =  tmp;          
                    case 9
                        Dataset_NN(i,:) = Dataset(i,1:Tmax);
                    case 10
                        Dataset_NN(i,:) = Dataset(i,1:Tmax);                        
                    case 11
                        var_values = Dataset(i,:);
                        tmp = var_values(1:Tmax);
                        tmp(x(53)+x(54):end) = var_values(x(53):Tmax-x(54));
                        Dataset_NN(i,:) =  tmp;                        
                end
            end
        catch e
            disp('ERROR')
        end
        
end



end
