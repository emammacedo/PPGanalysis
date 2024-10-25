function [nd_outd]=nd5p(ind,hstep,npoints)

%Calcula as derivadas de uma sequência discreta, utilizando five-point
%numerical algorithm (Código cedido pelo professor)

nd_outd = [];

if isempty(ind) 
    return;
end

nd_outd(1) = (-25.*ind(1)+48.*ind(2)-36.*ind(3)+16.*ind(4)-3.*ind(5))/(12.*hstep);
nd_outd(2) =(-3.*ind(1)-10.*ind(2)+18.*ind(3)-6.*ind(4)+ ind(5))/(12.*hstep); 

for l=3:npoints-2,
    nd_outd(l) = (ind(l-2)-8.*ind(l-1)+8.*ind(l+1)-ind(l+2))/(12.*hstep); 
end

nd_outd(npoints-1) = (-ind(npoints-4)+6.*ind(npoints-3)- 18.*ind(npoints-2)+10.*ind(npoints-1)+3.*ind(npoints))/(12.*hstep);
nd_outd(npoints) = (3.*ind(npoints-4)-16.*ind(npoints-3) + 36.*ind(npoints-2)-48.*ind(npoints-1)+25.*ind(npoints))/(12.*hstep);
return