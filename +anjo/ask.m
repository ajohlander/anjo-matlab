function [answer] = ask(prompt,def_ans,ask_title)
%ANJO.ASK Ask a question.
%
%   answer = ANJO.ASK(prompt)
%
%   answer = ANJO.ASK(prompt,def_ans) Specified default answer.

if(nargin < 3)
    ask_title = 'anjo.ask';
    if(nargin == 1)
        def_ans = '';
    end
end

a = inputdlg(prompt,ask_title,1,{def_ans});

if(isempty(a))
    answer = '';
else
    answer = a{1};
end