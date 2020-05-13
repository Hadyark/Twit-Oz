functor
import
    QTk at 'x-oz://system/wp/QTk.ozf'
    System
    Application
    OS
    Browser
    Panel
    Reader
    Parser
    Saver

    Dico

define
    PortMain
    Ready
%%% Easier macros for imported functions
    Browse = Browser.browse
    Show = System.show

%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
    Text1 Text2 Description=td(
        title: "Frequency count"
        lr(
            text(handle:Text1 width:28 height:5 background:white foreground:black wrap:word)
            button(text:"Change" action:Press)
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

    proc {Press} Word Inserted Input in
        Word = {Text1 getText(p(1 0) 'end' $)}
        {System.show main(Word)}
        
        {Send Saver.port predict({CreateSearch {List.subtract Word 10} nil nil} Inserted)}
        %{System.show ins(Inserted)}
        
        {Text2 set(1:Inserted)} % you can get/set text this way too        
    end
    % Build the layout from the description
    W={QTk.build Description}
    {W show}
%    
    

    proc{TreatStream Stream N File X}
    {Text2 set(1:X#"/208 files")}
        if N == init then
            thread {Reader.scan {Parser.startParser PortMain} {New Reader.textfile init(name:"tweets/part_"#File#".txt")} 1}end
            %thread {Reader.scan {Parser.startParser} {New Reader.textfile init(name:"tweets/a"#File#".txt")} 1}end
            {TreatStream Stream 1 File+1 X}
        elseif N == 0 andthen Ready == true then {Text2 set(1:"Ready !")}
        elseif N > 0 andthen N =< 3 andthen File =< 208 then
                thread {Reader.scan {Parser.startParser PortMain} {New Reader.textfile init(name:"tweets/part_"#File#".txt")} 1}end
                %thread {Reader.scan {Parser.startParser} {New Reader.textfile init(name:"tweets/a"#File#".txt")} 1}end
                {TreatStream Stream N+1 File+1 X}
        else
            case Stream
            of nil then skip
            [] kill|S then
                %{System.show dead(X+1)}
                {TreatStream Stream N-1 File X+1}
            end
        end
    end

    proc{StartM}
        Stream
    in
        {NewPort Stream PortMain}
        {TreatStream Stream init 1 0}
    end

    {Saver.startSaver PortMain Ready}
    {StartM}
end
