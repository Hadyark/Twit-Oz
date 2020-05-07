functor
import
    Open
    Parser
    System
export
    textfile:TextFile
    scan:Scan
define
    PortParser = {Parser.startParser}
    % Fetches the N-th line in a file
    % @pre: - InFile: a TextFile from the file
    %       - N: the desires Nth line
    % @post: Returns the N-the line or 'none' in case it doesn't exist
    fun{CreateSentence Line Word}OutPut in%{System.show parse(Line)}
        case Line
        of nil then 
            {String.toAtom Word OutPut}
            OutPut | nil
        [] 32 | T then 
            {String.toAtom Word OutPut}
            OutPut | {CreateSentence T nil}
        else
            {CreateSentence Line.2 {Append Word [Line.1]}}
        end
    end
    fun {Scan InFile N}
        Line={InFile getS($)}
    in
        if Line==false then
            {InFile close}
            {Send PortParser endFile}
            none
        else
            {Send PortParser parse({CreateSentence Line nil})}
            {Scan InFile N+1}
        end
    end
    
    class TextFile % This class enables line-by-line reading
        from Open.file Open.text
    end

end