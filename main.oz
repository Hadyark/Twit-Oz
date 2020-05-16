functor
import
    QTk at 'x-oz://system/wp/QTk.ozf'
    System
    Application
    OS
    Browser
    Reader
    Parser
    Saver

define
    PortMain
    Ready
%%% Easier macros for imported functions
    Browse = Browser.browse
    Show = System.show

%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
    fun{EditInput Word} Input L in
        Input = {Text1 getText(p(1 0) 'end' $)}
        L ={CreateSearch {List.subtract Input 10} nil nil}
        if {List.length L} > 1 then
            L.1#' '#L.2.1
        elseif {List.length L} == 1 then
            L.1#' '#Word
        else
            ''
        end
    end
    Text1 Text2 DropList Description=td(
        title: "Frequency count"
        lr(
            text(handle:Text1 width:28 height:5 background:white foreground:black wrap:word)
            button(text:"Change" action:Press)
            dropdownlistbox(
            init:[0]                           
            handle:DropList                           
            action:proc{$} {Text1 set(
                            {EditInput {List.nth {DropList get($)} {DropList get(firstselection:$)}}}
                            )} 
                    end)
        )
        text(handle:Text2 width:28 height:5 background:black foreground:white glue:w wrap:word)
        action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
    )
    fun {CreateSearch List Word Search} OutPut in
        case List
        of nil then
            {String.toAtom Word OutPut}
            {Append Search [OutPut]}
        [] H|T then
            if H==32 then
                {String.toAtom Word OutPut}
                {CreateSearch T nil {Append Search [OutPut]}}
            else
                {CreateSearch T {Append Word [H]} Search}
            end
        end
    end

    proc {Press} Inserted Input Keys in
        Input = {Text1 getText(p(1 0) 'end' $)}
        %{System.show main(Word)}
        
        {Send Saver.port predict({CreateSearch {List.subtract Input 10} nil nil} Inserted Keys)}
        %{System.show ins(Inserted)}
        
        {Text2 set(1:Inserted)} % you can get/set text this way too 
        {DropList set(1:Keys)}      
    end
    % Build the layout from the description
    W={QTk.build Description}
    {W show}
%    
    

    proc{TreatStream Stream N File X}
    %{System.show Stream.1}
        case Stream
        of init|S then
            {Send PortMain newT}{Send PortMain newT}{Send PortMain newT}
            thread {Reader.scan {Parser.startParser PortMain} {New Reader.textfile init(name:"tweets/part_"#File#".txt")}}end
            thread {Reader.scan {Parser.startParser PortMain} {New Reader.textfile init(name:"tweets/part_"#File+1#".txt")}}end
            thread {Reader.scan {Parser.startParser PortMain} {New Reader.textfile init(name:"tweets/part_"#File+2#".txt")}}end
            {TreatStream S N File X}
        [] newT|S then%{System.show n(n:N+1 x:X file: File)}
            {TreatStream S N+1 File+1 X}
        [] kill|S then
            %{System.show dead(X+1)}
            {Text2 set(1:X#"/208 files")}
            %{System.show k(n:N-1 x:X+1 file: File)}
            if File > 208 andthen N > 1 then {TreatStream S N-1 File X+1}
            elseif File =< 208 then
                thread {Reader.scan {Parser.startParser PortMain} {New Reader.textfile init(name:"tweets/part_"#File#".txt")}}end
                {TreatStream S N File+1 X+1}
            elseif N == 1 andthen Ready == true then {Text2 set(1:"Ready !")}
            end
        end
    end

    proc{StartM}
        Stream
    in
        {NewPort Stream PortMain}
        {Send PortMain init}
        {TreatStream Stream 0 1 0}
        %thread {Reader.scan {Parser.startParser PortMain} {New Reader.textfile init(name:"tweets/m.txt")} 1}end
    end

    {Saver.startSaver PortMain Ready}
    {StartM}
end
