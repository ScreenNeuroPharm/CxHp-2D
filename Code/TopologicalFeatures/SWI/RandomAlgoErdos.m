function Net_RND = RandomAlgoErdos(Nodes,m)

%ERDREY     Generate adjacency matrix for a G(n,m) type random graph.
%
%   Input   n: dimension of matrix (number of nodes in graph).
%           m: 2*m is the number of 1's in matrix (number of edges in graph).
%           Defaults to the smallest integer larger than n*log(n)/2.
%
%   Output  A: n by n symmetric matrix with the attribute sparse.
%
%
%   Description:    An undirected graph is chosen uniformly at random from
%                   the set of all symmetric graphs with n nodes and m
%                   edges.
%  
%   Reference:  P. Erdos, A. Renyi,
%               On Random Graphs,
%               Publ. Math. Debrecen, 6 1959, pp. 290-297.
%
%   Example: A = erdrey(100,10);

if nargin == 1
    m = ceil(Nodes*log(Nodes)/2);
end

Net_RND = spalloc(Nodes, Nodes, m);
idx = randperm(Nodes * Nodes, m);

Net_RND(idx) = 1;

Net_RND = sparse(ones(Nodes,Nodes));
v = find(triu(Net_RND,1)>0);
p = randperm(length(v));


Net_RND = sparse(Nodes,Nodes);
Net_RND(v(p(1:m))) = 1;
Net_RND = Net_RND+Net_RND';
Net_RND = full(Net_RND);
