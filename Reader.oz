functor
import
    Open
    System
export
    textfile:TextFile
    scan:Scan
define
    
    % Fetches the N-th line in a file
    % @pre: - InFile: a TextFile from the file
    %       - N: the desires Nth line
    % @post: Returns the N-the line or 'none' in case it doesn't exist
    proc{SendSentence PortParser Line Word Sentence}OutPut in%{System.show parse(Line)}
        case Line
        of nil then 
            if Word \= nil then
                {String.toAtom Word OutPut}
                {Send PortParser parse({Append Sentence [OutPut]})}     
            end
        [] H | T then 
            %{System.show reader(H)} 
            %if (H >= 48 andthen H =< 57) orelse (H >= 65 andthen H =< 90) orelse (H >= 97 andthen H =< 122) then
            
            if (H == 33 orelse H == 63 orelse H == 46) andthen (T == nil orelse T.1 == 32) then % If it is '. ' 
                if Word \= nil then
                    {String.toAtom Word OutPut}
                    {Send PortParser parse({Append Sentence [OutPut]})}
                else
                    {Send PortParser parse(Sentence)}
                end
                {SendSentence PortParser T nil nil}
            elseif H == 40 orelse H == 41 then %if '(' or ')'
                if Word \= nil then
                    {String.toAtom Word OutPut}
                    {Send PortParser parse({Append Sentence [OutPut]})}
                else
                    {Send PortParser parse(Sentence)}
                end
                {SendSentence PortParser T nil nil}
            elseif H \= 32 then %If not a ' '
                {SendSentence PortParser T {Append Word [H]} Sentence}
            else
                if Word \= nil then
                    {String.toAtom Word OutPut}
                    {SendSentence PortParser T nil {Append Sentence [OutPut]}}
                else
                    {SendSentence PortParser T nil Sentence}
                end
            end 
        end
    end
    proc {Scan PortParser InFile N}
        Line={InFile getS($)}
    in
        if Line==false then
            {InFile close}
            {Send PortParser endFile}
        else
            {SendSentence PortParser Line nil nil}
            {Scan PortParser InFile N+1}
        end
    end

    class TextFile % This class enables line-by-line reading
        from Open.file Open.text
    end

end