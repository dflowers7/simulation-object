classdef simulation
    
    properties
        simtype
        simname
    end
    
    properties (Dependent=true)
        int
    end
    
    properties (GetAccess=protected)
        sol
        inttype
        intname
        ymodel
        dydxmodel
        dydumodel
        x_names
        u_names
        y_names
        k_names
        s_names
        nx
        ny
        nu
        nk
        ns
        nq
        nh
        k
        s
        q
        h
        uexperiment
    end
    
    methods
        
        function obj = simulation(sim)
            if nargin ~= 0
                [m,n] = size(sim);
                obj(m,n) = simulation;
                for j = n:-1:1
                    for i = m:-1:1
                        obj(i,j).simtype = sim(i,j).Type;
                        obj(i,j).simname = sim(i,j).Name;
                        obj(i,j).sol = sim(i,j).int.sol;
                        % Set empty fields rather than removing entirely to avoid problems with version detection in devals function
                        obj(i,j).sol.stats = [];
                        obj(i,j).sol.extdata = [];
                        obj(i,j).inttype = sim(i,j).int.Type;
                        obj(i,j).intname = sim(i,j).int.Name;
                        
                        ymodel = functions(sim(i,j).int.y);
                        ymodel = ymodel.workspace{1}.y;
                        obj(i,j).ymodel = ymodel;
                        
                        obj(i,j).dydxmodel = sim(i,j).int.dydx;
                        obj(i,j).dydumodel = sim(i,j).int.dydu;
                        obj(i,j).x_names = sim(i,j).int.x_names;
                        obj(i,j).u_names = sim(i,j).int.u_names;
                        obj(i,j).y_names = sim(i,j).int.y_names;
                        obj(i,j).k_names = sim(i,j).int.k_names;
                        obj(i,j).s_names = sim(i,j).int.s_names;
                        obj(i,j).nx = sim(i,j).int.nx;
                        obj(i,j).ny = sim(i,j).int.ny;
                        obj(i,j).nu = sim(i,j).int.nu;
                        obj(i,j).nk = sim(i,j).int.nk;
                        obj(i,j).ns = sim(i,j).int.ns;
                        obj(i,j).nq = sim(i,j).int.nq;
                        obj(i,j).nh = sim(i,j).int.nh;
                        obj(i,j).k = sim(i,j).int.k;
                        obj(i,j).s = sim(i,j).int.s;
                        obj(i,j).q = sim(i,j).int.q;
                        obj(i,j).h = sim(i,j).int.h;
                        obj(i,j).uexperiment = sim(i,j).int.u;
                    end
                end
            end
        end
        
        function val = t(self,varargin)
            if numel(self) > 1
                error('simulation methods can only be evaluated for a scalar simulation object.')
            end
            val = self.sol.x(varargin{:});
        end
        
        function val = x(self,t,varargin)
            if numel(self) > 1
                error('simulation methods can only be evaluated for a scalar simulation object.')
            end
            val = devals(self.sol,t);
            if nargin >= 3
                ind = self.fixIndex(self.x_names, varargin{:});
                val = val(ind,:);
            end
        end
        
        function val = y(self,t,varargin)
            if numel(self) > 1
                error('simulation methods can only be evaluated for a scalar simulation object.')
            end
            xval = devals(self.sol,t);
            uval = self.uexperiment(t);
            val = self.ymodel(t, xval, uval);
            if nargin >= 3
                ind = self.fixIndex(self.y_names, varargin{:});
                val = val(ind,:);
            end
        end
        
        function val = u(self,t,varargin)
            if numel(self) > 1
                error('simulation methods can only be evaluated for a scalar simulation object.')
            end
            val = self.uexperiment(t);
            if nargin >= 3
                ind = self.fixIndex(self.u_names, varargin{:});
                val = val(ind,:);
            end
        end
        
    end
    
    methods
        
        function varargout = get.int(self)
            for i = numel(self):-1:1
                thisself = self(i);
                varargout{i}.Type = thisself.inttype;
                varargout{i}.Name = thisself.intname;
                varargout{i}.x_names = thisself.x_names;
                varargout{i}.u_names = thisself.u_names;
                varargout{i}.y_names = thisself.y_names;
                varargout{i}.k_names = thisself.k_names;
                varargout{i}.s_names = thisself.s_names;
                varargout{i}.nx = thisself.nx;
                varargout{i}.ny = thisself.ny;
                varargout{i}.nu = thisself.nu;
                varargout{i}.nk = thisself.nk;
                varargout{i}.ns = thisself.ns;
                varargout{i}.nq = thisself.nq;
                varargout{i}.nh = thisself.nh;
                varargout{i}.k = thisself.k;
                varargout{i}.s = thisself.s;
                varargout{i}.q = thisself.q;
                varargout{i}.h = thisself.h;
                varargout{i}.dydx = thisself.dydxmodel;
                varargout{i}.dydu = thisself.dydumodel;
                varargout{i}.t = thisself.sol.x;
                varargout{i}.x = @thisself.x;
                varargout{i}.u = thisself.uexperiment;
                varargout{i}.y = @thisself.y;
                varargout{i}.ie = thisself.sol.ie;
                varargout{i}.te = thisself.sol.xe;
                varargout{i}.xe = thisself.sol.ye;
                varargout{i}.ue = thisself.u(varargout{i}.te);
                varargout{i}.ye = thisself.y(varargout{i}.te);
                varargout{i}.sol = thisself.sol;
            end
        end
        
    end
    
    methods (Access=protected,Static=true)
        
        function ind = fixIndex(names, ind)
            if ischar(ind) || iscellstr(ind)
                indorig = ind;
                [~,ind] = ismember(ind, names);
            end
            ismissing = ind == 0;
            if any(ismissing)
                error('%s not found.', strjoin(indorig(ismissing), ', '))
            end
        end
        
    end
end