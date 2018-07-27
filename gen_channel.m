function [h2D,varargout] = gen_channel(ts,fd,xsig,Reset)
persistent ch
persistent delays
persistent fmax
persistent tsamp
if(isempty(ch) || fd~=fmax || ts~=tsamp)
    model = 'EVA';
    if strcmpi(model,'EPA')
        delays = [0 30 70 90 110 190 410]*1e-9;
        powers = [0.0 -1.0 -2.0 -3.0 -8.0 -17.2 -20.8];
    elseif strcmpi(model,'EVA')
        delays = [0 30 150 310 370 710 1090 1730 2510]*1e-9;
        powers = [0.0 -1.5 -1.4 -3.6 -0.6 -9.1 -7.0 -12.0 -16.9];
    elseif strcmpi(model,'ETU')
        delays = [0 50 120 200 230 500 1600 2300 5000]*1e-9;
        powers = [-1.0 -1.0 -1.0 0.0 0.0 0.0 -3.0 -5.0 -7.0];
    else
        error('Undefined input power delay profile');
    end

     %fc     = 4e9;
     %lambda = 3e8/fc;
     %V      = 500e3/3600;
    %fmax   = V/lambda;

     disp(['fd  = ',num2str(fmax),' Hz']);
    fmax   = fd;
    tsamp  = ts;
    ch     = rayleighchan(tsamp,fmax);

    dopobj = doppler.jakes;
    % dopobj = doppler.flat;
    % dopobj = doppler.gaussian(0.5);
    ch.DopplerSpectrum = dopobj;

    ch.PathDelays     = delays;
    ch.AvgPathGaindB  = powers;
    ch.StorePathGains = 1;
    ch.ResetBeforeFiltering = 0;
end
if(Reset == true)
    ch.reset();
end
ysig = filter(ch,xsig);
PG   = ch.PathGains.';
varargout{1} = ysig;

n = (-100:ceil(delays(end)/tsamp)+100)';
hh = zeros(length(n),size(PG,2));
for iy = 1:length(delays)
    sincfun = sinc(n - delays(iy)/tsamp);
    for ix=1:size(PG,2)    
        hh(:,ix) = hh(:,ix) + PG(iy,ix) * sincfun;
    end
end
h2D = hh(101+ch.ChannelFilter.TapIndices,:);

if(size(h2D,2)==1)
    h2D = repmat(h2D,1,length(xsig));
end;

