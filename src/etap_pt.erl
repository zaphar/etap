-module(etap_pt).
-compile(export_all).

%% TODO(jwall): can I do this in a single pass?
parse_transform(Forms, _Options) ->
    {Count, Filtered} = process_forms(0, [], Forms),
    Finished = replace_count(Count, Filtered),
    Finished
    .

process_forms(Count, AccForms, []) ->
    {Count, AccForms};
process_forms(Count, Acc, Forms) ->
    [H | T] = Forms,
    AccCount = tally(Count, H),
    case AccCount > Count of
        true ->
            Acc1 = Acc;
        false ->
            Acc1 = Acc ++ [H]
    end,
    process_forms(AccCount, Acc1, T).

replace_count(_Count, []) ->
    [];
%% handle blocks
replace_count(Count, [{block, LineNum, Body} | T]) ->
    BodyForms = replace_count(Count, Body),
    [{block, LineNum, BodyForms} | replace_count(Count, T) ]; 
%% handle if blocks
replace_count(Count, [{'if', LineNum, Body} | T]) ->
    BodyForms = replace_count(Count, Body),
    [{'if', LineNum, BodyForms} | replace_count(Count, T) ]; 
%% handle case blocks
replace_count(Count, [{'case', LineNum, Of, Body} | T]) ->
    BodyForms = replace_count(Count, Body),
    [{'case', LineNum, Of, BodyForms} | replace_count(Count, T) ]; 
%% handle try catch blocks
replace_count(Count, [{'try', LineNum, Body, Case, Catch, After} | T]) ->
    BodyForms = replace_count(Count, Body),
    CatchForms = replace_count(Count, Catch),
    CaseForms = replace_count(Count, Case),
    AfterForms = replace_count(Count, After),
    [{'try', LineNum, BodyForms, CaseForms, CatchForms, AfterForms} | replace_count(Count, T) ]; 
%% handle recieve blocks
replace_count(Count, [{'receive', Line, Case} | T]) ->
    CaseForms = replace_count(Count, Case),
    [{'receive', Line, CaseForms} | replace_count(Count, T)];
replace_count(Count, [{'receive', Line, Case, Expression, Body} | T]) ->
    CaseForms = replace_count(Count, Case),
    BodyForms = replace_count(Count, Body),
    %% TODO(jwall): ok so obviously I need a way to handle a single form
    [ExpressionForm] = replace_count(Count, [Expression]),
    [{'receive', Line, CaseForms, ExpressionForm, BodyForms} | replace_count(Count, T)];
% handle functions
replace_count(Count, [ {'function', LineNum, Name, Arity, Clause} | T] ) ->
  FuncClause = replace_count(Count, Clause),
  [{'function', LineNum, Name, Arity, FuncClause} |  replace_count(Count, T)];
replace_count(Count, [ {'function', LineNum, Module, Name, Arity, Clause} | T] ) ->
  FuncClause = replace_count(Count, Clause),
  [{'function', LineNum, Module, Name, Arity, FuncClause} |  replace_count(Count, T)];
% anonymous also
replace_count(Count, [{'fun', Line, {clauses, Body}} | T]) ->
    BodyForms = replace_count(Count, Body),
    [{'fun', Line, {clauses, BodyForms}} | replace_count(Count, T)];
replace_count(Count, [ {'fun', Line, Function} | T] ) ->
    Func = replace_count(Count, Function),
    [{'fun', Line, Func} |  replace_count(Count, T)];
% handle clauses
replace_count(Count, [{'clause', LineNum, L1, L2, Forms} | T]) ->
    ClauseForms = replace_count(Count, Forms),
    [{'clause', LineNum, L1, L2, ClauseForms} | replace_count(Count, T)];
% handle call
replace_count(Count, [{'call', Line, Call, Forms} | T]) ->
    CallForms = replace_count(Count, Forms),
    [{'call', Line, Call, CallForms} | replace_count(Count, T)];
% ok now for the individual forms
replace_count(Count, Forms) ->
    [H | T] = Forms,
    [replace({Count, H}) | replace_count(Count, T)]. 

replace({Count, {atom, LineNum, calc_plan}}) ->
    {'call', LineNum, 
        {remote, LineNum, {atom, LineNum, etap}, {atom, LineNum, plan}},
            [{'integer', LineNum, Count}]};
%% ok what is adding these integerised components? count?
replace({_Count, Form}) ->
    Form.

tally(CurrCount, {attribute, _Line, plan, Count}) ->
   CurrCount + Count;
tally(CurrCount, _Form) ->
    CurrCount.

