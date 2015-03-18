function [dom_mat] = generate_dominance_matrix(pop, indices)
%   Generate the dominance matrix from the given population.
%   This function is O(n^2).
%
%     |   *c    *d
%     |
%     |   *a    *b
%    _|_______________
%     |
%   
%   For the above objective values, the dominance matrix 
%   will look like this --
%   
%       A   B   C   D
%   A   0   0   1   1
%   B   0   0   0   1
%   C  -1   0   0   0
%   D  -1  -1   0   0

global nreal ;
global nobj ;
global ncon ;

obj_col = nreal+1:nreal+nobj;
cv_col = nreal+nobj+ncon+1;
% collect the relevant column data from input array
cv = pop(:,cv_col);
objmat = pop(:,obj_col);
% pprint('objmat:\n', objmat);
% pprint('cv:\n', cv);

% logical array corrresponding to starting IF conditional statement
ifcvltzero = bsxfun(@and, cv < 0, cv.' < 0);
% pprint('ifcvltzero:\n', ifcvltzero);

% create logical arrays corresponding to the three IF-ElSE parts
ifcvgtlt = bsxfun(@gt, cv, cv.') - bsxfun(@lt, cv, cv.');
% pprint('ifcvgtlt\n', ifcvgtlt);
ifcvlteq = -bsxfun(@and, cv < 0, cv.' == 0) +...
                    bsxfun(@and, cv == 0, cv.' < 0);
% pprint('ifcvlteq\n', ifcvlteq);

objcomp = -all(bsxfun(@gt,permute(objmat,[1 3 2]),permute(objmat,[3 1 2])),3) + ...
             all(bsxfun(@lt,permute(objmat,[1 3 2]),permute(objmat,[3 1 2])),3);
                
% ifobjgt = bsxfun(@gt, objmat(:,1), objmat(:,1).'); 
% ifobjlt = bsxfun(@lt, objmat(:,1), objmat(:,1).');
% for f = 2:nobj % can we get rid of this loop ?
%     ifobjgt = ifobjgt & bsxfun(@gt, objmat(:,f), objmat(:,f).');
%     ifobjlt = ifobjlt & bsxfun(@lt, objmat(:,f), objmat(:,f).');
% end
% ifobjgt = -ifobjgt ;
% objcomp = ifobjgt + ifobjlt ;

% get the output taking care of all the conditionals
dom_mat = ifcvltzero .* ifcvgtlt + ...
            (~ifcvltzero) .* (ifcvlteq + (ifcvlteq == 0) .* objcomp);
% pprint('dom_mat:\n', dom_mat);
dom_mat = [indices', dom_mat] ;

% [nrow,~] = size(objmat);
% dom_mat1 = zeros(nrow,nrow);
% % fill only the upper triangular of mat
% for i = 1:nrow
%     %for j = i + 1:nrow
%     for j = 1:nrow
%         if(i ~= j) 
%             % compare_weights() is a function with some nested 
%             % if-then-else, that compares the values of 1st,2nd and 
%             % 4th columns in data and populates the matrix mat.
%             dom_mat1(i, j) = check_dominance([objmat(i,:), cv(i,:)],...
%                                                 [objmat(j,:), cv(j,:)]);
%         end
%     end
% end
% pprint('dom_mat1\n', dom_mat1);

end
