function alpha = circ_vmrnd(theta, kappa,n,bPLOT)

% alpha = circ_vmrnd(theta, kappa, n)
% 
%   example call: R =circ_vmrnd(pi/4,4,1000,bPLOT); 
%
% Simulates n random angles from a von Mises distribution, with preferred 
% direction thetahat and concentration parameter kappa.
%
% theta:    mean parameter
%           default -> 0
% kappa:    concentration parameter
%           default -> 10
% n:        number of samples. NOTE! if n is has two entries (e.g. [2 10])
%           the function creates output consequent dimensionality
%           default -> 10
% bPLOT:    plot or not
%           1 -> plot
%           0 -> not (default)
%%%%%%%%%%%%%%%%%%%%%%%%%%
% alpha:    samples from von Mises distribution in radians
%
%   References:
%     Statistical analysis of circular data, Fisher, sec. 3.3.6, p. 49
%
% Circular Statistics Toolbox for Matlab


if ~exist('bPLOT','var') || isempty(bPLOT) bPLOT = 0; end

% default parameter
if nargin < 3, n = 10;    end
if nargin < 2, kappa = 1; end
if nargin < 1, theta = 0; end

if numel(n) > 2
  error('n must be a scalar or two-entry vector!')
elseif numel(n) == 2
  m = n;
  n = n(1) * n(2);
end  

% if kappa is small, treat as uniform distribution
if kappa < 1e-6
    alpha = 2*pi*rand(n,1);
    return
end

% other cases
a = 1 + sqrt((1+4*kappa.^2));
b = (a - sqrt(2*a))/(2*kappa);
r = (1 + b^2)/(2*b);

alpha = zeros(n,1);
for j = 1:n
  while true
      u = rand(3,1);

      z = cos(pi*u(1));
      f = (1+r*z)/(r+z);
      c = kappa*(r-f);

      if u(2) < c * (2-c) || ~(log(c)-log(u(2)) + 1 -c < 0)
         break
      end

      
  end

  alpha(j) = theta +  sign(u(3) - 0.5) * acos(f);
  alpha(j) = angle(exp(i*alpha(j)));
end

if exist('m','var')
  alpha = reshape(alpha,m(1),m(2));
end


if bPLOT
   b=linspace(-1,1,75); 
   [hc]=hist(cos(alpha),b);
   [hs]=hist(sin(alpha),b);
   
   figure; hold on
   axis square; axis([-1 1 -1 1].*1.125);
   plotCircle(1,[0 0],'k');
   plot(xlim,[0 0],'k-','linewidth',.25);
   plot([0 0],ylim,'k-','linewidth',.25);
   plot(b,.25.*hc./max(hc),'k'); 
   plot(.25.*hs./max(hs),b,'k');
   plot(mean(cos(alpha)).*[1 1],[0 mean(sin(alpha))],'k--')
   plot([0 mean(cos(alpha))],mean(sin(alpha)).*[1 1],'k--')
   plot( cos(alpha), sin(alpha),'ko','markerface','w' );
   plot([0 mean(cos(alpha))],mean(sind(alpha)).*[1 1],'k--')
   plot( cos(alpha), sin(alpha),'ko','markerface','w');
   quiver(0,0,mean(cos(alpha)),mean(sin(alpha)),'k','linewidth',1,'maxheadsize',.5,'autoscale','off' )
   formatFigure('cos(R)','sin(R)',['vmpdf(\mu=' num2str(theta,'%.2f') ',\kappa=' num2str(kappa,'%.1f') ')']);
end
