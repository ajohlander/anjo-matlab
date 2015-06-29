function [answer] = ask(prompt,def_ans)
%ANJO.ASK Ask a question.
%
%   answer = ANJO.ASK(prompt)
%
%   answer = ANJO.ASK(prompt,def_ans) Specified default answer.

if(nargin == 1)
    def_ans = {''};
end

a = inputdlg(prompt,'anjo.ask',1,{def_ans});

if(isempty(a))
    answer = '';
else
    answer = a{1};
end

